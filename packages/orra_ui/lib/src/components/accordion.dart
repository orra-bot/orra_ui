import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../foundation/motion.dart';
import '../foundation/pressable.dart';
import '../foundation/surface.dart';
import '../icons/ra_icon.dart';
import '../theme/theme.dart';
import '../theme/theme_data.dart';
import '../tokens/components.dart';
import 'collapsible.dart';
import 'separator.dart';

/// 手风琴的一项。
@immutable
class RaAccordionItem {
  const RaAccordionItem({
    required this.value,
    required this.title,
    required this.child,
    this.enabled = true,
  });

  /// 标识（用于展开状态）。
  final Object value;
  final String title;
  final Widget child;
  final bool enabled;
}

/// 手风琴（Base UI Accordion）：一组可展开的标题 + 内容，行间细分隔线。
///
/// 默认同时只展开一项（[multiple] 为 true 时可多项）。展开状态可受控（[expanded] + [onExpandedChanged]）
/// 或由组件自行管理（[initiallyExpanded]）。键盘：↑ ↓ 在标题之间移动焦点，Home / End 跳到首尾，
/// Enter / Space 展开或收起。
class RaAccordion extends StatefulWidget {
  const RaAccordion({
    super.key,
    required this.items,
    this.multiple = false,
    this.expanded,
    this.initiallyExpanded = const <Object>{},
    this.onExpandedChanged,
  });

  final List<RaAccordionItem> items;
  final bool multiple;

  /// 受控的展开项（为空时组件自行管理）。
  final Set<Object>? expanded;
  final Set<Object> initiallyExpanded;
  final ValueChanged<Set<Object>>? onExpandedChanged;

  @override
  State<RaAccordion> createState() => _RaAccordionState();
}

class _RaAccordionState extends State<RaAccordion> {
  late Set<Object> _own = <Object>{...widget.initiallyExpanded};
  final List<FocusNode> _nodes = <FocusNode>[];

  Set<Object> get _expanded => widget.expanded ?? _own;

  void _syncNodes() {
    while (_nodes.length < widget.items.length) {
      _nodes.add(FocusNode(debugLabel: 'RaAccordion header ${_nodes.length}'));
    }
    while (_nodes.length > widget.items.length) {
      _nodes.removeLast().dispose();
    }
  }

  @override
  void dispose() {
    for (final FocusNode node in _nodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _toggle(int index) {
    final Object value = widget.items[index].value;
    final bool open = !_expanded.contains(value);
    final Set<Object> next = widget.multiple ? <Object>{..._expanded} : <Object>{};
    if (open) {
      next.add(value);
    } else {
      next.remove(value);
    }
    _nodes[index].requestFocus();
    if (widget.expanded == null) setState(() => _own = next);
    widget.onExpandedChanged?.call(next);
  }

  /// 只在焦点位于某个标题上时处理方向键（内容区里的控件不受影响）。
  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return KeyEventResult.ignored;
    final int current = _nodes.indexWhere((FocusNode n) => n.hasPrimaryFocus);
    if (current < 0) return KeyEventResult.ignored;
    final List<int> enabled = <int>[
      for (int i = 0; i < widget.items.length; i++)
        if (widget.items[i].enabled) i,
    ];
    if (enabled.isEmpty) return KeyEventResult.ignored;
    final LogicalKeyboardKey key = event.logicalKey;
    int? target;
    if (key == LogicalKeyboardKey.home) target = enabled.first;
    if (key == LogicalKeyboardKey.end) target = enabled.last;
    if (key == LogicalKeyboardKey.arrowDown || key == LogicalKeyboardKey.arrowUp) {
      final int step = key == LogicalKeyboardKey.arrowDown ? 1 : -1;
      int i = current;
      for (int n = 0; n < widget.items.length; n++) {
        i = (i + step) % widget.items.length;
        if (i < 0) i += widget.items.length;
        if (widget.items[i].enabled) {
          target = i;
          break;
        }
      }
    }
    if (target == null) return KeyEventResult.ignored;
    _nodes[target].requestFocus();
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    _syncNodes();
    final RaAccordionThemeData a = RaTheme.of(context).accordion;
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: _handleKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          RaSeparator(color: a.separatorColor),
          for (int i = 0; i < widget.items.length; i++) ...<Widget>[
            _AccordionHeader(
              item: widget.items[i],
              expanded: _expanded.contains(widget.items[i].value),
              focusNode: _nodes[i],
              onPressed: widget.items[i].enabled ? () => _toggle(i) : null,
            ),
            RaCollapsiblePanel(
              expanded: _expanded.contains(widget.items[i].value),
              child: Padding(
                padding: a.panelPadding,
                child: DefaultTextStyle(style: a.contentStyle, child: widget.items[i].child),
              ),
            ),
            RaSeparator(color: a.separatorColor),
          ],
        ],
      ),
    );
  }
}

class _AccordionHeader extends StatelessWidget {
  const _AccordionHeader({
    required this.item,
    required this.expanded,
    required this.focusNode,
    required this.onPressed,
  });

  final RaAccordionItem item;
  final bool expanded;
  final FocusNode focusNode;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final RaThemeData theme = RaTheme.of(context);
    final RaAccordionThemeData a = theme.accordion;
    return MergeSemantics(
      child: Semantics(
        expanded: expanded,
        header: true,
        child: RaPressable(
          onPressed: onPressed,
          focusNode: focusNode,
          semanticLabel: item.title,
          excludeSemantics: true,
          builder: (BuildContext context, RaPressState state) {
            final Color foreground = state.disabled ? a.disabledColor : a.titleColor;
            return RaAnimatedSurface(
              duration: state.transition,
              backgroundColor: state.hovered && !state.disabled
                  ? a.hoverColor
                  : const Color(0x00000000),
              foregroundColor: foreground,
              textStyle: a.titleStyle,
              radius: a.headerRadius,
              padding: a.headerPadding,
              constraints: BoxConstraints.tightFor(height: a.headerHeight),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: RaReducedMotion.resolve(context, theme.motion.base),
                    child: RaIcon.glyph(
                      theme.icons.chevronDown,
                      size: a.chevronSize,
                      color: state.disabled ? a.disabledColor : a.chevronColor,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
