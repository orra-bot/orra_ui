// 设计变量 · 第一层：基础（Primitive）。
//
// 只描述「值本身」（某个灰、某个尺寸），不描述用途；也是唯一允许出现字面量的一层。
// 组件不得直接引用本层，必须经语义层（RaColors、RaSpacing……）或组件层（RaButtonThemeData……）。
// 守护规则见 orra_guardrails。

import 'dart:math' as math;
import 'dart:ui' show Color, FontWeight, Offset;

import 'package:flutter/animation.dart' show Cubic;
import 'package:flutter/painting.dart' show BoxShadow;

/// 色板。数字越大越深；`a*` 后缀为透明度色（如 `blackA6` = 黑 6%）。取值对照 Linear。
abstract final class RaPalette {
  static const Color white = Color(0xFFFFFFFF);
  static const Color transparent = Color(0x00000000);

  // 中性灰（几乎无色相）
  static const Color gray10 = Color(0xFFF7F8F8);
  static const Color gray25 = Color(0xFFF9F9FA);
  static const Color gray50 = Color(0xFFEFEFF0);
  static const Color gray75 = Color(0xFFE8E8E8);
  static const Color gray100 = Color(0xFFE2E2E2);
  static const Color gray150 = Color(0xFFD3D3D3);
  static const Color gray400 = Color(0xFF9C9D9F);
  static const Color gray450 = Color(0xFF8A8A8E);
  static const Color gray550 = Color(0xFF6F6F74);
  static const Color gray600 = Color(0xFF5C5C5E);
  static const Color gray750 = Color(0xFF2E2F32);
  static const Color gray800 = Color(0xFF28282B);
  static const Color gray850 = Color(0xFF212224);
  static const Color gray875 = Color(0xFF1E1E20);
  static const Color gray900 = Color(0xFF1B1B1B);
  static const Color gray925 = Color(0xFF19191B);
  static const Color gray950 = Color(0xFF121213);
  static const Color gray975 = Color(0xFF09090A);

  // 靛蓝（默认强调色）
  static const Color indigo50 = Color(0xFFECEDFA);
  static const Color indigo200 = Color(0xFFB5BBF5);
  static const Color indigo300 = Color(0xFF8F98EA);
  static const Color indigo400 = Color(0xFF7A84E0);
  static const Color indigo500 = Color(0xFF6D78D5);
  static const Color indigo600 = Color(0xFF5E6AC1);
  static const Color indigo900 = Color(0xFF23253F);
  // 文本选区（强调色 24% / 40%）
  static const Color indigo500A24 = Color(0x3D6D78D5);
  static const Color indigo400A40 = Color(0x667A84E0);

  // 绿 / 橙 / 红（状态）
  static const Color green50 = Color(0xFFE3F2EA);
  static const Color green300 = Color(0xFF7FD6A6);
  static const Color green700 = Color(0xFF1F7A4D);
  static const Color green900 = Color(0xFF1C3A2B);

  static const Color orange25 = Color(0xFFFDF7F0);
  static const Color orange50 = Color(0xFFFBEEDF);
  static const Color orange300 = Color(0xFFF3B27A);
  static const Color orange700 = Color(0xFFB4530A);
  static const Color orange800 = Color(0xFFA04A08);
  static const Color orange900 = Color(0xFF3A2614);
  static const Color orange950 = Color(0xFF241A10);

  static const Color red25 = Color(0xFFFDF6F5);
  static const Color red150 = Color(0xFFE9B8B4);
  static const Color red200 = Color(0xFFFFB1AA);
  static const Color red300 = Color(0xFFFF8A80);
  static const Color red600 = Color(0xFFC0322B);
  static const Color red800 = Color(0xFF8E241F);
  static const Color red850 = Color(0xFF6B2B27);
  static const Color red950 = Color(0xFF241413);

  // 数据可视化
  static const Color vizBlue250 = Color(0xFF86B6EF);
  static const Color vizBlue350 = Color(0xFF5598E7);
  static const Color vizBlue400 = Color(0xFF3987E5);
  static const Color vizBlue450 = Color(0xFF2A78D6);
  static const Color vizBlue500 = Color(0xFF256ABF);
  static const Color vizBlue600 = Color(0xFF184F95);
  static const Color vizBlue650 = Color(0xFF104281);
  static const Color vizOrange500 = Color(0xFFEB6834);
  static const Color vizOrange600 = Color(0xFFD95926);

  // 透明度色（叠加、阴影、遮罩）
  static const Color blackA2 = Color(0x05000000);
  static const Color blackA3_5 = Color(0x09000000);
  static const Color blackA4 = Color(0x0A000000);
  static const Color blackA6 = Color(0x0F000000);
  static const Color blackA8 = Color(0x14000000);
  static const Color blackA12 = Color(0x1F000000);
  static const Color blackA20 = Color(0x33000000);
  static const Color blackA24 = Color(0x3D000000);
  static const Color blackA40 = Color(0x66000000);
  static const Color blackA55 = Color(0x8C000000);
  static const Color whiteA4 = Color(0x0AFFFFFF);
  static const Color whiteA6 = Color(0x0FFFFFFF);
  static const Color whiteA8 = Color(0x14FFFFFF);
  static const Color whiteA10 = Color(0x1AFFFFFF);
  static const Color gray400A45 = Color(0x739C9D9F);

  // Windows / Linux 窗口关闭按钮悬停（系统惯例红）
  static const Color closeRed = Color(0xFFE81123);
}

/// 像素刻度（间距、尺寸、圆角共用），单位为逻辑像素。
abstract final class RaSizes {
  static const double s0_5 = 0.5;
  static const double s1 = 1;
  static const double s2 = 2;
  static const double s3 = 3;
  static const double s4 = 4;
  static const double s5 = 5;
  static const double s6 = 6;
  static const double s7 = 7;
  static const double s8 = 8;
  static const double s9 = 9;
  static const double s10 = 10;
  static const double s12 = 12;
  static const double s14 = 14;
  static const double s16 = 16;
  static const double s18 = 18;
  static const double s20 = 20;
  static const double s22 = 22;
  static const double s24 = 24;
  static const double s28 = 28;
  static const double s32 = 32;
  static const double s36 = 36;
  static const double s40 = 40;
  static const double s44 = 44;
  static const double s48 = 48;
  static const double s64 = 64;
  static const double s88 = 88;
  static const double s999 = 999;
  static const double neg2 = -2;
}

/// 字体、字号、行高、字重刻度。
abstract final class RaFontScale {
  /// Inter（随 orra_ui 打包的可变字体，不请求网络）。
  static const String familyInter = 'Inter';
  static const String familyInterPackage = 'orra_ui';

  /// 中文与系统回落：macOS 苹方 / 冬青，Windows 微软雅黑，Linux Noto CJK。
  static const List<String> familySansFallback = <String>[
    'PingFang SC',
    'Hiragino Sans GB',
    'Segoe UI',
    'Microsoft YaHei',
    'Noto Sans CJK SC',
    'Noto Sans SC',
  ];

  static const String familySystemMono = 'Menlo';
  static const List<String> familyMonoFallback = <String>[
    'SF Mono',
    'Consolas',
    'DejaVu Sans Mono',
    'Noto Sans Mono',
  ];

  static const double size11 = 11;
  static const double size12 = 12;
  static const double size13 = 13;
  static const double size14 = 14;
  static const double size15 = 15;
  static const double size16 = 16;
  static const double size18 = 18;
  static const double size22 = 22;
  static const double size24 = 24;
  static const double size26 = 26;

  static const double lineHeight18 = 18;
  static const double lineHeight20 = 20;
  static const double lineHeight22 = 22;
  static const double lineHeight24 = 24;
  static const double lineHeight26 = 26;
  static const double lineHeight30 = 30;
  static const double lineHeight32 = 32;
  static const double lineHeight34 = 34;

  static const FontWeight weight450 = FontWeight(450);
  static const FontWeight weight500 = FontWeight(500);
  static const FontWeight weight600 = FontWeight(600);
  static const FontWeight weight700 = FontWeight(700);

  /// 字距：-0.01em（按字号换算）与 -0.16px。
  static const double letterSpacingNeg1Em = -0.01;
  static const double letterSpacingNeg016 = -0.16;
}

/// 时长（毫秒）与缓动。
abstract final class RaDurations {
  static const Duration ms0 = Duration.zero;
  static const Duration ms100 = Duration(milliseconds: 100);
  static const Duration ms150 = Duration(milliseconds: 150);
  static const Duration ms250 = Duration(milliseconds: 250);
  static const Duration ms300 = Duration(milliseconds: 300);
  static const Duration ms600 = Duration(milliseconds: 600);
  static const Duration ms800 = Duration(milliseconds: 800);
  static const Duration s5 = Duration(seconds: 5);
}

abstract final class RaCurves {
  /// cubic-bezier(0.22, 1, 0.36, 1)
  static const Cubic outExpo = Cubic(0.22, 1, 0.36, 1);
}

/// 缩放、透明度、线宽（图标网格单位）等其他数值。
abstract final class RaNumbers {
  static const double scale96 = 0.96;
  static const double scale98 = 0.98;
  static const double fraction2 = 0.02;
  static const double opacity60 = 0.6;
  static const double opacity70 = 0.7;
  static const double stroke1_5 = 1.5;
  static const double stroke2 = 2;
  static const double stroke2_5 = 2.5;
}

/// CSS 阴影换算。
abstract final class RaShadowMath {
  /// 把 CSS `box-shadow` 的模糊半径换算成 Flutter 的模糊半径，让两边的高斯 σ 相同
  /// （CSS：σ = blur / 2；Flutter：σ = blurRadius × 0.57735 + 0.5）。
  static BoxShadow css(double x, double y, double blur, double spread, Color color) {
    final double sigma = blur / 2;
    final double flutterBlur = math.max(0, (sigma - 0.5) / 0.57735);
    return BoxShadow(
      color: color,
      offset: Offset(x, y),
      blurRadius: flutterBlur,
      spreadRadius: spread,
    );
  }
}
