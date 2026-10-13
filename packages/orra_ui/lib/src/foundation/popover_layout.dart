// ignore_for_file: prefer_initializing_formals

import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// 浮层相对触发元素的方向。
enum RaPopoverSide { top, bottom, left, right }

/// 浮层沿方向垂直轴的对齐。
enum RaPopoverAlign { start, center, end }

/// 计算好的浮层位置。
@immutable
class RaPopoverPlacement {
  const RaPopoverPlacement(this.offset, this.side);

  /// 浮层左上角（浮层所在 Overlay 的坐标）。
  final Offset offset;

  /// 实际弹出方向（空间不足时会翻转）。
  final RaPopoverSide side;

  /// 计算浮层位置：优先 [side]，放不下且对侧放得下时翻转；随后把浮层夹在 [margin] 之内。
  static RaPopoverPlacement compute({
    required Rect anchor,
    required Size child,
    required Size overlay,
    required RaPopoverSide side,
    RaPopoverAlign align = RaPopoverAlign.center,
    double gap = 0,
    double margin = 0,
  }) {
    RaPopoverSide resolved = side;
    bool fits(RaPopoverSide s) => switch (s) {
      RaPopoverSide.bottom => anchor.bottom + gap + child.height <= overlay.height - margin,
      RaPopoverSide.top => anchor.top - gap - child.height >= margin,
      RaPopoverSide.right => anchor.right + gap + child.width <= overlay.width - margin,
      RaPopoverSide.left => anchor.left - gap - child.width >= margin,
    };
    final RaPopoverSide opposite = switch (side) {
      RaPopoverSide.bottom => RaPopoverSide.top,
      RaPopoverSide.top => RaPopoverSide.bottom,
      RaPopoverSide.right => RaPopoverSide.left,
      RaPopoverSide.left => RaPopoverSide.right,
    };
    if (!fits(side) && fits(opposite)) resolved = opposite;

    double alongStart(double start, double end, double extent) => switch (align) {
      RaPopoverAlign.start => start,
      RaPopoverAlign.center => (start + end) / 2 - extent / 2,
      RaPopoverAlign.end => end - extent,
    };

    double x;
    double y;
    switch (resolved) {
      case RaPopoverSide.bottom:
        y = anchor.bottom + gap;
        x = alongStart(anchor.left, anchor.right, child.width);
      case RaPopoverSide.top:
        y = anchor.top - gap - child.height;
        x = alongStart(anchor.left, anchor.right, child.width);
      case RaPopoverSide.right:
        x = anchor.right + gap;
        y = alongStart(anchor.top, anchor.bottom, child.height);
      case RaPopoverSide.left:
        x = anchor.left - gap - child.width;
        y = alongStart(anchor.top, anchor.bottom, child.height);
    }
    x = _clamp(x, margin, overlay.width - margin - child.width);
    y = _clamp(y, margin, overlay.height - margin - child.height);
    return RaPopoverPlacement(Offset(x, y), resolved);
  }

  static double _clamp(double v, double min, double max) =>
      max < min ? min : math.min(math.max(v, min), max);

  /// 浮层变换原点（相对浮层自身）：指向触发元素，用于「从触发位置展开」。
  Alignment originFor(Rect anchor, Size child) {
    final Offset anchorCenter = anchor.center - offset;
    double fx(double x) => child.width == 0 ? 0 : (x / child.width) * 2 - 1;
    double fy(double y) => child.height == 0 ? 0 : (y / child.height) * 2 - 1;
    return switch (side) {
      RaPopoverSide.bottom => Alignment(fx(anchorCenter.dx).clamp(-1.0, 1.0), -1),
      RaPopoverSide.top => Alignment(fx(anchorCenter.dx).clamp(-1.0, 1.0), 1),
      RaPopoverSide.right => Alignment(-1, fy(anchorCenter.dy).clamp(-1.0, 1.0)),
      RaPopoverSide.left => Alignment(1, fy(anchorCenter.dy).clamp(-1.0, 1.0)),
    };
  }
}

/// 把浮层放到触发元素旁边，并按实际弹出方向播放进场动画：
/// 从触发位置缩放展开（[scale] → 1），同时沿弹出方向位移 [enterOffset] → 0，透明度 0 → 1。
///
/// 放在 Overlay 中、占满整个 Overlay（例如 Positioned.fill）使用。
class RaPopoverPositioner extends SingleChildRenderObjectWidget {
  const RaPopoverPositioner({
    super.key,
    required this.anchor,
    required this.side,
    this.align = RaPopoverAlign.center,
    this.gap = 0,
    this.margin = 0,
    required this.animation,
    this.scale = 1,
    this.enterOffset = 0,
    super.child,
  });

  /// 触发元素在 Overlay 坐标中的矩形。
  final Rect anchor;
  final RaPopoverSide side;
  final RaPopoverAlign align;
  final double gap;
  final double margin;
  final Animation<double> animation;
  final double scale;
  final double enterOffset;

  @override
  RenderObject createRenderObject(BuildContext context) => RenderRaPopoverPositioner(
    anchor: anchor,
    side: side,
    align: align,
    gap: gap,
    margin: margin,
    animation: animation,
    scale: scale,
    enterOffset: enterOffset,
  );

  @override
  void updateRenderObject(BuildContext context, RenderRaPopoverPositioner renderObject) {
    renderObject
      ..anchor = anchor
      ..side = side
      ..align = align
      ..gap = gap
      ..margin = margin
      ..animation = animation
      ..scale = scale
      ..enterOffset = enterOffset;
  }
}

class RenderRaPopoverPositioner extends RenderProxyBox {
  RenderRaPopoverPositioner({
    required Rect anchor,
    required RaPopoverSide side,
    required RaPopoverAlign align,
    required double gap,
    required double margin,
    required Animation<double> animation,
    required double scale,
    required double enterOffset,
  }) : _anchor = anchor,
       _side = side,
       _align = align,
       _gap = gap,
       _margin = margin,
       _animation = animation,
       _scale = scale,
       _enterOffset = enterOffset;

  Rect _anchor;
  set anchor(Rect v) {
    if (v == _anchor) return;
    _anchor = v;
    markNeedsLayout();
  }

  RaPopoverSide _side;
  set side(RaPopoverSide v) {
    if (v == _side) return;
    _side = v;
    markNeedsLayout();
  }

  RaPopoverAlign _align;
  set align(RaPopoverAlign v) {
    if (v == _align) return;
    _align = v;
    markNeedsLayout();
  }

  double _gap;
  set gap(double v) {
    if (v == _gap) return;
    _gap = v;
    markNeedsLayout();
  }

  double _margin;
  set margin(double v) {
    if (v == _margin) return;
    _margin = v;
    markNeedsLayout();
  }

  Animation<double> _animation;
  set animation(Animation<double> v) {
    if (v == _animation) return;
    if (attached) _animation.removeListener(markNeedsPaint);
    _animation = v;
    if (attached) _animation.addListener(markNeedsPaint);
    markNeedsPaint();
  }

  double _scale;
  set scale(double v) {
    if (v == _scale) return;
    _scale = v;
    markNeedsPaint();
  }

  double _enterOffset;
  set enterOffset(double v) {
    if (v == _enterOffset) return;
    _enterOffset = v;
    markNeedsPaint();
  }

  RaPopoverPlacement? _placement;

  /// 最近一次布局的实际弹出方向（测试用）。
  RaPopoverSide? get resolvedSide => _placement?.side;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _animation.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _animation.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;

  @override
  void performLayout() {
    final RenderBox? child = this.child;
    if (child == null) return;
    final double maxW = math.max(0, size.width - _margin * 2);
    final double maxH = math.max(0, size.height - _margin * 2);
    child.layout(BoxConstraints(maxWidth: maxW, maxHeight: maxH), parentUsesSize: true);
    _placement = RaPopoverPlacement.compute(
      anchor: _anchor,
      child: child.size,
      overlay: size,
      side: _side,
      align: _align,
      gap: _gap,
      margin: _margin,
    );
  }

  Matrix4 _transform() {
    final RaPopoverPlacement placement = _placement!;
    final Size childSize = child!.size;
    final double t = _animation.value;
    final double s = _scale + (1 - _scale) * t;
    final Alignment origin = placement.originFor(_anchor, childSize);
    final Offset originPoint = origin.alongSize(childSize);
    final double travel = _enterOffset * (1 - t);
    final Offset shift = switch (placement.side) {
      RaPopoverSide.bottom => Offset(0, -travel),
      RaPopoverSide.top => Offset(0, travel),
      RaPopoverSide.right => Offset(-travel, 0),
      RaPopoverSide.left => Offset(travel, 0),
    };
    final Offset base = placement.offset + shift;
    return Matrix4.translationValues(base.dx + originPoint.dx, base.dy + originPoint.dy, 0)
      ..scaleByDouble(s, s, 1, 1)
      ..translateByDouble(-originPoint.dx, -originPoint.dy, 0, 1);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final RenderBox? child = this.child;
    if (child == null || _placement == null) return;
    final double t = _animation.value.clamp(0.0, 1.0);
    if (t == 0) return;
    final Matrix4 transform = _transform();
    void paintChild(PaintingContext context, Offset offset) {
      context.pushTransform(needsCompositing, offset, transform, (PaintingContext c, Offset o) {
        c.paintChild(child, o);
      });
    }

    if (t < 1) {
      context.pushOpacity(offset, (t * 255).round(), paintChild);
    } else {
      paintChild(context, offset);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final RenderBox? child = this.child;
    if (child == null || _placement == null) return false;
    return result.addWithPaintTransform(
      transform: _transform(),
      position: position,
      hitTest: (BoxHitTestResult result, Offset position) =>
          child.hitTest(result, position: position),
    );
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    // 只有浮层本身可命中，四周空白交给下层（点击外部由 TapRegion 处理）。
    if (hitTestChildren(result, position: position)) {
      result.add(BoxHitTestEntry(this, position));
      return true;
    }
    return false;
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    if (_placement != null) transform.multiply(_transform());
  }
}
