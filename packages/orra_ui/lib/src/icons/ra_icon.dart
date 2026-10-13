import 'package:flutter/widgets.dart';

import '../foundation/motion.dart';
import '../theme/theme.dart';
import '../theme/theme_data.dart';
import 'ra_glyph.dart';

/// 图标：默认 14px，颜色取自上层 IconTheme（组件会把前景色传下来）。
///
/// 接受任意图标库的 [IconData]（`RaIcon(LucideIcons.inbox)`），或一个 [RaGlyph]（`RaIcon.glyph(...)`）。
class RaIcon extends StatelessWidget {
  const RaIcon(this.icon, {super.key, this.size, this.color, this.semanticLabel}) : glyph = null;

  const RaIcon.glyph(RaGlyph this.glyph, {super.key, this.size, this.color, this.semanticLabel})
    : icon = null;

  final IconData? icon;
  final RaGlyph? glyph;
  final double? size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final RaThemeData theme = RaTheme.of(context);
    final IconThemeData iconTheme = IconTheme.of(context);
    final double resolvedSize = size ?? iconTheme.size ?? theme.sizing.iconSm;
    final Color resolvedColor = color ?? iconTheme.color ?? theme.colors.ink;
    final RaGlyph resolved = glyph ?? RaGlyph.icon(icon!);
    final Widget result = resolved.build(
      context,
      RaGlyphStyle(size: resolvedSize, color: resolvedColor, strokeWidth: theme.sizing.iconStroke),
    );
    if (semanticLabel == null) return ExcludeSemantics(child: result);
    return Semantics(
      label: semanticLabel,
      child: ExcludeSemantics(child: result),
    );
  }
}

/// 加载转圈（16px、粗线、0.8s 一圈）。
class RaSpinner extends StatefulWidget {
  const RaSpinner({super.key, this.size, this.color});

  final double? size;
  final Color? color;

  @override
  State<RaSpinner> createState() => _RaSpinnerState();
}

class _RaSpinnerState extends State<RaSpinner> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final RaThemeData theme = RaTheme.of(context);
    _controller.duration = theme.motion.spin;
    if (RaReducedMotion.of(context)) {
      _controller.stop();
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
    final RaThemeData theme = RaTheme.of(context);
    final double size = widget.size ?? theme.sizing.iconMd;
    final Color color = widget.color ?? IconTheme.of(context).color ?? theme.colors.ink;
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: RaSpinnerPainter(
          color: color,
          strokeWidth: theme.sizing.iconStrokeBold,
          turns: _controller,
        ),
      ),
    );
  }
}

/// 侧栏开关图标：外框 + 内侧竖条。竖条随开合在「实心块（展开）↔ 与外框同粗的线（收起）」之间过渡，
/// 时长与缓动同侧栏开合，可中途反向。[side] 为 right 时水平镜像（右侧栏开关）。
class RaSidebarIcon extends StatelessWidget {
  const RaSidebarIcon({
    super.key,
    required this.collapsed,
    this.side = AxisDirection.left,
    this.size,
  });

  final bool collapsed;

  /// [AxisDirection.left] 或 [AxisDirection.right]。
  final AxisDirection side;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final RaThemeData theme = RaTheme.of(context);
    final double dimension = size ?? theme.sizing.iconMd;
    final Color color = IconTheme.of(context).color ?? theme.colors.ink;
    final Widget icon = TweenAnimationBuilder<double>(
      tween: Tween<double>(end: collapsed ? 0 : 1),
      duration: RaReducedMotion.resolve(context, theme.motion.layout),
      curve: theme.motion.emphasized,
      builder: (BuildContext context, double open, Widget? _) => CustomPaint(
        size: Size.square(dimension),
        painter: _SidebarIconPainter(
          open: open,
          color: color,
          strokeWidth: theme.sizing.iconStrokeThin,
        ),
      ),
    );
    final Widget sized = SizedBox.square(dimension: dimension, child: icon);
    if (side == AxisDirection.right) {
      return Transform.flip(flipX: true, child: sized);
    }
    return sized;
  }
}

class _SidebarIconPainter extends CustomPainter {
  _SidebarIconPainter({required this.open, required this.color, required this.strokeWidth});

  /// 0 = 收起（竖条宽 0），1 = 展开（竖条宽 2）。
  final double open;
  final Color color;

  /// 20 网格单位。
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.shortestSide / 20);
    final Paint stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final Paint fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(3, 4, 14, 12), const Radius.circular(3)),
      stroke,
    );
    final Rect bar = Rect.fromLTWH(6, 7, 2 * open, 6);
    canvas.drawRect(bar, fill);
    canvas.drawRect(bar, stroke);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SidebarIconPainter old) =>
      old.open != open || old.color != color || old.strokeWidth != strokeWidth;
}
