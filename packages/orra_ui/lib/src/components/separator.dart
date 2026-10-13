import 'package:flutter/widgets.dart';

import '../foundation/hairline.dart';
import '../theme/theme.dart';
import '../theme/theme_data.dart';

/// 细分隔线（0.5px，描边色）。
class RaSeparator extends StatelessWidget {
  const RaSeparator({super.key, this.axis = Axis.horizontal, this.color});

  final Axis axis;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final RaThemeData theme = RaTheme.of(context);
    final double width = RaHairline.snap(context, theme.sizing.borderWidth);
    final Widget line = ColoredBox(color: color ?? theme.colors.border);
    return Semantics(
      container: true,
      child: axis == Axis.horizontal
          ? SizedBox(height: width, width: double.infinity, child: line)
          : SizedBox(width: width, height: double.infinity, child: line),
    );
  }
}
