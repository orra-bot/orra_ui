import 'package:flutter/widgets.dart';
import 'package:orra_ui/orra_ui.dart';

import 'shell_theme.dart';
import 'window_controller.dart';

/// Windows / Linux 的窗口按钮：最小化、最大化 / 还原、关闭（关闭悬停为系统红）。
/// macOS 使用系统红绿灯，不需要本组件。
class RaWindowCaptionButtons extends StatelessWidget {
  const RaWindowCaptionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final RaWindowController window = RaWindowScope.of(context);
    final RaLocalizations l10n = RaLocalizations.of(context);
    final RaIconSet icons = RaTheme.of(context).icons;
    return ValueListenableBuilder<bool>(
      valueListenable: window.maximized,
      builder: (BuildContext context, bool maximized, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _CaptionButton(
            label: l10n.minimizeWindow,
            glyph: icons.windowMinimize,
            onPressed: window.minimize,
          ),
          _CaptionButton(
            label: maximized ? l10n.restoreWindow : l10n.maximizeWindow,
            glyph: maximized ? icons.windowRestore : icons.windowMaximize,
            onPressed: window.toggleMaximize,
          ),
          _CaptionButton(
            label: l10n.closeWindow,
            glyph: icons.windowClose,
            onPressed: window.close,
            destructive: true,
          ),
        ],
      ),
    );
  }
}

class _CaptionButton extends StatelessWidget {
  const _CaptionButton({
    required this.label,
    required this.glyph,
    required this.onPressed,
    this.destructive = false,
  });

  final String label;
  final RaGlyph glyph;
  final VoidCallback onPressed;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final RaShellThemeData s = RaShellThemeData.of(context);
    return RaTooltip(
      message: label,
      side: RaPopoverSide.bottom,
      excludeFromSemantics: true,
      child: RaPressable(
        onPressed: onPressed,
        semanticLabel: label,
        canRequestFocus: false,
        mouseCursor: SystemMouseCursors.basic,
        builder: (BuildContext context, RaPressState state) {
          final bool hot = state.hovered || state.pressed;
          final Color? background = !hot
              ? null
              : destructive
              ? s.closeHoverColor
              : state.pressed
              ? s.captionPressedColor
              : s.captionHoverColor;
          final Color foreground = destructive && hot
              ? s.onCloseHoverColor
              : (hot ? s.windowButtonActiveColor : s.windowButtonColor);
          return RaAnimatedSurface(
            duration: state.transition,
            backgroundColor: background,
            constraints: BoxConstraints.tightFor(
              width: s.captionButtonWidth,
              height: s.titlebarHeight,
            ),
            alignment: Alignment.center,
            child: glyph.build(
              context,
              RaGlyphStyle(
                size: s.captionIconSize,
                color: foreground,
                strokeWidth: s.captionIconStroke,
              ),
            ),
          );
        },
      ),
    );
  }
}
