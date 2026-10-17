import 'package:flutter/widgets.dart';

import '../foundation/dashed_border.dart';
import '../foundation/hairline.dart';
import '../foundation/localizations.dart';
import '../theme/theme.dart';
import '../theme/theme_data.dart';
import '../tokens/components.dart';
import 'button.dart';

/// 加载 / 空 / 错误状态块的共用外框。
class _StateFrame extends StatelessWidget {
  const _StateFrame({
    required this.children,
    this.backgroundColor,
    this.borderColor,
    this.dashed = false,
  });

  final List<Widget> children;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool dashed;

  @override
  Widget build(BuildContext context) {
    final RaThemeData theme = RaTheme.of(context);
    final RaStateBlockThemeData s = theme.stateBlock;
    Widget result = DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(s.radius),
        border: borderColor != null && !dashed
            ? Border.all(
                color: borderColor!,
                width: RaHairline.snap(context, theme.sizing.borderWidth),
              )
            : null,
      ),
      child: Padding(
        padding: EdgeInsets.all(s.padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: s.gap,
          children: children,
        ),
      ),
    );
    if (borderColor != null && dashed) {
      result = RaDashedBorder(
        color: borderColor!,
        width: theme.sizing.borderWidth,
        radius: s.radius,
        dashLength: s.dashLength,
        dashGap: s.dashGap,
        child: result,
      );
    }
    return result;
  }
}

/// 骨架条：占位用的浅灰圆角条。[widthFactor] 为占可用宽度的比例。
class RaSkeleton extends StatelessWidget {
  const RaSkeleton({super.key, this.widthFactor = 1, this.height});

  final double widthFactor;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final RaStateBlockThemeData s = RaTheme.of(context).stateBlock;
    return FractionallySizedBox(
      alignment: AlignmentDirectional.centerStart,
      widthFactor: widthFactor,
      child: Container(
        height: height ?? s.skeletonHeight,
        decoration: BoxDecoration(
          color: s.skeletonColor,
          borderRadius: BorderRadius.circular(s.skeletonRadius),
        ),
      ),
    );
  }
}

/// 加载中：三行骨架；读屏读出 [label]（默认「正在加载…」）。
class RaLoadingState extends StatelessWidget {
  const RaLoadingState({super.key, this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    final RaStateBlockThemeData s = RaTheme.of(context).stateBlock;
    return Semantics(
      liveRegion: true,
      label: label ?? RaLocalizations.of(context).loading,
      excludeSemantics: true,
      child: _StateFrame(
        backgroundColor: s.loadingBackgroundColor,
        borderColor: s.loadingBorderColor,
        children: <Widget>[for (final double w in s.skeletonWidths) RaSkeleton(widthFactor: w)],
      ),
    );
  }
}

/// 空状态：虚线框、标题、可选说明与操作。
class RaEmptyState extends StatelessWidget {
  const RaEmptyState({super.key, required this.title, this.description, this.action});

  final String title;
  final Widget? description;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final RaStateBlockThemeData s = RaTheme.of(context).stateBlock;
    return _StateFrame(
      borderColor: s.emptyBorderColor,
      dashed: true,
      children: <Widget>[
        Text(title, style: s.titleStyle),
        if (description != null) DefaultTextStyle(style: s.textStyle, child: description!),
        if (action != null)
          Padding(
            padding: EdgeInsets.only(top: s.actionTopGap),
            child: action,
          ),
      ],
    );
  }
}

/// 失败状态：标题（默认「加载失败」）、原因，可选「重试」（[retrying] 时显示转圈）。
class RaErrorState extends StatelessWidget {
  const RaErrorState({
    super.key,
    required this.message,
    this.title,
    this.onRetry,
    this.retrying = false,
  });

  final String message;
  final String? title;
  final VoidCallback? onRetry;
  final bool retrying;

  @override
  Widget build(BuildContext context) {
    final RaStateBlockThemeData s = RaTheme.of(context).stateBlock;
    final RaLocalizations l = RaLocalizations.of(context);
    return Semantics(
      liveRegion: true,
      container: true,
      child: _StateFrame(
        backgroundColor: s.errorBackgroundColor,
        borderColor: s.errorBorderColor,
        children: <Widget>[
          Text(title ?? l.loadFailed, style: s.titleStyle.copyWith(color: s.errorTitleColor)),
          Text(message, style: s.textStyle),
          if (onRetry != null)
            Padding(
              padding: EdgeInsets.only(top: s.actionTopGap),
              child: RaButton(
                size: RaButtonSize.sm,
                onPressed: onRetry,
                loading: retrying,
                child: Text(retrying ? l.retrying : l.retry),
              ),
            ),
        ],
      ),
    );
  }
}
