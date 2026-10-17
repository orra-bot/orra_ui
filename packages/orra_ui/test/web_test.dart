import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orra_ui/orra_ui.dart';

import 'helpers.dart';

/// 网页端行为：VM 测试中用 debugRaIsWebOverride 模拟浏览器。
void main() {
  late List<String> calls;

  setUp(() {
    calls = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.contextMenu,
      (MethodCall call) async {
        calls.add(call.method);
        return null;
      },
    );
  });

  tearDown(() {
    debugRaIsWebOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.contextMenu,
      null,
    );
  });

  Widget twoRegions({bool enabled = true}) => Row(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      RaContextMenu(
        enabled: enabled,
        items: <Widget>[RaMenuItem(onPressed: () {}, child: const Text('Copy'))],
        child: const SizedBox(key: ValueKey<String>('a'), width: 200, height: 200),
      ),
      RaContextMenu(
        items: <Widget>[RaMenuItem(onPressed: () {}, child: const Text('Paste'))],
        child: const SizedBox(key: ValueKey<String>('b'), width: 200, height: 200),
      ),
      const SizedBox(key: ValueKey<String>('outside'), width: 200, height: 200),
    ],
  );

  Offset center(WidgetTester tester, String key) =>
      tester.getCenter(find.byKey(ValueKey<String>(key)));

  testWidgets('网页端：悬停右键菜单区域时禁用浏览器菜单，离开后恢复；相邻区域之间不闪开', (WidgetTester tester) async {
    debugRaIsWebOverride = true;
    await pumpRa(tester, twoRegions());
    final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: center(tester, 'outside'));
    await tester.pump();
    expect(calls, isEmpty);

    await mouse.moveTo(center(tester, 'a'));
    await tester.pump();
    expect(calls, <String>['disableContextMenu']);

    await mouse.moveTo(center(tester, 'b'));
    await tester.pump();
    expect(calls, <String>['disableContextMenu'], reason: '从 a 移到 b 期间保持禁用');

    await mouse.moveTo(center(tester, 'outside'));
    await tester.pump();
    expect(calls, <String>['disableContextMenu', 'enableContextMenu']);

    // 右键仍打开应用自己的菜单。
    await mouse.moveTo(center(tester, 'b'));
    await tester.pump();
    await tester.tapAt(center(tester, 'b'), buttons: kSecondaryButton);
    await tester.pumpAndSettle();
    expect(find.text('Paste'), findsOneWidget);
    await mouse.removePointer();
  });

  testWidgets('网页端：区域卸载时恢复浏览器菜单', (WidgetTester tester) async {
    debugRaIsWebOverride = true;
    await pumpRa(tester, twoRegions());
    final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: center(tester, 'a'));
    await tester.pump();
    expect(calls, <String>['disableContextMenu']);

    await pumpRa(tester, const SizedBox.expand());
    expect(calls, <String>['disableContextMenu', 'enableContextMenu']);
    await mouse.removePointer();
  });

  testWidgets('网页端：禁用的右键菜单不拦截浏览器菜单', (WidgetTester tester) async {
    debugRaIsWebOverride = true;
    await pumpRa(tester, twoRegions(enabled: false));
    final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: center(tester, 'a'));
    await tester.pump();
    expect(calls, isEmpty);
    await mouse.removePointer();
  });

  testWidgets('桌面端：不触碰浏览器菜单通道', (WidgetTester tester) async {
    debugRaIsWebOverride = false;
    await pumpRa(tester, twoRegions());
    final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: center(tester, 'a'));
    await tester.pump();
    await mouse.moveTo(center(tester, 'outside'));
    await tester.pump();
    expect(calls, isEmpty);
    await mouse.removePointer();
  });
}
