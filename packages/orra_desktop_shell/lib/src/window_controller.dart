import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:window_manager/window_manager.dart';

/// 外壳对窗口的操作。默认实现基于 window_manager；测试中可通过 [RaWindowScope] 注入假实现。
abstract class RaWindowController {
  /// 开始拖动窗口（在标题栏空白处按下并移动时调用）。
  Future<void> startDragging();

  /// 最大化 / 还原。
  Future<void> toggleMaximize();
  Future<void> minimize();
  Future<void> close();

  /// 窗口底色：必须与主题的 chrome 一致，否则首帧与调整大小时闪色。
  Future<void> setBackgroundColor(Color color);

  /// 是否最大化（Windows / Linux 窗口按钮据此切换图标）。
  ValueListenable<bool> get maximized;
}

/// 基于 window_manager 的默认实现。插件不可用（如单元测试）时静默忽略。
class RaWindowManagerController with WindowListener implements RaWindowController {
  RaWindowManagerController._();

  static final RaWindowManagerController instance = RaWindowManagerController._();

  final ValueNotifier<bool> _maximized = ValueNotifier<bool>(false);
  bool _listening = false;

  void _ensureListening() {
    if (_listening) return;
    _listening = true;
    _guard(() async {
      windowManager.addListener(this);
      _maximized.value = await windowManager.isMaximized();
    });
  }

  static Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } on MissingPluginException {
      // 无窗口插件的环境（单元测试、Web）：忽略。
    }
  }

  @override
  ValueListenable<bool> get maximized {
    _ensureListening();
    return _maximized;
  }

  @override
  Future<void> startDragging() => _guard(windowManager.startDragging);

  @override
  Future<void> toggleMaximize() => _guard(() async {
    if (await windowManager.isMaximized()) {
      await windowManager.unmaximize();
    } else {
      await windowManager.maximize();
    }
  });

  @override
  Future<void> minimize() => _guard(windowManager.minimize);

  @override
  Future<void> close() => _guard(windowManager.close);

  @override
  Future<void> setBackgroundColor(Color color) =>
      _guard(() => windowManager.setBackgroundColor(color));

  @override
  void onWindowMaximize() => _maximized.value = true;

  @override
  void onWindowUnmaximize() => _maximized.value = false;
}

/// 向下提供 [RaWindowController]。
class RaWindowScope extends InheritedWidget {
  const RaWindowScope({super.key, required this.controller, required super.child});

  final RaWindowController controller;

  static RaWindowController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<RaWindowScope>()?.controller ??
      RaWindowManagerController.instance;

  @override
  bool updateShouldNotify(RaWindowScope old) => controller != old.controller;
}

/// orra_desktop_shell 自带的原生能力（目前只有 macOS 红绿灯定位）。
abstract final class RaNativeWindow {
  static const MethodChannel _channel = MethodChannel('orra_desktop_shell');

  /// macOS：把红绿灯放到 x = [x]、在高 [titlebarHeight] 的标题栏内垂直居中，
  /// 并在窗口缩放、退出全屏、切换焦点后自动重新定位。其他平台无操作。
  static Future<void> setTrafficLightPosition({
    required double x,
    required double titlebarHeight,
  }) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.macOS) return;
    try {
      await _channel.invokeMethod<void>('setTrafficLightPosition', <String, double>{
        'x': x,
        'titlebarHeight': titlebarHeight,
      });
    } on MissingPluginException {
      // 测试环境。
    }
  }
}
