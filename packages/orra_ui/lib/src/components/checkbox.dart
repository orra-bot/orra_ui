import 'package:flutter/widgets.dart';

import '../foundation/hairline.dart';
import '../foundation/motion.dart';
import '../foundation/pressable.dart';
import '../icons/ra_icon.dart';
import '../theme/theme.dart';
import '../theme/theme_data.dart';
import '../tokens/components.dart';

/// 勾选类控件（复选框、单选框、开关）的「控件 + 标签 + 说明」排布：整行可点击，
/// 控件与标签首行垂直居中对齐。
class RaControlLabel extends StatelessWidget {
  const RaControlLabel({super.key, required this.control, this.label, this.description});

  final Widget control;
  final Widget? label;
  final Widget? description;

  @override
  Widget build(BuildContext context) {
    final RaControlThemeData s = RaTheme.of(context).control;
    if (label == null && description == null) return control;
    final double lineHeight = (s.labelStyle.fontSize ?? 0) * (s.labelStyle.height ?? 1);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: s.labelGap,
      children: <Widget>[
        SizedBox(
          height: lineHeight,
          child: Center(child: control),
        ),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (label != null) DefaultTextStyle(style: s.labelStyle, child: label!),
              if (description != null)
                DefaultTextStyle(style: s.descriptionStyle, child: description!),
            ],
          ),
        ),
      ],
    );
  }
}

/// 复选框（Base UI Checkbox）：14px 方框，选中为强调色实心 + 白色对勾。
///
/// [value] 为 null 表示「部分选中」（显示横线），点击后变为选中。
class RaCheckbox extends StatelessWidget {
  const RaCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.description,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
  });

  final bool? value;
  final ValueChanged<bool>? onChanged;
  final Widget? label;
  final Widget? description;

  /// 没有 [label] 时的无障碍名称。
  final String? semanticLabel;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final RaThemeData theme = RaTheme.of(context);
    final RaControlThemeData s = theme.control;
    final bool on = value ?? true;
    return RaPressable(
      onPressed: onChanged == null ? null : () => onChanged!(!(value ?? false)),
      focusNode: focusNode,
      autofocus: autofocus,
      semanticsButton: false,
      semanticsChecked: value ?? false,
      semanticsMixed: value == null ? true : null,
      semanticLabel: semanticLabel,
      builder: (BuildContext context, RaPressState state) {
        final Color fill = on
            ? (state.hovered ? s.checkedHoverColor : s.checkedColor)
            : s.backgroundColor;
        final Color border = on
            ? fill
            : state.hovered
            ? s.hoverBorderColor
            : s.borderColor;
        final Widget box = AnimatedContainer(
          duration: RaReducedMotion.resolve(context, s.duration),
          width: s.boxSize,
          height: s.boxSize,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(s.boxRadius),
            border: Border.all(
              color: border,
              width: RaHairline.snap(context, theme.sizing.borderWidth),
            ),
            boxShadow: on ? null : s.shadows,
          ),
          child: on
              ? Center(
                  child: RaIcon.glyph(
                    value == null ? theme.icons.minus : theme.icons.check,
                    size: s.indicatorSize,
                    color: s.onCheckedColor,
                  ),
                )
              : null,
        );
        return Opacity(
          opacity: state.disabled ? s.disabledOpacity : 1,
          child: RaControlLabel(control: box, label: label, description: description),
        );
      },
    );
  }
}
