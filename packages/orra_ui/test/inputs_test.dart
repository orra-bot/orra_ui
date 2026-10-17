import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orra_ui/orra_ui.dart';

import 'helpers.dart';

void main() {
  final RaThemeData theme = RaThemeData.light();

  group('RaSlider', () {
    Widget slider({
      required double value,
      required ValueChanged<double>? onChanged,
      double? step,
      ValueChanged<double>? onChangeEnd,
      bool enabled = true,
    }) => SizedBox(
      width: 214,
      child: RaSlider(
        value: value,
        onChanged: onChanged,
        onChangeEnd: onChangeEnd,
        step: step,
        min: 0,
        max: 100,
        enabled: enabled,
        semanticLabel: '音量',
      ),
    );

    Finder thumb() => find.descendant(
      of: find.byType(RaSlider),
      matching: find.byWidgetPredicate(
        (Widget w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration! as BoxDecoration).shape == BoxShape.circle,
      ),
    );

    testWidgets('20 high, 4px track, 14px thumb inset by half its width', (
      WidgetTester tester,
    ) async {
      await pumpRa(tester, slider(value: 0, onChanged: (_) {}));
      final Rect box = tester.getRect(find.byType(RaSlider));
      expect(box.height, 20);
      expect(tester.getSize(thumb()), const Size(14, 14));
      expect(tester.getTopLeft(thumb()).dx, box.left);
      final Iterable<Container> bars = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(RaSlider),
          matching: find.byWidgetPredicate(
            (Widget w) =>
                w is Container &&
                w.decoration is BoxDecoration &&
                (w.decoration! as BoxDecoration).shape == BoxShape.rectangle,
          ),
        ),
      );
      expect((bars.first.decoration! as BoxDecoration).color, theme.slider.trackColor);
      expect(
        tester
            .getSize(
              find.byWidgetPredicate(
                (Widget w) =>
                    w is Container &&
                    w.decoration is BoxDecoration &&
                    (w.decoration! as BoxDecoration).color == theme.slider.trackColor,
              ),
            )
            .height,
        4,
      );
    });

    testWidgets('tap jumps, drag follows, step snaps', (WidgetTester tester) async {
      double value = 0;
      double? ended;
      await pumpRa(
        tester,
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) => slider(
            value: value,
            step: 10,
            onChanged: (double v) => setState(() => value = v),
            onChangeEnd: (double v) => ended = v,
          ),
        ),
      );
      final Rect box = tester.getRect(find.byType(RaSlider));
      // 可移动范围：7 .. 207（宽 200）。中点 → 50。
      await tester.tapAt(Offset(box.left + 7 + 100, box.center.dy));
      await tester.pump();
      expect(value, 50);
      expect(ended, 50);
      // 吸附：62% → 60。
      await tester.tapAt(Offset(box.left + 7 + 124, box.center.dy));
      await tester.pump();
      expect(value, 60);

      final TestGesture drag = await tester.startGesture(Offset(box.left + 7 + 120, box.center.dy));
      await drag.moveBy(const Offset(40, 0));
      await tester.pump();
      await drag.moveBy(const Offset(40, 0));
      await tester.pump();
      expect(value, 100);
      await drag.up();
      await tester.pump();
      expect(ended, 100);
      expect(tester.getTopRight(thumb()).dx, box.right);
    });

    testWidgets('keyboard: arrows step, Shift / PageUp large step, Home / End', (
      WidgetTester tester,
    ) async {
      double value = 50;
      await pumpRa(
        tester,
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) =>
              slider(value: value, step: 1, onChanged: (double v) => setState(() => value = v)),
        ),
      );
      await tester.tap(find.byType(RaSlider));
      await tester.pump();
      value = 50;
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(value, 51);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(value, 50);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();
      expect(value, 60);
      await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
      await tester.pump();
      expect(value, 50);
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      expect(value, 100);
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump();
      expect(value, 0);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(value, 0, reason: '不越过下限');
    });

    testWidgets('disabled ignores input and dims', (WidgetTester tester) async {
      double value = 20;
      await pumpRa(
        tester,
        slider(value: value, onChanged: (double v) => value = v, enabled: false),
      );
      final Rect box = tester.getRect(find.byType(RaSlider));
      await tester.tapAt(Offset(box.right - 7, box.center.dy));
      await tester.pump();
      expect(value, 20);
      expect(
        tester
            .widget<Opacity>(
              find.descendant(of: find.byType(RaSlider), matching: find.byType(Opacity)),
            )
            .opacity,
        theme.slider.disabledOpacity,
      );
    });
  });

  group('RaNumberField', () {
    Widget field(
      num? Function() get,
      void Function(num?) set, {
      num? min,
      num? max,
      int? decimals,
      num step = 1,
    }) => SizedBox(
      width: 240,
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => RaNumberField(
          label: '并发上限',
          value: get(),
          min: min,
          max: max,
          step: step,
          decimals: decimals,
          onChanged: (num? v) => setState(() => set(v)),
        ),
      ),
    );

    Finder button(String label) => find.bySemanticsLabel(label);

    testWidgets('+ / − step and disable at the bounds', (WidgetTester tester) async {
      num? value = 9;
      await pumpRa(tester, field(() => value, (num? v) => value = v, min: 0, max: 10));
      expect(find.text('9'), findsOneWidget);
      await tester.tap(button('+'));
      await tester.pump();
      expect(value, 10);
      expect(find.text('10'), findsOneWidget);
      // 到上限后「+」禁用。
      await tester.tap(button('+'));
      await tester.pump();
      expect(value, 10);
      await tester.tap(button('−'));
      await tester.pump();
      expect(value, 9);
      final Size size = tester.getSize(
        find
            .ancestor(of: find.byType(RaIcon).first, matching: find.byType(RaAnimatedSurface))
            .first,
      );
      expect(size, Size.square(theme.numberField.buttonSize));
    });

    testWidgets('arrow keys step; Shift steps by 10', (WidgetTester tester) async {
      num? value = 5;
      await pumpRa(tester, field(() => value, (num? v) => value = v));
      await tester.tap(find.byType(EditableText));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(value, 6);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();
      expect(value, -4);
    });

    testWidgets('blur clamps and formats; invalid input restores', (WidgetTester tester) async {
      num? value = 1.5;
      await pumpRa(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            field(() => value, (num? v) => value = v, min: 0, max: 5, decimals: 2, step: 0.5),
            const RaTextField(label: '其他'),
          ],
        ),
      );
      expect(find.text('1.50'), findsOneWidget);
      await tester.enterText(find.byType(EditableText).first, '7.333');
      await tester.tap(find.byType(EditableText).last);
      await tester.pump();
      expect(value, 5);
      expect(find.text('5.00'), findsOneWidget);

      await tester.enterText(find.byType(EditableText).first, '-.');
      await tester.tap(find.byType(EditableText).last);
      await tester.pump();
      expect(value, 5);
      expect(find.text('5.00'), findsOneWidget);

      await tester.enterText(find.byType(EditableText).first, '2.345');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(value, 2.35);
      expect(find.text('2.35'), findsOneWidget);
    });

    testWidgets('only digits, dot and minus are accepted', (WidgetTester tester) async {
      num? value;
      await pumpRa(tester, field(() => value, (num? v) => value = v, min: 0));
      await tester.enterText(find.byType(EditableText), '1a2-');
      await tester.pump();
      expect(find.text('12'), findsOneWidget, reason: 'min ≥ 0 时不允许负号，整数不允许小数点');
    });
  });

  group('RaProgress / RaMeter', () {
    /// 进度条的实际填充块。
    Finder fill() => find.descendant(
      of: find.byType(AnimatedFractionallySizedBox),
      matching: find.byType(DecoratedBox),
    );

    testWidgets('progress fills its fraction of a 4px track; label and percent', (
      WidgetTester tester,
    ) async {
      await pumpRa(
        tester,
        const SizedBox(width: 200, child: RaProgress(value: 0.25, label: '上传中', showValue: true)),
      );
      await tester.pumpAndSettle();
      final Size bar = tester.getSize(fill());
      expect(bar.width, closeTo(50, 0.01));
      expect(bar.height, 4);
      expect(find.text('上传中'), findsOneWidget);
      expect(find.text('25%'), findsOneWidget);
    });

    testWidgets('indeterminate slides; still with reduced motion', (WidgetTester tester) async {
      await pumpRa(tester, const SizedBox(width: 200, child: RaProgress(value: null)));
      Finder segment() => find.descendant(
        of: find.byType(FractionallySizedBox),
        matching: find.byType(DecoratedBox),
      );
      final double a = tester.getTopLeft(segment()).dx;
      await tester.pump(theme.progress.indeterminatePeriod ~/ 2);
      final double b = tester.getTopLeft(segment()).dx;
      expect(b, isNot(a));

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: RaApp(
            debugShowCheckedModeBanner: false,
            home: const Align(
              alignment: Alignment.topLeft,
              child: SizedBox(width: 200, child: RaProgress(value: null)),
            ),
          ),
        ),
      );
      final double c = tester.getTopLeft(segment()).dx;
      await tester.pump(theme.progress.indeterminatePeriod ~/ 3);
      expect(tester.getTopLeft(segment()).dx, c);
    });

    testWidgets('meter colors by thresholds', (WidgetTester tester) async {
      Color colorOf(Finder meter) =>
          (tester.widget<DecoratedBox>(find.descendant(of: meter, matching: fill())).decoration
                  as BoxDecoration)
              .color!;
      await pumpRa(
        tester,
        const SizedBox(
          width: 200,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RaMeter(key: Key('a'), value: 3, max: 10, low: 7, high: 9, valueLabel: '3 / 10 GB'),
              RaMeter(key: Key('b'), value: 8, max: 10, low: 7, high: 9),
              RaMeter(key: Key('c'), value: 9.5, max: 10, low: 7, high: 9),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(colorOf(find.byKey(const Key('a'))), theme.colors.accent);
      expect(colorOf(find.byKey(const Key('b'))), theme.colors.attention);
      expect(colorOf(find.byKey(const Key('c'))), theme.colors.danger);
      expect(find.text('3 / 10 GB'), findsOneWidget);
      expect(find.text('80%'), findsOneWidget);
    });
  });
}
