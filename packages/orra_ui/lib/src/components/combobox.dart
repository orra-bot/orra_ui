import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../foundation/hairline.dart';
import '../foundation/localizations.dart';
import '../foundation/motion.dart';
import '../foundation/popover_layout.dart';
import '../foundation/pressable.dart';
import '../icons/ra_icon.dart';
import '../theme/theme.dart';
import '../theme/theme_data.dart';
import '../tokens/components.dart';
import 'text_field.dart';

/// 可搜索选择框的一个选项。
@immutable
class RaComboboxOption<T> {
  const RaComboboxOption({required this.value, required this.label, this.enabled = true});

  final T value;
  final String label;
  final bool enabled;
}

/// 过滤函数：[query] 为输入框当前文字。
typedef RaComboboxFilter<T> = bool Function(RaComboboxOption<T> option, String query);

/// 默认过滤：不区分大小写的包含匹配。
bool raComboboxContains<T>(RaComboboxOption<T> option, String query) =>
    option.label.toLowerCase().contains(query.trim().toLowerCase());

/// 可搜索的选择框（Base UI Combobox）：在输入框里输入过滤，从预设选项中选一个。
///
/// 聚焦或点击时展开全部选项，输入后只显示匹配项；↑ ↓ 移动高亮（循环），Enter 选中，Esc 收起，
/// 焦点始终留在输入框。失焦时若文字与选中项不符，恢复为选中项的名称。
class RaCombobox<T> extends StatefulWidget {
  const RaCombobox({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.label,
    this.hideLabel = false,
    this.placeholder,
    this.description,
    this.emptyText,
    this.filter,
    this.width,
    this.focusNode,
    this.autofocus = false,
  });

  final List<RaComboboxOption<T>> options;
  final T? value;

  /// 为空时禁用。
  final ValueChanged<T>? onChanged;

  /// 标签；同时作为无障碍名称。
  final String? label;
  final bool hideLabel;
  final String? placeholder;
  final String? description;

  /// 没有匹配项时显示的文字（如「没有匹配的成员」）；为空时用「没有匹配项」。
  final String? emptyText;
  final RaComboboxFilter<T>? filter;

  /// 固定宽度；为空时撑满父级给的宽度。
  final double? width;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  State<RaCombobox<T>> createState() => _RaComboboxState<T>();
}

class _RaComboboxState<T> extends State<RaCombobox<T>> {
  final TextEditingController _text = TextEditingController();

  /// 输入过文字后才按文字过滤；刚展开时显示全部选项。
  bool _filtering = false;

  String get _selectedLabel {
    for (final RaComboboxOption<T> o in widget.options) {
      if (o.value == widget.value) return o.label;
    }
    return '';
  }

  @override
  void initState() {
    super.initState();
    _text.text = _selectedLabel;
  }

  @override
  void didUpdateWidget(RaCombobox<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_filtering && _text.text != _selectedLabel) _text.text = _selectedLabel;
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  List<_ComboEntry> _entries(String query) {
    final RaComboboxFilter<T> filter = widget.filter ?? raComboboxContains<T>;
    return <_ComboEntry>[
      for (final RaComboboxOption<T> o in widget.options)
        if (!_filtering || filter(o, query))
          _ComboEntry(
            key: o.value,
            label: o.label,
            enabled: o.enabled,
            selected: o.value == widget.value,
          ),
    ];
  }

  void _pick(_ComboEntry entry) {
    _filtering = false;
    final String label = entry.label;
    _text.value = TextEditingValue(
      text: label,
      selection: TextSelection.collapsed(offset: label.length),
    );
    widget.onChanged?.call(entry.key as T);
  }

  void _restore() {
    _filtering = false;
    final String label = _selectedLabel;
    if (_text.text != label) _text.text = label;
  }

  @override
  Widget build(BuildContext context) {
    final RaComboboxThemeData c = RaTheme.of(context).combobox;
    final Widget field = _ComboField(
      controller: _text,
      entries: _entries,
      onPick: _pick,
      onQueryChanged: () => _filtering = true,
      onOpened: () => _filtering = false,
      onBlur: _restore,
      highlightSelected: true,
      enabled: widget.onChanged != null,
      label: widget.label,
      hideLabel: widget.hideLabel,
      placeholder: widget.placeholder,
      description: widget.description,
      emptyText: widget.emptyText ?? RaLocalizations.of(context).noResults,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      trailing: IgnorePointer(
        child: RaIcon.glyph(
          RaTheme.of(context).icons.chevronDown,
          size: c.caretSize,
          color: c.caretColor,
        ),
      ),
    );
    if (widget.width == null) return field;
    return SizedBox(width: widget.width, child: field);
  }
}

/// 自动补全（Base UI Autocomplete）：自由输入文字，下方给出建议；选中建议即填入输入框。
///
/// 建议来自 [suggestions]（按输入不区分大小写过滤）或 [optionsBuilder]。
/// ↑ ↓ 移动高亮，Enter 采用高亮的建议（没有高亮时交给 [onSubmitted]），Esc 收起。
class RaAutocomplete extends StatefulWidget {
  const RaAutocomplete({
    super.key,
    this.suggestions,
    this.optionsBuilder,
    this.controller,
    this.initialValue,
    this.onSelected,
    this.onChanged,
    this.onSubmitted,
    this.label,
    this.hideLabel = false,
    this.placeholder,
    this.description,
    this.emptyText,
    this.enabled = true,
    this.search = false,
    this.focusNode,
    this.autofocus = false,
  }) : assert(suggestions != null || optionsBuilder != null, '需要 suggestions 或 optionsBuilder');

  final List<String>? suggestions;

  /// 按当前文字给出建议（优先于 [suggestions]）。
  final Iterable<String> Function(String query)? optionsBuilder;
  final TextEditingController? controller;
  final String? initialValue;

  /// 选中某条建议。
  final ValueChanged<String>? onSelected;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? label;
  final bool hideLabel;
  final String? placeholder;
  final String? description;

  /// 没有建议时显示的文字；为空时不显示列表。
  final String? emptyText;
  final bool enabled;

  /// 搜索样式（左侧放大镜）。
  final bool search;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  State<RaAutocomplete> createState() => _RaAutocompleteState();
}

class _RaAutocompleteState extends State<RaAutocomplete> {
  TextEditingController? _own;
  TextEditingController get _text =>
      widget.controller ?? (_own ??= TextEditingController(text: widget.initialValue));

  @override
  void dispose() {
    _own?.dispose();
    super.dispose();
  }

  List<_ComboEntry> _entries(String query) {
    final Iterable<String> found =
        widget.optionsBuilder?.call(query) ??
        widget.suggestions!.where(
          (String s) => s.toLowerCase().contains(query.trim().toLowerCase()),
        );
    return <_ComboEntry>[
      for (final String s in found) _ComboEntry(key: s, label: s, enabled: true, selected: false),
    ];
  }

  void _pick(_ComboEntry entry) {
    _text.value = TextEditingValue(
      text: entry.label,
      selection: TextSelection.collapsed(offset: entry.label.length),
    );
    widget.onChanged?.call(entry.label);
    widget.onSelected?.call(entry.label);
  }

  @override
  Widget build(BuildContext context) {
    return _ComboField(
      controller: _text,
      entries: _entries,
      onPick: _pick,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      highlightSelected: false,
      enabled: widget.enabled,
      label: widget.label,
      hideLabel: widget.hideLabel,
      placeholder: widget.placeholder,
      description: widget.description,
      emptyText: widget.emptyText,
      search: widget.search,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
    );
  }
}

// ---------------------------------------------------------------------------
// 共用实现
// ---------------------------------------------------------------------------

@immutable
class _ComboEntry {
  const _ComboEntry({
    required this.key,
    required this.label,
    required this.enabled,
    required this.selected,
  });

  final Object? key;
  final String label;
  final bool enabled;
  final bool selected;
}

/// 输入框 + 下方列表。焦点始终在输入框，列表项不可聚焦，靠高亮序号与键盘交互。
class _ComboField extends StatefulWidget {
  const _ComboField({
    required this.controller,
    required this.entries,
    required this.onPick,
    required this.highlightSelected,
    required this.enabled,
    this.onQueryChanged,
    this.onOpened,
    this.onBlur,
    this.onChanged,
    this.onSubmitted,
    this.label,
    this.hideLabel = false,
    this.placeholder,
    this.description,
    this.emptyText,
    this.search = false,
    this.trailing,
    this.focusNode,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final List<_ComboEntry> Function(String query) entries;
  final ValueChanged<_ComboEntry> onPick;

  /// 展开时高亮当前选中项（选择框）；否则不预先高亮（自动补全，Enter 提交自由文字）。
  final bool highlightSelected;
  final bool enabled;
  final VoidCallback? onQueryChanged;
  final VoidCallback? onOpened;
  final VoidCallback? onBlur;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? label;
  final bool hideLabel;
  final String? placeholder;
  final String? description;
  final String? emptyText;
  final bool search;
  final Widget? trailing;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  State<_ComboField> createState() => _ComboFieldState();
}

class _ComboFieldState extends State<_ComboField> with SingleTickerProviderStateMixin {
  final MenuController _menu = MenuController();
  late final AnimationController _animation = AnimationController(vsync: this);
  final ScrollController _scroll = ScrollController();
  FocusNode? _ownFocus;
  FocusNode get _focus => widget.focusNode ?? (_ownFocus ??= FocusNode(debugLabel: 'RaCombobox'));

  List<_ComboEntry> _current = const <_ComboEntry>[];
  int _highlight = -1;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_handleFocus);
  }

  @override
  void didUpdateWidget(_ComboField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _ownFocus)?.removeListener(_handleFocus);
      _focus.addListener(_handleFocus);
    }
    if (_menu.isOpen) {
      _refresh(resetHighlight: false);
      if (_highlight >= _current.length) _highlight = _current.length - 1;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _animation.duration = RaReducedMotion.resolve(context, RaTheme.of(context).menu.duration);
  }

  @override
  void dispose() {
    _focus.removeListener(_handleFocus);
    _ownFocus?.dispose();
    _animation.dispose();
    _scroll.dispose();
    super.dispose();
  }

  bool get _hasList => _current.isNotEmpty || widget.emptyText != null;

  void _refresh({bool resetHighlight = true}) {
    _current = widget.entries(widget.controller.text);
    if (resetHighlight) {
      _highlight = widget.highlightSelected
          ? _current.indexWhere((_ComboEntry e) => e.selected && e.enabled)
          : -1;
      if (_highlight < 0 && widget.highlightSelected) {
        _highlight = _current.indexWhere((_ComboEntry e) => e.enabled);
      }
    }
  }

  void _open() {
    if (!widget.enabled) return;
    widget.onOpened?.call();
    _refresh();
    if (!_hasList) return;
    if (_menu.isOpen) {
      setState(() {});
    } else {
      _menu.open();
    }
  }

  void _close() {
    if (_menu.isOpen) _menu.close();
  }

  void _handleFocus() {
    if (_focus.hasFocus) {
      _open();
    } else {
      _close();
      widget.onBlur?.call();
    }
  }

  void _handleChanged(String text) {
    widget.onQueryChanged?.call();
    widget.onChanged?.call(text);
    _refresh();
    // 输入后高亮第一条匹配项（选择框）；自动补全仍不预先高亮。
    if (widget.highlightSelected) _highlight = _current.indexWhere((_ComboEntry e) => e.enabled);
    if (!_hasList) {
      _close();
    } else if (!_menu.isOpen) {
      _menu.open();
    } else {
      setState(() {});
    }
  }

  void _move(int delta) {
    if (!_menu.isOpen) {
      _open();
      return;
    }
    final int count = _current.length;
    if (count == 0) return;
    int i = _highlight < 0 ? (delta > 0 ? -1 : count) : _highlight;
    for (int n = 0; n < count; n++) {
      i = (i + delta) % count;
      if (i < 0) i += count;
      if (_current[i].enabled) break;
    }
    if (!_current[i].enabled) return;
    setState(() => _highlight = i);
    _revealHighlight();
  }

  /// 让高亮项留在列表可视范围内。
  void _revealHighlight() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients || _highlight < 0) return;
      final RaMenuThemeData m = RaTheme.of(context).menu;
      final double top = m.padding + _highlight * m.itemHeight;
      final double bottom = top + m.itemHeight + m.padding;
      final ScrollPosition p = _scroll.position;
      if (top - m.padding < p.pixels) {
        _scroll.jumpTo((top - m.padding).clamp(0.0, p.maxScrollExtent));
      } else if (bottom > p.pixels + p.viewportDimension) {
        _scroll.jumpTo((bottom - p.viewportDimension).clamp(0.0, p.maxScrollExtent));
      }
    });
  }

  void _pick(_ComboEntry entry) {
    if (!entry.enabled) return;
    widget.onPick(entry);
    _close();
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
    if (key == LogicalKeyboardKey.escape && _menu.isOpen) {
      _close();
      return KeyEventResult.handled;
    }
    if ((key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter) &&
        _menu.isOpen &&
        _highlight >= 0 &&
        _highlight < _current.length) {
      _pick(_current[_highlight]);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _handleOpenRequested(Offset? position, VoidCallback showOverlay) {
    showOverlay();
    _animation.forward();
    setState(() {});
    _revealHighlight();
  }

  void _handleCloseRequested(VoidCallback hideOverlay) {
    if (_animation.status == AnimationStatus.reverse) return;
    _animation.reverse().whenComplete(() {
      if (!mounted || _animation.status != AnimationStatus.dismissed) return;
      hideOverlay();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RawMenuAnchor(
      controller: _menu,
      onOpenRequested: _handleOpenRequested,
      onCloseRequested: _handleCloseRequested,
      onClose: () {
        if (mounted) setState(() {});
      },
      overlayBuilder: _buildOverlay,
      builder: (BuildContext context, MenuController controller, Widget? child) => Semantics(
        expanded: controller.isOpen,
        child: Focus(
          canRequestFocus: false,
          skipTraversal: true,
          onKeyEvent: _handleKey,
          child: Listener(
            // 已聚焦但列表收起（例如按过 Esc）时，再次点击输入框重新展开。
            onPointerDown: (_) {
              if (_focus.hasFocus && !_menu.isOpen) _open();
            },
            child: RaTextField(
              controller: widget.controller,
              focusNode: _focus,
              label: widget.label,
              hideLabel: widget.hideLabel,
              placeholder: widget.placeholder,
              description: widget.description,
              enabled: widget.enabled,
              search: widget.search,
              autofocus: widget.autofocus,
              trailing: widget.trailing,
              onChanged: _handleChanged,
              onSubmitted: widget.onSubmitted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context, RawMenuOverlayInfo info) {
    final RaThemeData theme = RaTheme.of(context);
    final RaMenuThemeData m = theme.menu;
    final RaComboboxThemeData c = theme.combobox;
    final Rect anchor = _fieldRect(info.anchorRect);
    final Widget list = _current.isEmpty
        ? Padding(
            padding: c.emptyPadding,
            child: Text(widget.emptyText ?? '', style: c.emptyStyle),
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (int i = 0; i < _current.length; i++)
                _ComboRow(
                  entry: _current[i],
                  highlighted: i == _highlight,
                  showCheck: widget.highlightSelected,
                  onHover: () {
                    if (_current[i].enabled && _highlight != i) setState(() => _highlight = i);
                  },
                  onTap: () => _pick(_current[i]),
                ),
            ],
          );
    return Positioned.fill(
      child: RaPopoverPositioner(
        anchor: anchor,
        side: RaPopoverSide.bottom,
        align: RaPopoverAlign.start,
        gap: m.sideOffset,
        margin: m.screenMargin,
        animation: _animation,
        scale: m.scale,
        enterOffset: m.enterOffset,
        child: TapRegion(
          groupId: info.tapRegionGroupId,
          onTapOutside: (_) => _close(),
          // 与输入框同组：点击列表不会让输入框失焦。
          child: TextFieldTapRegion(
            child: RaNoDragRegion(
              child: SizedBox(
                width: anchor.width,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: c.maxListHeight),
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
                      child: SingleChildScrollView(
                        controller: _scroll,
                        padding: EdgeInsets.all(m.padding),
                        child: DefaultTextStyle(
                          style: m.itemTextStyle.copyWith(color: m.itemColor),
                          child: Semantics(explicitChildNodes: true, child: list),
                        ),
                      ),
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

  /// 输入框控件本身的矩形（不含标签与说明）：列表贴着输入框下缘弹出。
  Rect _fieldRect(Rect anchorRect) {
    final RenderObject? field = _focus.context?.findRenderObject();
    final RenderObject? overlay = Overlay.maybeOf(context)?.context.findRenderObject();
    if (field is! RenderBox || overlay is! RenderBox || !field.attached) return anchorRect;
    // 锚点包含标签与说明；单行输入框高度固定、编辑区竖直居中，
    // 因此取锚点的左右边界 + 编辑区的竖直中心 ± 输入框半高。
    final RaFieldThemeData f = RaTheme.of(context).field;
    final Offset center = field.localToGlobal(field.size.center(Offset.zero), ancestor: overlay);
    return Rect.fromLTRB(
      anchorRect.left,
      center.dy - f.height / 2,
      anchorRect.right,
      center.dy + f.height / 2,
    );
  }
}

class _ComboRow extends StatelessWidget {
  const _ComboRow({
    required this.entry,
    required this.highlighted,
    required this.showCheck,
    required this.onHover,
    required this.onTap,
  });

  final _ComboEntry entry;
  final bool highlighted;
  final bool showCheck;
  final VoidCallback onHover;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final RaThemeData theme = RaTheme.of(context);
    final RaMenuThemeData m = theme.menu;
    final Color color = entry.enabled ? m.itemColor : m.disabledColor;
    return Semantics(
      button: true,
      enabled: entry.enabled,
      selected: entry.selected,
      checked: showCheck ? entry.selected : null,
      inMutuallyExclusiveGroup: showCheck ? true : null,
      label: entry.label,
      excludeSemantics: true,
      onTap: entry.enabled ? onTap : null,
      child: MouseRegion(
        cursor: entry.enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
        onEnter: (_) => onHover(),
        onHover: (_) => onHover(),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: entry.enabled ? onTap : null,
          child: Container(
            height: m.itemHeight,
            padding: EdgeInsets.symmetric(horizontal: m.itemPaddingX),
            decoration: BoxDecoration(
              color: highlighted && entry.enabled ? m.highlightColor : null,
              borderRadius: BorderRadius.circular(m.itemRadius),
            ),
            child: Row(
              spacing: m.itemGap,
              children: <Widget>[
                Expanded(
                  child: Text(
                    entry.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: color),
                  ),
                ),
                if (showCheck)
                  entry.selected
                      ? RaIcon.glyph(
                          theme.icons.check,
                          size: m.indicatorSize,
                          color: entry.enabled ? m.checkColor : m.disabledColor,
                        )
                      : SizedBox.square(dimension: m.indicatorSize),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
