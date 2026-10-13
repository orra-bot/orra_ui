import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orra_ui/orra_ui.dart';

import 'helpers.dart';

void main() {
  testWidgets('smoke: all components build', (WidgetTester tester) async {
    await pumpRa(
      tester,
      SizedBox(
        width: 600,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            RaButton(onPressed: () {}, child: const Text('Secondary')),
            RaButton(
              variant: RaButtonVariant.primary,
              onPressed: () {},
              child: const Text('Primary'),
            ),
            RaIconButton(label: 'Close', icon: RaIcon.glyph(RaGlyphs.x), onPressed: () {}),
            const RaTextField(label: 'Name', placeholder: 'Type'),
            RaMenu(
              items: <Widget>[
                RaMenuItem(onPressed: () {}, shortcut: '⌘K', child: const Text('Search')),
                const RaMenuSeparator(),
                RaSubmenu(
                  label: const Text('More'),
                  items: <Widget>[RaMenuItem(onPressed: () {}, child: const Text('Nested'))],
                ),
              ],
              child: const RaMenuTrigger(child: Text('Open')),
            ),
            RaSidebarSection(
              title: 'Group',
              children: <Widget>[
                RaSidebarItem(label: 'Inbox', onPressed: () {}, trailing: const Text('3')),
              ],
            ),
            const RaStatusDot(tone: RaStatusTone.running),
            const RaSidebarIcon(collapsed: false),
          ],
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Search'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Search'), findsNothing);

    final BuildContext context = tester.element(find.text('Open'));
    RaToast.of(context).success('已保存');
    await tester.pumpAndSettle();
    expect(find.text('已保存'), findsOneWidget);

    unawaited(
      showRaDialog<void>(
        context: context,
        builder: (_) => RaDialog(
          title: 'Hello',
          actions: <Widget>[RaButton(onPressed: () {}, child: const Text('OK'))],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Hello'), findsOneWidget);
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
  });
}
