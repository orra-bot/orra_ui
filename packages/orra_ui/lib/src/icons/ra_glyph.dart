import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// 绘制图标时的样式。
@immutable
class RaGlyphStyle {
  const RaGlyphStyle({required this.size, required this.color, required this.strokeWidth});

  final double size;
  final Color color;

  /// 线宽，以 24 网格为单位（2 = Lucide 默认）。
  final double strokeWidth;
}

/// 图标来源：不绑定任何图标库。
///
/// - [RaGlyph.icon]：任意基于字体的图标（Lucide、Phosphor、Material Symbols……）；
/// - [RaGlyph.builder]：任意 Widget（SVG 等）；
/// - [RaPathGlyph]：内置的 24 网格线条图标（默认图标集使用）。
@immutable
abstract class RaGlyph {
  const RaGlyph();

  const factory RaGlyph.icon(IconData icon) = _IconDataGlyph;

  const factory RaGlyph.builder(Widget Function(BuildContext context, RaGlyphStyle style) builder) =
      _BuilderGlyph;

  Widget build(BuildContext context, RaGlyphStyle style);
}

class _IconDataGlyph extends RaGlyph {
  const _IconDataGlyph(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context, RaGlyphStyle style) =>
      Icon(icon, size: style.size, color: style.color);
}

class _BuilderGlyph extends RaGlyph {
  const _BuilderGlyph(this.builder);

  final Widget Function(BuildContext context, RaGlyphStyle style) builder;

  @override
  Widget build(BuildContext context, RaGlyphStyle style) => builder(context, style);
}

/// 24 网格上的一个图形。
@immutable
sealed class RaGlyphShape {
  const RaGlyphShape();
}

/// 折线（[points] 为 x0, y0, x1, y1…）；[closed] 闭合，[filled] 填充。
class RaGlyphPolyline extends RaGlyphShape {
  const RaGlyphPolyline(this.points, {this.closed = false, this.filled = false});

  final List<double> points;
  final bool closed;
  final bool filled;
}

class RaGlyphCircle extends RaGlyphShape {
  const RaGlyphCircle(this.cx, this.cy, this.r);

  final double cx;
  final double cy;
  final double r;
}

class RaGlyphRect extends RaGlyphShape {
  const RaGlyphRect(this.x, this.y, this.width, this.height, {this.radius = 0});

  final double x;
  final double y;
  final double width;
  final double height;
  final double radius;
}

/// 由 24 网格图形组成的线条图标（圆头圆角，与 Lucide 一致）。
class RaPathGlyph extends RaGlyph {
  const RaPathGlyph(this.shapes, {this.grid = 24});

  final List<RaGlyphShape> shapes;
  final double grid;

  @override
  Widget build(BuildContext context, RaGlyphStyle style) {
    return SizedBox.square(
      dimension: style.size,
      child: CustomPaint(painter: _PathGlyphPainter(this, style)),
    );
  }
}

class _PathGlyphPainter extends CustomPainter {
  _PathGlyphPainter(this.glyph, this.style);

  final RaPathGlyph glyph;
  final RaGlyphStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.shortestSide / glyph.grid;
    canvas.save();
    canvas.scale(scale);
    final Paint stroke = Paint()
      ..color = style.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = style.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;
    final Paint fill = Paint()
      ..color = style.color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    for (final RaGlyphShape shape in glyph.shapes) {
      switch (shape) {
        case RaGlyphPolyline(:final List<double> points, :final bool closed, :final bool filled):
          final Path path = Path()..moveTo(points[0], points[1]);
          for (int i = 2; i + 1 < points.length; i += 2) {
            path.lineTo(points[i], points[i + 1]);
          }
          if (closed || filled) path.close();
          if (filled) canvas.drawPath(path, fill);
          canvas.drawPath(path, stroke);
        case RaGlyphCircle(:final double cx, :final double cy, :final double r):
          canvas.drawCircle(Offset(cx, cy), r, stroke);
        case RaGlyphRect(
          :final double x,
          :final double y,
          :final double width,
          :final double height,
          :final double radius,
        ):
          canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(x, y, width, height), Radius.circular(radius)),
            stroke,
          );
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PathGlyphPainter old) =>
      old.glyph != glyph ||
      old.style.color != style.color ||
      old.style.strokeWidth != style.strokeWidth;
}

/// 内置图标（几何取自 Lucide，ISC 许可）。
abstract final class RaGlyphs {
  static const RaGlyph check = RaPathGlyph(<RaGlyphShape>[
    RaGlyphPolyline(<double>[20, 6, 9, 17, 4, 12]),
  ]);
  static const RaGlyph chevronDown = RaPathGlyph(<RaGlyphShape>[
    RaGlyphPolyline(<double>[6, 9, 12, 15, 18, 9]),
  ]);
  static const RaGlyph chevronRight = RaPathGlyph(<RaGlyphShape>[
    RaGlyphPolyline(<double>[9, 18, 15, 12, 9, 6]),
  ]);
  static const RaGlyph chevronLeft = RaPathGlyph(<RaGlyphShape>[
    RaGlyphPolyline(<double>[15, 18, 9, 12, 15, 6]),
  ]);

  /// 实心 ▾。
  static const RaGlyph caretDown = RaPathGlyph(<RaGlyphShape>[
    RaGlyphPolyline(<double>[5, 8, 19, 8, 12, 17], filled: true),
  ]);

  /// 实心 ▸。
  static const RaGlyph caretRight = RaPathGlyph(<RaGlyphShape>[
    RaGlyphPolyline(<double>[8, 5, 8, 19, 17, 12], filled: true),
  ]);
  static const RaGlyph x = RaPathGlyph(<RaGlyphShape>[
    RaGlyphPolyline(<double>[18, 6, 6, 18]),
    RaGlyphPolyline(<double>[6, 6, 18, 18]),
  ]);
  static const RaGlyph search = RaPathGlyph(<RaGlyphShape>[
    RaGlyphCircle(11, 11, 8),
    RaGlyphPolyline(<double>[21, 21, 16.66, 16.66]),
  ]);
  static const RaGlyph circleCheck = RaPathGlyph(<RaGlyphShape>[
    RaGlyphCircle(12, 12, 10),
    RaGlyphPolyline(<double>[9, 12, 11, 14, 15, 10]),
  ]);
  static const RaGlyph circleX = RaPathGlyph(<RaGlyphShape>[
    RaGlyphCircle(12, 12, 10),
    RaGlyphPolyline(<double>[15, 9, 9, 15]),
    RaGlyphPolyline(<double>[9, 9, 15, 15]),
  ]);

  // Windows / Linux 窗口按钮（10 网格，细线）。
  static const RaGlyph windowMinimize = RaPathGlyph(<RaGlyphShape>[
    RaGlyphPolyline(<double>[0.5, 5, 9.5, 5]),
  ], grid: 10);
  static const RaGlyph windowMaximize = RaPathGlyph(<RaGlyphShape>[
    RaGlyphRect(0.5, 0.5, 9, 9, radius: 1),
  ], grid: 10);
  static const RaGlyph windowRestore = RaPathGlyph(<RaGlyphShape>[
    RaGlyphRect(0.5, 2.5, 7, 7, radius: 1),
    RaGlyphPolyline(<double>[2.5, 2.5, 2.5, 0.5, 9.5, 0.5, 9.5, 7.5, 7.5, 7.5]),
  ], grid: 10);
  static const RaGlyph windowClose = RaPathGlyph(<RaGlyphShape>[
    RaGlyphPolyline(<double>[0.5, 0.5, 9.5, 9.5]),
    RaGlyphPolyline(<double>[9.5, 0.5, 0.5, 9.5]),
  ], grid: 10);
}

/// 加载转圈（24 网格上的 3/4 圆弧，0.8s 一圈）。
class RaSpinnerPainter extends CustomPainter {
  RaSpinnerPainter({required this.color, required this.strokeWidth, required this.turns})
    : super(repaint: turns);

  final Color color;

  /// 线宽（24 网格单位）。
  final double strokeWidth;
  final Animation<double> turns;

  // 「M21 12a9 9 0 1 1-6.2-8.56」：从 0° 顺时针约 288°。
  static const double _sweep = 288 * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.shortestSide / 24;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(turns.value * 2 * math.pi);
    canvas.scale(scale);
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: Offset.zero, radius: 9), 0, _sweep, false, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(RaSpinnerPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth || old.turns != turns;
}
