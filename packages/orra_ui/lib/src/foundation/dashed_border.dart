import 'dart:ui' show PathMetric;

import 'package:flutter/widgets.dart';

import 'hairline.dart';

/// 虚线圆角描边（相当于 CSS 的 `border-style: dashed`），画在 [child] 之上。
class RaDashedBorder extends StatelessWidget {
  const RaDashedBorder({
    super.key,
    required this.color,
    required this.width,
    required this.radius,
    required this.dashLength,
    required this.dashGap,
    required this.child,
  });

  final Color color;

  /// 线宽（逻辑像素，会按设备像素取整）。
  final double width;
  final double radius;
  final double dashLength;
  final double dashGap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _DashedBorderPainter(
        color: color,
        width: RaHairline.snap(context, width),
        radius: radius,
        dashLength: dashLength,
        dashGap: dashGap,
      ),
      child: child,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({
    required this.color,
    required this.width,
    required this.radius,
    required this.dashLength,
    required this.dashGap,
  });

  final Color color;
  final double width;
  final double radius;
  final double dashLength;
  final double dashGap;

  @override
  void paint(Canvas canvas, Size size) {
    if (width <= 0 || size.isEmpty) return;
    final Rect rect = (Offset.zero & size).deflate(width / 2);
    final Path outline = Path()..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    final Path dashes = Path();
    for (final PathMetric metric in outline.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        dashes.addPath(metric.extractPath(distance, distance + dashLength), Offset.zero);
        distance += dashLength + dashGap;
      }
    }
    canvas.drawPath(dashes, paint);
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color ||
      old.width != width ||
      old.radius != radius ||
      old.dashLength != dashLength ||
      old.dashGap != dashGap;
}
