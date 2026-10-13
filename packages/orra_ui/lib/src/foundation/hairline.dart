import 'package:flutter/widgets.dart';

/// 细线取整：设计稿里的 0.5px 在 2 倍屏上正好是 1 个物理像素；
/// 1 倍屏上不足 1 物理像素会发虚，取整为 1 物理像素（与浏览器行为一致）。
abstract final class RaHairline {
  /// 把逻辑像素宽度 [width] 对齐到整数个物理像素（至少 1 个）。
  static double snap(BuildContext context, double width) {
    final double dpr = MediaQuery.maybeDevicePixelRatioOf(context) ?? 1;
    return snapFor(width, dpr);
  }

  static double snapFor(double width, double devicePixelRatio) {
    if (width <= 0) return 0;
    final double physical = (width * devicePixelRatio).roundToDouble();
    return (physical < 1 ? 1 : physical) / devicePixelRatio;
  }
}
