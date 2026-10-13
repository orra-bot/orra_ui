import 'package:flutter/widgets.dart';

import '../foundation/popover_layout.dart';
import '../tokens/components.dart';
import 'button.dart';
import 'tooltip.dart';

/// 只有图标的工具栏按钮（28px 圆形）+ 提示气泡。
///
/// [label] 同时作为无障碍名称与提示文字（必填），可带 [shortcut]。
class RaIconButton extends StatelessWidget {
  const RaIconButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.shortcut,
    this.selected = false,
    this.tooltipSide = RaPopoverSide.bottom,
    this.showTooltip = true,
    this.style,
    this.focusNode,
  });

  final String label;

  /// 图标（RaIcon、Icon 或任意 Widget；颜色与 14px 尺寸由按钮传下去）。
  final Widget icon;
  final VoidCallback? onPressed;
  final String? shortcut;

  /// 按下状态（aria-pressed）或弹出层已展开。
  final bool selected;
  final RaPopoverSide tooltipSide;
  final bool showTooltip;
  final RaButtonStyle? style;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final Widget button = RaButton(
      onPressed: onPressed,
      variant: RaButtonVariant.icon,
      selected: selected,
      style: style,
      focusNode: focusNode,
      semanticLabel: label,
      child: icon,
    );
    if (!showTooltip) return button;
    return RaTooltip(
      message: label,
      shortcut: shortcut,
      side: tooltipSide,
      excludeFromSemantics: true,
      child: button,
    );
  }
}
