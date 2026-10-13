// 应用侧的语义层：把品牌色板映射到 orra_ui 的语义颜色（浅 / 深各一套）。

import 'package:orra_ui/orra_ui.dart';

import 'brand_palette.dart';

enum Brand { indigo, teal, amber }

extension BrandLabel on Brand {
  String get label => switch (this) {
    Brand.indigo => '靛蓝（默认）',
    Brand.teal => '青绿',
    Brand.amber => '琥珀',
  };
}

RaThemeData brandTheme(Brand brand, {required bool dark}) {
  switch (brand) {
    case Brand.indigo:
      return dark ? RaThemeData.dark() : RaThemeData.light();
    case Brand.teal:
      return dark
          ? RaThemeData.dark(
              colors: const RaColors.dark(
                accent: BrandPalette.teal400,
                accentHover: BrandPalette.teal300,
                accentSoft: BrandPalette.teal900,
                accentInk: BrandPalette.teal200,
                selection: BrandPalette.teal400A40,
              ),
            )
          : RaThemeData.light(
              colors: const RaColors.light(
                accent: BrandPalette.teal600,
                accentHover: BrandPalette.teal700,
                accentSoft: BrandPalette.teal50,
                accentInk: BrandPalette.teal700,
                selection: BrandPalette.teal600A24,
              ),
            );
    case Brand.amber:
      return dark
          ? RaThemeData.dark(
              colors: const RaColors.dark(
                accent: BrandPalette.amber400,
                accentHover: BrandPalette.amber300,
                accentSoft: BrandPalette.amber900,
                accentInk: BrandPalette.amber200,
                selection: BrandPalette.amber400A40,
              ),
            )
          : RaThemeData.light(
              colors: const RaColors.light(
                accent: BrandPalette.amber600,
                accentHover: BrandPalette.amber700,
                accentSoft: BrandPalette.amber50,
                accentInk: BrandPalette.amber700,
                selection: BrandPalette.amber600A24,
              ),
            );
  }
}
