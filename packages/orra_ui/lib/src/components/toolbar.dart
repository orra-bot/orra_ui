import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../foundation/hairline.dart';
import '../theme/theme.dart';
import '../theme/theme_data.dart';
import '../tokens/components.dart';

/// 工具栏（Base UI Toolbar）：一行按钮、开关按钮、选择器与分隔线。
///
/// 键盘：← →（竖排为 ↑ ↓）在工具栏内的可聚焦项之间移动焦点并首尾循环，Home / End 跳到首尾；
/// 焦点在输入框里时方向键留给输入框。
class RaToolbar extends StatefulWidget {
  const RaToolbar({
    super.key,
    required this.children,
    this.semanticLabel,
    this.axis = Axis.horizontal,
  });

  final List<Widget> children;
  final String? semanticLabel;
  final Axis axis;

  @override
  State<RaToolbar> createState() => _RaToolbarState();
}

class _RaToolbarState extends State<RaToolbar> {
  final FocusNode _node = FocusNode(
    debugLabel: 'RaToolbar',
    canRequestFocus: false,
    skipTraversal: true,
  );

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return KeyEventResult.ignored;
    final FocusNode? focused = FocusManager.instance.primaryFocus;
    if (focused == null) return KeyEventResult.ignored;
    // 输入框需要方向键移动光标。
    final BuildContext? focusedContext = focused.context;
    if (focusedContext != null &&
        (focusedContext.widget is EditableText ||
            focusedContext.findAncestorWidgetOfExactType<EditableText>() != null)) {
      return KeyEventResult.ignored;
    }
    final LogicalKeyboardKey key = event.logicalKey;
    final bool horizontal = widget.axis == Axis.horizontal;
    final bool rtl = Directionality.maybeOf(context) == TextDirection.rtl;
    int step = 0;
    bool edge = false;
    if (horizontal && key == LogicalKeyboardKey.arrowRight) step = rtl ? -1 : 1;
    if (horizontal && key == LogicalKeyboardKey.arrowLeft) step = rtl ? 1 : -1;
    if (!horizontal && key == LogicalKeyboardKey.arrowDown) step = 1;
    if (!horizontal && key == LogicalKeyboardKey.arrowUp) step = -1;
    if (key == LogicalKeyboardKey.home) {
      step = -1;
      edge = true;
    }
    if (key == LogicalKeyboardKey.end) {
      step = 1;
      edge = true;
    }
    if (step == 0) return KeyEventResult.ignored;

    final List<FocusNode> items = _node.traversalDescendants.toList()
      ..sort((FocusNode a, FocusNode b) {
        final Rect ra = a.rect;
        final Rect rb = b.rect;
        return horizontal ? ra.left.compareTo(rb.left) : ra.top.compareTo(rb.top);
      });
    if (horizontal && rtl) items.setAll(0, items.reversed.toList());
    if (items.isEmpty) return KeyEventResult.ignored;
    final FocusNode target;
    if (edge) {
      target = step < 0 ? items.first : items.last;
    } else {
      final int index = items.indexWhere((FocusNode n) => n == focused || n.hasFocus);
      if (index < 0) return KeyEventResult.ignored;
      target = items[(index + step) % items.length];
    }
    target.requestFocus();
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final RaToolbarThemeData s = RaTheme.of(context).toolbar;
    final bool horizontal = widget.axis == Axis.horizontal;
    return Semantics(
      container: true,
      label: widget.semanticLabel,
      explicitChildNodes: true,
      child: Focus(
        focusNode: _node,
        onKeyEvent: _handleKey,
        child: _ToolbarAxis(
          axis: widget.axis,
          child: horizontal
              ? Row(mainAxisSize: MainAxisSize.min, spacing: s.gap, children: widget.children)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: s.gap,
                  children: widget.children,
                ),
        ),
      ),
    );
  }
}

/// 让分隔线知道工具栏的方向。
class _ToolbarAxis extends InheritedWidget {
  const _ToolbarAxis({required this.axis, required super.child});

  final Axis axis;

  static Axis of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ToolbarAxis>()?.axis ?? Axis.horizontal;

  @override
  bool updateShouldNotify(_ToolbarAxis old) => axis != old.axis;
}

/// 工具栏分隔线：横排工具栏中为 16 高竖线、左右各留 4；竖排工具栏中为横线。
class RaToolbarSeparator extends StatelessWidget {
  const RaToolbarSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    final RaThemeData theme = RaTheme.of(context);
    final RaToolbarThemeData s = theme.toolbar;
    final double width = RaHairline.snap(context, theme.sizing.borderWidth);
    final bool horizontal = _ToolbarAxis.of(context) == Axis.horizontal;
    final Widget line = ColoredBox(color: s.separatorColor);
    return ExcludeSemantics(
      child: Padding(
        padding: horizontal
            ? EdgeInsets.symmetric(horizontal: s.separatorMargin)
            : EdgeInsets.symmetric(vertical: s.separatorMargin),
        child: horizontal
            ? SizedBox(width: width, height: s.separatorHeight, child: line)
            : SizedBox(width: s.separatorHeight, height: width, child: line),
      ),
    );
  }
}
