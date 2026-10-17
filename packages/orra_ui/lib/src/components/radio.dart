import 'package:flutter/widgets.dart';

import '../foundation/hairline.dart';
import '../foundation/motion.dart';
import '../foundation/pressable.dart';
import '../foundation/roving_focus.dart';
import '../theme/theme.dart';
import '../theme/theme_data.dart';
import '../tokens/components.dart';
import 'checkbox.dart';

/// 单选组的一项。
@immutable
class RaRadioOption<T> {
  const RaRadioOption({
    required this.value,
    required this.label,
    this.description,
    this.enabled = true,
  });

  final T value;
  final String label;
  final String? description;
  final bool enabled;
}

/// 单选组（Base UI RadioGroup）：14px 圆框，选中为强调色实心 + 白色圆点。
/// 键盘：方向键移动并选中（首尾循环）。
class RaRadioGroup<T> extends StatefulWidget {
  const RaRadioGroup({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.semanticLabel,
    this.axis = Axis.vertical,
  });

  final List<RaRadioOption<T>> options;
  final T? value;
  final ValueChanged<T>? onChanged;
  final String? semanticLabel;

  /// 竖排（默认）或横排。
  final Axis axis;

  @override
  State<RaRadioGroup<T>> createState() => _RaRadioGroupState<T>();
}

class _RaRadioGroupState<T> extends State<RaRadioGroup<T>> {
  final List<FocusNode> _nodes = <FocusNode>[];

  void _syncNodes() {
    while (_nodes.length < widget.options.length) {
      _nodes.add(FocusNode(debugLabel: 'RaRadio ${_nodes.length}'));
    }
    while (_nodes.length > widget.options.length) {
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

  bool _enabled(int i) => widget.onChanged != null && widget.options[i].enabled;

  int _currentIndex() {
    final int focused = _nodes.indexWhere((FocusNode n) => n.hasPrimaryFocus);
    if (focused >= 0) return focused;
    return widget.options.indexWhere((RaRadioOption<T> o) => o.value == widget.value);
  }

  @override
  Widget build(BuildContext context) {
    _syncNodes();
    final RaThemeData theme = RaTheme.of(context);
    final RaControlThemeData s = theme.control;
    final List<Widget> children = <Widget>[
      for (int i = 0; i < widget.options.length; i++)
        RaRadio<T>(
          value: widget.options[i].value,
          groupValue: widget.value,
          onChanged: _enabled(i) ? widget.onChanged : null,
          focusNode: _nodes[i],
          label: Text(widget.options[i].label),
          description: widget.options[i].description == null
              ? null
              : Text(widget.options[i].description!),
        ),
    ];
    return Semantics(
      container: true,
      label: widget.semanticLabel,
      explicitChildNodes: true,
      child: RaRovingGroup(
        count: widget.options.length,
        currentIndex: _currentIndex,
        isEnabled: _enabled,
        onMove: (int i) {
          _nodes[i].requestFocus();
          final T value = widget.options[i].value;
          if (value != widget.value) widget.onChanged?.call(value);
        },
        child: widget.axis == Axis.vertical
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: s.groupGap,
                children: children,
              )
            : Wrap(spacing: theme.spacing.xl, runSpacing: s.groupGap, children: children),
      ),
    );
  }
}

/// 单个单选框；通常通过 [RaRadioGroup] 使用。
class RaRadio<T> extends StatelessWidget {
  const RaRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.label,
    this.description,
    this.semanticLabel,
    this.focusNode,
  });

  final T value;
  final T? groupValue;
  final ValueChanged<T>? onChanged;
  final Widget? label;
  final Widget? description;
  final String? semanticLabel;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final RaThemeData theme = RaTheme.of(context);
    final RaControlThemeData s = theme.control;
    final bool checked = value == groupValue;
    return RaPressable(
      onPressed: onChanged == null
          ? null
          : () {
              focusNode?.requestFocus();
              onChanged!(value);
            },
      focusNode: focusNode,
      semanticsButton: false,
      semanticsChecked: checked,
      semanticsInMutuallyExclusiveGroup: true,
      semanticLabel: semanticLabel,
      builder: (BuildContext context, RaPressState state) {
        final Color fill = checked
            ? (state.hovered ? s.checkedHoverColor : s.checkedColor)
            : s.backgroundColor;
        final Color border = checked
            ? fill
            : state.hovered
            ? s.hoverBorderColor
            : s.borderColor;
        final Duration duration = RaReducedMotion.resolve(context, s.duration);
        final Widget circle = AnimatedContainer(
          duration: duration,
          width: s.boxSize,
          height: s.boxSize,
          decoration: BoxDecoration(
            color: fill,
            shape: BoxShape.circle,
            border: Border.all(
              color: border,
              width: RaHairline.snap(context, theme.sizing.borderWidth),
            ),
            boxShadow: checked ? null : s.shadows,
          ),
          child: Center(
            child: AnimatedScale(
              duration: duration,
              scale: checked ? 1 : 0,
              child: Container(
                width: s.radioDotSize,
                height: s.radioDotSize,
                decoration: BoxDecoration(shape: BoxShape.circle, color: s.onCheckedColor),
              ),
            ),
          ),
        );
        return Opacity(
          opacity: state.disabled ? s.disabledOpacity : 1,
          child: RaControlLabel(control: circle, label: label, description: description),
        );
      },
    );
  }
}
