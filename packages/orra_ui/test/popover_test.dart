import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orra_ui/orra_ui.dart';

import 'helpers.dart';

final Finder _surface = find.byType(RaPopoverSurface);

void main() {
  final RaThemeData theme = RaThemeData.light();

  Widget popover({String? title}) => Padding(
    padding: const EdgeInsets.all(200),
    child: RaPopover(
      title: title,
      description: title == null ? null : const Text('知道链接的成员都可以查看。'),
      content: RaButton(onPressed: () {}, child: const Text('复制链接')),
      child: Builder(
        builder: (BuildContext context) => RaButton(
          onPressed: RaPopover.of(context).toggle,
          selected: RaPopover.of(context).isOpen,
          child: const Text('分享'),
        ),
      ),
    ),
  );

  testWidgets('opens below the trigger with the popover surface', (WidgetTester tester) async {
    await pumpRa(tester, popover(title: '分享'));
    await tester.tap(find.text('分享'));
    await tester.pumpAndSettle();
    expect(_surface, findsOneWidget);
    final Rect trigger = tester.getRect(find.widgetWithText(RaButton, '分享').first);
    final Rect panel = tester.getRect(_surface);
    expect(panel.top - trigger.bottom, theme.popover.sideOffset);
    expect(panel.center.dx, closeTo(trigger.center.dx, 0.01));
    expect(panel.width, lessThanOrEqualTo(theme.popover.maxWidth));
    final BoxDecoration d = firstBoxDecoration(tester, _surface)!;
    expect(d.color, theme.colors.surface);
    expect(d.borderRadius, BorderRadius.circular(12));
    expect(d.boxShadow, theme.shadows.popup);
    // 标题与说明。
    expect(find.text('知道链接的成员都可以查看。'), findsOneWidget);
    expect(tester.getTopLeft(find.text('分享').last).dy - panel.top, theme.popover.padding.top);
  });

  testWidgets('tap outside closes; tapping the trigger toggles', (WidgetTester tester) async {
    await pumpRa(tester, popover());
    await tester.tap(find.text('分享'));
    await tester.pumpAndSettle();
    expect(_surface, findsOneWidget);
    await tester.tapAt(const Offset(1200, 800));
    await tester.pumpAndSettle();
    expect(_surface, findsNothing);

    await tester.tap(find.text('分享'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('分享'));
    await tester.pumpAndSettle();
    expect(_surface, findsNothing);
  });

  testWidgets('focus moves into the panel; Esc closes and restores focus', (
    WidgetTester tester,
  ) async {
    final FocusNode trigger = FocusNode();
    addTearDown(trigger.dispose);
    await pumpRa(
      tester,
      RaPopover(
        content: const Text('内容'),
        child: Builder(
          builder: (BuildContext context) => RaButton(
            focusNode: trigger,
            onPressed: RaPopover.of(context).toggle,
            child: const Text('打开'),
          ),
        ),
      ),
    );
    trigger.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(_surface, findsOneWidget);
    expect(trigger.hasFocus, isFalse);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(_surface, findsNothing);
    expect(trigger.hasPrimaryFocus, isTrue);
  });

  testWidgets('content can close the popover', (WidgetTester tester) async {
    await pumpRa(
      tester,
      RaPopover(
        width: 240,
        content: Builder(
          builder: (BuildContext context) =>
              RaButton(onPressed: RaPopover.of(context).close, child: const Text('完成')),
        ),
        child: Builder(
          builder: (BuildContext context) =>
              RaButton(onPressed: RaPopover.of(context).open, child: const Text('打开')),
        ),
      ),
    );
    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();
    expect(tester.getSize(_surface).width, 240);
    await tester.tap(find.text('完成'));
    await tester.pumpAndSettle();
    expect(_surface, findsNothing);
  });

  group('RaPreviewCard', () {
    Widget card() => const Padding(
      padding: EdgeInsets.all(200),
      child: RaPreviewCard(content: Text('Ive Tian · 设计'), child: Text('@ive')),
    );

    testWidgets('opens after the hover delay, stays while over the card, closes after leaving', (
      WidgetTester tester,
    ) async {
      await pumpRa(tester, card());
      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: const Offset(1200, 800));
      await mouse.moveTo(tester.getCenter(find.text('@ive')));
      await tester.pump(const Duration(milliseconds: 300));
      expect(_surface, findsNothing);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(_surface, findsOneWidget);
      expect(tester.getSize(_surface).width, theme.popover.previewWidth);

      // 移到卡片上：保持打开。
      await mouse.moveTo(tester.getCenter(find.text('Ive Tian · 设计')));
      await tester.pump(const Duration(milliseconds: 500));
      expect(_surface, findsOneWidget);

      // 离开两者：300ms 后关闭。
      await mouse.moveTo(const Offset(1200, 800));
      await tester.pump(const Duration(milliseconds: 100));
      expect(_surface, findsOneWidget);
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pumpAndSettle();
      expect(_surface, findsNothing);
    });

    testWidgets('a quick pass does not open it', (WidgetTester tester) async {
      await pumpRa(tester, card());
      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: tester.getCenter(find.text('@ive')));
      await tester.pump(const Duration(milliseconds: 200));
      await mouse.moveTo(const Offset(1200, 800));
      await tester.pump(const Duration(seconds: 1));
      expect(_surface, findsNothing);
    });

    testWidgets('keyboard focus opens it; Esc closes', (WidgetTester tester) async {
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);
      await pumpRa(
        tester,
        RaPreviewCard(
          content: const Text('预览'),
          child: RaButton(focusNode: node, onPressed: () {}, child: const Text('链接')),
        ),
      );
      node.requestFocus();
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();
      expect(_surface, findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(_surface, findsNothing);
      expect(node.hasPrimaryFocus, isTrue);
    });
  });
}
