import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orra_desktop_shell/orra_desktop_shell.dart';
import 'package:orra_ui/orra_ui.dart';

import 'fake_window.dart';

const ValueKey<String> kToggle = ValueKey<String>('ra-sidebar-toggle');
const ValueKey<String> kBack = ValueKey<String>('ra-back');
const ValueKey<String> kForward = ValueKey<String>('ra-forward');
const ValueKey<String> kPanel = ValueKey<String>('ra-panel');
const ValueKey<String> kTitlebar = ValueKey<String>('ra-titlebar');

/// 网页端：VM 测试中用 debugRaIsWebOverride 模拟浏览器，TargetPlatformVariant 模拟用户的操作系统。
void main() {
  setUp(() => debugRaIsWebOverride = true);
  tearDown(() => debugRaIsWebOverride = null);

  const TargetPlatformVariant hosts = TargetPlatformVariant(<TargetPlatform>{
    TargetPlatform.macOS,
    TargetPlatform.windows,
    TargetPlatform.linux,
  });

  test('任何操作系统上的浏览器都是 RaShellPlatform.web', () {
    for (final TargetPlatform p in TargetPlatform.values) {
      debugDefaultTargetPlatformOverride = p;
      expect(RaShellPlatform.current, RaShellPlatform.web, reason: '$p');
    }
    debugDefaultTargetPlatformOverride = null;
    expect(RaShellPlatform.web.hasTrafficLights, isFalse);
    expect(RaShellPlatform.web.drawsCaptionButtons, isFalse);
    expect(RaShellPlatform.web.hasNativeMenuBar, isFalse);
  });

  group('框架几何', () {
    testWidgets('没有红绿灯与窗口按钮：按钮组左缘 12、仍在 22 中线上，面板顶边 44、距右 / 下 8', (WidgetTester tester) async {
      await pumpFrame(tester);
      expect(find.byType(RaWindowCaptionButtons), findsNothing);
      expect(tester.getTopLeft(find.byKey(kToggle)).dx, 12);
      expect(tester.getSize(find.byKey(kTitlebar)).height, 44);
      for (final ValueKey<String> key in <ValueKey<String>>[kToggle, kBack, kForward]) {
        expect(tester.getCenter(find.byKey(key)).dy, 22, reason: '$key');
      }
      final Rect panel = tester.getRect(find.byKey(kPanel));
      expect(panel.top, 44);
      expect(panel.left, 238);
      expect(panel.right, 1280 - 8);
      expect(panel.bottom, 820 - 8);
    }, variant: hosts);

    testWidgets('收起侧栏后标题栏内容紧跟按钮组（12 + 88 + 12）', (WidgetTester tester) async {
      const Key titlebar = ValueKey<String>('titlebar-content');
      await pumpFrame(tester, sidebarOpen: false, titlebar: const SizedBox.expand(key: titlebar));
      expect(tester.getTopLeft(find.byKey(titlebar)).dx, 12 + 88 + 12);
      expect(tester.getTopRight(find.byKey(titlebar)).dx, 1280);
    }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));
  });

  group('窗口能力', () {
    testWidgets('未注入时默认使用浏览器实现：拖动、双击标题栏都不执行，也不报错', (WidgetTester tester) async {
      tester.view.devicePixelRatio = 2;
      tester.view.physicalSize = const Size(1280, 820) * 2;
      addTearDown(tester.view.reset);
      late RaWindowController controller;
      await tester.pumpWidget(
        RaApp(
          debugShowCheckedModeBanner: false,
          home: RaDesktopFrame(
            sidebar: Builder(
              builder: (BuildContext context) {
                controller = RaWindowScope.of(context);
                return const SizedBox.expand();
              },
            ),
            child: const SizedBox.expand(),
          ),
        ),
      );
      expect(controller, same(RaBrowserWindowController.instance));
      expect(controller.maximized.value, isFalse);

      const Offset empty = Offset(640, 22);
      await tester.dragFrom(empty, const Offset(120, 40));
      await tester.tapAt(empty);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tapAt(empty);
      await tester.pump(const Duration(seconds: 1));
      expect(controller.maximized.value, isFalse);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'RaDesktopWindow.ensureInitialized 不调用窗口插件',
      (WidgetTester tester) async {
        final List<String> calls = <String>[];
        final TestDefaultBinaryMessenger messenger =
            TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
        const MethodChannel windowManager = MethodChannel('window_manager');
        messenger.setMockMethodCallHandler(windowManager, (MethodCall call) async {
          calls.add(call.method);
          throw PlatformException(code: 'unavailable');
        });
        addTearDown(() => messenger.setMockMethodCallHandler(windowManager, null));

        await RaDesktopWindow.ensureInitialized(const RaWindowOptions(title: 'Acme'));
        expect(calls, isEmpty);

        // 对照：桌面端会初始化 window_manager。
        debugRaIsWebOverride = false;
        await expectLater(
          RaDesktopWindow.ensureInitialized(const RaWindowOptions(rememberState: false)),
          throwsA(isA<PlatformException>()),
        );
        expect(calls, contains('ensureInitialized'));
        // 对照组走桌面路径（dart:io、window_manager），只在 VM 中运行。
      },
      variant: TargetPlatformVariant.only(TargetPlatform.macOS),
      skip: kIsWeb,
    );
  });

  group('快捷键', () {
    testWidgets('Mac 上的浏览器用 ⌘，显示与实际快捷键一致', (WidgetTester tester) async {
      final SingleActivator a = raPrimaryShortcut(LogicalKeyboardKey.keyK);
      expect(a.meta, isTrue);
      expect(a.control, isFalse);
      await tester.pumpWidget(
        Builder(
          builder: (BuildContext context) {
            expect(RaShellStrings.of(context).shortcut('K'), '⌘K');
            return const SizedBox();
          },
        ),
      );
    }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

    testWidgets(
      'Windows / Linux 上的浏览器用 Ctrl',
      (WidgetTester tester) async {
        final SingleActivator a = raPrimaryShortcut(LogicalKeyboardKey.keyK);
        expect(a.control, isTrue);
        expect(a.meta, isFalse);
        await tester.pumpWidget(
          Builder(
            builder: (BuildContext context) {
              expect(RaShellStrings.of(context).shortcut('K'), 'Ctrl+K');
              return const SizedBox();
            },
          ),
        );
      },
      variant: const TargetPlatformVariant(<TargetPlatform>{
        TargetPlatform.windows,
        TargetPlatform.linux,
      }),
    );

    testWidgets('Mac 上的浏览器没有原生菜单栏：可见命令的快捷键也由页面处理', (WidgetTester tester) async {
      final List<String> invoked = <String>[];
      await tester.pumpWidget(
        RaApp(
          debugShowCheckedModeBanner: false,
          home: RaAppMenuBar(
            appName: 'Acme',
            menus: <RaMenuBarMenu>[
              RaMenuBarMenu(
                label: 'View',
                entries: <RaMenuBarEntry>[
                  RaCommand(
                    label: 'Toggle Sidebar',
                    shortcut: raPrimaryShortcut(LogicalKeyboardKey.backslash),
                    onInvoked: () => invoked.add('toggle'),
                  ),
                  const RaSystemMenuItem(PlatformProvidedMenuItemType.toggleFullScreen),
                ],
              ),
            ],
            child: const SizedBox.expand(),
          ),
        ),
      );
      expect(find.byType(PlatformMenuBar), findsNothing);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
      final bool handled = await tester.sendKeyEvent(LogicalKeyboardKey.backslash);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
      expect(invoked, <String>['toggle']);
      // 返回 handled 时网页引擎会阻止浏览器的默认行为。
      expect(handled, isTrue);
    }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));
  });
}
