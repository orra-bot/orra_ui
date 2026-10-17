import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../foundation/localizations.dart';
import '../foundation/motion.dart';
import '../foundation/pressable.dart';
import '../theme/theme.dart';
import '../theme/theme_data.dart';
import '../tokens/components.dart';
import 'button.dart';

/// 从窗口右侧滑出一个抽屉（窄窗口下的侧栏 / 详情）。点击遮罩或按 Esc 关闭。
///
/// [builder] 通常返回 [RaDrawer]。
Future<T?> showRaDrawer<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
}) {
  final RaThemeData theme = RaTheme.of(context);
  return Navigator.of(context, rootNavigator: useRootNavigator).push<T>(
    RaDrawerRoute<T>(
      builder: builder,
      theme: theme,
      barrierDismissible: barrierDismissible,
      barrierLabel: RaLocalizations.of(context).close,
      duration: RaReducedMotion.resolve(context, theme.drawer.duration),
      settings: routeSettings,
    ),
  );
}

/// 抽屉路由：遮罩淡入，面板从右侧滑入（RTL 下从左侧）。
class RaDrawerRoute<T> extends PopupRoute<T> {
  RaDrawerRoute({
    required this.builder,
    required this.theme,
    required this.duration,
    this.barrierDismissible = true,
    this.barrierLabel,
    super.settings,
  });

  final WidgetBuilder builder;
  final RaThemeData theme;
  final Duration duration;

  @override
  final bool barrierDismissible;

  @override
  final String? barrierLabel;

  @override
  Color? get barrierColor => theme.drawer.barrierColor;

  @override
  Duration get transitionDuration => duration;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondary) {
    return RaTheme(
      data: theme,
      child: Builder(builder: builder),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(rtl ? -1 : 1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: theme.drawer.curve)),
      child: child,
    );
  }
}

/// 抽屉面板：标题 + 「关闭」按钮，下方内容可滚动。宽 min(360, 窗口宽 × 92%)，贴窗口右缘、撑满高度。
class RaDrawer extends StatelessWidget {
  const RaDrawer({super.key, required this.title, required this.child, this.width});

  final String title;
  final Widget child;

  /// 覆盖默认宽度上限。
  final double? width;

  @override
  Widget build(BuildContext context) {
    final RaThemeData theme = RaTheme.of(context);
    final RaDrawerThemeData d = theme.drawer;
    final double screen = MediaQuery.sizeOf(context).width;
    final double panelWidth = math.min(width ?? d.width, screen * d.maxWidthFraction);
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: RaNoDragRegion(
        child: SizedBox(
          width: panelWidth,
          height: double.infinity,
          child: Semantics(
            scopesRoute: true,
            namesRoute: true,
            explicitChildNodes: true,
            label: title,
            child: DecoratedBox(
              decoration: BoxDecoration(color: d.backgroundColor, boxShadow: d.shadows),
              child: Padding(
                padding: EdgeInsets.all(d.padding),
                child: DefaultTextStyle(
                  style: theme.typography.body.copyWith(color: theme.colors.ink),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: d.gap,
                    children: <Widget>[
                      Row(
                        spacing: theme.spacing.sm,
                        children: <Widget>[
                          Expanded(
                            child: Semantics(header: true, child: Text(title, style: d.titleStyle)),
                          ),
                          RaButton(
                            variant: RaButtonVariant.quiet,
                            size: RaButtonSize.sm,
                            onPressed: () => Navigator.maybePop(context),
                            child: Text(RaLocalizations.of(context).close),
                          ),
                        ],
                      ),
                      Expanded(child: SingleChildScrollView(child: child)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
