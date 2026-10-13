import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orra_gallery/gallery_app.dart';
import 'package:orra_ui/orra_ui.dart';

void main() {
  testWidgets('逐页打开展示应用，没有异常', (WidgetTester tester) async {
    tester.view.devicePixelRatio = 2;
    tester.view.physicalSize = const Size(1280, 820) * 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const GalleryApp());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    for (final GalleryRoute route in GalleryRoute.values) {
      await tester.tap(find.widgetWithText(RaSidebarItem, route.label));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: route.label);
    }

    // 后退回到上一页。
    await tester.tap(find.byKey(const ValueKey<String>('ra-back')));
    await tester.pumpAndSettle();
    // 侧栏项与面包屑当前项都显示「对话框与提示」，页面大标题也是。
    expect(find.text(GalleryRoute.overlays.label), findsNWidgets(3));
  });
}

