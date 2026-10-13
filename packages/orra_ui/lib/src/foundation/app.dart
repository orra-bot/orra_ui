import 'package:flutter/widgets.dart';

import '../components/scrollbar.dart';
import '../components/toast.dart';
import '../theme/theme.dart';
import '../theme/theme_data.dart';
import '../tokens/colors.dart';
import 'localizations.dart';

/// 浅色 / 深色 / 跟随系统。
enum RaThemeMode { system, light, dark }

/// 应用根：只依赖 widgets 层（不引入 Material / Cupertino）。
///
/// 负责主题（跟随系统深浅）、默认文字样式与选区颜色、滚动条、提示视口、组件文案。
/// 桌面页面切换没有转场动画。
class RaApp extends StatelessWidget {
  const RaApp({
    super.key,
    this.title = '',
    this.theme,
    this.darkTheme,
    this.themeMode = RaThemeMode.system,
    this.home,
    this.routes = const <String, WidgetBuilder>{},
    this.initialRoute,
    this.onGenerateRoute,
    this.navigatorKey,
    this.navigatorObservers = const <NavigatorObserver>[],
    this.builder,
    this.locale,
    this.localizationsDelegates = const <LocalizationsDelegate<dynamic>>[],
    this.supportedLocales = RaLocalizations.supportedLocales,
    this.shortcuts,
    this.actions,
    this.toastController,
    this.debugShowCheckedModeBanner = true,
  });

  final String title;

  /// 浅色主题，默认 [RaThemeData.light]。
  final RaThemeData? theme;

  /// 深色主题，默认 [RaThemeData.dark]。
  final RaThemeData? darkTheme;
  final RaThemeMode themeMode;
  final Widget? home;
  final Map<String, WidgetBuilder> routes;
  final String? initialRoute;
  final RouteFactory? onGenerateRoute;
  final GlobalKey<NavigatorState>? navigatorKey;
  final List<NavigatorObserver> navigatorObservers;
  final TransitionBuilder? builder;
  final Locale? locale;
  final Iterable<LocalizationsDelegate<dynamic>> localizationsDelegates;
  final Iterable<Locale> supportedLocales;
  final Map<ShortcutActivator, Intent>? shortcuts;
  final Map<Type, Action<Intent>>? actions;
  final RaToastController? toastController;
  final bool debugShowCheckedModeBanner;

  RaThemeData _resolveTheme(BuildContext context) {
    final bool dark = switch (themeMode) {
      RaThemeMode.light => false,
      RaThemeMode.dark => true,
      RaThemeMode.system => MediaQuery.platformBrightnessOf(context) == Brightness.dark,
    };
    return dark ? (darkTheme ?? RaThemeData.dark()) : (theme ?? RaThemeData.light());
  }

  @override
  Widget build(BuildContext context) {
    final bool hasNavigator = home != null || routes.isNotEmpty || onGenerateRoute != null;
    return WidgetsApp(
      title: title,
      color: const RaColors.light().accent,
      navigatorKey: navigatorKey,
      navigatorObservers: hasNavigator ? navigatorObservers : const <NavigatorObserver>[],
      home: home,
      routes: routes,
      initialRoute: initialRoute,
      onGenerateRoute: onGenerateRoute,
      pageRouteBuilder: hasNavigator
          ? <T>(RouteSettings settings, WidgetBuilder builder) => PageRouteBuilder<T>(
              settings: settings,
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
              pageBuilder: (BuildContext context, _, _) => builder(context),
            )
          : null,
      locale: locale,
      localizationsDelegates: <LocalizationsDelegate<dynamic>>[
        ...localizationsDelegates,
        RaLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      supportedLocales: supportedLocales,
      shortcuts: shortcuts,
      actions: actions,
      debugShowCheckedModeBanner: debugShowCheckedModeBanner,
      builder: (BuildContext context, Widget? child) {
        final RaThemeData data = _resolveTheme(context);
        Widget result = child ?? const SizedBox.shrink();
        if (builder != null) result = builder!(context, result);
        return RaTheme(
          data: data,
          child: RaThemeScope(
            child: RaToastViewport(controller: toastController, child: result),
          ),
        );
      },
    );
  }
}

/// 把主题落到 widgets 层的默认值上：文字样式、图标、选区颜色、滚动条、底色。
///
/// RaApp 已内置；嵌入到其他 App（例如 MaterialApp）时可手动包一层。
class RaThemeScope extends StatelessWidget {
  const RaThemeScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final RaThemeData theme = RaTheme.of(context);
    return ColoredBox(
      color: theme.colors.ground,
      child: DefaultTextStyle(
        style: theme.typography.body.copyWith(color: theme.colors.ink),
        child: IconTheme(
          data: IconThemeData(color: theme.colors.ink, size: theme.sizing.iconSm),
          child: DefaultSelectionStyle(
            cursorColor: theme.field.cursorColor,
            selectionColor: theme.field.selectionColor,
            child: ScrollConfiguration(behavior: const RaScrollBehavior(), child: child),
          ),
        ),
      ),
    );
  }
}
