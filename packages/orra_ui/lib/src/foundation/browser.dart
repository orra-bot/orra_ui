import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// 是否运行在浏览器中（[kIsWeb]）。测试中可用 [debugRaIsWebOverride] 模拟网页端。
bool get raIsWeb => debugRaIsWebOverride ?? kIsWeb;

/// 测试用：覆盖 [raIsWeb]。测试结束时需恢复为 null。
bool? debugRaIsWebOverride;

/// 网页端：指针位于 [child] 上时禁用浏览器自带的右键菜单，离开后恢复，
/// 让应用自己的右键菜单（`RaContextMenu` 等）不被浏览器菜单盖住；区域外（如输入框）仍是浏览器菜单。
/// 多个区域共用一个计数：从一个区域直接移到相邻区域时不会闪开浏览器菜单。非网页端直接返回 [child]。
class RaBrowserContextMenuGuard extends StatefulWidget {
  const RaBrowserContextMenuGuard({super.key, required this.child, this.enabled = true});

  final Widget child;
  final bool enabled;

  @override
  State<RaBrowserContextMenuGuard> createState() => _RaBrowserContextMenuGuardState();
}

class _RaBrowserContextMenuGuardState extends State<RaBrowserContextMenuGuard> {
  /// 当前悬停中的区域数。
  static int _active = 0;

  /// 已经通知浏览器禁用自带菜单。
  static bool _disabled = false;
  static bool _syncScheduled = false;

  bool _hovered = false;

  void _setHovered(bool value) {
    if (value == _hovered) return;
    _hovered = value;
    _active += value ? 1 : -1;
    _scheduleSync();
  }

  /// 同一次指针移动中「离开 a」先于「进入 b」派发：合并到微任务里再比较，相邻区域之间不会先启用再禁用。
  static void _scheduleSync() {
    if (_syncScheduled) return;
    _syncScheduled = true;
    scheduleMicrotask(() {
      _syncScheduled = false;
      final bool disable = _active > 0;
      if (disable == _disabled) return;
      _disabled = disable;
      // 直接使用 BrowserContextMenu 背后的系统通道：BrowserContextMenu 在非网页端断言失败，无法在测试中模拟。
      SystemChannels.contextMenu.invokeMethod<void>(
        disable ? 'disableContextMenu' : 'enableContextMenu',
      );
    });
  }

  @override
  void didUpdateWidget(RaBrowserContextMenuGuard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled) _setHovered(false);
  }

  @override
  void dispose() {
    _setHovered(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!raIsWeb || !widget.enabled) return widget.child;
    return MouseRegion(
      opaque: false,
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: widget.child,
    );
  }
}
