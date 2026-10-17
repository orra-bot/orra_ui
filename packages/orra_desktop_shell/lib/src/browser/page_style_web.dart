import 'dart:ui' show Color;

import 'package:web/web.dart' as web;

/// 让页面底色与窗口底一致：Flutter 视图尚未覆盖的区域（加载中、调整窗口大小）不露出白底
///（`<html>` 没有背景时，`<body>` 的背景铺满整个视口）；
/// 同时更新 `<meta name="theme-color">`，浏览器地址栏 / 标签栏随之变色。
void setPageBackgroundColor(Color color) {
  final String css = _cssColor(color);
  web.document.body?.style.backgroundColor = css;

  // index.html 可能按 prefers-color-scheme 写了两个 theme-color：主题确定后只保留一个、去掉 media，
  // 否则应用选择的深浅与系统不一致时，浏览器仍按系统取色。
  final web.NodeList metas = web.document.querySelectorAll('meta[name="theme-color"]');
  web.Element? meta;
  for (int i = 0; i < metas.length; i++) {
    final web.Element element = metas.item(i)! as web.Element;
    if (meta == null) {
      meta = element..removeAttribute('media');
    } else {
      element.remove();
    }
  }
  if (meta == null) {
    meta = web.document.createElement('meta')..setAttribute('name', 'theme-color');
    web.document.head?.append(meta);
  }
  meta.setAttribute('content', css);
}

/// 不透明色输出 `#rrggbb`（theme-color 的常见写法），半透明色输出 `rgba(...)`。
String _cssColor(Color c) {
  int channel(double v) => (v * 255).round().clamp(0, 255);
  final List<int> rgb = <int>[channel(c.r), channel(c.g), channel(c.b)];
  if (c.a >= 1) return '#${rgb.map((int v) => v.toRadixString(16).padLeft(2, '0')).join()}';
  return 'rgba(${rgb.join(', ')}, ${c.a.toStringAsFixed(3)})';
}
