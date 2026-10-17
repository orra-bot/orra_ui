import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
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

Color? _bg(WidgetTester tester, String label) =>
    decoratedColor(tester, find.ancestor(of: find.text(label), matching: find.byType(RaButton)));

void main() {
  final RaThemeData theme = RaThemeData.light();

  testWidgets('sizes: 28 / 32 / 40, radius 8 / 8 / 10', (WidgetTester tester) async {
    await pumpRa(
      tester,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          RaButton(size: RaButtonSize.sm, onPressed: () {}, child: const Text('S')),
          RaButton(onPressed: () {}, child: const Text('M')),
          RaButton(size: RaButtonSize.lg, onPressed: () {}, child: const Text('L')),
        ],
      ),
    );
    double h(String l) =>
        tester.getSize(find.ancestor(of: find.text(l), matching: find.byType(RaButton))).height;
    expect(h('S'), 28);
    expect(h('M'), 32);
    expect(h('L'), 40);
    BorderRadius? r(String l) =>
        firstBoxDecoration(
              tester,
              find.ancestor(of: find.text(l), matching: find.byType(RaButton)),
            )!.borderRadius
            as BorderRadius?;
    expect(r('S'), BorderRadius.circular(8));
    expect(r('M'), BorderRadius.circular(8));
    expect(r('L'), BorderRadius.circular(10));
  });

  testWidgets('button shrink-wraps inside a wide column', (WidgetTester tester) async {
    await pumpRa(
      tester,
      SizedBox(
        width: 600,
        child: Column(
          children: <Widget>[RaButton(onPressed: () {}, child: const Text('Go'))],
        ),
      ),
    );
    final Size size = tester.getSize(find.byType(RaButton));
    expect(size.width, lessThan(200));
    expect(size.height, 32);
  });

  testWidgets('hover appears instantly and fades out over 75ms', (WidgetTester tester) async {
    await pumpRa(
      tester,
      RaButton(variant: RaButtonVariant.primary, onPressed: () {}, child: const Text('Primary')),
    );
    expect(_bg(tester, 'Primary'), theme.colors.accent);
    final TestGesture mouse = await _mouse(tester);
    await mouse.moveTo(tester.getCenter(find.text('Primary')));
    await tester.pump();
    expect(_bg(tester, 'Primary'), theme.colors.accentHover);

    await mouse.moveTo(const Offset(1200, 800));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 37));
    final Color mid = _bg(tester, 'Primary')!;
    expect(mid, isNot(theme.colors.accent));
    expect(mid, isNot(theme.colors.accentHover));
    await tester.pump(const Duration(milliseconds: 40));
    expect(_bg(tester, 'Primary'), theme.colors.accent);
  });

  testWidgets('disabled does not fire; cursor is forbidden', (WidgetTester tester) async {
    await pumpRa(
      tester,
      const RaButton(variant: RaButtonVariant.primary, onPressed: null, child: Text('Off')),
    );
    expect(_bg(tester, 'Off'), theme.colors.disabledBg);
    final TestGesture mouse = await _mouse(tester);
    await mouse.moveTo(tester.getCenter(find.text('Off')));
    await tester.pump();
    expect(
      RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1),
      SystemMouseCursors.forbidden,
    );
  });

  testWidgets('tap fires; disabled tap does not', (WidgetTester tester) async {
    int taps = 0;
    await pumpRa(
      tester,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          RaButton(onPressed: () => taps++, child: const Text('On')),
          const RaButton(onPressed: null, child: Text('Off')),
        ],
      ),
    );
    await tester.tap(find.text('On'));
    await tester.tap(find.text('Off'), warnIfMissed: false);
    expect(taps, 1);
  });

  testWidgets('loading shows spinner, blocks presses but stays focusable', (
    WidgetTester tester,
  ) async {
    int taps = 0;
    final FocusNode node = FocusNode();
    addTearDown(node.dispose);
    await pumpRa(
      tester,
      RaButton(loading: true, focusNode: node, onPressed: () => taps++, child: const Text('Save')),
    );
    expect(find.byType(RaSpinner), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
    await tester.tap(find.text('Save'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(taps, 0);
    node.requestFocus();
    await tester.pump();
    expect(node.hasFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(taps, 0);
  });

  testWidgets('Enter and Space activate a focused button', (WidgetTester tester) async {
    int taps = 0;
    final FocusNode node = FocusNode();
    addTearDown(node.dispose);
    await pumpRa(
      tester,
      RaButton(focusNode: node, onPressed: () => taps++, child: const Text('K')),
    );
    node.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(taps, 2);
  });

  testWidgets('icon button is 28×28 and shows tooltip after 600ms', (WidgetTester tester) async {
    await pumpRa(
      tester,
      Padding(
        padding: const EdgeInsets.all(100),
        child: RaIconButton(
          label: '关闭',
          shortcut: '⌘W',
          icon: RaIcon.glyph(RaGlyphs.x),
          onPressed: () {},
        ),
      ),
    );
    expect(tester.getSize(find.byType(RaButton)), const Size(28, 28));
    expect(find.text('关闭'), findsNothing);
    final TestGesture mouse = await _mouse(tester);
    await mouse.moveTo(tester.getCenter(find.byType(RaButton)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('关闭'), findsNothing);
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.text('关闭'), findsOneWidget);
    expect(find.text('⌘W'), findsOneWidget);
    // 默认在下方，距离 6。
    final Rect button = tester.getRect(find.byType(RaButton));
    final Rect bubble = tester.getRect(
      find.ancestor(of: find.text('关闭'), matching: find.byType(DecoratedBox)).first,
    );
    expect(bubble.top, closeTo(button.bottom + 6, 0.01));
    await mouse.moveTo(const Offset(1200, 800));
    await tester.pumpAndSettle();
    expect(find.text('关闭'), findsNothing);
  });

  testWidgets('icon button hover background is translucent', (WidgetTester tester) async {
    await pumpRa(
      tester,
      Padding(
        padding: const EdgeInsets.all(40),
        child: RaIconButton(label: 'x', icon: RaIcon.glyph(RaGlyphs.x), onPressed: () {}),
      ),
    );
    final TestGesture mouse = await _mouse(tester);
    await mouse.moveTo(tester.getCenter(find.byType(RaButton)));
    await tester.pump();
    final Color bg = decoratedColor(tester, find.byType(RaButton))!;
    expect(bg, theme.colors.fillTranslucentSelected);
    expect(bg.a, lessThan(1));
    await mouse.moveTo(const Offset(1200, 800));
    await tester.pumpAndSettle();
  });

  testWidgets('white buttons hover to the light opaque surfaceHover, not the dark overlay', (
    WidgetTester tester,
  ) async {
    final RaThemeData theme = RaThemeData.light();
    await pumpRa(tester, RaButton(onPressed: () {}, child: const Text('次要')));
    final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: tester.getCenter(find.byType(RaButton)));
    await tester.pumpAndSettle();
    final Color hover = decoratedColor(tester, find.byType(RaButton))!;
    expect(hover, theme.colors.surfaceHover);
    expect(hover.a, 1);
  });
}
