// 设计变量 · 第二层：语义（Semantic）· 颜色。
//
// 描述「用途」，只引用基础层（RaPalette），不写字面量。
// 深色模式只在这一层重新赋值；组件层与组件代码不感知明暗。
//
// 本文件由脚本生成字段骨架，修改字段时请保持 light / dark / copyWith / == 同步。

import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show ColorProperty;

import 'primitives.dart';

/// 语义颜色。默认取值对照 Linear；换品牌色时改 [accent] 系列即可（见 [RaColors.light] 的参数）。
@immutable
class RaColors with Diagnosticable {
  const RaColors({
    required this.ground,
    required this.surface,
    required this.surfaceRaised,
    required this.sunken,
    required this.hover,
    required this.surfaceWindow,
    required this.surfaceCanvas,
    required this.surfaceInverse,
    required this.overlay,
    required this.fillTranslucentHover,
    required this.fillTranslucentSelected,
    required this.fillTranslucentActive,
    required this.borderTranslucent,
    required this.vizSeries1,
    required this.vizSeries2,
    required this.vizSeqEmpty,
    required this.vizSeq1,
    required this.vizSeq2,
    required this.vizSeq3,
    required this.vizSeq4,
    required this.border,
    required this.borderStrong,
    required this.borderCanvas,
    required this.borderPopover,
    required this.ink,
    required this.ink2,
    required this.ink3,
    required this.inkInverse,
    required this.inkWindow2,
    required this.inkWindow3,
    required this.accent,
    required this.accentHover,
    required this.accentSoft,
    required this.accentInk,
    required this.onAccent,
    required this.selection,
    required this.success,
    required this.successSoft,
    required this.attention,
    required this.attentionSoft,
    required this.attentionInk,
    required this.attentionWash,
    required this.danger,
    required this.dangerBorder,
    required this.dangerWash,
    required this.dangerInk,
    required this.onDanger,
    required this.disabledBg,
    required this.disabledInk,
    required this.scrollbarThumb,
    required this.windowCloseHover,
    required this.onWindowCloseHover,
  });

  /// 浅色（默认）。
  const RaColors.light({
    this.ground = RaPalette.gray50,
    this.surface = RaPalette.white,
    this.surfaceRaised = RaPalette.gray25,
    this.sunken = RaPalette.gray50,
    this.hover = RaPalette.blackA6,
    this.surfaceWindow = RaPalette.gray50,
    this.surfaceCanvas = RaPalette.gray25,
    this.surfaceInverse = RaPalette.gray900,
    this.overlay = RaPalette.blackA20,
    this.fillTranslucentHover = RaPalette.blackA3_5,
    this.fillTranslucentSelected = RaPalette.blackA6,
    this.fillTranslucentActive = RaPalette.blackA8,
    this.borderTranslucent = RaPalette.blackA8,
    this.vizSeries1 = RaPalette.vizBlue450,
    this.vizSeries2 = RaPalette.vizOrange500,
    this.vizSeqEmpty = RaPalette.gray75,
    this.vizSeq1 = RaPalette.vizBlue250,
    this.vizSeq2 = RaPalette.vizBlue350,
    this.vizSeq3 = RaPalette.vizBlue500,
    this.vizSeq4 = RaPalette.vizBlue650,
    this.border = RaPalette.gray100,
    this.borderStrong = RaPalette.gray150,
    this.borderCanvas = RaPalette.gray100,
    this.borderPopover = RaPalette.gray75,
    this.ink = RaPalette.gray900,
    this.ink2 = RaPalette.gray600,
    this.ink3 = RaPalette.gray400,
    this.inkInverse = RaPalette.white,
    this.inkWindow2 = RaPalette.gray600,
    this.inkWindow3 = RaPalette.gray400,
    this.accent = RaPalette.indigo500,
    this.accentHover = RaPalette.indigo600,
    this.accentSoft = RaPalette.indigo50,
    this.accentInk = RaPalette.indigo600,
    this.onAccent = RaPalette.white,
    this.selection = RaPalette.indigo500A24,
    this.success = RaPalette.green700,
    this.successSoft = RaPalette.green50,
    this.attention = RaPalette.orange700,
    this.attentionSoft = RaPalette.orange50,
    this.attentionInk = RaPalette.orange800,
    this.attentionWash = RaPalette.orange25,
    this.danger = RaPalette.red600,
    this.dangerBorder = RaPalette.red150,
    this.dangerWash = RaPalette.red25,
    this.dangerInk = RaPalette.red800,
    this.onDanger = RaPalette.white,
    this.disabledBg = RaPalette.gray75,
    this.disabledInk = RaPalette.gray400,
    this.scrollbarThumb = RaPalette.gray400A45,
    this.windowCloseHover = RaPalette.closeRed,
    this.onWindowCloseHover = RaPalette.white,
  });

  /// 深色：按同一层次单独选色，不是自动反转。
  const RaColors.dark({
    this.ground = RaPalette.gray975,
    this.surface = RaPalette.gray925,
    this.surfaceRaised = RaPalette.gray875,
    this.sunken = RaPalette.gray875,
    this.hover = RaPalette.whiteA6,
    this.surfaceWindow = RaPalette.gray975,
    this.surfaceCanvas = RaPalette.gray950,
    this.surfaceInverse = RaPalette.gray10,
    this.overlay = RaPalette.blackA55,
    this.fillTranslucentHover = RaPalette.whiteA4,
    this.fillTranslucentSelected = RaPalette.whiteA8,
    this.fillTranslucentActive = RaPalette.whiteA10,
    this.borderTranslucent = RaPalette.whiteA8,
    this.vizSeries1 = RaPalette.vizBlue400,
    this.vizSeries2 = RaPalette.vizOrange600,
    this.vizSeqEmpty = RaPalette.gray850,
    this.vizSeq1 = RaPalette.vizBlue600,
    this.vizSeq2 = RaPalette.vizBlue500,
    this.vizSeq3 = RaPalette.vizBlue400,
    this.vizSeq4 = RaPalette.vizBlue250,
    this.border = RaPalette.gray850,
    this.borderStrong = RaPalette.gray750,
    this.borderCanvas = RaPalette.gray850,
    this.borderPopover = RaPalette.gray800,
    this.ink = RaPalette.gray10,
    this.ink2 = RaPalette.gray450,
    this.ink3 = RaPalette.gray550,
    this.inkInverse = RaPalette.gray975,
    this.inkWindow2 = RaPalette.gray450,
    this.inkWindow3 = RaPalette.gray550,
    this.accent = RaPalette.indigo400,
    this.accentHover = RaPalette.indigo300,
    this.accentSoft = RaPalette.indigo900,
    this.accentInk = RaPalette.indigo200,
    this.onAccent = RaPalette.white,
    this.selection = RaPalette.indigo400A40,
    this.success = RaPalette.green300,
    this.successSoft = RaPalette.green900,
    this.attention = RaPalette.orange300,
    this.attentionSoft = RaPalette.orange900,
    this.attentionInk = RaPalette.orange300,
    this.attentionWash = RaPalette.orange950,
    this.danger = RaPalette.red300,
    this.dangerBorder = RaPalette.red850,
    this.dangerWash = RaPalette.red950,
    this.dangerInk = RaPalette.red200,
    this.onDanger = RaPalette.white,
    this.disabledBg = RaPalette.gray800,
    this.disabledInk = RaPalette.gray550,
    this.scrollbarThumb = RaPalette.gray400A45,
    this.windowCloseHover = RaPalette.closeRed,
    this.onWindowCloseHover = RaPalette.white,
  });

  /// 应用底色（窗口底）
  final Color ground;

  /// 卡片、浮层、输入框
  final Color surface;

  /// 比内容面板更亮一级的表面
  final Color surfaceRaised;

  /// 下沉面（气泡、代码）
  final Color sunken;

  /// 浅色表面上的悬停
  final Color hover;

  /// 窗口底（侧栏与内容面板四周）
  final Color surfaceWindow;

  /// 内容面板底
  final Color surfaceCanvas;

  /// 反色表面
  final Color surfaceInverse;

  /// 对话框遮罩
  final Color overlay;

  /// 半透明叠加：悬停
  final Color fillTranslucentHover;

  /// 半透明叠加：选中
  final Color fillTranslucentSelected;

  /// 半透明叠加：按下
  final Color fillTranslucentActive;

  /// 半透明描边
  final Color borderTranslucent;

  /// 数据可视化：类别色 1
  final Color vizSeries1;

  /// 数据可视化：类别色 2
  final Color vizSeries2;

  /// 热力图：空
  final Color vizSeqEmpty;

  /// 热力图：一级
  final Color vizSeq1;

  /// 热力图：二级
  final Color vizSeq2;

  /// 热力图：三级
  final Color vizSeq3;

  /// 热力图：四级
  final Color vizSeq4;

  /// 描边（细线）
  final Color border;

  /// 较强描边（悬停的输入框）
  final Color borderStrong;

  /// 内容面板描边
  final Color borderCanvas;

  /// 浮层（菜单、提示、对话框）描边
  final Color borderPopover;

  /// 正文
  final Color ink;

  /// 次要文字
  final Color ink2;

  /// 弱文字（占位、时间）
  final Color ink3;

  /// 反色文字
  final Color inkInverse;

  /// 窗口底上的次要文字
  final Color inkWindow2;

  /// 窗口底上的弱文字
  final Color inkWindow3;

  /// 强调（主操作、发送、选中）
  final Color accent;

  /// 强调悬停
  final Color accentHover;

  /// 强调浅底
  final Color accentSoft;

  /// 强调文字
  final Color accentInk;

  /// 强调底上的文字
  final Color onAccent;

  /// 文本选区
  final Color selection;

  /// 成功
  final Color success;

  /// 成功浅底
  final Color successSoft;

  /// 注意
  final Color attention;

  /// 注意浅底
  final Color attentionSoft;

  /// 注意文字
  final Color attentionInk;

  /// 注意极浅底
  final Color attentionWash;

  /// 危险
  final Color danger;

  /// 危险描边
  final Color dangerBorder;

  /// 危险极浅底
  final Color dangerWash;

  /// 危险文字
  final Color dangerInk;

  /// 危险底上的文字
  final Color onDanger;

  /// 禁用底色
  final Color disabledBg;

  /// 禁用文字
  final Color disabledInk;

  /// 滚动条滑块
  final Color scrollbarThumb;

  /// Windows / Linux 关闭按钮悬停底色
  final Color windowCloseHover;

  /// 关闭按钮悬停时的图标
  final Color onWindowCloseHover;

  RaColors copyWith({
    Color? ground,
    Color? surface,
    Color? surfaceRaised,
    Color? sunken,
    Color? hover,
    Color? surfaceWindow,
    Color? surfaceCanvas,
    Color? surfaceInverse,
    Color? overlay,
    Color? fillTranslucentHover,
    Color? fillTranslucentSelected,
    Color? fillTranslucentActive,
    Color? borderTranslucent,
    Color? vizSeries1,
    Color? vizSeries2,
    Color? vizSeqEmpty,
    Color? vizSeq1,
    Color? vizSeq2,
    Color? vizSeq3,
    Color? vizSeq4,
    Color? border,
    Color? borderStrong,
    Color? borderCanvas,
    Color? borderPopover,
    Color? ink,
    Color? ink2,
    Color? ink3,
    Color? inkInverse,
    Color? inkWindow2,
    Color? inkWindow3,
    Color? accent,
    Color? accentHover,
    Color? accentSoft,
    Color? accentInk,
    Color? onAccent,
    Color? selection,
    Color? success,
    Color? successSoft,
    Color? attention,
    Color? attentionSoft,
    Color? attentionInk,
    Color? attentionWash,
    Color? danger,
    Color? dangerBorder,
    Color? dangerWash,
    Color? dangerInk,
    Color? onDanger,
    Color? disabledBg,
    Color? disabledInk,
    Color? scrollbarThumb,
    Color? windowCloseHover,
    Color? onWindowCloseHover,
  }) {
    return RaColors(
      ground: ground ?? this.ground,
      surface: surface ?? this.surface,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      sunken: sunken ?? this.sunken,
      hover: hover ?? this.hover,
      surfaceWindow: surfaceWindow ?? this.surfaceWindow,
      surfaceCanvas: surfaceCanvas ?? this.surfaceCanvas,
      surfaceInverse: surfaceInverse ?? this.surfaceInverse,
      overlay: overlay ?? this.overlay,
      fillTranslucentHover: fillTranslucentHover ?? this.fillTranslucentHover,
      fillTranslucentSelected: fillTranslucentSelected ?? this.fillTranslucentSelected,
      fillTranslucentActive: fillTranslucentActive ?? this.fillTranslucentActive,
      borderTranslucent: borderTranslucent ?? this.borderTranslucent,
      vizSeries1: vizSeries1 ?? this.vizSeries1,
      vizSeries2: vizSeries2 ?? this.vizSeries2,
      vizSeqEmpty: vizSeqEmpty ?? this.vizSeqEmpty,
      vizSeq1: vizSeq1 ?? this.vizSeq1,
      vizSeq2: vizSeq2 ?? this.vizSeq2,
      vizSeq3: vizSeq3 ?? this.vizSeq3,
      vizSeq4: vizSeq4 ?? this.vizSeq4,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      borderCanvas: borderCanvas ?? this.borderCanvas,
      borderPopover: borderPopover ?? this.borderPopover,
      ink: ink ?? this.ink,
      ink2: ink2 ?? this.ink2,
      ink3: ink3 ?? this.ink3,
      inkInverse: inkInverse ?? this.inkInverse,
      inkWindow2: inkWindow2 ?? this.inkWindow2,
      inkWindow3: inkWindow3 ?? this.inkWindow3,
      accent: accent ?? this.accent,
      accentHover: accentHover ?? this.accentHover,
      accentSoft: accentSoft ?? this.accentSoft,
      accentInk: accentInk ?? this.accentInk,
      onAccent: onAccent ?? this.onAccent,
      selection: selection ?? this.selection,
      success: success ?? this.success,
      successSoft: successSoft ?? this.successSoft,
      attention: attention ?? this.attention,
      attentionSoft: attentionSoft ?? this.attentionSoft,
      attentionInk: attentionInk ?? this.attentionInk,
      attentionWash: attentionWash ?? this.attentionWash,
      danger: danger ?? this.danger,
      dangerBorder: dangerBorder ?? this.dangerBorder,
      dangerWash: dangerWash ?? this.dangerWash,
      dangerInk: dangerInk ?? this.dangerInk,
      onDanger: onDanger ?? this.onDanger,
      disabledBg: disabledBg ?? this.disabledBg,
      disabledInk: disabledInk ?? this.disabledInk,
      scrollbarThumb: scrollbarThumb ?? this.scrollbarThumb,
      windowCloseHover: windowCloseHover ?? this.windowCloseHover,
      onWindowCloseHover: onWindowCloseHover ?? this.onWindowCloseHover,
    );
  }

  /// 在两套颜色之间插值（主题切换动画）。
  static RaColors lerp(RaColors a, RaColors b, double t) {
    if (identical(a, b)) return a;
    return RaColors(
      ground: Color.lerp(a.ground, b.ground, t)!,
      surface: Color.lerp(a.surface, b.surface, t)!,
      surfaceRaised: Color.lerp(a.surfaceRaised, b.surfaceRaised, t)!,
      sunken: Color.lerp(a.sunken, b.sunken, t)!,
      hover: Color.lerp(a.hover, b.hover, t)!,
      surfaceWindow: Color.lerp(a.surfaceWindow, b.surfaceWindow, t)!,
      surfaceCanvas: Color.lerp(a.surfaceCanvas, b.surfaceCanvas, t)!,
      surfaceInverse: Color.lerp(a.surfaceInverse, b.surfaceInverse, t)!,
      overlay: Color.lerp(a.overlay, b.overlay, t)!,
      fillTranslucentHover: Color.lerp(a.fillTranslucentHover, b.fillTranslucentHover, t)!,
      fillTranslucentSelected: Color.lerp(a.fillTranslucentSelected, b.fillTranslucentSelected, t)!,
      fillTranslucentActive: Color.lerp(a.fillTranslucentActive, b.fillTranslucentActive, t)!,
      borderTranslucent: Color.lerp(a.borderTranslucent, b.borderTranslucent, t)!,
      vizSeries1: Color.lerp(a.vizSeries1, b.vizSeries1, t)!,
      vizSeries2: Color.lerp(a.vizSeries2, b.vizSeries2, t)!,
      vizSeqEmpty: Color.lerp(a.vizSeqEmpty, b.vizSeqEmpty, t)!,
      vizSeq1: Color.lerp(a.vizSeq1, b.vizSeq1, t)!,
      vizSeq2: Color.lerp(a.vizSeq2, b.vizSeq2, t)!,
      vizSeq3: Color.lerp(a.vizSeq3, b.vizSeq3, t)!,
      vizSeq4: Color.lerp(a.vizSeq4, b.vizSeq4, t)!,
      border: Color.lerp(a.border, b.border, t)!,
      borderStrong: Color.lerp(a.borderStrong, b.borderStrong, t)!,
      borderCanvas: Color.lerp(a.borderCanvas, b.borderCanvas, t)!,
      borderPopover: Color.lerp(a.borderPopover, b.borderPopover, t)!,
      ink: Color.lerp(a.ink, b.ink, t)!,
      ink2: Color.lerp(a.ink2, b.ink2, t)!,
      ink3: Color.lerp(a.ink3, b.ink3, t)!,
      inkInverse: Color.lerp(a.inkInverse, b.inkInverse, t)!,
      inkWindow2: Color.lerp(a.inkWindow2, b.inkWindow2, t)!,
      inkWindow3: Color.lerp(a.inkWindow3, b.inkWindow3, t)!,
      accent: Color.lerp(a.accent, b.accent, t)!,
      accentHover: Color.lerp(a.accentHover, b.accentHover, t)!,
      accentSoft: Color.lerp(a.accentSoft, b.accentSoft, t)!,
      accentInk: Color.lerp(a.accentInk, b.accentInk, t)!,
      onAccent: Color.lerp(a.onAccent, b.onAccent, t)!,
      selection: Color.lerp(a.selection, b.selection, t)!,
      success: Color.lerp(a.success, b.success, t)!,
      successSoft: Color.lerp(a.successSoft, b.successSoft, t)!,
      attention: Color.lerp(a.attention, b.attention, t)!,
      attentionSoft: Color.lerp(a.attentionSoft, b.attentionSoft, t)!,
      attentionInk: Color.lerp(a.attentionInk, b.attentionInk, t)!,
      attentionWash: Color.lerp(a.attentionWash, b.attentionWash, t)!,
      danger: Color.lerp(a.danger, b.danger, t)!,
      dangerBorder: Color.lerp(a.dangerBorder, b.dangerBorder, t)!,
      dangerWash: Color.lerp(a.dangerWash, b.dangerWash, t)!,
      dangerInk: Color.lerp(a.dangerInk, b.dangerInk, t)!,
      onDanger: Color.lerp(a.onDanger, b.onDanger, t)!,
      disabledBg: Color.lerp(a.disabledBg, b.disabledBg, t)!,
      disabledInk: Color.lerp(a.disabledInk, b.disabledInk, t)!,
      scrollbarThumb: Color.lerp(a.scrollbarThumb, b.scrollbarThumb, t)!,
      windowCloseHover: Color.lerp(a.windowCloseHover, b.windowCloseHover, t)!,
      onWindowCloseHover: Color.lerp(a.onWindowCloseHover, b.onWindowCloseHover, t)!,
    );
  }

  List<Color> get _values => <Color>[
    ground,
    surface,
    surfaceRaised,
    sunken,
    hover,
    surfaceWindow,
    surfaceCanvas,
    surfaceInverse,
    overlay,
    fillTranslucentHover,
    fillTranslucentSelected,
    fillTranslucentActive,
    borderTranslucent,
    vizSeries1,
    vizSeries2,
    vizSeqEmpty,
    vizSeq1,
    vizSeq2,
    vizSeq3,
    vizSeq4,
    border,
    borderStrong,
    borderCanvas,
    borderPopover,
    ink,
    ink2,
    ink3,
    inkInverse,
    inkWindow2,
    inkWindow3,
    accent,
    accentHover,
    accentSoft,
    accentInk,
    onAccent,
    selection,
    success,
    successSoft,
    attention,
    attentionSoft,
    attentionInk,
    attentionWash,
    danger,
    dangerBorder,
    dangerWash,
    dangerInk,
    onDanger,
    disabledBg,
    disabledInk,
    scrollbarThumb,
    windowCloseHover,
    onWindowCloseHover,
  ];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RaColors && listEquals(other._values, _values);
  }

  @override
  int get hashCode => Object.hashAll(_values);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('ground', ground));
    properties.add(ColorProperty('surface', surface));
    properties.add(ColorProperty('surfaceRaised', surfaceRaised));
    properties.add(ColorProperty('sunken', sunken));
    properties.add(ColorProperty('hover', hover));
    properties.add(ColorProperty('surfaceWindow', surfaceWindow));
    properties.add(ColorProperty('surfaceCanvas', surfaceCanvas));
    properties.add(ColorProperty('surfaceInverse', surfaceInverse));
    properties.add(ColorProperty('overlay', overlay));
    properties.add(ColorProperty('fillTranslucentHover', fillTranslucentHover));
    properties.add(ColorProperty('fillTranslucentSelected', fillTranslucentSelected));
    properties.add(ColorProperty('fillTranslucentActive', fillTranslucentActive));
    properties.add(ColorProperty('borderTranslucent', borderTranslucent));
    properties.add(ColorProperty('vizSeries1', vizSeries1));
    properties.add(ColorProperty('vizSeries2', vizSeries2));
    properties.add(ColorProperty('vizSeqEmpty', vizSeqEmpty));
    properties.add(ColorProperty('vizSeq1', vizSeq1));
    properties.add(ColorProperty('vizSeq2', vizSeq2));
    properties.add(ColorProperty('vizSeq3', vizSeq3));
    properties.add(ColorProperty('vizSeq4', vizSeq4));
    properties.add(ColorProperty('border', border));
    properties.add(ColorProperty('borderStrong', borderStrong));
    properties.add(ColorProperty('borderCanvas', borderCanvas));
    properties.add(ColorProperty('borderPopover', borderPopover));
    properties.add(ColorProperty('ink', ink));
    properties.add(ColorProperty('ink2', ink2));
    properties.add(ColorProperty('ink3', ink3));
    properties.add(ColorProperty('inkInverse', inkInverse));
    properties.add(ColorProperty('inkWindow2', inkWindow2));
    properties.add(ColorProperty('inkWindow3', inkWindow3));
    properties.add(ColorProperty('accent', accent));
    properties.add(ColorProperty('accentHover', accentHover));
    properties.add(ColorProperty('accentSoft', accentSoft));
    properties.add(ColorProperty('accentInk', accentInk));
    properties.add(ColorProperty('onAccent', onAccent));
    properties.add(ColorProperty('selection', selection));
    properties.add(ColorProperty('success', success));
    properties.add(ColorProperty('successSoft', successSoft));
    properties.add(ColorProperty('attention', attention));
    properties.add(ColorProperty('attentionSoft', attentionSoft));
    properties.add(ColorProperty('attentionInk', attentionInk));
    properties.add(ColorProperty('attentionWash', attentionWash));
    properties.add(ColorProperty('danger', danger));
    properties.add(ColorProperty('dangerBorder', dangerBorder));
    properties.add(ColorProperty('dangerWash', dangerWash));
    properties.add(ColorProperty('dangerInk', dangerInk));
    properties.add(ColorProperty('onDanger', onDanger));
    properties.add(ColorProperty('disabledBg', disabledBg));
    properties.add(ColorProperty('disabledInk', disabledInk));
    properties.add(ColorProperty('scrollbarThumb', scrollbarThumb));
    properties.add(ColorProperty('windowCloseHover', windowCloseHover));
    properties.add(ColorProperty('onWindowCloseHover', onWindowCloseHover));
  }
}
