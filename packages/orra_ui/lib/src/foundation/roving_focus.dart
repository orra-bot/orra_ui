import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// 一组单选项的键盘导航（Base UI Tabs / ToggleGroup / RadioGroup 的行为）：
/// 方向键移到上一项 / 下一项（首尾循环），Home / End 移到第一项 / 最后一项，跳过禁用项。
///
/// 只负责算出目标序号并交给 [onMove]；选中与聚焦由组件自己完成。
class RaRovingGroup extends StatelessWidget {
  const RaRovingGroup({
    super.key,
    required this.count,
    required this.currentIndex,
    required this.onMove,
    required this.child,
    this.axis,
    this.isEnabled,
  });

  final int count;

  /// 当前聚焦（或选中）的项；-1 表示没有。
  final int Function() currentIndex;
  final ValueChanged<int> onMove;
  final Widget child;

  /// 响应的方向；为空时横竖方向键都响应（单选组）。
  final Axis? axis;
  final bool Function(int index)? isEnabled;

  int? _target(KeyEvent event, TextDirection direction) {
    final LogicalKeyboardKey key = event.logicalKey;
    final bool horizontal = axis == null || axis == Axis.horizontal;
    final bool vertical = axis == null || axis == Axis.vertical;
    final bool rtl = direction == TextDirection.rtl;
    int step = 0;
    if (horizontal && key == LogicalKeyboardKey.arrowRight) step = rtl ? -1 : 1;
    if (horizontal && key == LogicalKeyboardKey.arrowLeft) step = rtl ? 1 : -1;
    if (vertical && key == LogicalKeyboardKey.arrowDown) step = 1;
    if (vertical && key == LogicalKeyboardKey.arrowUp) step = -1;
    bool enabledAt(int i) => isEnabled?.call(i) ?? true;
    if (key == LogicalKeyboardKey.home) {
      for (int i = 0; i < count; i++) {
        if (enabledAt(i)) return i;
      }
      return null;
    }
    if (key == LogicalKeyboardKey.end) {
      for (int i = count - 1; i >= 0; i--) {
        if (enabledAt(i)) return i;
      }
      return null;
    }
    if (step == 0) return null;
    final int from = currentIndex();
    int i = from < 0 ? (step > 0 ? -1 : count) : from;
    for (int n = 0; n < count; n++) {
      i = (i + step) % count;
      if (i < 0) i += count;
      if (enabledAt(i)) return i;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final TextDirection direction = Directionality.maybeOf(context) ?? TextDirection.ltr;
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: (FocusNode node, KeyEvent event) {
        if (event is! KeyDownEvent && event is! KeyRepeatEvent) return KeyEventResult.ignored;
        final int? target = _target(event, direction);
        if (target == null) return KeyEventResult.ignored;
        onMove(target);
        return KeyEventResult.handled;
      },
      child: child,
    );
  }
}
