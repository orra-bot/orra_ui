import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../foundation/browser.dart';
import '../foundation/hairline.dart';
import '../foundation/motion.dart';
import '../foundation/popover_layout.dart';
import '../foundation/pressable.dart';
import '../icons/ra_icon.dart';
import '../theme/theme.dart';
import '../theme/theme_data.dart';
import '../tokens/components.dart';
import 'button.dart';

/// 触发元素用来控制菜单的句柄（`RaMenu.of(context)`）。
class RaMenuHandle {
  RaMenuHandle._(this._state);

  final _MenuAnchorState _state;

  bool get isOpen => _state._controller.isOpen;
  void open() => _state._controller.open();
  void close() => _state._controller.close();
  void toggle() => isOpen ? close() : open();
}

/// 下拉菜单。
///
/// ```dart
/// RaMenu(
///   items: [
///     RaMenuItem(onPressed: …, child: Text('设置')),
///     RaMenuSeparator(),
///     RaSubmenu(label: Text('切换 Workspace'), items: [...]),
///   ],
///   child: RaMenuTrigger(child: Text('Workspace')),
/// )
/// ```
///
/// 触发元素可以是 [RaMenuTrigger]，或任何在内部调用 `RaMenu.of(context).toggle()` 的组件。
class RaMenu extends StatelessWidget {
  const RaMenu({
    super.key,
    required this.items,
    required this.child,
    this.side = RaPopoverSide.bottom,
    this.align = RaPopoverAlign.end,
    this.onOpenChanged,
    this.controller,
  });

  final List<Widget> items;
  final Widget child;
  final RaPopoverSide side;
  final RaPopoverAlign align;
  final ValueChanged<bool>? onOpenChanged;
  final MenuController? controller;

  /// 最近的菜单句柄。
  static RaMenuHandle of(BuildContext context) {
    final _MenuHandleScope? scope = context.dependOnInheritedWidgetOfExactType<_MenuHandleScope>();
    assert(scope != null, 'RaMenu.of() 只能在 RaMenu 的 child 内调用。');
    return scope!.handle;
  }

  @override
  Widget build(BuildContext context) {
    return _MenuAnchor(
      items: items,
      side: side,
      align: align,
      controller: controller,
      onOpenChanged: onOpenChanged,
      builder: (BuildContext context, _MenuAnchorState state) => child,
    );
  }
}

/// 右键菜单：在 [child] 上按右键时在指针位置打开。
class RaContextMenu extends StatelessWidget {
  const RaContextMenu({
    super.key,
    required this.items,
    required this.child,
    this.enabled = true,
    this.onOpenChanged,
  });

  final List<Widget> items;
  final Widget child;
  final bool enabled;
  final ValueChanged<bool>? onOpenChanged;

  @override
  Widget build(BuildContext context) {
    return _MenuAnchor(
      items: items,
      side: RaPopoverSide.bottom,
      align: RaPopoverAlign.start,
      contextMenu: true,
      onOpenChanged: onOpenChanged,
      builder: (BuildContext context, _MenuAnchorState state) => Listener(
        // 触发区域属于菜单的点击分组，在其中左键点击不算「外部」，需要自行关闭。
        onPointerDown: (PointerDownEvent event) {
          if (event.buttons == kPrimaryButton && state._controller.isOpen) {
            state._controller.close();
          }
        },
        child: RaBrowserContextMenuGuard(
          enabled: enabled,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onSecondaryTapUp: enabled
                ? (TapUpDetails d) => state._controller.open(position: d.localPosition)
                : null,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// 菜单触发按钮：pill（账户等胶囊按钮）· chip（输入框上方的选择器）· row（侧栏整行）。
enum RaMenuTriggerVariant { pill, chip, row }

class RaMenuTrigger extends StatelessWidget {
  const RaMenuTrigger({
    super.key,
    required this.child,
    this.leading,
    this.trailing,
    this.variant = RaMenuTriggerVariant.pill,
    this.enabled = true,
    this.semanticLabel,
  });

  final Widget child;
  final Widget? leading;
  final Widget? trailing;
  final RaMenuTriggerVariant variant;
  final bool enabled;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final RaThemeData theme = RaTheme.of(context);
    final RaMenuHandle menu = RaMenu.of(context);
    RaButtonStyle style = switch (variant) {
      RaMenuTriggerVariant.pill => theme.menu.triggerPill,
      RaMenuTriggerVariant.chip => theme.menu.triggerChip,
      RaMenuTriggerVariant.row => theme.menu.triggerRow,
    };
    if (leading == null && variant == RaMenuTriggerVariant.pill) {
      style = style.copyWith(padding: theme.menu.triggerPillPlainPadding);
    } else if (leading == null && variant == RaMenuTriggerVariant.chip) {
      style = style.copyWith(padding: theme.menu.triggerChipPlainPadding);
    }
    final Widget button = RaButton(
      // chip / row 平时透明：以安静按钮为底，不继承次要按钮的描边与阴影。
      variant: variant == RaMenuTriggerVariant.pill
          ? RaButtonVariant.secondary
          : RaButtonVariant.quiet,
      hoverExitDuration: variant == RaMenuTriggerVariant.row
          ? theme.sidebar.hoverExitDuration
          : null,
      onPressed: enabled ? menu.toggle : null,
      selected: menu.isOpen,
      style: style,
      leading: leading,
      trailing: trailing,
      semanticLabel: semanticLabel,
      expand: variant == RaMenuTriggerVariant.row,
      child: variant == RaMenuTriggerVariant.row
          ? Align(alignment: AlignmentDirectional.centerStart, child: child)
          : child,
    );
    return button;
  }
}

// ---------------------------------------------------------------------------
// 菜单项
// ---------------------------------------------------------------------------

/// 普通菜单项。[shortcut] / [meta] 显示在行尾（12px 常规灰）。
class RaMenuItem extends StatelessWidget {
  const RaMenuItem({
    super.key,
    required this.onPressed,
    required this.child,
    this.leading,
    this.shortcut,
    this.meta,
    this.danger = false,
    this.closeOnActivate = true,
  });

  /// 为空时禁用。
  final VoidCallback? onPressed;
  final Widget child;
  final Widget? leading;
  final String? shortcut;
  final Widget? meta;

  /// 危险操作（文字为危险色）。
  final bool danger;
  final bool closeOnActivate;

  @override
  Widget build(BuildContext context) {
    return _MenuItemFrame(
      onPressed: onPressed,
      closeOnActivate: closeOnActivate,
      danger: danger,
      leading: leading,
      meta: meta ?? (shortcut == null ? null : Text(shortcut!)),
      child: child,
    );
  }
}

/// 单选项：当前项对勾在行尾（强调色）。默认选中后不关闭菜单（选择框式菜单设 [closeOnActivate]）。
class RaMenuRadioItem<T> extends StatelessWidget {
  const RaMenuRadioItem({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.child,
    this.leading,
    this.meta,
    this.enabled = true,
    this.closeOnActivate = false,
  });

  final T value;
  final T? groupValue;
  final ValueChanged<T>? onChanged;
  final Widget child;
  final Widget? leading;
  final Widget? meta;
  final bool enabled;
  final bool closeOnActivate;

  @override
  Widget build(BuildContext context) {
    final RaThemeData theme = RaTheme.of(context);
    final bool checked = value == groupValue;
    final bool active = enabled && onChanged != null;
    return Semantics(
      checked: checked,
      inMutuallyExclusiveGroup: true,
      child: _MenuItemFrame(
        onPressed: active ? () => onChanged!(value) : null,
        closeOnActivate: closeOnActivate,
        leading: leading,
        meta: meta,
        indicator: checked
            ? RaIcon.glyph(
                theme.icons.check,
                size: theme.menu.indicatorSize,
                color: active ? theme.menu.checkColor : theme.menu.disabledColor,
              )
            : SizedBox.square(dimension: theme.menu.indicatorSize),
        child: child,
      ),
    );
  }
}

/// 菜单顶部的说明（如当前账户），不可选中。
class RaMenuHeader extends StatelessWidget {
  const RaMenuHeader({super.key, this.title, required this.child});

  /// 强调行（13px 正文色）。
  final Widget? title;

  /// 说明（12px 弱色）。
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final RaMenuThemeData m = RaTheme.of(context).menu;
    return Padding(
      padding: m.headerPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (title != null) DefaultTextStyle(style: m.headerStrongStyle, child: title!),
          DefaultTextStyle(style: m.headerStyle, child: child),
        ],
      ),
    );
  }
}

/// 分隔线：贯穿整个浮层宽度，上下各 6。
class RaMenuSeparator extends StatelessWidget {
  const RaMenuSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    final RaThemeData theme = RaTheme.of(context);
    final RaMenuThemeData m = theme.menu;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: m.separatorGap),
      child: SizedBox(
        height: RaHairline.snap(context, theme.sizing.borderWidth),
        child: ColoredBox(color: m.separatorColor),
      ),
    );
  }
}

/// 子菜单入口：外观同菜单项，行尾为实心 ▸；悬停或按右方向键展开，左方向键收起。
class RaSubmenu extends StatelessWidget {
  const RaSubmenu({
    super.key,
    required this.label,
    required this.items,
    this.leading,
    this.meta,
    this.enabled = true,
  });

  final Widget label;
  final List<Widget> items;
  final Widget? leading;
  final Widget? meta;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return _MenuAnchor(
      items: items,
      side: RaPopoverSide.right,
      align: RaPopoverAlign.start,
      submenu: true,
      builder: (BuildContext context, _MenuAnchorState state) => _SubmenuTrigger(
        state: state,
        label: label,
        leading: leading,
        meta: meta,
        enabled: enabled,
      ),
    );
  }
}

/// 头像：无图片时显示姓名前两个字符。
class RaAvatar extends StatelessWidget {
  const RaAvatar({super.key, required this.name, this.image, this.size});

  final String name;
  final ImageProvider? image;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final RaMenuThemeData m = RaTheme.of(context).menu;
    final double dimension = size ?? m.avatarSize;
    final String trimmed = name.trim();
    final String initials = trimmed.isEmpty
        ? '?'
        : String.fromCharCodes(trimmed.runes.take(2)).toUpperCase();
    return Semantics(
      label: name,
      image: true,
      child: ExcludeSemantics(
        child: Container(
          width: dimension,
          height: dimension,
          alignment: Alignment.center,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: m.avatarBackground,
            image: image == null ? null : DecorationImage(image: image!, fit: BoxFit.cover),
          ),
          child: image == null
              ? Text(initials, style: m.avatarTextStyle.copyWith(color: m.avatarForeground))
              : null,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 内部实现
// ---------------------------------------------------------------------------

class _MenuHandleScope extends InheritedWidget {
  const _MenuHandleScope({required this.handle, required this.isOpen, required super.child});

  final RaMenuHandle handle;
  final bool isOpen;

  @override
  bool updateShouldNotify(_MenuHandleScope old) => isOpen != old.isOpen || handle != old.handle;
}

/// 整个菜单系统（根菜单与所有子菜单）共享：是否处于键盘导航模式。
class _MenuRootScope extends InheritedWidget {
  const _MenuRootScope({required this.keyboardMode, required super.child});

  final ValueNotifier<bool> keyboardMode;

  static _MenuRootScope? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_MenuRootScope>();

  @override
  bool updateShouldNotify(_MenuRootScope old) => keyboardMode != old.keyboardMode;
}

/// 一个浮层（面板）内的菜单项登记表与所属控制器。
class _MenuPanelScope extends InheritedWidget {
  const _MenuPanelScope({required this.panel, required super.child});

  final _MenuPanelState panel;

  static _MenuPanelState? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_MenuPanelScope>()?.panel;

  @override
  bool updateShouldNotify(_MenuPanelScope old) => panel != old.panel;
}

class _MenuAnchor extends StatefulWidget {
  const _MenuAnchor({
    required this.items,
    required this.side,
    required this.align,
    required this.builder,
    this.contextMenu = false,
    this.submenu = false,
    this.controller,
    this.onOpenChanged,
  });

  final List<Widget> items;
  final RaPopoverSide side;
  final RaPopoverAlign align;
  final Widget Function(BuildContext context, _MenuAnchorState state) builder;
  final bool contextMenu;
  final bool submenu;
  final MenuController? controller;
  final ValueChanged<bool>? onOpenChanged;

  @override
  State<_MenuAnchor> createState() => _MenuAnchorState();
}

class _MenuAnchorState extends State<_MenuAnchor> with SingleTickerProviderStateMixin {
  late MenuController _controller = widget.controller ?? MenuController();
  late final AnimationController _animation = AnimationController(vsync: this);
  late final RaMenuHandle _handle = RaMenuHandle._(this);
  final FocusNode _panelNode = FocusNode(debugLabel: 'RaMenu panel');
  ValueNotifier<bool>? _ownKeyboardMode;
  FocusNode? _restoreFocus;
  bool _focusFirstItem = false;

  /// 子菜单入口的焦点（子菜单关闭后焦点回到这里）。
  FocusNode? triggerNode;

  @override
  void didUpdateWidget(_MenuAnchor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _controller = widget.controller ?? MenuController();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _animation.duration = RaReducedMotion.resolve(context, RaTheme.of(context).menu.duration);
  }

  @override
  void dispose() {
    _animation.dispose();
    _panelNode.dispose();
    _ownKeyboardMode?.dispose();
    super.dispose();
  }

  ValueNotifier<bool> _keyboardMode(BuildContext context) {
    return _MenuRootScope.maybeOf(context)?.keyboardMode ??
        (_ownKeyboardMode ??= ValueNotifier<bool>(false));
  }

  /// 打开后把焦点放到第一个可用项（键盘展开子菜单时）。
  void openAndFocusFirst() {
    _focusFirstItem = true;
    _controller.open();
  }

  void _handleOpenRequested(Offset? position, VoidCallback showOverlay) {
    if (!widget.submenu) {
      _restoreFocus = FocusManager.instance.primaryFocus;
      _MenuRootScope.maybeOf(context)?.keyboardMode.value = false;
      _ownKeyboardMode?.value = false;
    } else {
      _restoreFocus = triggerNode;
    }
    showOverlay();
    _animation.forward();
    widget.onOpenChanged?.call(true);
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_controller.isOpen) return;
      if (_focusFirstItem) {
        _focusFirstItem = false;
        _panelState?.focusEdge(first: true);
      } else if (!widget.submenu) {
        _panelNode.requestFocus();
      }
    });
  }

  void _handleCloseRequested(VoidCallback hideOverlay) {
    if (_animation.status == AnimationStatus.reverse) return;
    _animation.reverse().whenComplete(() {
      if (!mounted || _animation.status != AnimationStatus.dismissed) return;
      final bool focusInside = _panelNode.hasFocus;
      hideOverlay();
      if (focusInside && (_restoreFocus?.context?.mounted ?? false)) {
        _restoreFocus!.requestFocus();
      }
      _restoreFocus = null;
    });
  }

  void _handleClosed() {
    widget.onOpenChanged?.call(false);
    if (mounted) setState(() {});
  }

  _MenuPanelState? _panelState;

  @override
  Widget build(BuildContext context) {
    return RawMenuAnchor(
      controller: _controller,
      consumeOutsideTaps: true,
      onOpenRequested: _handleOpenRequested,
      onCloseRequested: _handleCloseRequested,
      onClose: _handleClosed,
      overlayBuilder: _buildOverlay,
      builder: (BuildContext context, MenuController controller, Widget? child) => _MenuHandleScope(
        handle: _handle,
        isOpen: controller.isOpen,
        child: Builder(builder: (BuildContext context) => widget.builder(context, this)),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context, RawMenuOverlayInfo info) {
    final RaThemeData theme = RaTheme.of(context);
    final RaMenuThemeData m = theme.menu;
    Rect anchor = info.anchorRect;
    final Offset? position = info.position;
    if (position != null) {
      anchor = Rect.fromLTWH(anchor.left + position.dx, anchor.top + position.dy, 0, 0);
    }
    final ValueNotifier<bool> keyboardMode = _keyboardMode(context);
    final Widget panel = TapRegion(
      groupId: info.tapRegionGroupId,
      // RawMenuAnchor 的根只会在点击外部时收起子菜单，自身的关闭由浮层负责。
      onTapOutside: (_) => _controller.close(),
      child: _MenuPanel(
        anchorState: this,
        items: widget.items,
        panelNode: _panelNode,
        controller: _controller,
        submenu: widget.submenu,
      ),
    );
    return Positioned.fill(
      child: _MenuRootScope(
        keyboardMode: keyboardMode,
        child: RaPopoverPositioner(
          anchor: anchor,
          side: widget.side,
          align: widget.align,
          gap: widget.contextMenu ? 0 : m.sideOffset,
          margin: m.screenMargin,
          animation: _animation,
          scale: m.scale,
          enterOffset: m.enterOffset,
          child: panel,
        ),
      ),
    );
  }
}

class _MenuPanel extends StatefulWidget {
  const _MenuPanel({
    required this.anchorState,
    required this.items,
    required this.panelNode,
    required this.controller,
    required this.submenu,
  });

  final _MenuAnchorState anchorState;
  final List<Widget> items;
  final FocusNode panelNode;
  final MenuController controller;
  final bool submenu;

  @override
  State<_MenuPanel> createState() => _MenuPanelState();
}

class _MenuPanelState extends State<_MenuPanel> {
  final List<FocusNode> _itemNodes = <FocusNode>[];

  MenuController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    widget.anchorState._panelState = this;
  }

  @override
  void dispose() {
    if (widget.anchorState._panelState == this) widget.anchorState._panelState = null;
    super.dispose();
  }

  void register(FocusNode node) => _itemNodes.add(node);
  void unregister(FocusNode node) => _itemNodes.remove(node);

  ValueNotifier<bool> get keyboardMode =>
      _MenuRootScope.maybeOf(context)?.keyboardMode ?? ValueNotifier<bool>(false);

  List<FocusNode> get _focusable {
    final List<FocusNode> nodes = _itemNodes
        .where((FocusNode n) => n.canRequestFocus && n.context != null && n.context!.mounted)
        .toList();
    nodes.sort((FocusNode a, FocusNode b) => a.rect.top.compareTo(b.rect.top));
    return nodes;
  }

  void focusEdge({required bool first}) {
    final List<FocusNode> nodes = _focusable;
    if (nodes.isEmpty) {
      widget.panelNode.requestFocus();
      return;
    }
    keyboardMode.value = true;
    (first ? nodes.first : nodes.last).requestFocus();
  }

  void _move(int delta) {
    final List<FocusNode> nodes = _focusable;
    if (nodes.isEmpty) return;
    keyboardMode.value = true;
    final int current = nodes.indexWhere((FocusNode n) => n.hasPrimaryFocus);
    final int next = current < 0
        ? (delta > 0 ? 0 : nodes.length - 1)
        : (current + delta) % nodes.length;
    nodes[next].requestFocus();
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return KeyEventResult.ignored;
    final LogicalKeyboardKey key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowDown) {
      _move(1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      _move(-1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.home) {
      focusEdge(first: true);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.end) {
      focusEdge(first: false);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowLeft && widget.submenu) {
      keyboardMode.value = true;
      widget.controller.close();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.tab) {
      // 菜单内不做 Tab 遍历（与原生菜单一致）。
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return _MenuPanelScope(
      panel: this,
      child: Focus(
        focusNode: widget.panelNode,
        onKeyEvent: _handleKey,
        child: MouseRegion(
          onHover: (_) => keyboardMode.value = false,
          child: RaMenuSurface(children: widget.items),
        ),
      ),
    );
  }
}

/// 菜单浮层的外观：白底、圆角 12、0.5px 描边、弹层阴影；上下内边距 6，菜单项左右缩进 6，
/// 分隔线贯穿全宽。最小宽 224，过高时滚动。
///
/// RaMenu / RaContextMenu 已内置；自定义浮层（如输入框右键菜单）可直接使用。
class RaMenuSurface extends StatelessWidget {
  const RaMenuSurface({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final RaThemeData theme = RaTheme.of(context);
    final RaMenuThemeData m = theme.menu;
    final double maxHeight = MediaQuery.sizeOf(context).height - m.screenMargin * 2;
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: RaNoDragRegion(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: m.minWidth,
            maxWidth: m.maxWidth,
            maxHeight: maxHeight < 0 ? 0 : maxHeight,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: m.backgroundColor,
              borderRadius: BorderRadius.circular(m.radius),
              border: Border.all(
                color: m.borderColor,
                width: RaHairline.snap(context, theme.sizing.borderWidth),
              ),
              boxShadow: m.shadows,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(m.radius),
              child: IntrinsicWidth(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(vertical: m.padding),
                  child: DefaultTextStyle(
                    style: m.itemTextStyle.copyWith(color: m.itemColor),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        for (final Widget item in children)
                          item is RaMenuSeparator
                              ? item
                              : Padding(
                                  padding: EdgeInsets.symmetric(horizontal: m.padding),
                                  child: item,
                                ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 菜单项的公共外观与行为：高亮块（悬停或键盘焦点）、前置图标、行尾附注与指示位。
class _MenuItemFrame extends StatefulWidget {
  const _MenuItemFrame({
    required this.onPressed,
    required this.child,
    this.leading,
    this.meta,
    this.indicator,
    this.danger = false,
    this.closeOnActivate = true,
    this.forceHighlight = false,
    this.focusNode,
    this.onHoverChanged,
    this.onKeyEvent,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final Widget? leading;
  final Widget? meta;

  /// 行尾固定宽度的指示位（对勾、子菜单箭头）。
  final Widget? indicator;
  final bool danger;
  final bool closeOnActivate;
  final bool forceHighlight;
  final FocusNode? focusNode;
  final ValueChanged<bool>? onHoverChanged;
  final FocusOnKeyEventCallback? onKeyEvent;

  @override
  State<_MenuItemFrame> createState() => _MenuItemFrameState();
}

class _MenuItemFrameState extends State<_MenuItemFrame> {
  FocusNode? _ownNode;
  FocusNode get _node => widget.focusNode ?? (_ownNode ??= FocusNode(debugLabel: 'RaMenuItem'));
  _MenuPanelState? _panel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final _MenuPanelState? panel = _MenuPanelScope.maybeOf(context);
    if (panel != _panel) {
      _panel?.unregister(_node);
      _panel = panel;
      _panel?.register(_node);
    }
  }

  @override
  void dispose() {
    _panel?.unregister(_node);
    _ownNode?.dispose();
    super.dispose();
  }

  void _activate() {
    final VoidCallback? onPressed = widget.onPressed;
    if (onPressed == null) return;
    if (widget.closeOnActivate) {
      Actions.maybeInvoke<DismissIntent>(context, const DismissIntent());
    }
    onPressed();
  }

  void _hoverChanged(bool hovered) {
    if (hovered) {
      _panel?.keyboardMode.value = false;
      // 悬停到普通项时收起同一层已展开的子菜单。
      if (widget.indicator is! _SubmenuIndicator) _panel?.controller.closeChildren();
      if (_node.canRequestFocus) _node.requestFocus();
    }
    widget.onHoverChanged?.call(hovered);
  }

  @override
  Widget build(BuildContext context) {
    final RaThemeData theme = RaTheme.of(context);
    final RaMenuThemeData m = theme.menu;
    final ValueNotifier<bool> keyboardMode =
        _MenuRootScope.maybeOf(context)?.keyboardMode ?? ValueNotifier<bool>(false);
    Widget item = RaPressable(
      onPressed: widget.onPressed == null ? null : _activate,
      focusNode: _node,
      onHoverChanged: _hoverChanged,
      builder: (BuildContext context, RaPressState state) {
        return ValueListenableBuilder<bool>(
          valueListenable: keyboardMode,
          builder: (BuildContext context, bool keyboard, _) {
            final bool highlighted =
                !state.disabled &&
                (widget.forceHighlight || state.hovered || (state.focused && keyboard));
            final Color color = state.disabled
                ? m.disabledColor
                : (widget.danger ? m.dangerColor : m.itemColor);
            return Container(
              height: m.itemHeight,
              padding: EdgeInsets.symmetric(horizontal: m.itemPaddingX),
              decoration: BoxDecoration(
                color: highlighted ? m.highlightColor : null,
                borderRadius: BorderRadius.circular(m.itemRadius),
              ),
              child: IconTheme.merge(
                data: IconThemeData(color: color, size: theme.sizing.iconSm),
                child: DefaultTextStyle.merge(
                  style: TextStyle(color: color),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  child: Row(
                    spacing: m.itemGap,
                    children: <Widget>[
                      ?widget.leading,
                      Expanded(child: widget.child),
                      if (widget.meta != null)
                        Padding(
                          padding: EdgeInsetsDirectional.only(start: m.metaGap - m.itemGap),
                          child: DefaultTextStyle(style: m.metaStyle, child: widget.meta!),
                        ),
                      ?widget.indicator,
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
    if (widget.onKeyEvent != null) {
      item = Focus(
        canRequestFocus: false,
        skipTraversal: true,
        onKeyEvent: widget.onKeyEvent,
        child: item,
      );
    }
    return item;
  }
}

class _SubmenuIndicator extends StatelessWidget {
  const _SubmenuIndicator();

  @override
  Widget build(BuildContext context) {
    final RaThemeData theme = RaTheme.of(context);
    final RaMenuThemeData m = theme.menu;
    return SizedBox(
      width: m.indicatorSize,
      child: Center(
        child: RaIcon.glyph(
          theme.icons.caretRight,
          size: m.submenuIconSize,
          color: m.submenuIconColor,
        ),
      ),
    );
  }
}

class _SubmenuTrigger extends StatefulWidget {
  const _SubmenuTrigger({
    required this.state,
    required this.label,
    this.leading,
    this.meta,
    required this.enabled,
  });

  final _MenuAnchorState state;
  final Widget label;
  final Widget? leading;
  final Widget? meta;
  final bool enabled;

  @override
  State<_SubmenuTrigger> createState() => _SubmenuTriggerState();
}

class _SubmenuTriggerState extends State<_SubmenuTrigger> {
  final FocusNode _node = FocusNode(debugLabel: 'RaSubmenu trigger');
  Timer? _hoverTimer;

  @override
  void initState() {
    super.initState();
    widget.state.triggerNode = _node;
  }

  @override
  void dispose() {
    _hoverTimer?.cancel();
    _node.dispose();
    super.dispose();
  }

  MenuController get _controller => widget.state._controller;

  void _openFromHover(bool hovered) {
    _hoverTimer?.cancel();
    if (!hovered || !widget.enabled || _controller.isOpen) return;
    // 先收起同一层的其他子菜单。
    _MenuPanelScope.maybeOf(context)?.controller.closeChildren();
    _hoverTimer = Timer(RaTheme.of(context).menu.submenuHoverDelay, () {
      if (mounted && !_controller.isOpen) _controller.open();
    });
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.arrowRight &&
        widget.enabled) {
      widget.state.openAndFocusFirst();
      return KeyEventResult.handled;
    }
    // RawMenuAnchor 用自己的 Shortcuts 包住入口（方向键 → DirectionalFocusIntent），
    // 这里先把导航键交给所在面板，保持与普通菜单项一致的上下移动 / 左键收起。
    return _MenuPanelScope.maybeOf(context)?._handleKey(node, event) ?? KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final bool open = RaMenu.of(context).isOpen;
    return Semantics(
      expanded: open,
      child: _MenuItemFrame(
        focusNode: _node,
        onPressed: widget.enabled ? () => open ? _controller.close() : _controller.open() : null,
        closeOnActivate: false,
        forceHighlight: open,
        leading: widget.leading,
        meta: widget.meta,
        indicator: const _SubmenuIndicator(),
        onHoverChanged: _openFromHover,
        onKeyEvent: _handleKey,
        child: widget.label,
      ),
    );
  }
}

@visibleForTesting
RenderRaPopoverPositioner? debugFindMenuPositioner(RenderObject root) {
  RenderRaPopoverPositioner? found;
  void visit(RenderObject child) {
    if (found != null) return;
    if (child is RenderRaPopoverPositioner) {
      found = child;
      return;
    }
    child.visitChildren(visit);
  }

  visit(root);
  return found;
}
