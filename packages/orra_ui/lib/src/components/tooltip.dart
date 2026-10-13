import 'package:flutter/widgets.dart';

import '../foundation/hairline.dart';
import '../foundation/motion.dart';
import '../foundation/popover_layout.dart';
import '../theme/theme.dart';
import '../theme/theme_data.dart';
import '../tokens/components.dart';

/// 提示气泡：取代原生 title。悬停一段时间后出现，点击触发元素即消失。
///
/// 白底、0.5px 描边、11px、最宽 280；可带快捷键（等宽数字、次要色）。
class RaTooltip extends StatelessWidget {
  const RaTooltip({
    super.key,
    required this.message,
    this.shortcut,
    this.side = RaPopoverSide.top,
    this.excludeFromSemantics = false,
    required this.child,
  });

  final String message;

  /// 跟在文字后面的快捷键（如 ⌘K）。
  final String? shortcut;
  final RaPopoverSide side;

  /// 触发元素已有同样的无障碍名称时（如 RaIconButton）设为 true，避免重复朗读。
  final bool excludeFromSemantics;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final RaThemeData theme = RaTheme.of(context);
    final RaTooltipThemeData t = theme.tooltip;
    final Duration duration = RaReducedMotion.resolve(context, t.duration);
    return RawTooltip(
      semanticsTooltip: excludeFromSemantics ? null : message,
      hoverDelay: t.showDelay,
      dismissDelay: Duration.zero,
      triggerMode: TooltipTriggerMode.manual,
      enableFeedback: false,
      ignorePointer: true,
      animationStyle: AnimationStyle(duration: duration, reverseDuration: duration),
      positionDelegate: (TooltipPositionContext c) {
        final Rect anchor = Rect.fromCenter(
          center: c.target,
          width: c.targetSize.width,
          height: c.targetSize.height,
        );
        return RaPopoverPlacement.compute(
          anchor: anchor,
          child: c.tooltipSize,
          overlay: c.overlaySize,
          side: side,
          gap: t.sideOffset,
          margin: t.screenMargin,
        ).offset;
      },
      tooltipBuilder: (BuildContext context, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: t.scale, end: 1).animate(animation),
            child: _TooltipBubble(theme: theme, message: message, shortcut: shortcut),
          ),
        );
      },
      child: child,
    );
  }
}

class _TooltipBubble extends StatelessWidget {
  const _TooltipBubble({required this.theme, required this.message, this.shortcut});

  final RaThemeData theme;
  final String message;
  final String? shortcut;

  @override
  Widget build(BuildContext context) {
    final RaTooltipThemeData t = theme.tooltip;
    final Widget text = Text(message, style: t.textStyle.copyWith(color: t.foregroundColor));
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: t.maxWidth),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: t.backgroundColor,
          borderRadius: BorderRadius.circular(t.radius),
          border: Border.all(
            color: t.borderColor,
            width: RaHairline.snap(context, theme.sizing.borderWidth),
          ),
          boxShadow: t.shadows,
        ),
        child: Padding(
          padding: t.padding,
          child: shortcut == null
              ? text
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: t.shortcutGap,
                  children: <Widget>[
                    Flexible(child: text),
                    Text(shortcut!, style: t.shortcutStyle),
                  ],
                ),
        ),
      ),
    );
  }
}
