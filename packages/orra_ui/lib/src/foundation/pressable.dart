import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../theme/theme.dart';
import '../theme/theme_data.dart';
import 'motion.dart';

/// 标记「不可拖动窗口」的区域（相当于 CSS 的 `-webkit-app-region: no-drag`）。
///
/// 所有可交互组件都自带此标记；窗口拖动区（orra_desktop_shell 的 RaWindowDragArea）
/// 在按下位置命中此标记时不拖动窗口。
class RaNoDragRegion extends StatelessWidget {
  const RaNoDragRegion({super.key, required this.child});

  final Widget child;

  /// 命中测试路径上的标记值。
  static const Object marker = _NoDragMarker();

  /// [result] 中是否包含不可拖动标记。
  static bool hitTestContainsMarker(HitTestResult result) {
    for (final HitTestEntry entry in result.path) {
      final HitTestTarget target = entry.target;
      if (target is RenderMetaData && identical(target.metaData, marker)) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) =>
      MetaData(metaData: marker, behavior: HitTestBehavior.translucent, child: child);
}

class _NoDragMarker {
  const _NoDragMarker();
}

/// 交互状态与本次过渡应使用的时长。
@immutable
class RaPressState {
  const RaPressState(this.states, this.transition);

  final Set<WidgetState> states;

  /// Linear 的节奏：悬停出现立即生效、移开淡出 75ms、按下 50ms。
  final Duration transition;

  bool get hovered => states.contains(WidgetState.hovered);
  bool get pressed => states.contains(WidgetState.pressed);
  bool get focused => states.contains(WidgetState.focused);
  bool get selected => states.contains(WidgetState.selected);
  bool get disabled => states.contains(WidgetState.disabled);
}

typedef RaPressableBuilder = Widget Function(BuildContext context, RaPressState state);

/// 可点击区域的底座：悬停、按下、聚焦、键盘激活（Enter / Space）、无障碍语义、鼠标指针，
/// 以及「悬停立即出现、移开淡出」的过渡时长。不画任何东西，外观交给 [builder]。
///
/// 全局不显示焦点环（产品决定），[RaPressState.focused] 仍可用于需要的场景。
class RaPressable extends StatefulWidget {
  const RaPressable({
    super.key,
    required this.builder,
    this.onPressed,
    this.onLongPress,
    this.onSecondaryTapUp,
    this.onMiddlePressed,
    this.onHoverChanged,
    this.onFocusChanged,
    this.focusNode,
    this.autofocus = false,
    this.selected = false,
    this.focusableWhenDisabled = false,
    this.canRequestFocus = true,
    this.mouseCursor,
    this.semanticLabel,
    this.semanticsButton = true,
    this.excludeSemantics = false,
    this.semanticsChecked,
    this.semanticsMixed,
    this.semanticsToggled,
    this.semanticsInMutuallyExclusiveGroup,
    this.pressOnDown = false,
    this.hoverExitDuration,
  });

  final RaPressableBuilder builder;

  /// 为空时禁用。
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final GestureTapUpCallback? onSecondaryTapUp;

  /// 鼠标中键点击（例如在新标签页打开）。
  final VoidCallback? onMiddlePressed;
  final ValueChanged<bool>? onHoverChanged;
  final ValueChanged<bool>? onFocusChanged;
  final FocusNode? focusNode;
  final bool autofocus;

  /// 选中 / 当前项 / 弹出层已展开。
  final bool selected;

  /// 禁用时仍可聚焦（加载中的按钮）。
  final bool focusableWhenDisabled;
  final bool canRequestFocus;
  final MouseCursor? mouseCursor;
  final String? semanticLabel;
  final bool semanticsButton;
  final bool excludeSemantics;

  /// 复选框 / 单选项的勾选状态；[semanticsMixed] 为「部分选中」。
  final bool? semanticsChecked;
  final bool? semanticsMixed;

  /// 开关的开合状态。
  final bool? semanticsToggled;

  /// 单选组中的一项。
  final bool? semanticsInMutuallyExclusiveGroup;

  /// 按下即触发（标签页：按下即选中，不等松开）。
  final bool pressOnDown;

  /// 悬停移开时的过渡时长；为空时用主题的基础时长（75ms 淡出）。
  final Duration? hoverExitDuration;

  bool get enabled => onPressed != null;

  @override
  State<RaPressable> createState() => _RaPressableState();
}

class _RaPressableState extends State<RaPressable> {
  bool _hovered = false;
  bool _pressed = false;
  bool _focused = false;
  Duration _transition = Duration.zero;
  Set<WidgetState> _lastStates = const <WidgetState>{};

  late final Map<Type, Action<Intent>> _actions = <Type, Action<Intent>>{
    ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) => _activate()),
    ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(onInvoke: (_) => _activate()),
  };

  Object? _activate() {
    widget.onPressed?.call();
    return null;
  }

  Set<WidgetState> get _states => <WidgetState>{
    if (_hovered) WidgetState.hovered,
    if (_pressed && widget.enabled) WidgetState.pressed,
    if (_focused) WidgetState.focused,
    if (widget.selected) WidgetState.selected,
    if (!widget.enabled) WidgetState.disabled,
  };

  /// 根据状态变化选择过渡时长：出现悬停 / 选中立即生效；按下 / 松开用快速；其余（移开）用基础时长淡出。
  Duration _transitionFor(Set<WidgetState> next, RaThemeData theme) {
    final Set<WidgetState> prev = _lastStates;
    bool added(WidgetState s) => next.contains(s) && !prev.contains(s);
    bool removed(WidgetState s) => !next.contains(s) && prev.contains(s);
    if (added(WidgetState.hovered) || added(WidgetState.selected)) return theme.motion.instant;
    if (added(WidgetState.pressed) || removed(WidgetState.pressed)) return theme.motion.fast;
    if (removed(WidgetState.hovered) && widget.hoverExitDuration != null) {
      return widget.hoverExitDuration!;
    }
    return theme.motion.base;
  }

  void _setHovered(bool value) {
    if (_hovered == value) return;
    setState(() => _hovered = value);
    widget.onHoverChanged?.call(value);
  }

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  void didUpdateWidget(RaPressable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled && _pressed) _pressed = false;
  }

  @override
  Widget build(BuildContext context) {
    final RaThemeData theme = RaTheme.of(context);
    final Set<WidgetState> states = _states;
    if (!setEquals(states, _lastStates)) {
      _transition = RaReducedMotion.resolve(context, _transitionFor(states, theme));
      _lastStates = states;
    }
    final bool enabled = widget.enabled;
    final MouseCursor cursor =
        widget.mouseCursor ?? (enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden);

    Widget result = widget.builder(context, RaPressState(states, _transition));

    result = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled
          ? (_) {
              _setPressed(true);
              if (widget.pressOnDown) widget.onPressed?.call();
            }
          : null,
      onTapUp: enabled ? (_) => _setPressed(false) : null,
      onTap: enabled && !widget.pressOnDown ? widget.onPressed : null,
      onTapCancel: enabled ? () => _setPressed(false) : null,
      onLongPress: enabled ? widget.onLongPress : null,
      onSecondaryTapUp: widget.onSecondaryTapUp,
      onTertiaryTapUp: widget.onMiddlePressed == null ? null : (_) => widget.onMiddlePressed!(),
      child: result,
    );

    result = FocusableActionDetector(
      enabled: (enabled || widget.focusableWhenDisabled) && widget.canRequestFocus,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      actions: enabled ? _actions : const <Type, Action<Intent>>{},
      mouseCursor: cursor,
      onFocusChange: (bool focused) {
        setState(() => _focused = focused);
        widget.onFocusChanged?.call(focused);
      },
      child: MouseRegion(
        onEnter: (_) => _setHovered(true),
        onExit: (_) {
          _setHovered(false);
          _setPressed(false);
        },
        child: result,
      ),
    );

    return RaNoDragRegion(
      child: Semantics(
        container: true,
        button: widget.semanticsButton,
        enabled: enabled,
        selected: widget.selected ? true : null,
        checked: widget.semanticsChecked,
        mixed: widget.semanticsMixed,
        toggled: widget.semanticsToggled,
        inMutuallyExclusiveGroup: widget.semanticsInMutuallyExclusiveGroup,
        label: widget.semanticLabel,
        excludeSemantics: widget.excludeSemantics,
        onTap: enabled ? widget.onPressed : null,
        child: result,
      ),
    );
  }
}
