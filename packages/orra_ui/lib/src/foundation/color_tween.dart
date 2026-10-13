import 'package:flutter/animation.dart';

/// 预乘 alpha 的颜色插值（与 CSS 过渡一致）。
///
/// Flutter 的 [Color.lerp] 直接插值 RGBA：白色 → 半透明黑的中途会出现明显的灰；
/// 预乘后插值则平滑过渡，淡出到透明时也保持原有色相。
Color raLerpColor(Color a, Color b, double t) {
  final double alpha = a.a + (b.a - a.a) * t;
  if (alpha <= 0) return b.withValues(alpha: 0);
  double channel(double ca, double cb) => ((ca * a.a) + ((cb * b.a) - (ca * a.a)) * t) / alpha;
  return Color.from(
    alpha: alpha.clamp(0.0, 1.0),
    red: channel(a.r, b.r).clamp(0.0, 1.0),
    green: channel(a.g, b.g).clamp(0.0, 1.0),
    blue: channel(a.b, b.b).clamp(0.0, 1.0),
  );
}

class RaColorTween extends Tween<Color> {
  RaColorTween({super.begin, super.end});

  @override
  Color lerp(double t) => raLerpColor(begin!, end!, t);
}
