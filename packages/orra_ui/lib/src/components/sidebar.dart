import 'package:flutter/widgets.dart';

import '../foundation/motion.dart';
import '../foundation/pressable.dart';
import '../foundation/surface.dart';
import '../icons/ra_icon.dart';
import '../theme/theme.dart';
import '../theme/theme_data.dart';
import '../tokens/components.dart';

/// 侧栏行的语气：default 默认 · primary 主动作（新建、搜索）· child 子项（文字缩进）· muted 弱化（已归档）。
enum RaSidebarItemTone { normal, primary, child, muted }

/// 侧栏导航行：图标 + 文本 + 行尾信息或快捷键。28px 高、圆角 8；
/// 默认次要色，悬停 / 选中变为正文色；底色只用半透明叠加色。
class RaSidebarItem extends StatelessWidget {
  const RaSidebarItem({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailing,
    this.shortcut,
    this.selected = false,
    this.tone = RaSidebarItemTone.normal,
    this.onMiddlePressed,
    this.onSecondaryTapUp,
    this.focusNode,
  });

  final String label;
  final VoidCallback? onPressed;

  /// 14px 图标（RaIcon / Icon）。
  final Widget? icon;

  /// 行尾元信息（计数、相对时间、状态点）。
  final Widget? trailing;
  final String? shortcut;

  /// 当前页面。
  final bool selected;
  final RaSidebarItemTone tone;

  /// 中键点击（例如在新标签页打开）。
  final VoidCallback? onMiddlePressed;
  final GestureTapUpCallback? onSecondaryTapUp;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final RaThemeData theme = RaTheme.of(context);
    final RaSidebarThemeData s = theme.sidebar;
    return RaPressable(
      onPressed: onPressed,
      onMiddlePressed: onMiddlePressed,
      onSecondaryTapUp: onSecondaryTapUp,
      selected: selected,
      focusNode: focusNode,
      semanticLabel: label,
      excludeSemantics: true,
      builder: (BuildContext context, RaPressState state) {
        final Color background = state.pressed
            ? s.pressedColor
            : state.selected
            ? s.selectedColor
            : state.hovered
            ? s.hoverColor
            : const Color(0x00000000);
        final Color idleInk = tone == RaSidebarItemTone.muted ? s.itemMutedColor : s.itemColor;
        final Color foreground = state.hovered || state.selected ? s.itemActiveColor : idleInk;
        return RaAnimatedSurface(
          duration: state.transition,
          backgroundColor: background,
          foregroundColor: foreground,
          textStyle: s.itemTextStyle,
          iconSize: s.itemIconSize,
          radius: s.itemRadius,
          constraints: BoxConstraints.tightFor(height: s.itemHeight),
          padding: EdgeInsetsDirectional.only(
            start: tone == RaSidebarItemTone.child ? s.itemIndentChild : s.itemPaddingX,
            end: s.itemPaddingX,
          ),
          child: Row(
            spacing: s.itemGap,
            children: <Widget>[
              if (icon != null)
                SizedBox(
                  width: s.itemIconSize,
                  child: Center(child: icon),
                ),
              Expanded(
                child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, softWrap: false),
              ),
              if (trailing != null) DefaultTextStyle(style: s.trailingStyle, child: trailing!),
              if (shortcut != null) Text(shortcut!, style: s.shortcutStyle),
            ],
          ),
        );
      },
    );
  }
}

/// 侧栏分组：标题可折叠（实心小三角常显），整行可悬停；右侧可放一个操作按钮（如「+」）。
class RaSidebarSection extends StatefulWidget {
  const RaSidebarSection({
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
  State<RaSidebarSection> createState() => _RaSidebarSectionState();
}

class _RaSidebarSectionState extends State<RaSidebarSection> with SingleTickerProviderStateMixin {
  late bool _expanded = widget.expanded ?? widget.initiallyExpanded;
  late final AnimationController _controller = AnimationController(
    vsync: this,
    value: _expanded ? 1 : 0,
  );
  bool _headHovered = false;
  Duration _headTransition = Duration.zero;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.duration = RaReducedMotion.resolve(context, RaTheme.of(context).motion.base);
  }

  @override
  void didUpdateWidget(RaSidebarSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool? expanded = widget.expanded;
    if (expanded != null && expanded != _expanded) _setExpanded(expanded, notify: false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setExpanded(bool value, {bool notify = true}) {
    setState(() => _expanded = value);
    if (value) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    if (notify) widget.onExpandedChanged?.call(value);
  }

  void _setHeadHovered(bool value) {
    final RaThemeData theme = RaTheme.of(context);
    setState(() {
      _headHovered = value;
      _headTransition = RaReducedMotion.resolve(
        context,
        value ? theme.motion.instant : theme.motion.base,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final RaThemeData theme = RaTheme.of(context);
    final RaSidebarThemeData s = theme.sidebar;
    final Widget toggle = RaPressable(
      onPressed: () => _setExpanded(!_expanded),
      semanticLabel: widget.title,
      excludeSemantics: true,
      builder: (BuildContext context, RaPressState state) => Semantics(
        expanded: _expanded,
        child: SizedBox(
          height: s.sectionHeadHeight,
          child: Row(
            spacing: s.sectionToggleGap,
            children: <Widget>[
              Flexible(
                child: Text(
                  widget.title,
                  style: s.sectionTitleStyle.copyWith(color: s.sectionTitleColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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

    final Widget head = MouseRegion(
      onEnter: (_) => _setHeadHovered(true),
      onExit: (_) => _setHeadHovered(false),
      child: RaAnimatedSurface(
        duration: _headTransition,
        backgroundColor: _headHovered ? s.hoverColor : const Color(0x00000000),
        radius: s.itemRadius,
        padding: s.sectionHeadPadding,
        constraints: BoxConstraints.tightFor(height: s.sectionHeadHeight),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Align(alignment: AlignmentDirectional.centerStart, child: toggle),
            ),
            if (widget.action != null)
              SizedBox.square(
                dimension: s.sectionActionSize,
                child: FittedBox(child: widget.action),
              ),
          ],
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(height: s.sectionGap),
        head,
        SizedBox(height: s.sectionHeadBottomGap),
        AnimatedBuilder(
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: s.rowGap,
            children: widget.children,
          ),
        ),
      ],
    );
  }
}

/// 状态圆点：attention 需要处理 · running 运行中（带光晕）· online 在线 · offline 离线。
enum RaStatusTone { attention, running, online, offline }

class RaStatusDot extends StatelessWidget {
  const RaStatusDot({super.key, required this.tone, this.label});

  final RaStatusTone tone;

  /// 无障碍名称；为空时对读屏隐藏。
  final String? label;

  @override
  Widget build(BuildContext context) {
    final RaSidebarThemeData s = RaTheme.of(context).sidebar;
    final bool small = tone == RaStatusTone.online || tone == RaStatusTone.offline;
    final Color color = switch (tone) {
      RaStatusTone.attention => s.dotAttention,
      RaStatusTone.running => s.dotRunning,
      RaStatusTone.online => s.dotOnline,
      RaStatusTone.offline => s.dotOffline,
    };
    final double size = small ? s.dotSizeSmall : s.dotSize;
    final Widget dot = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: tone == RaStatusTone.running
            ? <BoxShadow>[BoxShadow(color: s.dotRunningHalo, spreadRadius: s.dotHaloWidth)]
            : null,
      ),
    );
    if (label == null) return ExcludeSemantics(child: dot);
    return Semantics(label: label, image: true, child: dot);
  }
}
