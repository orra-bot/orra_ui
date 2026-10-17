import 'package:flutter/foundation.dart';
import 'package:orra_ui/orra_ui.dart';

/// 外壳运行的宿主：决定窗口按钮、菜单栏与窗口能力。
///
/// - [macOS]：系统红绿灯 + 原生菜单栏；
/// - [windows] / [linux]：外壳绘制最小化 / 最大化 / 关闭；
/// - [web]：浏览器标签页，没有窗口按钮与原生菜单栏，窗口操作（拖动、最大化）无效。
///   未正式支持的移动平台按 [web] 处理（同样没有窗口外框）。
enum RaShellPlatform {
  macOS,
  windows,
  linux,
  web;

  /// 当前宿主。测试中用 `debugRaIsWebOverride = true` 模拟网页端、`TargetPlatformVariant` 模拟桌面系统。
  static RaShellPlatform get current {
    if (raIsWeb) return RaShellPlatform.web;
    return switch (defaultTargetPlatform) {
      TargetPlatform.macOS => RaShellPlatform.macOS,
      TargetPlatform.windows => RaShellPlatform.windows,
      TargetPlatform.linux || TargetPlatform.fuchsia => RaShellPlatform.linux,
      TargetPlatform.android || TargetPlatform.iOS => RaShellPlatform.web,
    };
  }

  /// 系统红绿灯占据标题栏左侧。
  bool get hasTrafficLights => this == RaShellPlatform.macOS;

  /// 由外壳绘制最小化 / 最大化 / 关闭按钮。
  bool get drawsCaptionButtons => this == RaShellPlatform.windows || this == RaShellPlatform.linux;

  /// 生成原生菜单栏（其余宿主只保留快捷键）。
  bool get hasNativeMenuBar => this == RaShellPlatform.macOS;
}

/// 主修饰键是否为 ⌘：按用户的操作系统判断，网页端在 Mac 浏览器中同样为 ⌘。
bool get raUsesCommandKey =>
    defaultTargetPlatform == TargetPlatform.macOS || defaultTargetPlatform == TargetPlatform.iOS;
