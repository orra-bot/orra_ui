import 'package:flutter/widgets.dart';

import '../foundation/popover_layout.dart';
import '../foundation/roving_focus.dart';
import '../theme/theme.dart';
import '../tokens/components.dart';
import 'button.dart';
import 'tooltip.dart';

/// 开关按钮（Base UI Toggle）：按下 / 弹起两种状态（aria-pressed），如工具栏里的「加粗」「固定」。
///
/// 只有 [icon] 时为 28px 圆形图标按钮，[label] 同时作为提示与无障碍名称（可带 [shortcut]）；
/// 有 [child] 时为安静按钮（文字 + 可选图标）。按下状态沿用按钮的「选中」外观。
class RaToggle extends StatelessWidget {
  const RaToggle({
    super.key,
    required this.pressed,
    required this.onChanged,
    required this.label,
    this.icon,
    this.child,
    this.shortcut,
    this.tooltipSide = RaPopoverSide.bottom,
    this.focusNode,
  }) : assert(icon != null || child != null, 'RaToggle 需要 icon 或 child');

  final bool pressed;
  final ValueChanged<bool>? onChanged;

  /// 无障碍名称；仅图标时也是提示文字。
  final String label;
  final Widget? icon;
  final Widget? child;
  final String? shortcut;
  final RaPopoverSide tooltipSide;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final bool iconOnly = child == null;
    final Widget button = RaButton(
      onPressed: onChanged == null ? null : () => onChanged!(!pressed),
      variant: iconOnly ? RaButtonVariant.icon : RaButtonVariant.quiet,
      size: RaButtonSize.sm,
      selected: pressed,
      focusNode: focusNode,
      semanticLabel: label,
      leading: iconOnly ? null : icon,
      child: child ?? icon!,
    );
    // 与按钮自身的语义节点合并成一个，补上「按下」状态。
    final Widget toggle = MergeSemantics(
      child: Semantics(toggled: pressed, child: button),
    );
    if (!iconOnly) return toggle;
    return RaTooltip(
      message: label,
      shortcut: shortcut,
      side: tooltipSide,
      excludeFromSemantics: true,
      child: toggle,
    );
  }
}

/// 开关按钮组中的一项。
@immutable
class RaToggleItem<T> {
  const RaToggleItem({
    required this.value,
    required this.label,
    this.icon,
    this.showLabel = false,
    this.shortcut,
    this.enabled = true,
  });

  final T value;
  final String label;
  final Widget? icon;

  /// 显示文字（否则只显示图标，文字作为提示）。没有 [icon] 时总是显示文字。
  final bool showLabel;
  final String? shortcut;
  final bool enabled;
}

/// 开关按钮组（Base UI ToggleGroup）：工具栏里一组可多选（[multiple]）或单选的开关按钮。
///
/// 单选时再次点击当前项会取消（与分段切换不同；必须始终有选中项时用 RaSegmentedControl）。
/// 键盘：方向键在组内移动焦点（首尾循环），Home / End 跳到首尾；Enter / Space 切换。
class RaToggleGroup<T> extends StatefulWidget {
  const RaToggleGroup({
    super.key,
    required this.items,
    required this.values,
    required this.onChanged,
    this.multiple = true,
    this.axis = Axis.horizontal,
    this.semanticLabel,
  });

  final List<RaToggleItem<T>> items;
  final Set<T> values;
  final ValueChanged<Set<T>>? onChanged;
  final bool multiple;
  final Axis axis;
  final String? semanticLabel;

  @override
  State<RaToggleGroup<T>> createState() => _RaToggleGroupState<T>();
}

class _RaToggleGroupState<T> extends State<RaToggleGroup<T>> {
  final List<FocusNode> _nodes = <FocusNode>[];

  void _syncNodes() {
    while (_nodes.length < widget.items.length) {
      _nodes.add(FocusNode(debugLabel: 'RaToggleItem ${_nodes.length}'));
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

  bool _enabled(int i) => widget.onChanged != null && widget.items[i].enabled;

  int _currentIndex() => _nodes.indexWhere((FocusNode n) => n.hasPrimaryFocus);

  void _toggle(int index, bool pressed) {
    final T value = widget.items[index].value;
    final Set<T> next = widget.multiple ? <T>{...widget.values} : <T>{};
    if (pressed) {
      next.add(value);
    } else {
      next.remove(value);
    }
    _nodes[index].requestFocus();
    widget.onChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    _syncNodes();
    final RaToolbarThemeData s = RaTheme.of(context).toolbar;
    final List<Widget> children = <Widget>[
      for (int i = 0; i < widget.items.length; i++)
        RaToggle(
          pressed: widget.values.contains(widget.items[i].value),
          onChanged: _enabled(i) ? (bool p) => _toggle(i, p) : null,
          label: widget.items[i].label,
          icon: widget.items[i].icon,
          shortcut: widget.items[i].shortcut,
          focusNode: _nodes[i],
          child: widget.items[i].showLabel || widget.items[i].icon == null
              ? Text(widget.items[i].label)
              : null,
        ),
    ];
    return Semantics(
      container: true,
      label: widget.semanticLabel,
      explicitChildNodes: true,
      child: RaRovingGroup(
        axis: widget.axis,
        count: widget.items.length,
        currentIndex: _currentIndex,
        isEnabled: _enabled,
        onMove: (int i) => _nodes[i].requestFocus(),
        child: widget.axis == Axis.horizontal
            ? Row(mainAxisSize: MainAxisSize.min, spacing: s.gap, children: children)
            : Column(mainAxisSize: MainAxisSize.min, spacing: s.gap, children: children),
      ),
    );
  }
}
