import 'package:flutter/widgets.dart';

import '../foundation/motion.dart';
import '../theme/theme.dart';
import '../tokens/components.dart';

/// 进度条（Base UI Progress）：4px 胶囊轨道，强调色进度；[value] 为空时为不确定进度（一段条循环滑动）。
///
/// 上方可带标签与百分比。
class RaProgress extends StatelessWidget {
  const RaProgress({
    super.key,
    required this.value,
    this.label,
    this.showValue = false,
    this.semanticLabel,
  });

  /// 0..1；为空表示不确定。
  final double? value;
  final String? label;

  /// 右侧显示百分比（不确定进度时不显示）。
  final bool showValue;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final RaProgressThemeData s = RaTheme.of(context).progress;
    final double? v = value?.clamp(0.0, 1.0);
    final String? percent = v == null ? null : '${(v * 100).round()}%';
    return Semantics(
      container: true,
      label: semanticLabel ?? label,
      value: percent,
      child: _LabeledBar(
        label: label,
        valueText: showValue ? percent : null,
        bar: v == null
            ? const _IndeterminateFill()
            : _AnimatedFill(fraction: v, color: s.fillColor),
      ),
    );
  }
}

/// 计量条（Base UI Meter）：表示一个量在范围内的位置（如用量 6.2 / 10 GB）。
///
/// [tone] 为空时按阈值着色：≥ [high] 为危险色，≥ [low] 为提醒色，其余为强调色。
class RaMeter extends StatelessWidget {
  const RaMeter({
    super.key,
    required this.value,
    this.min = 0,
    this.max = 1,
    this.label,
    this.valueLabel,
    this.tone,
    this.low,
    this.high,
    this.semanticLabel,
  }) : assert(max > min);

  final double value;
  final double min;
  final double max;
  final String? label;

  /// 右侧文字；为空时显示百分比。
  final String? valueLabel;
  final RaMeterTone? tone;

  /// 提醒阈值（与 [value] 同一量纲）。
  final double? low;

  /// 危险阈值。
  final double? high;
  final String? semanticLabel;

  RaMeterTone get _tone {
    if (tone != null) return tone!;
    if (high != null && value >= high!) return RaMeterTone.danger;
    if (low != null && value >= low!) return RaMeterTone.attention;
    return RaMeterTone.normal;
  }

  @override
  Widget build(BuildContext context) {
    final RaProgressThemeData s = RaTheme.of(context).progress;
    final double fraction = ((value - min) / (max - min)).clamp(0.0, 1.0);
    final String text = valueLabel ?? '${(fraction * 100).round()}%';
    final Color color = s.meterColors[_tone] ?? s.fillColor;
    return Semantics(
      container: true,
      label: semanticLabel ?? label,
      value: text,
      child: _LabeledBar(
        label: label,
        valueText: text,
        bar: _AnimatedFill(fraction: fraction, color: color),
      ),
    );
  }
}

/// 标签行 + 轨道。
class _LabeledBar extends StatelessWidget {
  const _LabeledBar({required this.bar, this.label, this.valueText});

  final Widget bar;
  final String? label;
  final String? valueText;

  @override
  Widget build(BuildContext context) {
    final RaProgressThemeData s = RaTheme.of(context).progress;
    final Widget track = ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(s.radius),
        child: SizedBox(
          height: s.trackHeight,
          width: double.infinity,
          child: ColoredBox(color: s.trackColor, child: bar),
        ),
      ),
    );
    if (label == null && valueText == null) return track;
    return ExcludeSemantics(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: s.labelGap,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: label == null
                    ? const SizedBox.shrink()
                    : Text(
                        label!,
                        style: s.labelStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
              if (valueText != null) Text(valueText!, style: s.valueStyle),
            ],
          ),
          track,
        ],
      ),
    );
  }
}

/// 从起点填充到 [fraction]，数值变化时过渡。
class _AnimatedFill extends StatelessWidget {
  const _AnimatedFill({required this.fraction, required this.color});

  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final RaProgressThemeData s = RaTheme.of(context).progress;
    return AnimatedFractionallySizedBox(
      duration: RaReducedMotion.resolve(context, s.duration),
      alignment: AlignmentDirectional.centerStart,
      widthFactor: fraction,
      heightFactor: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(s.radius)),
      ),
    );
  }
}

/// 不确定进度：一段条从左到右循环滑过；减弱动效时静止在起点。
class _IndeterminateFill extends StatefulWidget {
  const _IndeterminateFill();

  @override
  State<_IndeterminateFill> createState() => _IndeterminateFillState();
}

class _IndeterminateFillState extends State<_IndeterminateFill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.duration = RaTheme.of(context).progress.indeterminatePeriod;
    if (RaReducedMotion.of(context)) {
      _controller.stop();
      _controller.value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final RaProgressThemeData s = RaTheme.of(context).progress;
    final double segment = s.indeterminateFraction;
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        // 起点在轨道左侧之外，终点在右侧之外：-segment → 1。
        final double start = -segment + _controller.value * (1 + segment);
        return FractionallySizedBox(
          widthFactor: segment,
          heightFactor: 1,
          alignment: Alignment(segment >= 1 ? 0 : (start / (1 - segment)) * 2 - 1, 0),
          child: child,
        );
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: s.fillColor,
          borderRadius: BorderRadius.circular(s.radius),
        ),
      ),
    );
  }
}
