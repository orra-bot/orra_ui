import 'package:flutter/widgets.dart';

import '../foundation/dashed_border.dart';
import '../foundation/hairline.dart';
import '../theme/theme.dart';
import '../theme/theme_data.dart';
import '../tokens/components.dart';

/// 状态标签：20 高胶囊、12px / 500，可带圆点。语气见 [RaTagTone]。
class RaTag extends StatelessWidget {
  const RaTag({
    super.key,
    required this.label,
    this.tone = RaTagTone.neutral,
    this.dot = false,
    this.icon,
  });

  final String label;
  final RaTagTone tone;

  /// 文字前的圆点（当前色）。
  final bool dot;

  /// 文字前的图标（与 [dot] 二选一）。
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final RaThemeData theme = RaTheme.of(context);
    final RaTagThemeData s = theme.tag;
    final RaTagStyle style = s.styleOf(tone);
    final double borderWidth = RaHairline.snap(context, theme.sizing.borderWidth);
    final Color? border = style.borderColor;
    Widget result = DecoratedBox(
      decoration: BoxDecoration(
        color: style.backgroundColor,
        borderRadius: BorderRadius.circular(s.radius),
        border: border != null && !style.dashed
            ? Border.all(color: border, width: borderWidth)
            : null,
      ),
      child: SizedBox(
        height: s.height,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: s.paddingX),
          child: IconTheme.merge(
            data: IconThemeData(color: style.foregroundColor, size: theme.sizing.iconXs),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: s.gap,
              children: <Widget>[
                if (dot)
                  Container(
                    width: s.dotSize,
                    height: s.dotSize,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: style.foregroundColor),
                  )
                else
                  ?icon,
                Text(
                  label,
                  maxLines: 1,
                  softWrap: false,
                  style: s.textStyle.copyWith(color: style.foregroundColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (border != null && style.dashed) {
      result = RaDashedBorder(
        color: border,
        width: theme.sizing.borderWidth,
        radius: s.height / 2,
        dashLength: s.dashLength,
        dashGap: s.dashGap,
        child: result,
      );
    }
    return result;
  }
}

/// 未读数量徽标：[count] 不大于 0 时不显示；超过 [max] 显示「max+」。
class RaCountTag extends StatelessWidget {
  const RaCountTag({super.key, required this.count, required this.semanticLabel, this.max = 99});

  final int count;

  /// 无障碍名称（例如「3 条未读」）。
  final String semanticLabel;
  final int max;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    final RaTagThemeData s = RaTheme.of(context).tag;
    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: Container(
        constraints: BoxConstraints(minWidth: s.countSize, minHeight: s.countSize),
        padding: EdgeInsets.symmetric(horizontal: s.countPaddingX),
        decoration: BoxDecoration(
          color: s.countBackgroundColor,
          borderRadius: BorderRadius.circular(s.radius),
        ),
        alignment: Alignment.center,
        child: Text(count > max ? '$max+' : '$count', style: s.countTextStyle),
      ),
    );
  }
}
