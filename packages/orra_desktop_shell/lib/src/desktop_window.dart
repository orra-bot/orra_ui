import 'dart:io';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart';
import 'package:orra_ui/orra_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window_manager/window_manager.dart';

import 'shell_theme.dart';
import 'window_controller.dart';
import 'window_state.dart';

/// 主窗口选项。
@immutable
class RaWindowOptions {
  const RaWindowOptions({
    this.title = '',
    this.defaultSize = const Size(1280, 820),
    this.minimumSize = const Size(900, 600),
    this.rememberState = true,
    this.stateFileName = 'window-state.json',
    this.theme,
    this.darkTheme,
  });

  final String title;

  /// 首次启动（或保存的位置不可用）时的尺寸。
  final Size defaultSize;
  final Size minimumSize;

  /// 记住窗口位置、尺寸与最大化状态（全屏 / 最小化时不保存）。
  final bool rememberState;
  final String stateFileName;

  /// 用于推导窗口底色与标题栏几何；与 RaApp 的主题保持一致。
  final RaThemeData? theme;
  final RaThemeData? darkTheme;
}

/// 主窗口初始化：在 `runApp` 之前调用。
///
/// - 隐藏系统标题栏（macOS 保留红绿灯并按标题栏中线定位；Windows / Linux 由 RaDesktopFrame 绘制窗口按钮）；
/// - 窗口底色 = 主题的 chrome（浅 / 深），首帧渲染前不显示窗口，避免闪色；
/// - 恢复上次的位置与尺寸（校验格式，并确认至少 100×50 落在某个显示器内）。
abstract final class RaDesktopWindow {
  static Future<void> ensureInitialized([RaWindowOptions options = const RaWindowOptions()]) async {
    WidgetsFlutterBinding.ensureInitialized();
    await windowManager.ensureInitialized();

    final bool dark = PlatformDispatcher.instance.platformBrightness == Brightness.dark;
    final RaThemeData theme = dark
        ? (options.darkTheme ?? RaThemeData.dark())
        : (options.theme ?? RaThemeData.light());
    final RaShellThemeData shell = theme.extension<RaShellThemeData>(RaShellThemeData.fallback);

    RaWindowStateStore? store;
    RaWindowState? saved;
    if (options.rememberState) {
      final Directory dir = await getApplicationSupportDirectory();
      store = RaWindowStateStore(
        File('${dir.path}${Platform.pathSeparator}${options.stateFileName}'),
      );
      saved = await store.load();
      if (saved != null && !await _isOnSomeDisplay(saved)) saved = null;
      saved = saved?.clampSize(options.minimumSize.width, options.minimumSize.height);
    }

    final WindowOptions windowOptions = WindowOptions(
      title: options.title,
      size: saved == null ? options.defaultSize : Size(saved.width, saved.height),
      minimumSize: options.minimumSize,
      center: saved == null,
      backgroundColor: shell.chrome,
      titleBarStyle: TitleBarStyle.hidden,
      windowButtonVisibility: true,
    );

    final RaWindowState? restore = saved;
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      if (restore != null) {
        await windowManager.setBounds(restore.bounds);
        if (restore.maximized) await windowManager.maximize();
      }
      await RaNativeWindow.setTrafficLightPosition(
        x: shell.trafficLightX,
        titlebarHeight: shell.titlebarHeight,
      );
      await windowManager.show();
      await windowManager.focus();
    });

    if (store != null) {
      final _WindowStateRecorder recorder = _WindowStateRecorder(store, restore);
      windowManager.addListener(recorder);
      await windowManager.setPreventClose(true);
    }
  }

  static Future<bool> _isOnSomeDisplay(RaWindowState state) async {
    try {
      final List<Display> displays = await screenRetriever.getAllDisplays();
      final List<Rect> areas = <Rect>[
        for (final Display d in displays)
          (d.visiblePosition ?? Offset.zero) & (d.visibleSize ?? d.size),
      ];
      return state.isVisibleOn(areas);
    } on Exception {
      return false;
    }
  }
}

/// 记录窗口位置：调整大小 / 移动时防抖写入；关闭前立即写入。
class _WindowStateRecorder with WindowListener {
  _WindowStateRecorder(this.store, RaWindowState? initial) : _normal = initial?.bounds;

  final RaWindowStateStore store;

  /// 最近一次「非最大化」时的位置与尺寸：最大化时保存它，还原后回到原位。
  Rect? _normal;

  Future<void> _record() async {
    if (await windowManager.isFullScreen() || await windowManager.isMinimized()) return;
    final bool maximized = await windowManager.isMaximized();
    if (!maximized) _normal = await windowManager.getBounds();
    final Rect? normal = _normal;
    if (normal == null) return;
    store.schedule(
      RaWindowState(
        x: normal.left,
        y: normal.top,
        width: normal.width,
        height: normal.height,
        maximized: maximized,
      ),
    );
  }

  @override
  void onWindowResized() => _record();

  @override
  void onWindowMoved() => _record();

  @override
  void onWindowMaximize() => _record();

  @override
  void onWindowUnmaximize() => _record();

  @override
  void onWindowClose() async {
    await _record();
    await store.flush();
    await windowManager.setPreventClose(false);
    await windowManager.destroy();
  }
}

/// 让窗口底色随主题变化（切换深浅色、自定义主题）。RaDesktopFrame 已内置。
class RaWindowBackgroundSync extends StatefulWidget {
  const RaWindowBackgroundSync({super.key, required this.child});

  final Widget child;

  @override
  State<RaWindowBackgroundSync> createState() => _RaWindowBackgroundSyncState();
}

class _RaWindowBackgroundSyncState extends State<RaWindowBackgroundSync> {
  Color? _applied;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Color chrome = RaShellThemeData.of(context).chrome;
    if (chrome != _applied) {
      _applied = chrome;
      RaWindowScope.of(context).setBackgroundColor(chrome);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
