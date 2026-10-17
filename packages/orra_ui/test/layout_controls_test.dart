import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orra_ui/orra_ui.dart';

import 'helpers.dart';

void main() {
  final RaThemeData theme = RaThemeData.light();

  group('RaToggle', () {
    testWidgets('icon-only is a 28 circle; toggles and reports toggled semantics', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      bool pressed = false;
      await pumpRa(
        tester,
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) => RaToggle(
            pressed: pressed,
            onChanged: (bool v) => setState(() => pressed = v),
            label: '加粗',
            icon: RaIcon.glyph(RaGlyphs.check),
          ),
        ),
      );
      expect(tester.getSize(find.byType(RaButton)), const Size(28, 28));
      expect(
        tester.getSemantics(find.bySemanticsLabel('加粗')),
        isSemantics(label: '加粗', hasToggledState: true, isToggled: false),
      );
      await tester.tap(find.byType(RaButton));
      await tester.pumpAndSettle();
      expect(pressed, isTrue);
      expect(
        tester.getSemantics(find.bySemanticsLabel('加粗')),
        isSemantics(label: '加粗', hasToggledState: true, isToggled: true),
      );
      handle.dispose();
    });

    testWidgets('with text uses the quiet look; pressed shows the selected fill', (
      WidgetTester tester,
    ) async {
      await pumpRa(
        tester,
        RaToggle(pressed: true, onChanged: (_) {}, label: '固定', child: const Text('固定')),
      );
      expect(decoratedColor(tester, find.byType(RaButton)), theme.colors.hover);
    });
  });

  group('RaToggleGroup', () {
    Widget group({
      required Set<String> values,
      required ValueChanged<Set<String>> onChanged,
      bool multiple = true,
    }) => RaToggleGroup<String>(
      values: values,
      onChanged: onChanged,
      multiple: multiple,
      items: const <RaToggleItem<String>>[
        RaToggleItem<String>(value: 'b', label: 'B'),
        RaToggleItem<String>(value: 'i', label: 'I'),
        RaToggleItem<String>(value: 'u', label: 'U'),
      ],
    );

    testWidgets('multiple keeps others; single replaces and can clear', (
      WidgetTester tester,
    ) async {
      Set<String> values = <String>{'b'};
      await pumpRa(tester, group(values: values, onChanged: (Set<String> v) => values = v));
      await tester.tap(find.text('I'));
      expect(values, <String>{'b', 'i'});

      values = <String>{'b'};
      await pumpRa(
        tester,
        group(values: values, multiple: false, onChanged: (Set<String> v) => values = v),
      );
      await tester.tap(find.text('I'));
      expect(values, <String>{'i'});
      await pumpRa(
        tester,
        group(values: values, multiple: false, onChanged: (Set<String> v) => values = v),
      );
      await tester.tap(find.text('I'));
      expect(values, isEmpty);
    });

    testWidgets('arrow keys move focus without toggling, and wrap', (WidgetTester tester) async {
      Set<String> values = <String>{};
      await pumpRa(tester, group(values: values, onChanged: (Set<String> v) => values = v));
      await tester.tap(find.text('U'));
      await tester.pump();
      values = <String>{};
      bool focused(String label) => Focus.of(tester.element(find.text(label))).hasPrimaryFocus;
      expect(focused('U'), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(focused('B'), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(focused('U'), isTrue);
      expect(values, isEmpty);
    });
  });

  group('RaToolbar', () {
    testWidgets('arrows move focus between items and wrap; Home / End', (
      WidgetTester tester,
    ) async {
      final List<FocusNode> nodes = List<FocusNode>.generate(3, (int i) => FocusNode());
      addTearDown(() {
        for (final FocusNode n in nodes) {
          n.dispose();
        }
      });
      await pumpRa(
        tester,
        RaToolbar(
          semanticLabel: '格式',
          children: <Widget>[
            RaButton(focusNode: nodes[0], onPressed: () {}, child: const Text('A')),
            const RaToolbarSeparator(),
            RaButton(focusNode: nodes[1], onPressed: () {}, child: const Text('B')),
            RaButton(focusNode: nodes[2], onPressed: () {}, child: const Text('C')),
          ],
        ),
      );
      nodes[0].requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(nodes[1].hasPrimaryFocus, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(nodes[0].hasPrimaryFocus, isTrue, reason: '首尾循环');
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      expect(nodes[2].hasPrimaryFocus, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump();
      expect(nodes[0].hasPrimaryFocus, isTrue);

      // 分隔线：16 高、0.5px（2 倍屏 1 物理像素），左右各留 4。
      final Finder separator = find.byType(RaToolbarSeparator);
      expect(tester.getSize(separator), const Size(8.5, 16));
      expect(
        tester.getTopLeft(find.text('B')).dx - tester.getTopRight(find.byType(RaButton).first).dx,
        greaterThan(8.5),
      );
    });

    testWidgets('arrow keys stay in a text field inside the toolbar', (WidgetTester tester) async {
      final FocusNode field = FocusNode();
      final FocusNode button = FocusNode();
      addTearDown(field.dispose);
      addTearDown(button.dispose);
      final TextEditingController controller = TextEditingController(text: 'abc');
      addTearDown(controller.dispose);
      await pumpRa(
        tester,
        RaToolbar(
          children: <Widget>[
            SizedBox(
              width: 200,
              child: RaTextField(
                label: 'Find',
                hideLabel: true,
                controller: controller,
                focusNode: field,
              ),
            ),
            RaButton(focusNode: button, onPressed: () {}, child: const Text('Go')),
          ],
        ),
      );
      field.requestFocus();
      await tester.pump();
      controller.selection = const TextSelection.collapsed(offset: 3);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(field.hasPrimaryFocus, isTrue);
      // 网页端的文本框方向键由浏览器处理，测试里的按键不会移动光标。
      if (!kIsWeb) expect(controller.selection.baseOffset, 2);
    });
  });

  group('RaAccordion', () {
    const List<RaAccordionItem> items = <RaAccordionItem>[
      RaAccordionItem(value: 'a', title: 'Alpha', child: Text('alpha body')),
      RaAccordionItem(value: 'b', title: 'Beta', child: Text('beta body')),
      RaAccordionItem(value: 'c', title: 'Gamma', child: Text('gamma body'), enabled: false),
    ];

    double panelHeight(WidgetTester tester, String text) => tester
        .getSize(find.ancestor(of: find.text(text), matching: find.byType(RaCollapsiblePanel)))
        .height;

    testWidgets('40 high headers; single mode closes the other item', (WidgetTester tester) async {
      await pumpRa(tester, const SizedBox(width: 400, child: RaAccordion(items: items)));
      expect(tester.getSize(find.byType(RaPressable).first).height, 40);
      expect(panelHeight(tester, 'alpha body'), 0);
      await tester.tap(find.text('Alpha'));
      await tester.pumpAndSettle();
      expect(panelHeight(tester, 'alpha body'), greaterThan(0));
      await tester.tap(find.text('Beta'));
      await tester.pumpAndSettle();
      expect(panelHeight(tester, 'alpha body'), 0);
      expect(panelHeight(tester, 'beta body'), greaterThan(0));
      // 禁用项点不开。
      await tester.tap(find.text('Gamma'));
      await tester.pumpAndSettle();
      expect(panelHeight(tester, 'gamma body'), 0);
    });

    testWidgets('multiple keeps several open; controlled follows the parent', (
      WidgetTester tester,
    ) async {
      await pumpRa(
        tester,
        const SizedBox(width: 400, child: RaAccordion(items: items, multiple: true)),
      );
      await tester.tap(find.text('Alpha'));
      await tester.tap(find.text('Beta'));
      await tester.pumpAndSettle();
      expect(panelHeight(tester, 'alpha body'), greaterThan(0));
      expect(panelHeight(tester, 'beta body'), greaterThan(0));

      Set<Object>? reported;
      await pumpRa(
        tester,
        SizedBox(
          width: 400,
          child: RaAccordion(
            items: items,
            expanded: const <Object>{'b'},
            onExpandedChanged: (Set<Object> v) => reported = v,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Alpha'));
      await tester.pumpAndSettle();
      expect(reported, <Object>{'a'});
      // 受控：父级没更新，仍然是 b 展开。
      expect(panelHeight(tester, 'beta body'), greaterThan(0));
      expect(panelHeight(tester, 'alpha body'), 0);
    });

    testWidgets('arrows move between headers (skipping disabled); Enter toggles', (
      WidgetTester tester,
    ) async {
      await pumpRa(tester, const SizedBox(width: 400, child: RaAccordion(items: items)));
      await tester.tap(find.text('Alpha'));
      await tester.pumpAndSettle();
      bool focused(String title) => Focus.of(tester.element(find.text(title))).hasPrimaryFocus;
      expect(focused('Alpha'), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(focused('Beta'), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(focused('Alpha'), isTrue, reason: '跳过禁用项并循环');
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      expect(focused('Beta'), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(panelHeight(tester, 'beta body'), greaterThan(0));
    });

    testWidgets('header reports expanded semantics', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpRa(
        tester,
        const SizedBox(
          width: 400,
          child: RaAccordion(items: items, initiallyExpanded: <Object>{'a'}),
        ),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Alpha')),
        isSemantics(label: 'Alpha', hasExpandedState: true, isExpanded: true, isHeader: true),
      );
      handle.dispose();
    });
  });

  group('RaCheckboxGroup', () {
    const List<RaCheckboxOption<String>> options = <RaCheckboxOption<String>>[
      RaCheckboxOption<String>(value: 'mail', label: 'Mail'),
      RaCheckboxOption<String>(value: 'push', label: 'Push'),
    ];

    testWidgets('parent: none / mixed / all; children indented 22', (WidgetTester tester) async {
      Set<String> values = <String>{};
      Widget build() => StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => RaCheckboxGroup<String>(
          parentLabel: 'All',
          options: options,
          values: values,
          onChanged: (Set<String> v) => setState(() => values = v),
        ),
      );
      await pumpRa(tester, build());
      RaCheckbox parent() => tester.widget<RaCheckbox>(find.byType(RaCheckbox).first);
      expect(parent().value, isFalse);
      expect(tester.getTopLeft(find.text('Mail')).dx - tester.getTopLeft(find.text('All')).dx, 22);
      await tester.tap(find.text('Mail'));
      await tester.pump();
      expect(parent().value, isNull);
      await tester.tap(find.text('All'));
      await tester.pump();
      expect(values, <String>{'mail', 'push'});
      expect(parent().value, isTrue);
      await tester.tap(find.text('All'));
      await tester.pump();
      expect(values, isEmpty);
    });
  });

  group('RaFieldset', () {
    testWidgets('disabled blocks taps and focus inside', (WidgetTester tester) async {
      int taps = 0;
      await pumpRa(
        tester,
        RaFieldset(
          legend: 'Notifications',
          description: const Text('How we reach you.'),
          enabled: false,
          children: <Widget>[RaButton(onPressed: () => taps++, child: const Text('Save'))],
        ),
      );
      await tester.tap(find.text('Save'), warnIfMissed: false);
      expect(taps, 0);
      expect(find.byType(ExcludeFocus), findsWidgets);
      expect(
        tester.widget<Opacity>(find.byType(Opacity).first).opacity,
        theme.control.disabledOpacity,
      );

      await pumpRa(
        tester,
        RaFieldset(
          legend: 'Notifications',
          children: <Widget>[RaButton(onPressed: () => taps++, child: const Text('Save'))],
        ),
      );
      await tester.tap(find.text('Save'));
      expect(taps, 1);
    });
  });
}
