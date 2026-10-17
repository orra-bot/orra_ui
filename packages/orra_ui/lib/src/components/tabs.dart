import 'package:flutter/widgets.dart';

import '../foundation/pressable.dart';
import '../foundation/roving_focus.dart';
import '../foundation/surface.dart';
import '../theme/theme.dart';
import '../theme/theme_data.dart';
import '../tokens/components.dart';

/// 一个标签。
@immutable
class RaTab<T> {
  const RaTab({required this.value, required this.label, this.icon, this.enabled = true});

  final T value;
  final String label;

  /// 14px 图标（RaIcon / Icon）。
  final Widget? icon;
  final bool enabled;
}

/// 页面内标签列表（Base UI Tabs）：横排或竖排（Workspace 模块导航）。
///
/// 只负责标签本身；内容区由调用方按 [value] 切换（或用 [RaTabs.withPanels]）。
/// 键盘：方向键在标签间移动并选中（首尾循环），Home / End 跳到首尾。按下即选中。
class RaTabs<T> extends StatefulWidget {
  const RaTabs({
    super.key,
    required this.tabs,
    required this.value,
    required this.onChanged,
    this.axis = Axis.horizontal,
    this.semanticLabel,
  });

  final List<RaTab<T>> tabs;

  /// 当前标签。
  final T value;
  final ValueChanged<T>? onChanged;

  /// 横排或竖排。竖排时标签撑满宽度、文字左对齐。
  final Axis axis;
  final String? semanticLabel;

  /// 标签 + 内容区：内容区只构建当前标签。
  static Widget withPanels<T>({
    Key? key,
    required List<RaTab<T>> tabs,
    required T value,
    required ValueChanged<T>? onChanged,
    required Widget Function(BuildContext context, T value) panelBuilder,
    Axis axis = Axis.horizontal,
    double? gap,
  }) {
    return Builder(
      key: key,
      builder: (BuildContext context) {
        final RaThemeData theme = RaTheme.of(context);
        final Widget list = RaTabs<T>(tabs: tabs, value: value, onChanged: onChanged, axis: axis);
        final Widget panel = KeyedSubtree(
          key: ValueKey<T>(value),
          child: panelBuilder(context, value),
        );
        final double spacing = gap ?? theme.spacing.xl;
        return axis == Axis.horizontal
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: spacing,
                children: <Widget>[
                  Align(alignment: AlignmentDirectional.centerStart, child: list),
                  panel,
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: spacing,
                children: <Widget>[
                  IntrinsicWidth(child: list),
                  Expanded(child: panel),
                ],
              );
      },
    );
  }

  @override
  State<RaTabs<T>> createState() => _RaTabsState<T>();
}

class _RaTabsState<T> extends State<RaTabs<T>> {
  final List<FocusNode> _nodes = <FocusNode>[];

  void _syncNodes() {
    while (_nodes.length < widget.tabs.length) {
      _nodes.add(FocusNode(debugLabel: 'RaTab ${_nodes.length}'));
    }
    while (_nodes.length > widget.tabs.length) {
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

  bool _enabled(int i) => widget.onChanged != null && widget.tabs[i].enabled;

  int _currentIndex() {
    final int focused = _nodes.indexWhere((FocusNode n) => n.hasPrimaryFocus);
    if (focused >= 0) return focused;
    return widget.tabs.indexWhere((RaTab<T> t) => t.value == widget.value);
  }

  void _move(int index) {
    _nodes[index].requestFocus();
    final T value = widget.tabs[index].value;
    if (value != widget.value) widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    _syncNodes();
    final RaTabsThemeData s = RaTheme.of(context).tabs;
    final bool vertical = widget.axis == Axis.vertical;
    final List<Widget> children = <Widget>[
      for (int i = 0; i < widget.tabs.length; i++)
        _TabButton<T>(
          tab: widget.tabs[i],
          selected: widget.tabs[i].value == widget.value,
          focusNode: _nodes[i],
          expand: vertical,
          onPressed: _enabled(i) ? () => _move(i) : null,
        ),
    ];
    return Semantics(
      container: true,
      label: widget.semanticLabel,
      explicitChildNodes: true,
      child: RaRovingGroup(
        axis: widget.axis,
        count: widget.tabs.length,
        currentIndex: _currentIndex,
        isEnabled: _enabled,
        onMove: _move,
        child: vertical
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: s.listGap,
                children: children,
              )
            : Row(mainAxisSize: MainAxisSize.min, spacing: s.listGap, children: children),
      ),
    );
  }
}

class _TabButton<T> extends StatelessWidget {
  const _TabButton({
    required this.tab,
    required this.selected,
    required this.focusNode,
    required this.expand,
    required this.onPressed,
  });

  final RaTab<T> tab;
  final bool selected;
  final FocusNode focusNode;
  final bool expand;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final RaTabsThemeData s = RaTheme.of(context).tabs;
    return RaPressable(
      onPressed: onPressed,
      selected: selected,
      focusNode: focusNode,
      pressOnDown: true,
      semanticLabel: tab.label,
      excludeSemantics: true,
      builder: (BuildContext context, RaPressState state) {
        final Color background = state.disabled
            ? const Color(0x00000000)
            : state.pressed
            ? s.pressedColor
            : state.selected
            ? s.selectedColor
            : state.hovered
            ? s.hoverColor
            : const Color(0x00000000);
        final Color foreground = state.disabled
            ? s.disabledColor
            : state.hovered || state.selected
            ? s.activeColor
            : s.color;
        return RaAnimatedSurface(
          duration: state.transition,
          backgroundColor: background,
          foregroundColor: foreground,
          textStyle: s.textStyle,
          iconSize: s.iconSize,
          radius: s.radius,
          constraints: BoxConstraints.tightFor(height: s.height),
          padding: EdgeInsets.symmetric(horizontal: s.paddingX),
          child: Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            spacing: s.gap,
            children: <Widget>[
              if (tab.icon != null)
                SizedBox(
                  width: s.iconSize,
                  child: Center(child: tab.icon),
                ),
              Flexible(
                child: Text(
                  tab.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
