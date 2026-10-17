// 设计变量 · 第二层：语义（Semantic）· 字体、间距、圆角、线宽与图标、阴影、动效。
//
// 只引用基础层，不写字面量。阴影是唯一随明暗变化的非颜色变量（RaShadows.light / dark）。

import 'package:flutter/animation.dart' show Curve;
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'primitives.dart';

/// 字体角色与刻度。
///
/// 行高与字号都用像素描述（与设计稿一致），[style] 负责换算成 Flutter 的倍数行高，
/// 并使用均分行距（与 CSS 一致），保证文字在行内垂直居中。
@immutable
class RaTypography {
  const RaTypography({
    this.fontFamily = RaFontScale.familyInter,
    this.fontPackage = RaFontScale.familyInterPackage,
    this.fontFamilyFallback = RaFontScale.familySansFallback,
    this.monoFamily = RaFontScale.familySystemMono,
    this.monoFamilyFallback = RaFontScale.familyMonoFallback,
    this.size2xs = RaFontScale.size11,
    this.sizeXs = RaFontScale.size12,
    this.sizeSm = RaFontScale.size13,
    this.sizeMd = RaFontScale.size14,
    this.sizeLg = RaFontScale.size15,
    this.sizeXl = RaFontScale.size16,
    this.size2xl = RaFontScale.size18,
    this.size3xl = RaFontScale.size22,
    this.size4xl = RaFontScale.size26,
    this.sizeDisplay = RaFontScale.size24,
    this.lineHeightXs = RaFontScale.lineHeight18,
    this.lineHeightSm = RaFontScale.lineHeight20,
    this.lineHeightMd = RaFontScale.lineHeight22,
    this.lineHeightLg = RaFontScale.lineHeight24,
    this.lineHeightXl = RaFontScale.lineHeight26,
    this.lineHeight2xl = RaFontScale.lineHeight30,
    this.lineHeight3xl = RaFontScale.lineHeight34,
    this.lineHeightDisplay = RaFontScale.lineHeight32,
    this.weightRegular = RaFontScale.weight450,
    this.weightMedium = RaFontScale.weight500,
    this.weightSemibold = RaFontScale.weight600,
    this.weightBold = RaFontScale.weight700,
    this.letterSpacingTightEm = RaFontScale.letterSpacingNeg1Em,
    this.letterSpacingDisplay = RaFontScale.letterSpacingNeg016,
  });

  /// 字体族；默认 Inter（随包打包）。换成系统字体时把 [fontPackage] 设为 null。
  final String fontFamily;
  final String? fontPackage;
  final List<String> fontFamilyFallback;
  final String monoFamily;
  final List<String> monoFamilyFallback;

  final double size2xs;
  final double sizeXs;
  final double sizeSm;
  final double sizeMd;
  final double sizeLg;
  final double sizeXl;
  final double size2xl;
  final double size3xl;
  final double size4xl;
  final double sizeDisplay;

  final double lineHeightXs;
  final double lineHeightSm;
  final double lineHeightMd;
  final double lineHeightLg;
  final double lineHeightXl;
  final double lineHeight2xl;
  final double lineHeight3xl;
  final double lineHeightDisplay;

  final FontWeight weightRegular;
  final FontWeight weightMedium;
  final FontWeight weightSemibold;
  final FontWeight weightBold;

  /// 紧凑字距（相对字号，-0.01em）。
  final double letterSpacingTightEm;

  /// 页面大标题字距（像素）。
  final double letterSpacingDisplay;

  /// 由刻度组合出一个文字样式。[lineHeight] 为像素行高。
  TextStyle style({
    required double size,
    required double lineHeight,
    FontWeight? weight,
    Color? color,
    double? letterSpacing,
    bool tabularFigures = false,
    bool mono = false,
  }) {
    final FontWeight w = weight ?? weightRegular;
    return TextStyle(
      inherit: false,
      fontFamily: mono ? monoFamily : fontFamily,
      package: mono ? null : fontPackage,
      fontFamilyFallback: mono ? monoFamilyFallback : fontFamilyFallback,
      fontSize: size,
      height: lineHeight / size,
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: w,
      fontVariations: <FontVariation>[FontVariation.weight(w.value.toDouble())],
      fontFeatures: tabularFigures ? const <FontFeature>[FontFeature.tabularFigures()] : null,
      letterSpacing: letterSpacing,
      color: color,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none,
    );
  }

  // ---------- 文字角色 ----------

  /// 正文 13 / 20、450。
  TextStyle get body => style(size: sizeSm, lineHeight: lineHeightSm);

  /// 强调正文 13 / 20、500（按钮、导航行）。
  TextStyle get bodyMedium => style(size: sizeSm, lineHeight: lineHeightSm, weight: weightMedium);

  /// 说明、分组标题 12 / 18。
  TextStyle get caption => style(size: sizeXs, lineHeight: lineHeightXs);

  TextStyle get captionMedium =>
      style(size: sizeXs, lineHeight: lineHeightXs, weight: weightMedium);

  /// 提示气泡 11 / 18。
  TextStyle get micro => style(size: size2xs, lineHeight: lineHeightXs);

  /// 快捷键 11、500、等宽数字。
  TextStyle get kbd =>
      style(size: size2xs, lineHeight: lineHeightXs, weight: weightMedium, tabularFigures: true);

  /// 大号正文 14 / 22（大按钮）。
  TextStyle get bodyLarge => style(size: sizeMd, lineHeight: lineHeightMd, weight: weightMedium);

  /// 输入框正文 15 / 24。
  TextStyle get input => style(size: sizeLg, lineHeight: lineHeightLg);

  /// 小节标题 15 / 22、600（对话框标题）。
  TextStyle get title => style(size: sizeLg, lineHeight: lineHeightMd, weight: weightSemibold);

  /// 页面大标题 24 / 32、500，字距 -0.16px。
  TextStyle get display => style(
    size: sizeDisplay,
    lineHeight: lineHeightDisplay,
    weight: weightMedium,
    letterSpacing: letterSpacingDisplay,
  );

  /// 等宽 13 / 20。
  TextStyle get mono => style(size: sizeSm, lineHeight: lineHeightSm, mono: true);

  RaTypography copyWith({
    String? fontFamily,
    String? fontPackage,
    bool clearFontPackage = false,
    List<String>? fontFamilyFallback,
    String? monoFamily,
    List<String>? monoFamilyFallback,
    FontWeight? weightRegular,
    FontWeight? weightMedium,
    FontWeight? weightSemibold,
    FontWeight? weightBold,
  }) {
    return RaTypography(
      fontFamily: fontFamily ?? this.fontFamily,
      fontPackage: clearFontPackage ? null : (fontPackage ?? this.fontPackage),
      fontFamilyFallback: fontFamilyFallback ?? this.fontFamilyFallback,
      monoFamily: monoFamily ?? this.monoFamily,
      monoFamilyFallback: monoFamilyFallback ?? this.monoFamilyFallback,
      size2xs: size2xs,
      sizeXs: sizeXs,
      sizeSm: sizeSm,
      sizeMd: sizeMd,
      sizeLg: sizeLg,
      sizeXl: sizeXl,
      size2xl: size2xl,
      size3xl: size3xl,
      size4xl: size4xl,
      sizeDisplay: sizeDisplay,
      lineHeightXs: lineHeightXs,
      lineHeightSm: lineHeightSm,
      lineHeightMd: lineHeightMd,
      lineHeightLg: lineHeightLg,
      lineHeightXl: lineHeightXl,
      lineHeight2xl: lineHeight2xl,
      lineHeight3xl: lineHeight3xl,
      lineHeightDisplay: lineHeightDisplay,
      weightRegular: weightRegular ?? this.weightRegular,
      weightMedium: weightMedium ?? this.weightMedium,
      weightSemibold: weightSemibold ?? this.weightSemibold,
      weightBold: weightBold ?? this.weightBold,
      letterSpacingTightEm: letterSpacingTightEm,
      letterSpacingDisplay: letterSpacingDisplay,
    );
  }
}

/// 间距刻度：3xs 2 · 2xs 4 · xs 6 · sm 8 · md 10 · lg 12 · xl 16 · 2xl 20 · 3xl 24 · 4xl 32 · 5xl 40。
@immutable
class RaSpacing {
  const RaSpacing({
    this.xs3 = RaSizes.s2,
    this.xs2 = RaSizes.s4,
    this.xs = RaSizes.s6,
    this.sm = RaSizes.s8,
    this.md = RaSizes.s10,
    this.lg = RaSizes.s12,
    this.xl = RaSizes.s16,
    this.xl2 = RaSizes.s20,
    this.xl3 = RaSizes.s24,
    this.xl4 = RaSizes.s32,
    this.xl5 = RaSizes.s40,
  });

  final double xs3;
  final double xs2;
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xl2;
  final double xl3;
  final double xl4;
  final double xl5;
}

/// 圆角刻度：xs 2 · sm 6 · md 8 · lg 10 · xl 12 · 2xl 14 · 3xl 16 · pill。
@immutable
class RaRadii {
  const RaRadii({
    this.xs = RaSizes.s2,
    this.sm = RaSizes.s6,
    this.md = RaSizes.s8,
    this.lg = RaSizes.s10,
    this.xl = RaSizes.s12,
    this.xl2 = RaSizes.s14,
    this.xl3 = RaSizes.s16,
    this.pill = RaSizes.s999,
  });

  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xl2;
  final double xl3;

  /// 胶囊（足够大的圆角，Flutter 会按短边一半裁切）。
  final double pill;

  RaRadii copyWith({double? sm, double? md, double? lg, double? xl}) => RaRadii(
    xs: xs,
    sm: sm ?? this.sm,
    md: md ?? this.md,
    lg: lg ?? this.lg,
    xl: xl ?? this.xl,
    xl2: xl2,
    xl3: xl3,
    pill: pill,
  );
}

/// 线宽与图标尺寸。
@immutable
class RaSizing {
  const RaSizing({
    this.borderWidth = RaSizes.s0_5,
    this.icon2xs = RaSizes.s10,
    this.iconXs = RaSizes.s12,
    this.iconSm = RaSizes.s14,
    this.iconMd = RaSizes.s16,
    this.iconLg = RaSizes.s18,
    this.iconSlot = RaSizes.s16,
    this.iconStrokeThin = RaNumbers.stroke1_5,
    this.iconStroke = RaNumbers.stroke2,
    this.iconStrokeBold = RaNumbers.stroke2_5,
  });

  /// 细线：Retina 上为 1 物理像素；1 倍屏取整为 1px（见 RaHairline）。
  final double borderWidth;

  final double icon2xs;
  final double iconXs;

  /// 默认图标 14px。
  final double iconSm;
  final double iconMd;
  final double iconLg;

  /// 图标位：14px 图标放进 16px 的位里居中。
  final double iconSlot;

  /// 图标线宽，以 24 网格为单位（Lucide 默认 2；14px 下约 1.17px）。
  final double iconStrokeThin;
  final double iconStroke;
  final double iconStrokeBold;
}

/// 阴影（Linear：极淡的双层 / 三层阴影，配合 0.5px 描边）。
@immutable
class RaShadows {
  const RaShadows({
    required this.raised,
    required this.popup,
    required this.dialog,
    required this.spotlight,
  });

  RaShadows.light()
    : raised = _raised,
      popup = <BoxShadow>[
        RaShadowMath.css(0, RaSizes.s6, RaSizes.s18, 0, RaPalette.blackA2),
        RaShadowMath.css(0, RaSizes.s3, RaSizes.s9, 0, RaPalette.blackA4),
        RaShadowMath.css(0, RaSizes.s1, RaSizes.s1, 0, RaPalette.blackA4),
      ],
      dialog = <BoxShadow>[
        RaShadowMath.css(0, RaSizes.s24, RaSizes.s48, 0, RaPalette.blackA12),
        RaShadowMath.css(0, RaSizes.s1, RaSizes.s1, 0, RaPalette.blackA4),
      ],
      spotlight = _spotlight;

  RaShadows.dark()
    : raised = _raised,
      popup = <BoxShadow>[
        RaShadowMath.css(0, RaSizes.s6, RaSizes.s18, 0, RaPalette.blackA24),
        RaShadowMath.css(0, RaSizes.s1, RaSizes.s1, 0, RaPalette.blackA40),
      ],
      dialog = <BoxShadow>[RaShadowMath.css(0, RaSizes.s24, RaSizes.s48, 0, RaPalette.blackA55)],
      spotlight = _spotlight;

  static final List<BoxShadow> _raised = <BoxShadow>[
    RaShadowMath.css(0, RaSizes.s3, RaSizes.s6, RaSizes.neg2, RaPalette.blackA2),
    RaShadowMath.css(0, RaSizes.s1, RaSizes.s1, 0, RaPalette.blackA4),
  ];

  static final List<BoxShadow> _spotlight = <BoxShadow>[
    RaShadowMath.css(0, RaSizes.s24, RaSizes.s64, 0, RaPalette.blackA20),
    RaShadowMath.css(0, RaSizes.s1, RaSizes.s1, 0, RaPalette.blackA4),
  ];

  /// 面板、输入框、提示、按钮。
  final List<BoxShadow> raised;

  /// 菜单、通知。
  final List<BoxShadow> popup;

  /// 对话框。
  final List<BoxShadow> dialog;

  /// 命令面板。
  final List<BoxShadow> spotlight;
}

/// 动效：时长、缓动、浮层缩放。
@immutable
class RaMotion {
  const RaMotion({
    this.instant = RaDurations.ms0,
    this.fast = RaDurations.ms50,
    this.base = RaDurations.ms75,
    this.slow = RaDurations.ms125,
    this.layout = RaDurations.ms150,
    this.spin = RaDurations.ms800,
    this.emphasized = RaCurves.outExpo,
    this.scalePop = RaNumbers.scale96,
    this.scalePopSubtle = RaNumbers.scale98,
  });

  /// 悬停出现。
  final Duration instant;

  /// 按下、颜色变化。
  final Duration fast;

  /// 悬停消失、浮层淡入淡出。
  final Duration base;

  /// 浮层进出、标签让位。
  final Duration slow;

  /// 侧栏 / 右侧栏开合、标题栏留位。
  final Duration layout;

  /// 加载转圈一圈。
  final Duration spin;

  /// 布局动画缓动 cubic-bezier(0.22, 1, 0.36, 1)。
  final Curve emphasized;

  /// 浮层进场缩放。
  final double scalePop;
  final double scalePopSubtle;
}

/// 透明度。
@immutable
class RaOpacity {
  const RaOpacity({this.disabled = RaNumbers.opacity60, this.secondary = RaNumbers.opacity70});

  final double disabled;
  final double secondary;
}
