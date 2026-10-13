import 'package:flutter/widgets.dart';

import '../tokens/colors.dart';
import '../tokens/components.dart';
import '../tokens/semantic.dart';

/// 主题扩展：应用或其他包（如 orra_desktop_shell）登记自己的组件变量。
///
/// 读取时若主题里没有，就用 [RaThemeExtensionFactory] 从语义层推导默认值，
/// 因此扩展同样会随明暗、品牌色变化。
abstract class RaThemeExtension {
  const RaThemeExtension();

  /// 登记用的键，默认是运行时类型。
  Object get type => runtimeType;
}

typedef RaThemeExtensionFactory<T> = T Function(RaThemeData theme);

/// orra_ui 的主题：语义层（颜色、字体、间距……）+ 各组件变量 + 扩展。
///
/// ```dart
/// // 默认 Linear 风格
/// RaThemeData.light();
/// // 换品牌色
/// RaThemeData.light(colors: const RaColors.light(accent: Color(0xFF0E7C66), ...));
/// // 只改某个组件
/// final base = RaThemeData.light();
/// base.copyWith(button: base.button.withVariant(RaButtonVariant.primary, ...));
/// ```
@immutable
class RaThemeData {
  factory RaThemeData({
    Brightness brightness = Brightness.light,
    RaColors? colors,
    RaTypography? typography,
    RaSpacing? spacing,
    RaRadii? radii,
    RaSizing? sizing,
    RaShadows? shadows,
    RaMotion? motion,
    RaOpacity? opacity,
    RaIconSet? icons,
    RaChromeThemeData? chrome,
    RaButtonThemeData? button,
    RaFieldThemeData? field,
    RaTooltipThemeData? tooltip,
    RaMenuThemeData? menu,
    RaDialogThemeData? dialog,
    RaToastThemeData? toast,
    RaSidebarThemeData? sidebar,
    RaScrollbarThemeData? scrollbar,
    Iterable<RaThemeExtension> extensions = const <RaThemeExtension>[],
  }) {
    final bool dark = brightness == Brightness.dark;
    final RaTokens tokens = RaTokens(
      colors: colors ?? (dark ? const RaColors.dark() : const RaColors.light()),
      typography: typography ?? const RaTypography(),
      spacing: spacing ?? const RaSpacing(),
      radii: radii ?? const RaRadii(),
      sizing: sizing ?? const RaSizing(),
      shadows: shadows ?? (dark ? RaShadows.dark() : RaShadows.light()),
      motion: motion ?? const RaMotion(),
      opacity: opacity ?? const RaOpacity(),
    );
    return RaThemeData._(
      brightness: brightness,
      tokens: tokens,
      icons: icons ?? RaIconSet.fallback(),
      overrides: _ComponentOverrides(
        chrome: chrome,
        button: button,
        field: field,
        tooltip: tooltip,
        menu: menu,
        dialog: dialog,
        toast: toast,
        sidebar: sidebar,
        scrollbar: scrollbar,
      ),
      extensions: <Object, RaThemeExtension>{
        for (final RaThemeExtension e in extensions) e.type: e,
      },
    );
  }

  RaThemeData._({
    required this.brightness,
    required this.tokens,
    required this.icons,
    required _ComponentOverrides overrides,
    required Map<Object, RaThemeExtension> extensions,
  }) : _overrides = overrides,
       _extensions = Map<Object, RaThemeExtension>.unmodifiable(extensions),
       chrome = overrides.chrome ?? RaChromeThemeData.fallback(tokens),
       button = overrides.button ?? RaButtonThemeData.fallback(tokens),
       field = overrides.field ?? RaFieldThemeData.fallback(tokens),
       tooltip = overrides.tooltip ?? RaTooltipThemeData.fallback(tokens),
       menu = overrides.menu ?? RaMenuThemeData.fallback(tokens),
       dialog = overrides.dialog ?? RaDialogThemeData.fallback(tokens),
       toast = overrides.toast ?? RaToastThemeData.fallback(tokens),
       sidebar = overrides.sidebar ?? RaSidebarThemeData.fallback(tokens),
       scrollbar = overrides.scrollbar ?? RaScrollbarThemeData.fallback(tokens);

  /// 默认浅色主题（Linear 风格）。
  factory RaThemeData.light({
    RaColors? colors,
    RaTypography? typography,
    RaRadii? radii,
    RaIconSet? icons,
    Iterable<RaThemeExtension> extensions = const <RaThemeExtension>[],
  }) => RaThemeData(
    colors: colors,
    typography: typography,
    radii: radii,
    icons: icons,
    extensions: extensions,
  );

  /// 默认深色主题。
  factory RaThemeData.dark({
    RaColors? colors,
    RaTypography? typography,
    RaRadii? radii,
    RaIconSet? icons,
    Iterable<RaThemeExtension> extensions = const <RaThemeExtension>[],
  }) => RaThemeData(
    brightness: Brightness.dark,
    colors: colors,
    typography: typography,
    radii: radii,
    icons: icons,
    extensions: extensions,
  );

  final Brightness brightness;

  /// 语义层整体。
  final RaTokens tokens;
  final RaIconSet icons;

  final _ComponentOverrides _overrides;
  final Map<Object, RaThemeExtension> _extensions;

  RaColors get colors => tokens.colors;
  RaTypography get typography => tokens.typography;
  RaSpacing get spacing => tokens.spacing;
  RaRadii get radii => tokens.radii;
  RaSizing get sizing => tokens.sizing;
  RaShadows get shadows => tokens.shadows;
  RaMotion get motion => tokens.motion;
  RaOpacity get opacity => tokens.opacity;

  final RaChromeThemeData chrome;
  final RaButtonThemeData button;
  final RaFieldThemeData field;
  final RaTooltipThemeData tooltip;
  final RaMenuThemeData menu;
  final RaDialogThemeData dialog;
  final RaToastThemeData toast;
  final RaSidebarThemeData sidebar;
  final RaScrollbarThemeData scrollbar;

  /// 读取扩展；没有登记时用 [fallback] 从当前主题推导。
  T extension<T extends RaThemeExtension>(RaThemeExtensionFactory<T> fallback) {
    final RaThemeExtension? found = _extensions[T];
    return found is T ? found : fallback(this);
  }

  /// 修改语义层时，没有单独覆盖的组件主题会随之重新推导。
  RaThemeData copyWith({
    Brightness? brightness,
    RaColors? colors,
    RaTypography? typography,
    RaSpacing? spacing,
    RaRadii? radii,
    RaSizing? sizing,
    RaShadows? shadows,
    RaMotion? motion,
    RaOpacity? opacity,
    RaIconSet? icons,
    RaChromeThemeData? chrome,
    RaButtonThemeData? button,
    RaFieldThemeData? field,
    RaTooltipThemeData? tooltip,
    RaMenuThemeData? menu,
    RaDialogThemeData? dialog,
    RaToastThemeData? toast,
    RaSidebarThemeData? sidebar,
    RaScrollbarThemeData? scrollbar,
    Iterable<RaThemeExtension>? extensions,
  }) {
    return RaThemeData(
      brightness: brightness ?? this.brightness,
      colors: colors ?? tokens.colors,
      typography: typography ?? tokens.typography,
      spacing: spacing ?? tokens.spacing,
      radii: radii ?? tokens.radii,
      sizing: sizing ?? tokens.sizing,
      shadows: shadows ?? tokens.shadows,
      motion: motion ?? tokens.motion,
      opacity: opacity ?? tokens.opacity,
      icons: icons ?? this.icons,
      chrome: chrome ?? _overrides.chrome,
      button: button ?? _overrides.button,
      field: field ?? _overrides.field,
      tooltip: tooltip ?? _overrides.tooltip,
      menu: menu ?? _overrides.menu,
      dialog: dialog ?? _overrides.dialog,
      toast: toast ?? _overrides.toast,
      sidebar: sidebar ?? _overrides.sidebar,
      scrollbar: scrollbar ?? _overrides.scrollbar,
      extensions: extensions ?? _extensions.values,
    );
  }
}

@immutable
class _ComponentOverrides {
  const _ComponentOverrides({
    this.chrome,
    this.button,
    this.field,
    this.tooltip,
    this.menu,
    this.dialog,
    this.toast,
    this.sidebar,
    this.scrollbar,
  });

  final RaChromeThemeData? chrome;
  final RaButtonThemeData? button;
  final RaFieldThemeData? field;
  final RaTooltipThemeData? tooltip;
  final RaMenuThemeData? menu;
  final RaDialogThemeData? dialog;
  final RaToastThemeData? toast;
  final RaSidebarThemeData? sidebar;
  final RaScrollbarThemeData? scrollbar;
}
