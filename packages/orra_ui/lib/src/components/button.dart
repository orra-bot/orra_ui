import 'package:flutter/widgets.dart';

import '../foundation/pressable.dart';
import '../foundation/surface.dart';
import '../icons/ra_icon.dart';
import '../theme/theme.dart';
import '../theme/theme_data.dart';
import '../tokens/components.dart';

/// 按钮。
///
/// 变体见 [RaButtonVariant]：primary 主按钮 · secondary 次要（默认）· ghost 文字 · quiet 安静 ·
/// danger / dangerSolid · card 卡片 · item 列表项 · chip 输入框内胶囊 · send 发送 · icon 图标。
/// 尺寸 sm 28 / md 32 / lg 40。[loading] 显示转圈并禁用，但保留文字、仍可聚焦。
class RaButton extends StatelessWidget {
  const RaButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.leading,
    this.trailing,
    this.variant = RaButtonVariant.secondary,
    this.size = RaButtonSize.md,
    this.loading = false,
    this.selected = false,
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.onSecondaryTapUp,
    this.onMiddlePressed,
    this.expand = false,
    this.hoverExitDuration,
  });

  /// 为空时禁用。
  final VoidCallback? onPressed;

  /// 按钮内容（通常是 Text）。card / item 变体中可放多行结构化内容。
  final Widget child;

  /// 文字前的图标。
  final Widget? leading;

  /// 文字后的内容（如箭头）。
  final Widget? trailing;
  final RaButtonVariant variant;
  final RaButtonSize size;
  final bool loading;

  /// 选中 / 当前项 / 弹出层已展开。
  final bool selected;

  /// 实例级样式（与主题样式叠加，后者优先）。
  final RaButtonStyle? style;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? semanticLabel;
  final GestureTapUpCallback? onSecondaryTapUp;
  final VoidCallback? onMiddlePressed;

  /// 撑满可用宽度。
  final bool expand;

  /// 悬停移开时的过渡时长（侧栏里的按钮直接消失）；为空时淡出 75ms。
  final Duration? hoverExitDuration;

  @override
  Widget build(BuildContext context) {
    final RaThemeData theme = RaTheme.of(context);
    final RaButtonThemeData buttonTheme = theme.button;
    final RaButtonStyle s = buttonTheme.resolve(variant, size, style);
    final bool block = s.layout == RaButtonLayout.block;

    return RaPressable(
      onPressed: loading ? null : onPressed,
      focusableWhenDisabled: loading,
      focusNode: focusNode,
      autofocus: autofocus,
      selected: selected,
      semanticLabel: semanticLabel,
      onSecondaryTapUp: onSecondaryTapUp,
      onMiddlePressed: onMiddlePressed,
      hoverExitDuration: hoverExitDuration,
      builder: (BuildContext context, RaPressState state) {
        final Set<WidgetState> states = state.states;
        final Color? foreground = s.foregroundColor?.resolve(states);
        final double? height = block ? null : s.height;
        final bool square = s.square ?? false;

        final List<Widget> children = <Widget>[
          if (loading) RaSpinner(size: buttonTheme.spinnerSize, color: foreground),
          ?leading,
          if (block) child else Flexible(child: child),
          ?trailing,
        ];

        final Widget content = block
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: s.gap ?? 0,
                children: children,
              )
            : Row(
                mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: s.gap ?? 0,
                children: children,
              );

        return RaAnimatedSurface(
          duration: state.transition,
          backgroundColor: s.backgroundColor?.resolve(states),
          borderColor: s.borderColor?.resolve(states),
          borderWidth: s.borderColor == null ? 0 : theme.sizing.borderWidth,
          foregroundColor: foreground,
          textStyle: s.textStyle,
          iconSize: theme.sizing.iconSm,
          radius: s.radius ?? 0,
          shadows: s.shadows?.resolve(states),
          padding: s.padding,
          opacity: state.disabled && !loading ? (s.disabledOpacity ?? 1) : 1,
          constraints: BoxConstraints(
            minHeight: height ?? 0,
            maxHeight: height ?? double.infinity,
            minWidth: square ? (height ?? 0) : 0,
            maxWidth: square ? (height ?? double.infinity) : double.infinity,
          ),
          alignment: block ? null : Alignment.center,
          child: DefaultTextStyle.merge(
            softWrap: block,
            overflow: block ? null : TextOverflow.ellipsis,
            maxLines: block ? null : 1,
            child: content,
          ),
        );
      },
    );
  }
}
