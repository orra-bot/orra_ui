// 应用侧的基础层：品牌色板（唯一允许写颜色字面量的地方）。
// 演示「可配置设计系统」：同一套组件换品牌色，只改语义层 accent 系列的引用。

import 'dart:ui' show Color;

abstract final class BrandPalette {
  // 青绿
  static const Color teal50 = Color(0xFFE2F4F0);
  static const Color teal200 = Color(0xFF9FDCCF);
  static const Color teal300 = Color(0xFF6FC8B5);
  static const Color teal400 = Color(0xFF3FAF98);
  static const Color teal600 = Color(0xFF0E7C66);
  static const Color teal700 = Color(0xFF0B6655);
  static const Color teal900 = Color(0xFF12322B);
  static const Color teal600A24 = Color(0x3D0E7C66);
  static const Color teal400A40 = Color(0x663FAF98);

  // 橙
  static const Color amber50 = Color(0xFFFBEEDF);
  static const Color amber200 = Color(0xFFF6C99A);
  static const Color amber300 = Color(0xFFF3B27A);
  static const Color amber400 = Color(0xFFE8914A);
  static const Color amber600 = Color(0xFFC2620F);
  static const Color amber700 = Color(0xFFA2510B);
  static const Color amber900 = Color(0xFF3A2614);
  static const Color amber600A24 = Color(0x3DC2620F);
  static const Color amber400A40 = Color(0x66E8914A);
}
