import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../foundation/hairline.dart';
import '../foundation/pressable.dart';
import '../theme/theme.dart';
import '../theme/theme_data.dart';
import '../tokens/components.dart';

/// 滑杆（Base UI Slider，单值）：4px 轨道 + 强调色进度 + 14px 白色滑块。
///
/// 点击轨道跳到该位置并可继续拖动。键盘：方向键一步，Shift + 方向键 / PageUp / PageDown 一大步，
/// Home / End 到首尾。[step] 为空时连续取值。
class RaSlider extends StatefulWidget {
  const RaSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.onChangeEnd,
    this.min = 0,
    this.max = 1,
    this.step,
    this.largeStep,
    this.semanticLabel,
    this.enabled = true,
    this.focusNode,
    this.autofocus = false,
  }) : assert(max > min);

  final double value;

  /// 为空时禁用。
  final ValueChanged<double>? onChanged;

  /// 拖动结束 / 键盘调整后触发（适合提交保存）。
  final ValueChanged<double>? onChangeEnd;
  final double min;
  final double max;

  /// 步长；为空时连续。
  final double? step;

  /// 大步（Shift + 方向键、PageUp / PageDown）；默认 10 个 [step]，连续时为范围的 10%。
  final double? largeStep;
  final String? semanticLabel;
  final bool enabled;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  State<RaSlider> createState() => _RaSliderState();
}

class _RaSliderState extends State<RaSlider> {
  bool _hovered = false;
  bool _dragging = false;
  FocusNode? _ownFocusNode;

  FocusNode get _focusNode => widget.focusNode ?? (_ownFocusNode ??= FocusNode());

  @override
  void dispose() {
    _ownFocusNode?.dispose();
    super.dispose();
  }

  bool get _enabled => widget.enabled && widget.onChanged != null;

  double get _range => widget.max - widget.min;

  double get _smallStep => widget.step ?? _range / 100;

  double get _bigStep =>
      widget.largeStep ?? (widget.step == null ? _range / 10 : widget.step! * 10);

  double get _clampedValue => widget.value.clamp(widget.min, widget.max).toDouble();

  double _snap(double v) {
    double result = v.clamp(widget.min, widget.max).toDouble();
    final double? step = widget.step;
    if (step != null && step > 0) {
      result = widget.min + ((result - widget.min) / step).round() * step;
      result = result.clamp(widget.min, widget.max).toDouble();
    }
    return result;
  }

  /// 最近一次交给 [RaSlider.onChanged] 的值（父组件可能还没重建）。
  double? _lastEmitted;

  void _emit(double v) {
    final double next = _snap(v);
    _lastEmitted = next;
    if (next != widget.value) widget.onChanged?.call(next);
  }

  void _end() => widget.onChangeEnd?.call(_lastEmitted ?? _clampedValue);

  void _commit(double v) {
    _emit(v);
    widget.onChangeEnd?.call(_snap(v));
  }

  /// 指针位置 → 取值（滑块中心的可移动范围两端各内缩半个滑块）。
  double _valueAt(Offset local, double width, double thumb, bool rtl) {
    final double usable = math.max(0, width - thumb);
    double t = usable == 0 ? 0 : ((local.dx - thumb / 2) / usable).clamp(0.0, 1.0);
    if (rtl) t = 1 - t;
    return widget.min + t * _range;
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (!_enabled || (event is! KeyDownEvent && event is! KeyRepeatEvent)) {
      return KeyEventResult.ignored;
    }
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final bool shift = HardwareKeyboard.instance.isShiftPressed;
    final double step = shift ? _bigStep : _smallStep;
    final LogicalKeyboardKey key = event.logicalKey;
    double? next;
    if (key == LogicalKeyboardKey.arrowRight) next = _clampedValue + (rtl ? -step : step);
    if (key == LogicalKeyboardKey.arrowLeft) next = _clampedValue + (rtl ? step : -step);
    if (key == LogicalKeyboardKey.arrowUp) next = _clampedValue + step;
    if (key == LogicalKeyboardKey.arrowDown) next = _clampedValue - step;
    if (key == LogicalKeyboardKey.pageUp) next = _clampedValue + _bigStep;
    if (key == LogicalKeyboardKey.pageDown) next = _clampedValue - _bigStep;
    if (key == LogicalKeyboardKey.home) next = widget.min;
    if (key == LogicalKeyboardKey.end) next = widget.max;
    if (next == null) return KeyEventResult.ignored;
    _commit(next);
    return KeyEventResult.handled;
  }

  String _format(double v) {
    final double? step = widget.step;
    final int decimals = step == null || step >= 1
        ? (step == null ? 2 : 0)
        : math.max(0, -(math.log(step) / math.ln10).floor());
    return v.toStringAsFixed(decimals);
  }

  @override
  Widget build(BuildContext context) {
    final RaThemeData theme = RaTheme.of(context);
    final RaSliderThemeData s = theme.slider;
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final double value = _clampedValue;
    final double fraction = (value - widget.min) / _range;

    return RaNoDragRegion(
      child: Semantics(
        slider: true,
        enabled: _enabled,
        label: widget.semanticLabel,
        value: _format(value),
        increasedValue: _format(_snap(value + _smallStep)),
        decreasedValue: _format(_snap(value - _smallStep)),
        onIncrease: _enabled ? () => _commit(value + _smallStep) : null,
        onDecrease: _enabled ? () => _commit(value - _smallStep) : null,
        child: Focus(
          focusNode: _focusNode,
          autofocus: widget.autofocus,
          canRequestFocus: _enabled,
          onKeyEvent: _handleKey,
          child: MouseRegion(
            cursor: _enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
            onEnter: (_) => setState(() => _hovered = true),
            onExit: (_) => setState(() => _hovered = false),
            child: Opacity(
              opacity: _enabled ? 1 : s.disabledOpacity,
              child: SizedBox(
                height: s.height,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final double width = constraints.maxWidth;
                    final double usable = math.max(0, width - s.thumbSize);
                    final double thumbLeft = (rtl ? 1 - fraction : fraction) * usable;
                    final double thumbCenter = thumbLeft + s.thumbSize / 2;
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragStart: _enabled
                          ? (DragStartDetails d) {
                              setState(() => _dragging = true);
                              _emit(_valueAt(d.localPosition, width, s.thumbSize, rtl));
                            }
                          : null,
                      onHorizontalDragUpdate: _enabled
                          ? (DragUpdateDetails d) =>
                                _emit(_valueAt(d.localPosition, width, s.thumbSize, rtl))
                          : null,
                      onHorizontalDragEnd: _enabled
                          ? (DragEndDetails d) {
                              setState(() => _dragging = false);
                              _end();
                            }
                          : null,
                      onHorizontalDragCancel: _enabled
                          ? () => setState(() => _dragging = false)
                          : null,
                      onTapDown: _enabled
                          ? (TapDownDetails d) {
                              _focusNode.requestFocus();
                              _emit(_valueAt(d.localPosition, width, s.thumbSize, rtl));
                            }
                          : null,
                      onTapUp: _enabled ? (_) => _end() : null,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.centerLeft,
                        children: <Widget>[
                          Positioned(
                            left: 0,
                            right: 0,
                            child: Container(
                              height: s.trackHeight,
                              decoration: BoxDecoration(
                                color: s.trackColor,
                                borderRadius: BorderRadius.circular(s.trackHeight / 2),
                              ),
                            ),
                          ),
                          Positioned(
                            left: rtl ? thumbCenter : 0,
                            right: rtl ? 0 : width - thumbCenter,
                            child: Container(
                              height: s.trackHeight,
                              decoration: BoxDecoration(
                                color: s.fillColor,
                                borderRadius: BorderRadius.circular(s.trackHeight / 2),
                              ),
                            ),
                          ),
                          Positioned(
                            left: thumbLeft,
                            child: Container(
                              width: s.thumbSize,
                              height: s.thumbSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: s.thumbColor,
                                border: Border.all(
                                  color: _hovered || _dragging
                                      ? s.thumbHoverBorderColor
                                      : s.thumbBorderColor,
                                  width: RaHairline.snap(context, theme.sizing.borderWidth),
                                ),
                                boxShadow: s.thumbShadows,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
