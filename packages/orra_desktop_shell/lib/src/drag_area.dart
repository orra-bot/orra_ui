import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:orra_ui/orra_ui.dart';

import 'window_controller.dart';

/// 窗口拖动区（相当于 CSS 的 `-webkit-app-region: drag`）：在空白处按下并移动即拖动窗口，双击最大化 / 还原。
///
/// 区域内的按钮、输入框等可交互组件自带 [RaNoDragRegion] 标记，从它们上面开始的拖动不会移动窗口；
/// 按钮之间的空白仍然可以拖动。
///
/// 只用 Listener 识别拖动与双击，不参与手势竞技场，因此不会延迟区域内按钮的点击。
class RaWindowDragArea extends StatefulWidget {
  const RaWindowDragArea({super.key, required this.child, this.maximizeOnDoubleTap = true});

  final Widget child;
  final bool maximizeOnDoubleTap;

  @override
  State<RaWindowDragArea> createState() => _RaWindowDragAreaState();
}

class _RaWindowDragAreaState extends State<RaWindowDragArea> {
  int? _pointer;
  Offset? _downPosition;
  bool _dragging = false;
  Duration? _lastUpTime;
  Offset? _lastUpPosition;

  bool _hitsNoDrag(PointerEvent event) {
    final HitTestResult result = HitTestResult();
    WidgetsBinding.instance.hitTestInView(result, event.position, event.viewId);
    return RaNoDragRegion.hitTestContainsMarker(result);
  }

  void _handleDown(PointerDownEvent event) {
    if (event.buttons != kPrimaryButton || _hitsNoDrag(event)) {
      _pointer = null;
      return;
    }
    _pointer = event.pointer;
    _downPosition = event.position;
    _dragging = false;
  }

  void _handleMove(PointerMoveEvent event) {
    if (event.pointer != _pointer || _dragging) return;
    if ((event.position - _downPosition!).distance > kTouchSlop / 2) {
      _dragging = true;
      RaWindowScope.of(context).startDragging();
    }
  }

  void _handleUp(PointerUpEvent event) {
    if (event.pointer != _pointer) return;
    _pointer = null;
    if (_dragging || !widget.maximizeOnDoubleTap) {
      _lastUpTime = null;
      return;
    }
    final Duration now = event.timeStamp;
    final bool isDouble =
        _lastUpTime != null &&
        now - _lastUpTime! <= kDoubleTapTimeout &&
        (event.position - _lastUpPosition!).distance <= kDoubleTapSlop;
    if (isDouble) {
      _lastUpTime = null;
      RaWindowScope.of(context).toggleMaximize();
    } else {
      _lastUpTime = now;
      _lastUpPosition = event.position;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _handleDown,
      onPointerMove: _handleMove,
      onPointerUp: _handleUp,
      onPointerCancel: (_) => _pointer = null,
      child: widget.child,
    );
  }
}
