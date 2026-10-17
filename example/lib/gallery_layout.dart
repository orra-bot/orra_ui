// 应用侧的组件层：展示页的布局变量（对应原规范应用 styles.css 开头的 :root）。

import 'package:flutter/widgets.dart';
import 'package:orra_ui/orra_ui.dart';

@immutable
class GalleryLayout extends RaThemeExtension {
  const GalleryLayout({
    required this.pageMaxWidth,
    required this.pagePadding,
    required this.pageTitleGap,
    required this.sectionGap,
    required this.sectionHeadGap,
    required this.demoPadding,
    required this.demoRadius,
    required this.demoGap,
    required this.swatchSize,
    required this.swatchColumnWidth,
    required this.sidebarGap,
    required this.badgeSize,
    required this.badgeRadius,
    required this.fieldColumnWidth,
    required this.contextAreaHeight,
    required this.demoSidebarWidth,
    required this.sideCardWidth,
  });

  factory GalleryLayout.fallback(RaThemeData theme) => GalleryLayout(
    pageMaxWidth: 820,
    pagePadding: EdgeInsets.fromLTRB(RaSizes.s48, theme.spacing.xl5, RaSizes.s48, RaSizes.s64),
    pageTitleGap: theme.spacing.xs,
    sectionGap: theme.spacing.xl5,
    sectionHeadGap: theme.spacing.lg,
    demoPadding: EdgeInsets.all(theme.spacing.xl2),
    demoRadius: theme.radii.lg,
    demoGap: theme.spacing.lg,
    swatchSize: RaSizes.s32,
    swatchColumnWidth: 240,
    sidebarGap: theme.spacing.sm,
    badgeSize: RaSizes.s22,
    badgeRadius: theme.radii.sm,
    fieldColumnWidth: 360,
    contextAreaHeight: 96,
    demoSidebarWidth: 238,
    sideCardWidth: 304,
  );

  static GalleryLayout of(BuildContext context) =>
      RaTheme.of(context).extension<GalleryLayout>(GalleryLayout.fallback);

  final double pageMaxWidth;
  final EdgeInsets pagePadding;
  final double pageTitleGap;
  final double sectionGap;
  final double sectionHeadGap;
  final EdgeInsets demoPadding;
  final double demoRadius;
  final double demoGap;
  final double swatchSize;
  final double swatchColumnWidth;
  final double sidebarGap;
  final double badgeSize;
  final double badgeRadius;
  final double fieldColumnWidth;
  final double contextAreaHeight;
  final double demoSidebarWidth;

  /// 右侧栏卡片宽（右侧栏 320 − 右缘 8 − 左缘 8）。
  final double sideCardWidth;
}
