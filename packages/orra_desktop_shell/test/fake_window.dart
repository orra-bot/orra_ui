import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orra_desktop_shell/orra_desktop_shell.dart';
import 'package:orra_ui/orra_ui.dart';

class FakeWindow implements RaWindowController {
  int drags = 0;
  int maximizeToggles = 0;
  int minimizes = 0;
  int closes = 0;
  final List<Color> backgrounds = <Color>[];
  final ValueNotifier<bool> _maximized = ValueNotifier<bool>(false);

  @override
  ValueListenable<bool> get maximized => _maximized;

  @override
  Future<void> startDragging() async => drags++;

  @override
  Future<void> toggleMaximize() async {
    maximizeToggles++;
    _maximized.value = !_maximized.value;
  }

  @override
  Future<void> minimize() async => minimizes++;

  @override
  Future<void> close() async => closes++;

  @override
  Future<void> setBackgroundColor(Color color) async => backgrounds.add(color);
}

/// 1280×820、2 倍屏的桌面窗口。
Future<FakeWindow> pumpFrame(
  WidgetTester tester, {
  bool sidebarOpen = true,
  VoidCallback? onToggle,
  RaThemeMode mode = RaThemeMode.light,
  Widget? sidebar,
  Widget? child,
  Widget? titlebar,
  FakeWindow? window,
}) async {
  tester.view.devicePixelRatio = 2;
  tester.view.physicalSize = const Size(1280, 820) * 2;
  addTearDown(tester.view.reset);
  final FakeWindow fake = window ?? FakeWindow();
  await tester.pumpWidget(
    RaApp(
      themeMode: mode,
      debugShowCheckedModeBanner: false,
      home: RaWindowScope(
        controller: fake,
        child: RaDesktopFrame(
          sidebarOpen: sidebarOpen,
          onToggleSidebar: onToggle ?? () {},
          onBack: () {},
          titlebar: titlebar,
          sidebar: sidebar ?? const SizedBox.expand(),
          child: child ?? const SizedBox.expand(),
        ),
      ),
    ),
  );
  return fake;
}
