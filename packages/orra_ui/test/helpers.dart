import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orra_ui/orra_ui.dart';

/// 2 倍屏、1280×820 窗口（与默认窗口尺寸一致）。
Future<void> pumpRa(
  WidgetTester tester,
  Widget child, {
  RaThemeData? theme,
  RaThemeMode mode = RaThemeMode.light,
  Size size = const Size(1280, 820),
}) async {
  tester.view.devicePixelRatio = 2;
  tester.view.physicalSize = size * 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    RaApp(
      theme: theme,
      themeMode: mode,
      debugShowCheckedModeBanner: false,
      home: Align(alignment: Alignment.topLeft, child: child),
    ),
  );
}

/// 找到某个组件里第一个带底色的 DecoratedBox 的颜色。
Color? decoratedColor(WidgetTester tester, Finder finder) {
  final Iterable<DecoratedBox> boxes = tester.widgetList<DecoratedBox>(
    find.descendant(of: finder, matching: find.byType(DecoratedBox)),
  );
  for (final DecoratedBox box in boxes) {
    final Decoration d = box.decoration;
    if (d is BoxDecoration && d.color != null) return d.color;
  }
  return null;
}

BoxDecoration? firstBoxDecoration(WidgetTester tester, Finder finder) {
  final Iterable<DecoratedBox> boxes = tester.widgetList<DecoratedBox>(
    find.descendant(of: finder, matching: find.byType(DecoratedBox)),
  );
  for (final DecoratedBox box in boxes) {
    if (box.decoration is BoxDecoration) return box.decoration as BoxDecoration;
  }
  return null;
}
