import 'package:flutter/widgets.dart';

import '../foundation/motion.dart';
import '../foundation/pressable.dart';
import '../foundation/surface.dart';
import '../theme/theme.dart';
import '../tokens/components.dart';
import 'checkbox.dart';

/// 开关（Base UI Switch）：28×16 胶囊轨道，打开为强调色；白色滑块 12px 带淡阴影。
class RaSwitch extends StatelessWidget {
  const RaSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.description,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final Widget? label;
  final Widget? description;

  /// 没有 [label] 时的无障碍名称。
  final String? semanticLabel;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final RaControlThemeData s = RaTheme.of(context).control;
    return RaPressable(
      onPressed: onChanged == null ? null : () => onChanged!(!value),
      focusNode: focusNode,
      autofocus: autofocus,
      semanticsButton: false,
      semanticsToggled: value,
      semanticLabel: semanticLabel,
      builder: (BuildContext context, RaPressState state) {
        final Duration duration = RaReducedMotion.resolve(context, s.duration);
        final Color track = value
            ? (state.hovered ? s.checkedHoverColor : s.checkedColor)
            : (state.hovered ? s.switchTrackHoverColor : s.switchTrackColor);
        final double inset = (s.switchHeight - s.switchThumbSize) / 2;
        final Widget control = RaAnimatedSurface(
          duration: duration,
          backgroundColor: track,
          radius: s.switchHeight / 2,
          constraints: BoxConstraints.tightFor(width: s.switchWidth, height: s.switchHeight),
          padding: EdgeInsets.all(inset),
          child: AnimatedAlign(
            duration: duration,
            curve: RaTheme.of(context).motion.emphasized,
            alignment: value ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
            child: Container(
              width: s.switchThumbSize,
              height: s.switchThumbSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: s.switchThumbColor,
                boxShadow: s.switchThumbShadows,
              ),
            ),
          ),
        );
        return Opacity(
          opacity: state.disabled ? s.disabledOpacity : 1,
          child: RaControlLabel(control: control, label: label, description: description),
        );
      },
    );
  }
}
