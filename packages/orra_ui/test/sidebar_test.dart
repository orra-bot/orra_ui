import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orra_ui/orra_ui.dart';

import 'helpers.dart';

Finder _item(String label) =>
    find.byWidgetPredicate((Widget w) => w is RaSidebarItem && w.label == label);

Color? _bg(WidgetTester tester, String label) => decoratedColor(tester, _item(label));

void main() {
  final RaThemeData theme = RaThemeData.light();

  Widget sidebar({bool selected = false, VoidCallback? onInbox, VoidCallback? onMiddle}) =>
      ColoredBox(
        color: theme.chrome.chrome,
        child: SizedBox(
          width: 238,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: RaSidebarSection(
              title: '我的项目',
              action: RaIconButton(label: '新建', icon: RaIcon.glyph(RaGlyphs.x), onPressed: () {}),
              children: <Widget>[
                RaSidebarItem(
                  label: '收件箱',
                  icon: RaIcon.glyph(RaGlyphs.search),
                  trailing: const Text('3'),
                  selected: selected,
                  onPressed: onInbox ?? () {},
                  onMiddlePressed: onMiddle,
                ),
                RaSidebarItem(label: '子会话', tone: RaSidebarItemTone.child, onPressed: () {}),
                RaSidebarItem(label: '已归档', tone: RaSidebarItemTone.muted, onPressed: () {}),
              ],
            ),
          ),
        ),
      );

  testWidgets('rows are 28 high; text starts at 28', (WidgetTester tester) async {
    await pumpRa(tester, sidebar());
    final Rect row = tester.getRect(_item('收件箱'));
    expect(row.height, 28);
    expect(row.width, 214);
    expect(tester.getTopLeft(find.text('收件箱')).dx - row.left, closeTo(28, 0.01));
    final Rect child = tester.getRect(_item('子会话'));
    expect(tester.getTopLeft(find.text('子会话')).dx - child.left, closeTo(28, 0.01));
    // 行距 1。
    expect(child.top - row.bottom, closeTo(1, 0.01));
    // 默认次要色，muted 弱色。
    expect(
      tester
          .widget<RaAnimatedSurface>(
            find.descendant(of: _item('收件箱'), matching: find.byType(RaAnimatedSurface)),
          )
          .foregroundColor,
      theme.colors.inkWindow2,
    );
    expect(
      tester
          .widget<RaAnimatedSurface>(
            find.descendant(of: _item('已归档'), matching: find.byType(RaAnimatedSurface)),
          )
          .foregroundColor,
      theme.colors.inkWindow3,
    );
  });

  testWidgets('hover / selected / pressed use translucent fills only', (WidgetTester tester) async {
    await pumpRa(tester, sidebar(selected: true));
    final Color selected = _bg(tester, '收件箱')!;
    expect(selected, theme.chrome.chromeSelected);
    expect(selected.a, inExclusiveRange(0, 1));
    expect(
      tester
          .widget<RaAnimatedSurface>(
            find.descendant(of: _item('收件箱'), matching: find.byType(RaAnimatedSurface)),
          )
          .foregroundColor,
      theme.colors.ink,
    );

    final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: const Offset(1200, 800));
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(_item('子会话')));
    await tester.pump();
    final Color hover = _bg(tester, '子会话')!;
    expect(hover, theme.chrome.chromeHover);
    expect(hover.a, inExclusiveRange(0, 1));

    final TestGesture press = await tester.startGesture(tester.getCenter(_item('已归档')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    final Color pressed = _bg(tester, '已归档')!;
    expect(pressed, theme.chrome.chromeActive);
    expect(pressed.a, inExclusiveRange(0, 1));
    await press.up();
    await tester.pumpAndSettle();
  });

  testWidgets('hover fill disappears at once when the pointer leaves', (WidgetTester tester) async {
    await pumpRa(tester, sidebar());
    final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: tester.getCenter(_item('子会话')));
    await tester.pumpAndSettle();
    expect(_bg(tester, '子会话'), theme.chrome.chromeHover);
    await mouse.moveTo(const Offset(1000, 600));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    expect(_bg(tester, '子会话')?.a ?? 0, 0);
  });

  testWidgets('section head: 28 high, hover fill, caret always visible', (
    WidgetTester tester,
  ) async {
    await pumpRa(tester, sidebar());
    final Finder head = find
        .ancestor(of: find.text('我的项目'), matching: find.byType(RaAnimatedSurface))
        .last;
    expect(tester.getSize(head).height, 28);
    expect(find.descendant(of: head, matching: find.byType(RaIcon)), findsWidgets);
    final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: const Offset(1200, 800));
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(find.text('我的项目')));
    await tester.pump();
    expect(decoratedColor(tester, head), theme.chrome.chromeHover);
  });

  testWidgets('section collapses and expands', (WidgetTester tester) async {
    await pumpRa(tester, sidebar());
    expect(find.text('收件箱').hitTestable(), findsOneWidget);
    await tester.tap(find.text('我的项目'));
    await tester.pumpAndSettle();
    expect(find.text('收件箱').hitTestable(), findsNothing);
    expect(find.text('子会话').hitTestable(), findsNothing);
    await tester.tap(find.text('我的项目'));
    await tester.pumpAndSettle();
    expect(find.text('收件箱').hitTestable(), findsOneWidget);
  });

  testWidgets('item tap and middle click', (WidgetTester tester) async {
    int taps = 0;
    int middle = 0;
    await pumpRa(tester, sidebar(onInbox: () => taps++, onMiddle: () => middle++));
    await tester.tap(_item('收件箱'));
    await tester.tap(_item('收件箱'), buttons: kMiddleMouseButton);
    await tester.pump();
    expect(taps, 1);
    expect(middle, 1);
  });

  testWidgets('status dots', (WidgetTester tester) async {
    await pumpRa(
      tester,
      const Row(
        children: <Widget>[
          RaStatusDot(tone: RaStatusTone.attention),
          RaStatusDot(tone: RaStatusTone.running),
          RaStatusDot(tone: RaStatusTone.online, label: '在线'),
        ],
      ),
    );
    final List<Size> sizes = tester
        .widgetList<Container>(find.byType(Container))
        .map((Container c) => c.constraints!.biggest)
        .toList();
    expect(sizes, const <Size>[Size(7, 7), Size(7, 7), Size(6, 6)]);
    expect(find.bySemanticsLabel('在线'), findsOneWidget);
  });
}
