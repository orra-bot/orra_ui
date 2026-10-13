// 窗口外壳的组件变量（第三层）。默认由 RaThemeData 的语义层推导，可通过主题扩展覆盖：
// RaThemeData(extensions: [RaShellThemeData.fallback(base).copyWith(sidebarWidth: 260)])。

import 'package:flutter/widgets.dart';
import 'package:orra_ui/orra_ui.dart';

/// 窗口外壳几何与颜色（Linear 桌面版实测）：
/// 标题栏 44（红绿灯、窗口按钮组、标签栏共用 22px 中线）、侧栏 238、内容面板距窗口 8、圆角 12、面板顶栏 44。
@immutable
class RaShellThemeData extends RaThemeExtension {
  const RaShellThemeData({
    required this.titlebarHeight,
    required this.panelGap,
    required this.panelRadius,
    required this.panelHeaderHeight,
    required this.panelHeaderPadding,
    required this.panelHeaderGap,
    required this.panelHeaderItemGap,
    required this.breadcrumbMaxWidth,
    required this.sidebarWidth,
    required this.sidebarPadding,
    required this.controlsLeft,
    required this.controlsLeftMac,
    required this.controlsWidth,
    required this.controlsGap,
    required this.titlebarContentGap,
    required this.trafficLightX,
    required this.captionButtonWidth,
    required this.captionIconSize,
    required this.captionIconStroke,
    required this.resizeDuration,
    required this.resizeCurve,
    required this.chrome,
    required this.canvas,
    required this.canvasBorder,
    required this.panelShadows,
    required this.borderWidth,
    required this.windowButtonColor,
    required this.windowButtonActiveColor,
    required this.captionHoverColor,
    required this.captionPressedColor,
    required this.closeHoverColor,
    required this.onCloseHoverColor,
  });

  factory RaShellThemeData.fallback(RaThemeData theme) {
    final RaChromeThemeData chrome = theme.chrome;
    return RaShellThemeData(
      titlebarHeight: RaSizes.s44,
      panelGap: RaSizes.s8,
      panelRadius: theme.radii.xl,
      panelHeaderHeight: RaSizes.s44,
      panelHeaderPadding: EdgeInsets.only(left: theme.spacing.lg, right: theme.spacing.md),
      panelHeaderGap: theme.spacing.lg,
      panelHeaderItemGap: theme.spacing.xs3,
      breadcrumbMaxWidth: 220,
      sidebarWidth: 238,
      sidebarPadding: EdgeInsets.fromLTRB(
        theme.spacing.lg,
        theme.spacing.sm,
        theme.spacing.lg,
        theme.spacing.xs,
      ),
      controlsLeft: RaSizes.s12,
      controlsLeftMac: 84,
      controlsWidth: RaSizes.s88,
      controlsGap: theme.spacing.xs3,
      titlebarContentGap: theme.spacing.lg,
      trafficLightX: 18,
      captionButtonWidth: 46,
      captionIconSize: theme.sizing.icon2xs,
      captionIconStroke: RaSizes.s1,
      resizeDuration: theme.motion.layout,
      resizeCurve: theme.motion.emphasized,
      chrome: chrome.chrome,
      canvas: chrome.canvas,
      canvasBorder: chrome.canvasBorder,
      panelShadows: theme.shadows.raised,
      borderWidth: theme.sizing.borderWidth,
      windowButtonColor: chrome.chromeInk2,
      windowButtonActiveColor: theme.colors.ink,
      captionHoverColor: chrome.chromeHover,
      captionPressedColor: chrome.chromeActive,
      closeHoverColor: theme.colors.windowCloseHover,
      onCloseHoverColor: theme.colors.onWindowCloseHover,
    );
  }

  /// 当前主题下的外壳变量（主题扩展优先，否则由语义层推导）。
  static RaShellThemeData of(BuildContext context) =>
      RaTheme.of(context).extension<RaShellThemeData>(RaShellThemeData.fallback);

  /// 标题栏高度。改动时同步：macOS 红绿灯垂直居中由它推导，E2E 中线断言也依赖它。
  final double titlebarHeight;

  /// 内容面板与窗口右 / 下边缘的间隙；侧栏收起后也是面板的左间隙。
  final double panelGap;
  final double panelRadius;
  final double panelHeaderHeight;
  final EdgeInsets panelHeaderPadding;
  final double panelHeaderGap;
  final double panelHeaderItemGap;

  /// 面包屑单项最宽。
  final double breadcrumbMaxWidth;
  final double sidebarWidth;

  /// 侧栏内边距：首行中线与面板顶栏中线对齐（8 + 14 ≈ 0.5 + 22）。
  final EdgeInsets sidebarPadding;

  /// 窗口按钮组左缘（Windows / Linux）。
  final double controlsLeft;

  /// 窗口按钮组左缘（macOS：红绿灯右缘 72 + 12）。
  final double controlsLeftMac;

  /// 侧栏收起时窗口按钮组宽度（三个按钮）。
  final double controlsWidth;
  final double controlsGap;

  /// 侧栏收起时标题栏内容与窗口按钮组的间距。
  final double titlebarContentGap;

  /// macOS 红绿灯左缘。
  final double trafficLightX;

  /// Windows / Linux 窗口按钮（最小化、最大化、关闭）宽度。
  final double captionButtonWidth;
  final double captionIconSize;

  /// 窗口按钮图标线宽（10 网格单位，约 1px）。
  final double captionIconStroke;

  /// 侧栏开合时长与缓动。
  final Duration resizeDuration;
  final Curve resizeCurve;
  final Color chrome;
  final Color canvas;
  final Color canvasBorder;
  final List<BoxShadow> panelShadows;
  final double borderWidth;

  /// 标题栏按钮：悬停 / 按下不铺底色，只靠图标变深。
  final Color windowButtonColor;
  final Color windowButtonActiveColor;
  final Color captionHoverColor;
  final Color captionPressedColor;
  final Color closeHoverColor;
  final Color onCloseHoverColor;

  /// 当前平台的窗口按钮组左缘。
  double controlsLeftFor(TargetPlatform platform) =>
      platform == TargetPlatform.macOS ? controlsLeftMac : controlsLeft;

  RaShellThemeData copyWith({
    double? titlebarHeight,
    double? panelGap,
    double? panelRadius,
    double? sidebarWidth,
    double? controlsLeftMac,
    double? trafficLightX,
    Duration? resizeDuration,
  }) {
    return RaShellThemeData(
      titlebarHeight: titlebarHeight ?? this.titlebarHeight,
      panelGap: panelGap ?? this.panelGap,
      panelRadius: panelRadius ?? this.panelRadius,
      panelHeaderHeight: panelHeaderHeight,
      panelHeaderPadding: panelHeaderPadding,
      panelHeaderGap: panelHeaderGap,
      panelHeaderItemGap: panelHeaderItemGap,
      breadcrumbMaxWidth: breadcrumbMaxWidth,
      sidebarWidth: sidebarWidth ?? this.sidebarWidth,
      sidebarPadding: sidebarPadding,
      controlsLeft: controlsLeft,
      controlsLeftMac: controlsLeftMac ?? this.controlsLeftMac,
      controlsWidth: controlsWidth,
      controlsGap: controlsGap,
      titlebarContentGap: titlebarContentGap,
      trafficLightX: trafficLightX ?? this.trafficLightX,
      captionButtonWidth: captionButtonWidth,
      captionIconSize: captionIconSize,
      captionIconStroke: captionIconStroke,
      resizeDuration: resizeDuration ?? this.resizeDuration,
      resizeCurve: resizeCurve,
      chrome: chrome,
      canvas: canvas,
      canvasBorder: canvasBorder,
      panelShadows: panelShadows,
      borderWidth: borderWidth,
      windowButtonColor: windowButtonColor,
      windowButtonActiveColor: windowButtonActiveColor,
      captionHoverColor: captionHoverColor,
      captionPressedColor: captionPressedColor,
      closeHoverColor: closeHoverColor,
      onCloseHoverColor: onCloseHoverColor,
    );
  }
}
