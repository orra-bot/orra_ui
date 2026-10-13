import 'package:flutter/widgets.dart';

import 'color_tween.dart';
import 'hairline.dart';

/// 带状态过渡的表面：底色、描边色、前景色（文字与图标）随 [duration] 过渡。
///
/// [duration] 由 RaPressable 按状态变化给出（悬停出现 0、移开 150ms、按下 100ms），
/// 每次变化都用当次的时长，因此能做到「出现立即、消失淡出」。
class RaAnimatedSurface extends ImplicitlyAnimatedWidget {
  const RaAnimatedSurface({
    super.key,
    required super.duration,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 0,
    this.foregroundColor,
    this.textStyle,
    this.iconSize,
    this.radius = 0,
    this.shadows,
    this.shape = BoxShape.rectangle,
    this.padding,
    this.constraints,
    this.alignment,
    this.opacity = 1,
    required this.child,
  });

  final Color? backgroundColor;
  final Color? borderColor;

  /// 描边宽度（逻辑像素，会按设备像素取整）；0 表示无描边。
  final double borderWidth;
  final Color? foregroundColor;

  /// 内容的默认文字样式（颜色由 [foregroundColor] 覆盖）。
  final TextStyle? textStyle;

  /// 内容中图标的默认尺寸。
  final double? iconSize;
  final double radius;
  final List<BoxShadow>? shadows;
  final BoxShape shape;
  final EdgeInsetsGeometry? padding;
  final BoxConstraints? constraints;
  final AlignmentGeometry? alignment;
  final double opacity;
  final Widget child;

  @override
  AnimatedWidgetBaseState<RaAnimatedSurface> createState() => _RaAnimatedSurfaceState();
}

class _RaAnimatedSurfaceState extends AnimatedWidgetBaseState<RaAnimatedSurface> {
  RaColorTween? _background;
  RaColorTween? _border;
  RaColorTween? _foreground;

  static const Color _clear = Color(0x00000000);

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _background = visitor(
      _background,
      widget.backgroundColor ?? _clear,
      (dynamic v) => RaColorTween(begin: v as Color),
    ) as RaColorTween?;
    _border = visitor(
      _border,
      widget.borderColor ?? _clear,
      (dynamic v) => RaColorTween(begin: v as Color),
    ) as RaColorTween?;
    _foreground = visitor(
      _foreground,
      widget.foregroundColor ?? _clear,
      (dynamic v) => RaColorTween(begin: v as Color),
    ) as RaColorTween?;
  }

  @override
  Widget build(BuildContext context) {
    final Color background = _background?.evaluate(animation) ?? _clear;
    final Color border = _border?.evaluate(animation) ?? _clear;
    final Color? foreground = widget.foregroundColor == null
        ? null
        : _foreground?.evaluate(animation);
    final double borderWidth = widget.borderWidth > 0
        ? RaHairline.snap(context, widget.borderWidth)
        : 0;

    Widget content = widget.child;
    if (foreground != null || widget.textStyle != null) {
      final TextStyle base = widget.textStyle ?? DefaultTextStyle.of(context).style;
      content = DefaultTextStyle(
        style: foreground == null ? base : base.copyWith(color: foreground),
        child: content,
      );
    }
    if (foreground != null || widget.iconSize != null) {
      content = IconTheme.merge(
        data: IconThemeData(color: foreground, size: widget.iconSize),
        child: content,
      );
    }
    if (widget.padding != null) content = Padding(padding: widget.padding!, child: content);
    if (widget.alignment != null) {
      content = Align(
        alignment: widget.alignment!,
        widthFactor: 1,
        heightFactor: 1,
        child: content,
      );
    }

    final bool circle = widget.shape == BoxShape.circle;
    Widget result = DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        shape: widget.shape,
        borderRadius: circle || widget.radius == 0 ? null : BorderRadius.circular(widget.radius),
        border: borderWidth > 0 && border.a > 0
            ? Border.all(color: border, width: borderWidth)
            : null,
        boxShadow: widget.shadows,
      ),
      child: content,
    );
    if (widget.constraints != null) {
      result = ConstrainedBox(constraints: widget.constraints!, child: result);
    }
    if (widget.opacity < 1) result = Opacity(opacity: widget.opacity, child: result);
    return result;
  }
}
