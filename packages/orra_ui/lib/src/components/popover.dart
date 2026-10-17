import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../foundation/hairline.dart';
import '../foundation/motion.dart';
import '../foundation/popover_layout.dart';
import '../foundation/pressable.dart';
import '../theme/theme.dart';
import '../theme/theme_data.dart';
import '../tokens/components.dart';

/// 触发元素（或面板内容）用来控制弹出面板的句柄（`RaPopover.of(context)`）。
class RaPopoverHandle {
  RaPopoverHandle._(this._state);

  final _RaPopoverState _state;

  bool get isOpen => _state._controller.isOpen;
  void open() => _state._controller.open();
  void close() => _state._controller.close();
  void toggle() => isOpen ? close() : open();
}

/// 弹出面板（Base UI Popover）：锚定在触发元素旁的白底浮层，可放任意交互内容。
///
/// ```dart
/// RaPopover(
///   title: '分享',
///   description: Text('知道链接的成员都可以查看。'),
///   content: RaTextField(label: '链接', initialValue: url, readOnly: true),
///   child: Builder(
///     builder: (context) => RaButton(
///       onPressed: RaPopover.of(context).toggle,
///       selected: RaPopover.of(context).isOpen,
///       child: Text('分享'),
///     ),
///   ),
/// )
/// ```
///
/// 打开后焦点移入面板；Esc 或点击外部关闭，焦点回到打开前的位置。
/// 面板内容同样可以调用 `RaPopover.of(context).close()`。
class RaPopover extends StatefulWidget {
  const RaPopover({
    super.key,
    required this.content,
    required this.child,
    this.title,
    this.description,
    this.side = RaPopoverSide.bottom,
    this.align = RaPopoverAlign.center,
    this.width,
    this.onOpenChanged,
    this.controller,
  });

  /// 面板内容。
  final Widget content;

  /// 触发元素：在内部调用 `RaPopover.of(context).toggle()`。
  final Widget child;

  /// 面板标题（同时作为面板的无障碍名称）。
  final String? title;
  final Widget? description;
  final RaPopoverSide side;
  final RaPopoverAlign align;

  /// 固定面板宽度；为空时随内容，最宽 [RaPopoverThemeData.maxWidth]。
  final double? width;
  final ValueChanged<bool>? onOpenChanged;
  final MenuController? controller;

  /// 最近的弹出面板句柄。
  static RaPopoverHandle of(BuildContext context) {
    final _PopoverScope? scope = context.dependOnInheritedWidgetOfExactType<_PopoverScope>();
    assert(scope != null, 'RaPopover.of() 只能在 RaPopover 的 child 或 content 内调用。');
    return scope!.handle;
  }

  @override
  State<RaPopover> createState() => _RaPopoverState();
}

class _RaPopoverState extends State<RaPopover> with SingleTickerProviderStateMixin {
  late MenuController _controller = widget.controller ?? MenuController();
  late final AnimationController _animation = AnimationController(vsync: this);
  late final RaPopoverHandle _handle = RaPopoverHandle._(this);
  final FocusScopeNode _panelNode = FocusScopeNode(debugLabel: 'RaPopover panel');
  FocusNode? _restoreFocus;

  @override
  void didUpdateWidget(RaPopover oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _controller = widget.controller ?? MenuController();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _animation.duration = RaReducedMotion.resolve(context, RaTheme.of(context).popover.duration);
  }

  @override
  void dispose() {
    _animation.dispose();
    _panelNode.dispose();
    super.dispose();
  }

  void _handleOpenRequested(Offset? position, VoidCallback showOverlay) {
    _restoreFocus = FocusManager.instance.primaryFocus;
    showOverlay();
    _animation.forward();
    widget.onOpenChanged?.call(true);
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_controller.isOpen) return;
      _panelNode.requestFocus();
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

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
      _controller.close();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return _PopoverScope(
      handle: _handle,
      isOpen: _controller.isOpen,
      child: RawMenuAnchor(
        controller: _controller,
        consumeOutsideTaps: true,
        onOpenRequested: _handleOpenRequested,
        onCloseRequested: _handleCloseRequested,
        onClose: _handleClosed,
        overlayBuilder: _buildOverlay,
        builder: (BuildContext context, MenuController controller, Widget? child) => widget.child,
      ),
    );
  }

  Widget _buildOverlay(BuildContext context, RawMenuOverlayInfo info) {
    final RaPopoverThemeData p = RaTheme.of(context).popover;
    return Positioned.fill(
      child: RaPopoverPositioner(
        anchor: info.anchorRect,
        side: widget.side,
        align: widget.align,
        gap: p.sideOffset,
        margin: p.screenMargin,
        animation: _animation,
        scale: p.scale,
        enterOffset: p.enterOffset,
        child: TapRegion(
          groupId: info.tapRegionGroupId,
          onTapOutside: (_) => _controller.close(),
          child: FocusScope(
            node: _panelNode,
            onKeyEvent: _handleKey,
            child: RaPopoverSurface(
              width: widget.width,
              semanticLabel: widget.title,
              child: RaPopoverPanel(
                title: widget.title,
                description: widget.description,
                child: widget.content,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PopoverScope extends InheritedWidget {
  const _PopoverScope({required this.handle, required this.isOpen, required super.child});

  final RaPopoverHandle handle;
  final bool isOpen;

  @override
  bool updateShouldNotify(_PopoverScope old) => isOpen != old.isOpen || handle != old.handle;
}

/// 弹出面板的外观：白底、圆角 12、0.5px 描边、弹层阴影、内边距 12，最宽 360。
///
/// RaPopover / RaPreviewCard 已内置；自定义浮层可直接使用。
class RaPopoverSurface extends StatelessWidget {
  const RaPopoverSurface({super.key, required this.child, this.width, this.semanticLabel});

  final Widget child;

  /// 固定宽度；为空时随内容，最宽 [RaPopoverThemeData.maxWidth]。
  final double? width;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final RaThemeData theme = RaTheme.of(context);
    final RaPopoverThemeData p = theme.popover;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: semanticLabel,
      child: RaNoDragRegion(
        child: ConstrainedBox(
          constraints: width == null
              ? BoxConstraints(maxWidth: p.maxWidth)
              : BoxConstraints.tightFor(width: width),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: p.backgroundColor,
              borderRadius: BorderRadius.circular(p.radius),
              border: Border.all(
                color: p.borderColor,
                width: RaHairline.snap(context, theme.sizing.borderWidth),
              ),
              boxShadow: p.shadows,
            ),
            child: Padding(
              padding: p.padding,
              child: DefaultTextStyle(
                style: theme.typography.body.copyWith(color: theme.colors.ink),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 弹出面板的内容排布：标题（13 / 500）+ 说明（13px 次要色）+ 内容，间距 4。
class RaPopoverPanel extends StatelessWidget {
  const RaPopoverPanel({super.key, this.title, this.description, required this.child});

  final String? title;
  final Widget? description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final RaPopoverThemeData p = RaTheme.of(context).popover;
    if (title == null && description == null) return child;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: p.gap,
      children: <Widget>[
        if (title != null) Semantics(header: true, child: Text(title!, style: p.titleStyle)),
        if (description != null) DefaultTextStyle(style: p.descriptionStyle, child: description!),
        child,
      ],
    );
  }
}

/// 悬停预览卡（Base UI Preview Card）：指针在 [child] 上停留 600ms 后在旁边显示卡片，
/// 用于预览链接、成员、对象等目标而不打断当前操作。
///
/// 指针在触发元素或卡片上时保持打开，离开两者 300ms 后关闭；键盘聚焦触发元素同样会打开，Esc 关闭。
/// 卡片内容可交互，但打开时不抢焦点。
class RaPreviewCard extends StatefulWidget {
  const RaPreviewCard({
    super.key,
    required this.content,
    required this.child,
    this.side = RaPopoverSide.bottom,
    this.align = RaPopoverAlign.center,
    this.width,
    this.onOpenChanged,
  });

  final Widget content;
  final Widget child;
  final RaPopoverSide side;
  final RaPopoverAlign align;

  /// 卡片宽度，默认 [RaPopoverThemeData.previewWidth]。
  final double? width;
  final ValueChanged<bool>? onOpenChanged;

  @override
  State<RaPreviewCard> createState() => _RaPreviewCardState();
}

class _RaPreviewCardState extends State<RaPreviewCard> with SingleTickerProviderStateMixin {
  final MenuController _controller = MenuController();
  late final AnimationController _animation = AnimationController(vsync: this);
  Timer? _openTimer;
  Timer? _closeTimer;
  bool _overTrigger = false;
  bool _overCard = false;
  bool _focused = false;

  bool get _wantsOpen => _overTrigger || _overCard || _focused;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _animation.duration = RaReducedMotion.resolve(context, RaTheme.of(context).popover.duration);
  }

  @override
  void dispose() {
    _openTimer?.cancel();
    _closeTimer?.cancel();
    _animation.dispose();
    super.dispose();
  }

  void _update() {
    final RaPopoverThemeData p = RaTheme.of(context).popover;
    if (_wantsOpen) {
      _closeTimer?.cancel();
      _closeTimer = null;
      if (!_controller.isOpen && _openTimer == null) {
        _openTimer = Timer(p.previewOpenDelay, () {
          _openTimer = null;
          if (mounted && _wantsOpen) _controller.open();
        });
      }
    } else {
      _openTimer?.cancel();
      _openTimer = null;
      if (_controller.isOpen && _closeTimer == null) {
        _closeTimer = Timer(p.previewCloseDelay, () {
          _closeTimer = null;
          if (mounted && !_wantsOpen) _controller.close();
        });
      }
    }
  }

  void _handleOpenRequested(Offset? position, VoidCallback showOverlay) {
    showOverlay();
    _animation.forward();
    widget.onOpenChanged?.call(true);
  }

  void _handleCloseRequested(VoidCallback hideOverlay) {
    if (_animation.status == AnimationStatus.reverse) return;
    _animation.reverse().whenComplete(() {
      if (!mounted || _animation.status != AnimationStatus.dismissed) return;
      hideOverlay();
    });
  }

  void _handleClosed() {
    _overCard = false;
    widget.onOpenChanged?.call(false);
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape &&
        _controller.isOpen) {
      _openTimer?.cancel();
      _openTimer = null;
      _controller.close();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return RawMenuAnchor(
      controller: _controller,
      onOpenRequested: _handleOpenRequested,
      onCloseRequested: _handleCloseRequested,
      onClose: _handleClosed,
      overlayBuilder: _buildOverlay,
      builder: (BuildContext context, MenuController controller, Widget? child) => Focus(
        canRequestFocus: false,
        skipTraversal: true,
        onKeyEvent: _handleKey,
        onFocusChange: (bool focused) {
          _focused = focused;
          _update();
        },
        child: MouseRegion(
          onEnter: (_) {
            _overTrigger = true;
            _update();
          },
          onExit: (_) {
            _overTrigger = false;
            _update();
          },
          child: widget.child,
        ),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context, RawMenuOverlayInfo info) {
    final RaPopoverThemeData p = RaTheme.of(context).popover;
    return Positioned.fill(
      child: RaPopoverPositioner(
        anchor: info.anchorRect,
        side: widget.side,
        align: widget.align,
        gap: p.sideOffset,
        margin: p.screenMargin,
        animation: _animation,
        scale: p.scale,
        enterOffset: p.enterOffset,
        child: MouseRegion(
          onEnter: (_) {
            _overCard = true;
            _update();
          },
          onExit: (_) {
            _overCard = false;
            _update();
          },
          child: RaPopoverSurface(width: widget.width ?? p.previewWidth, child: widget.content),
        ),
      ),
    );
  }
}
