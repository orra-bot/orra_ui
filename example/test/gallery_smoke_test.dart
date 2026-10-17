import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orra_desktop_shell/orra_desktop_shell.dart';
import 'package:orra_gallery/gallery_app.dart';
import 'package:orra_ui/orra_ui.dart';

Future<void> _browseAllPages(WidgetTester tester) async {
  tester.view.devicePixelRatio = 2;
  tester.view.physicalSize = const Size(1280, 820) * 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const GalleryApp());
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);

  for (final GalleryRoute route in GalleryRoute.values) {
    await tester.tap(find.widgetWithText(RaSidebarItem, route.label));
    // 有的页面带持续动画（不确定进度条），不能等到「静止」：按固定时长推进。
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull, reason: route.label);
  }

  // 后退回到上一页。
  await tester.tap(find.byKey(const ValueKey<String>('ra-back')));
  await tester.pumpAndSettle();
  // 侧栏项与面包屑当前项都显示「对话框与提示」，页面大标题也是。
  expect(find.text(GalleryRoute.overlays.label), findsNWidgets(3));
}

void main() {
  tearDown(() => debugRaIsWebOverride = null);

  testWidgets('桌面端：逐页打开展示应用，没有异常', (WidgetTester tester) async {
    debugRaIsWebOverride = false;
    await _browseAllPages(tester);
  });

  testWidgets(
    '网页端：逐页打开展示应用，没有异常；没有窗口按钮，侧栏开关从左 12 开始',
    (WidgetTester tester) async {
      debugRaIsWebOverride = true;
      await _browseAllPages(tester);
      expect(find.byType(RaWindowCaptionButtons), findsNothing);
      expect(tester.getTopLeft(find.byKey(const ValueKey<String>('ra-sidebar-toggle'))).dx, 12);
    },
    variant: const TargetPlatformVariant(<TargetPlatform>{
      TargetPlatform.macOS,
      TargetPlatform.windows,
    }),
  );
}
