import 'package:flutter/widgets.dart';

import '../foundation/hairline.dart';
import '../foundation/motion.dart';
import '../foundation/pressable.dart';
import '../foundation/surface.dart';
import '../icons/ra_icon.dart';
import '../theme/theme.dart';
import '../theme/theme_data.dart';
import '../tokens/components.dart';
import 'collapsible.dart';

/// 右侧栏属性卡片（Linear）：浮在内容面板上的白色卡片，标题可折叠，右侧可放一个操作按钮。
/// 内容通常是若干 [RaPropertyRow]，也可以是说明文字或按钮。
class RaSideCard extends StatefulWidget {
  const RaSideCard({
    super.key,
    required this.title,
    required this.children,
    this.action,
    this.initiallyExpanded = true,
    this.expanded,
    this.onExpandedChanged,
  });

  final String title;
  final List<Widget> children;

  /// 标题行右侧的操作（建议 RaIconButton）。
  final Widget? action;
  final bool initiallyExpanded;

  /// 受控展开状态（为空时组件自行管理）。
  final bool? expanded;
  final ValueChanged<bool>? onExpandedChanged;

  @override
  State<RaSideCard> createState() => _RaSideCardState();
}

class _RaSideCardState extends State<RaSideCard> {
  late bool _expanded = widget.expanded ?? widget.initiallyExpanded;

  @override
  void didUpdateWidget(RaSideCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool? expanded = widget.expanded;
    if (expanded != null && expanded != _expanded) setState(() => _expanded = expanded);
  }

  void _toggle() {
    final bool next = !_expanded;
    if (widget.expanded == null) setState(() => _expanded = next);
    widget.onExpandedChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final RaThemeData theme = RaTheme.of(context);
    final RaSideCardThemeData s = theme.sideCard;
    final Widget toggle = Semantics(
      expanded: _expanded,
      header: true,
      child: RaPressable(
        onPressed: _toggle,
        semanticLabel: widget.title,
        excludeSemantics: true,
        builder: (BuildContext context, RaPressState state) => RaAnimatedSurface(
          duration: state.transition,
          foregroundColor: state.hovered ? s.titleHoverColor : s.titleColor,
          textStyle: s.titleStyle,
          constraints: BoxConstraints.tightFor(height: s.headHeight),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: s.headGap,
            children: <Widget>[
              Flexible(
                child: Text(
                  widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ),
              AnimatedRotation(
                turns: _expanded ? 0 : -0.25,
                duration: RaReducedMotion.resolve(context, theme.motion.base),
                child: RaIcon.glyph(theme.icons.caretDown, size: s.caretSize, color: s.caretColor),
              ),
            ],
          ),
        ),
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: s.backgroundColor,
        borderRadius: BorderRadius.circular(s.radius),
        border: Border.all(
          color: s.borderColor,
          width: RaHairline.snap(context, theme.sizing.borderWidth),
        ),
        boxShadow: s.shadows,
      ),
      child: Padding(
        padding: s.padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              height: s.headHeight,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Align(alignment: AlignmentDirectional.centerStart, child: toggle),
                  ),
                  if (widget.action != null)
                    SizedBox.square(
                      dimension: s.actionSize,
                      child: FittedBox(child: widget.action),
                    ),
                ],
              ),
            ),
            RaCollapsiblePanel(
              expanded: _expanded,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: s.bodyPaddingY),
                child: DefaultTextStyle(
                  style: s.valueStyle,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: s.rowGap,
                    children: widget.children,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 属性行：左侧固定宽度的标签（12px 次要色），右侧为值（12px 正文色）。
class RaPropertyRow extends StatelessWidget {
  const RaPropertyRow({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final RaSideCardThemeData s = RaTheme.of(context).sideCard;
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: s.rowHeight),
      child: Row(
        spacing: s.rowColumnGap,
        children: <Widget>[
          SizedBox(
            width: s.labelWidth,
            child: Text(label, style: s.labelStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            child: DefaultTextStyle(
              style: s.valueStyle,
              child: Align(alignment: AlignmentDirectional.centerStart, child: child),
            ),
          ),
        ],
      ),
    );
  }
}
