import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orra_ui/orra_ui.dart';

import 'helpers.dart';

Future<TestGesture> _mouse(WidgetTester tester) async {
  final TestGesture gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await gesture.addPointer(location: const Offset(1200, 800));
  addTearDown(gesture.removePointer);
  return gesture;
}

final Finder _panel = find.byType(RaMenuSurface);

/// 菜单项的高亮块（带底色的 DecoratedBox）。
Color? _highlight(WidgetTester tester, String label) {
  final Finder item = find.ancestor(of: find.text(label), matching: find.byType(RaPressable)).first;
  return decoratedColor(tester, item);
}

Rect _highlightRect(WidgetTester tester, String label) {
  final Finder item = find.ancestor(of: find.text(label), matching: find.byType(RaPressable)).first;
  return tester.getRect(find.descendant(of: item, matching: find.byType(Container)).first);
}

void main() {
  final RaThemeData theme = RaThemeData.light();

  Widget menu({VoidCallback? onSearch, String? groupValue, ValueChanged<String>? onPick}) {
    return Padding(
      padding: const EdgeInsets.all(300),
      child: RaMenu(
        align: RaPopoverAlign.start,
        items: <Widget>[
          const RaMenuHeader(title: Text('Patrick'), child: Text('p@example.com')),
          RaMenuItem(onPressed: onSearch ?? () {}, shortcut: '⌘K', child: const Text('Search')),
          RaMenuItem(onPressed: () {}, child: const Text('Settings')),
          const RaMenuSeparator(),
          RaMenuRadioItem<String>(
            value: 'a',
            groupValue: groupValue,
            onChanged: onPick,
            child: const Text('Alpha'),
          ),
          RaMenuRadioItem<String>(
            value: 'b',
            groupValue: groupValue,
            onChanged: onPick,
            child: const Text('Beta'),
          ),
          RaSubmenu(
            label: const Text('More'),
            items: <Widget>[
              RaMenuItem(onPressed: () {}, child: const Text('Nested 1')),
              RaMenuItem(onPressed: () {}, child: const Text('Nested 2')),
            ],
          ),
        ],
        child: const RaMenuTrigger(child: Text('Open')),
      ),
    );
  }

  testWidgets('opens on tap with Linear geometry', (WidgetTester tester) async {
    await pumpRa(tester, menu());
    expect(_panel, findsNothing);
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(_panel, findsOneWidget);

    final Rect panel = tester.getRect(_panel);
    final Rect trigger = tester.getRect(find.byType(RaMenuTrigger));
    expect(panel.width, greaterThanOrEqualTo(224));
    // 向下弹出，距离 6，左对齐。
    expect(panel.top, closeTo(trigger.bottom + 6, 0.01));
    expect(panel.left, closeTo(trigger.left, 0.01));
    expect(tester.getSize(find.byType(RaMenuItem).first).height, 32);
    expect(tester.getTopLeft(find.text('Search')).dx - panel.left, closeTo(14, 0.01));

    final Rect separator = tester.getRect(find.byType(RaMenuSeparator));
    expect(separator.left, closeTo(panel.left, 0.01));
    expect(separator.right, closeTo(panel.right, 0.01));
    expect(separator.height, closeTo(6 + 0.5 + 6, 0.01));

    final BoxDecoration surface = firstBoxDecoration(tester, _panel)!;
    expect(surface.borderRadius, BorderRadius.circular(12));
    expect(surface.color, theme.colors.surface);
  });

  testWidgets('hover highlight is inset 6 with radius 6', (WidgetTester tester) async {
    await pumpRa(tester, menu());
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    final TestGesture mouse = await _mouse(tester);
    await mouse.moveTo(tester.getCenter(find.text('Settings')));
    await tester.pump();
    expect(_highlight(tester, 'Settings'), theme.colors.hover);
    expect(_highlight(tester, 'Search'), isNull);
    final Rect panel = tester.getRect(_panel);
    final Rect hl = _highlightRect(tester, 'Settings');
    expect(hl.left - panel.left, closeTo(6, 0.01));
    expect(panel.right - hl.right, closeTo(6, 0.01));
    expect(hl.height, 32);
  });

  testWidgets('arrow keys move focus and highlight; Esc closes', (WidgetTester tester) async {
    await pumpRa(tester, menu());
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(_highlight(tester, 'Search'), theme.colors.hover);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(_highlight(tester, 'Search'), isNull);
    expect(_highlight(tester, 'Settings'), theme.colors.hover);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    // 循环到最后一项（子菜单入口）。
    expect(_highlight(tester, 'More'), theme.colors.hover);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(_panel, findsNothing);
  });

  testWidgets('Enter activates the focused item', (WidgetTester tester) async {
    int searches = 0;
    await pumpRa(tester, menu(onSearch: () => searches++));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(searches, 1);
    expect(_panel, findsNothing);
  });

  testWidgets('clicking an item fires and closes', (WidgetTester tester) async {
    int searches = 0;
    await pumpRa(tester, menu(onSearch: () => searches++));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();
    expect(searches, 1);
    expect(_panel, findsNothing);
  });

  testWidgets('radio item shows check and stays open', (WidgetTester tester) async {
    String value = 'a';
    await pumpRa(
      tester,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) =>
            menu(groupValue: value, onPick: (String v) => setState(() => value = v)),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    Finder checkIn(String label) => find.descendant(
      of: find.ancestor(of: find.text(label), matching: find.byType(RaMenuRadioItem<String>)),
      matching: find.byType(RaIcon),
    );
    expect(checkIn('Alpha'), findsOneWidget);
    expect(checkIn('Beta'), findsNothing);
    await tester.tap(find.text('Beta'));
    await tester.pumpAndSettle();
    expect(value, 'b');
    expect(_panel, findsOneWidget);
    expect(checkIn('Alpha'), findsNothing);
    expect(checkIn('Beta'), findsOneWidget);
    // 对勾在行尾。
    final Rect check = tester.getRect(checkIn('Beta'));
    expect(tester.getRect(_panel).right - check.right, closeTo(14, 0.01));
  });

  testWidgets('submenu opens on hover after a delay', (WidgetTester tester) async {
    await pumpRa(tester, menu());
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    final TestGesture mouse = await _mouse(tester);
    await mouse.moveTo(tester.getCenter(find.text('More')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Nested 1'), findsNothing);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
    expect(find.text('Nested 1'), findsOneWidget);
    expect(_highlight(tester, 'More'), theme.colors.hover);
    // 子菜单在右侧。
    expect(
      tester.getRect(_panel.last).left,
      greaterThanOrEqualTo(tester.getRect(_panel.first).right - 0.01),
    );
    // 悬停到同层普通项时收起子菜单。
    await mouse.moveTo(tester.getCenter(find.text('Settings')));
    await tester.pumpAndSettle();
    expect(find.text('Nested 1'), findsNothing);
  });

  testWidgets('ArrowRight opens submenu and focuses first item; ArrowLeft closes', (
    WidgetTester tester,
  ) async {
    await pumpRa(tester, menu());
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    expect(_highlight(tester, 'More'), theme.colors.hover);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(find.text('Nested 1'), findsOneWidget);
    expect(_highlight(tester, 'Nested 1'), theme.colors.hover);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(_highlight(tester, 'Nested 2'), theme.colors.hover);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(find.text('Nested 1'), findsNothing);
    expect(_panel, findsOneWidget);
    // 焦点回到子菜单入口，继续用方向键。
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    // 本用例的单选项未提供 onChanged（禁用），方向键跳过它们。
    expect(_highlight(tester, 'Settings'), theme.colors.hover);
  });

  testWidgets('outside tap closes without hitting what is below', (WidgetTester tester) async {
    int below = 0;
    await pumpRa(
      tester,
      SizedBox(
        width: 1280,
        height: 820,
        child: Stack(
          children: <Widget>[
            Positioned(
              left: 900,
              top: 600,
              child: RaButton(onPressed: () => below++, child: const Text('Below')),
            ),
            menu(),
          ],
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Below'));
    await tester.pumpAndSettle();
    expect(_panel, findsNothing);
    // 菜单打开时点击外部只关闭菜单，不触发下层。
    expect(below, 0);
    await tester.tap(find.text('Below'));
    await tester.pump();
    expect(below, 1);
  });

  testWidgets('chip / row triggers are transparent at rest; plain pill has room on both sides', (
    WidgetTester tester,
  ) async {
    await pumpRa(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          RaMenu(
            items: const <Widget>[],
            child: const RaMenuTrigger(child: Text('排序')),
          ),
          RaMenu(
            items: const <Widget>[],
            child: const RaMenuTrigger(variant: RaMenuTriggerVariant.chip, child: Text('交给')),
          ),
          SizedBox(
            width: 214,
            child: RaMenu(
              items: const <Widget>[],
              child: const RaMenuTrigger(
                variant: RaMenuTriggerVariant.row,
                child: Text('Workspace'),
              ),
            ),
          ),
        ],
      ),
    );
    RaAnimatedSurface surface(String text) => tester.widget<RaAnimatedSurface>(
      find.ancestor(of: find.text(text), matching: find.byType(RaAnimatedSurface)).first,
    );
    for (final String text in <String>['交给', 'Workspace']) {
      expect(surface(text).backgroundColor, isNull, reason: text);
      expect(surface(text).borderColor, isNull, reason: text);
      expect(surface(text).shadows, isNull, reason: text);
    }
    final Rect pill = tester.getRect(find.byType(RaMenuTrigger).first);
    expect(tester.getTopLeft(find.text('排序')).dx - pill.left, 12);
    expect(pill.right - tester.getTopRight(find.text('排序')).dx, 10);
  });

  testWidgets('trigger toggles the menu', (WidgetTester tester) async {
    await pumpRa(tester, menu());
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(_panel, findsNothing);
  });

  testWidgets('context menu opens at the pointer', (WidgetTester tester) async {
    int copies = 0;
    await pumpRa(
      tester,
      RaContextMenu(
        items: <Widget>[RaMenuItem(onPressed: () => copies++, child: const Text('Copy'))],
        child: const SizedBox(width: 600, height: 400),
      ),
    );
    const Offset at = Offset(200, 150);
    await tester.tapAt(at, buttons: kSecondaryButton);
    await tester.pumpAndSettle();
    expect(_panel, findsOneWidget);
    final Rect panel = tester.getRect(_panel);
    expect(panel.left, closeTo(at.dx, 0.01));
    expect(panel.top, closeTo(at.dy, 0.01));
    await tester.tap(find.text('Copy'));
    await tester.pumpAndSettle();
    expect(copies, 1);
    expect(_panel, findsNothing);
  });

  testWidgets('menu flips up when there is no room below', (WidgetTester tester) async {
    await pumpRa(
      tester,
      Padding(
        padding: const EdgeInsets.only(left: 300, top: 760),
        child: RaMenu(
          items: <Widget>[
            for (int i = 0; i < 4; i++) RaMenuItem(onPressed: () {}, child: Text('Item $i')),
          ],
          child: const RaMenuTrigger(child: Text('Open')),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    final Rect panel = tester.getRect(_panel);
    final Rect trigger = tester.getRect(find.byType(RaMenuTrigger));
    expect(panel.bottom, closeTo(trigger.top - 6, 0.01));
  });
}
