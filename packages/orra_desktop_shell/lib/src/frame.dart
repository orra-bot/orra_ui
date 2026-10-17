import 'dart:ui' show lerpDouble;

import 'package:flutter/widgets.dart';
import 'package:orra_ui/orra_ui.dart';

import 'caption_buttons.dart';
import 'desktop_window.dart';
import 'drag_area.dart';
import 'shell_platform.dart';
import 'shell_strings.dart';
import 'shell_theme.dart';

/// 桌面窗口框架（Cursor / Linear / ChatGPT 桌面端的共同结构）：
///
/// ```
/// ┌──────────────── 标题栏 44（可拖动）────────────────┐
/// │ ●●●  [⊟]      [‹][›] │ [titlebar：标签栏等]      [—][□][×] │  ← 中线 22
/// ├──────────────┬────────────────────────────────────┤
/// │ 侧栏 238      │ ┌ 内容面板（圆角 12、0.5px 描边）──┐ │
/// │（实色窗口底）  │ │ child                          │ │
/// │              │ └──────────────────────────────┘ │
/// └──────────────┴────────── 面板距窗口右 / 下 8 ─────┘
/// ```
///
/// 侧栏在 238 ↔ 8 之间过渡（150ms、cubic-bezier(0.22, 1, 0.36, 1)，可中途反向）；内部保持 238 宽被裁切，
/// 收起动画结束后才隐藏（不可点、不可聚焦、读屏不读），展开时立即可见。
///
/// 网页端（[RaShellPlatform.web]）结构不变：标题栏保留为页面顶栏（侧栏开关、后退 / 前进、标签栏），
/// 但没有红绿灯与窗口按钮，按钮组从左 12 开始；拖动、双击最大化不执行。
class RaDesktopFrame extends StatefulWidget {
  const RaDesktopFrame({
    super.key,
    required this.sidebar,
    required this.child,
    this.titlebar,
    this.sidebarOpen = true,
    this.onToggleSidebar,
    this.onBack,
    this.onForward,
    this.showHistoryControls = true,
    this.hidden = false,
  });

  /// 侧栏内容（RaSidebarSection / RaSidebarItem……）。
  final Widget sidebar;

  /// 内容面板中的视图。
  final Widget child;

  /// 标题栏内容（如标签栏）：侧栏展开时从内容面板左缘开始，收起时紧跟窗口按钮组。
  final Widget? titlebar;
  final bool sidebarOpen;
  final VoidCallback? onToggleSidebar;

  /// 后退 / 前进；为空时按钮禁用。
  final VoidCallback? onBack;
  final VoidCallback? onForward;
  final bool showHistoryControls;

  /// 全窗口页面（设置等）打开时隐藏框架但保持挂载，返回后状态不变。
  final bool hidden;

  @override
  State<RaDesktopFrame> createState() => _RaDesktopFrameState();
}

class _RaDesktopFrameState extends State<RaDesktopFrame> with SingleTickerProviderStateMixin {
  /// 当前这一次过渡的线性进度（0 → 1）。
  ///
  /// 与 CSS 过渡一致：展开和收起都从当前位置出发、按时间正向套用缓动（先快后慢），
  /// 中途反向也从当前位置连续过渡。不用 `reverse()`——那会把缓动曲线倒着走，收起变成先慢后快。
  late final AnimationController _resize = AnimationController(vsync: this, value: 1);
  late double _from = widget.sidebarOpen ? 1 : 0;
  late double _to = _from;
  Curve _curve = Curves.linear;

  /// 侧栏展开程度：0 = 收起，1 = 展开。
  double get _openness => _from + (_to - _from) * _curve.transform(_resize.value);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final RaShellThemeData s = RaShellThemeData.of(context);
    _resize.duration = RaReducedMotion.resolve(context, s.resizeDuration);
    _curve = s.resizeCurve;
  }

  @override
  void didUpdateWidget(RaDesktopFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.sidebarOpen != oldWidget.sidebarOpen) {
      _from = _openness;
      _to = widget.sidebarOpen ? 1 : 0;
      _resize.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _resize.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final RaShellThemeData s = RaShellThemeData.of(context);
    final RaShellPlatform platform = RaShellPlatform.current;
    final bool customCaption = platform.drawsCaptionButtons;
    final double controlsLeft = s.controlsLeftFor(platform);
    final double controlsOpenWidth = s.sidebarWidth - s.sidebarPadding.right - controlsLeft;

    final Widget frame = AnimatedBuilder(
      animation: _resize,
      builder: (BuildContext context, Widget? _) {
        final double t = _openness;
        final double shellWidth = lerpDouble(s.panelGap, s.sidebarWidth, t)!;
        final double controlsWidth = lerpDouble(s.controlsWidth, controlsOpenWidth, t)!;
        final double titlebarStart = lerpDouble(
          controlsLeft + s.controlsWidth + s.titlebarContentGap,
          s.sidebarWidth,
          t,
        )!;
        final bool sidebarHidden = !widget.sidebarOpen && t == 0;

        return Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(
                  key: const ValueKey<String>('ra-titlebar'),
                  height: s.titlebarHeight,
                  child: RaWindowDragArea(
                    child: Row(
                      children: <Widget>[
                        SizedBox(width: titlebarStart),
                        Expanded(child: widget.titlebar ?? const SizedBox.expand()),
                        if (customCaption) const RaWindowCaptionButtons(),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SizedBox(
                        key: const ValueKey<String>('ra-sidebar-shell'),
                        width: shellWidth,
                        child: ClipRect(
                          child: OverflowBox(
                            alignment: AlignmentDirectional.topStart,
                            minWidth: s.sidebarWidth,
                            maxWidth: s.sidebarWidth,
                            child: ExcludeFocus(
                              excluding: sidebarHidden,
                              child: Visibility(
                                visible: !sidebarHidden,
                                maintainState: true,
                                maintainAnimation: true,
                                maintainSize: true,
                                child: Padding(
                                  key: const ValueKey<String>('ra-sidebar'),
                                  padding: s.sidebarPadding,
                                  child: widget.sidebar,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(child: RaPanel(child: widget.child)),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              left: controlsLeft,
              top: 0,
              width: controlsWidth,
              height: s.titlebarHeight,
              child: RaWindowDragArea(
                child: _WindowControls(
                  sidebarOpen: widget.sidebarOpen,
                  onToggleSidebar: widget.onToggleSidebar,
                  onBack: widget.onBack,
                  onForward: widget.onForward,
                  showHistory: widget.showHistoryControls,
                ),
              ),
            ),
          ],
        );
      },
    );

    return RaWindowBackgroundSync(
      child: Offstage(
        offstage: widget.hidden,
        child: TickerMode(
          enabled: !widget.hidden,
          child: ColoredBox(color: s.chrome, child: frame),
        ),
      ),
    );
  }
}

/// 窗口按钮组：侧栏开关在左，后退 / 前进在右（侧栏展开时贴侧栏内容右缘）。
/// 悬停 / 按下不铺底色，只靠图标变深。
class _WindowControls extends StatelessWidget {
  const _WindowControls({
    required this.sidebarOpen,
    required this.onToggleSidebar,
    required this.onBack,
    required this.onForward,
    required this.showHistory,
  });

  final bool sidebarOpen;
  final VoidCallback? onToggleSidebar;
  final VoidCallback? onBack;
  final VoidCallback? onForward;
  final bool showHistory;

  @override
  Widget build(BuildContext context) {
    final RaShellThemeData s = RaShellThemeData.of(context);
    final RaThemeData theme = RaTheme.of(context);
    final RaShellStrings strings = RaShellStrings.of(context);
    final RaButtonStyle style = RaButtonStyle(
      backgroundColor: const WidgetStatePropertyAll<Color?>(null),
      foregroundColor: raStateColor(
        s.windowButtonColor,
        hovered: s.windowButtonActiveColor,
        pressed: s.windowButtonActiveColor,
        disabled: theme.colors.disabledInk,
      ),
    );
    return Semantics(
      container: true,
      label: strings.windowControls,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          RaIconButton(
            key: const ValueKey<String>('ra-sidebar-toggle'),
            label: sidebarOpen ? strings.collapseSidebar : strings.expandSidebar,
            shortcut: strings.shortcut('\\'),
            icon: RaSidebarIcon(collapsed: !sidebarOpen),
            onPressed: onToggleSidebar,
            style: style,
          ),
          if (showHistory)
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: s.controlsGap,
              children: <Widget>[
                RaIconButton(
                  key: const ValueKey<String>('ra-back'),
                  label: strings.back,
                  shortcut: strings.shortcut('['),
                  icon: RaIcon.glyph(theme.icons.chevronLeft),
                  onPressed: onBack,
                  style: style,
                ),
                RaIconButton(
                  key: const ValueKey<String>('ra-forward'),
                  label: strings.forward,
                  shortcut: strings.shortcut(']'),
                  icon: RaIcon.glyph(theme.icons.chevronRight),
                  onPressed: onForward,
                  style: style,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// 内容面板：画布底色、圆角 12、0.5px 描边 + 淡阴影；距窗口右 / 下 8。
class RaPanel extends StatelessWidget {
  const RaPanel({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final RaShellThemeData s = RaShellThemeData.of(context);
    final BorderRadius radius = BorderRadius.circular(s.panelRadius);
    return Padding(
      padding: EdgeInsets.only(right: s.panelGap, bottom: s.panelGap),
      child: Container(
        key: const ValueKey<String>('ra-panel'),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: s.canvas, borderRadius: radius, boxShadow: s.panelShadows),
        foregroundDecoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(color: s.canvasBorder, width: RaHairline.snap(context, s.borderWidth)),
        ),
        child: child,
      ),
    );
  }
}

/// 内容面板顶栏：44px、可拖动窗口；leading / center / trailing 三段（中间段始终居中）。
class RaPanelHeader extends StatelessWidget {
  const RaPanelHeader({super.key, this.leading, this.center, this.trailing, this.bordered = false});

  final Widget? leading;
  final Widget? center;
  final Widget? trailing;

  /// 底部细线。
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final RaShellThemeData s = RaShellThemeData.of(context);
    final RaThemeData theme = RaTheme.of(context);
    return RaWindowDragArea(
      child: Container(
        height: s.panelHeaderHeight,
        padding: s.panelHeaderPadding,
        decoration: bordered
            ? BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: theme.colors.border,
                    width: RaHairline.snap(context, s.borderWidth),
                  ),
                ),
              )
            : null,
        child: Row(
          spacing: s.panelHeaderGap,
          children: <Widget>[
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: leading ?? const SizedBox.shrink(),
              ),
            ),
            ?center,
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: trailing ?? const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 面板标题（13 / 500）。
class RaPanelTitle extends StatelessWidget {
  const RaPanelTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final RaThemeData theme = RaTheme.of(context);
    return Padding(
      padding: EdgeInsetsDirectional.only(start: theme.spacing.xs2),
      child: Text(
        text,
        style: theme.typography.bodyMedium.copyWith(color: theme.colors.ink),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// 面包屑中的一项。
@immutable
class RaBreadcrumbItem {
  const RaBreadcrumbItem({required this.label, this.onPressed, this.current = false});

  final String label;
  final VoidCallback? onPressed;
  final bool current;
}

/// 顶栏面包屑：可点项是 28px 胶囊安静按钮（当前项正文色，其余次要色，最宽 220），分隔符 12px 弱色 ›。
class RaBreadcrumb extends StatelessWidget {
  const RaBreadcrumb({super.key, required this.items});

  final List<RaBreadcrumbItem> items;

  @override
  Widget build(BuildContext context) {
    final RaThemeData theme = RaTheme.of(context);
    final RaShellThemeData s = RaShellThemeData.of(context);
    final List<Widget> children = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      final RaBreadcrumbItem item = items[i];
      if (i > 0) {
        children.add(
          RaIcon.glyph(
            theme.icons.chevronRight,
            size: theme.sizing.iconXs,
            color: theme.colors.ink3,
          ),
        );
      }
      children.add(
        Flexible(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: s.breadcrumbMaxWidth),
            child: RaButton(
              onPressed: item.onPressed,
              variant: RaButtonVariant.quiet,
              size: RaButtonSize.sm,
              selected: item.current,
              style: RaButtonStyle(
                radius: theme.radii.pill,
                textStyle: theme.typography.bodyMedium,
                foregroundColor: raStateColor(
                  item.current ? theme.colors.ink : theme.colors.ink2,
                  hovered: theme.colors.ink,
                  disabled: item.current ? theme.colors.ink : theme.colors.ink2,
                ),
                backgroundColor: raStateColor(null, hovered: theme.colors.hover),
              ),
              child: Text(item.label),
            ),
          ),
        ),
      );
    }
    return Row(mainAxisSize: MainAxisSize.min, spacing: s.panelHeaderItemGap, children: children);
  }
}
