import 'package:flutter/widgets.dart';

import '../foundation/motion.dart';
import '../icons/ra_icon.dart';
import '../theme/theme.dart';
import '../theme/theme_data.dart';
import '../tokens/components.dart';
import 'button.dart';

/// 折叠面板的内容区：高度在展开 / 收起之间过渡（75ms），收起后内容不可聚焦、对读屏隐藏。
///
/// 只负责动画；标题与开关由调用方提供（见 [RaCollapsible]、RaSideCard）。
class RaCollapsiblePanel extends StatefulWidget {
  const RaCollapsiblePanel({super.key, required this.expanded, required this.child});

  final bool expanded;
  final Widget child;

  @override
  State<RaCollapsiblePanel> createState() => _RaCollapsiblePanelState();
}

class _RaCollapsiblePanelState extends State<RaCollapsiblePanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    value: widget.expanded ? 1 : 0,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.duration = RaReducedMotion.resolve(context, RaTheme.of(context).motion.base);
  }

  @override
  void didUpdateWidget(RaCollapsiblePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expanded != oldWidget.expanded) {
      if (widget.expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        final bool hidden = _controller.value == 0;
        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: _controller.value,
            child: ExcludeFocus(
              excluding: hidden,
              child: ExcludeSemantics(excluding: hidden, child: child),
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// 折叠面板（Base UI Collapsible）：安静按钮作标题（箭头展开时朝上），下方为可展开内容。
class RaCollapsible extends StatefulWidget {
  const RaCollapsible({
    super.key,
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
    this.expanded,
    this.onExpandedChanged,
  });

  final Widget title;
  final Widget child;
  final bool initiallyExpanded;

  /// 受控展开状态（为空时组件自行管理）。
  final bool? expanded;
  final ValueChanged<bool>? onExpandedChanged;

  @override
  State<RaCollapsible> createState() => _RaCollapsibleState();
}

class _RaCollapsibleState extends State<RaCollapsible> {
  late bool _expanded = widget.expanded ?? widget.initiallyExpanded;

  @override
  void didUpdateWidget(RaCollapsible oldWidget) {
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Semantics(
            expanded: _expanded,
            child: RaButton(
              variant: RaButtonVariant.quiet,
              size: RaButtonSize.sm,
              onPressed: _toggle,
              leading: AnimatedRotation(
                turns: _expanded ? 0.5 : 0,
                duration: RaReducedMotion.resolve(context, theme.motion.base),
                child: RaIcon.glyph(theme.icons.chevronDown, size: theme.sizing.iconSm),
              ),
              child: widget.title,
            ),
          ),
        ),
        RaCollapsiblePanel(expanded: _expanded, child: widget.child),
      ],
    );
  }
}
