import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orra_ui/orra_ui.dart';

import 'helpers.dart';

const List<RaComboboxOption<String>> _people = <RaComboboxOption<String>>[
  RaComboboxOption<String>(value: 'ada', label: 'Ada Lovelace'),
  RaComboboxOption<String>(value: 'alan', label: 'Alan Turing'),
  RaComboboxOption<String>(value: 'grace', label: 'Grace Hopper', enabled: false),
  RaComboboxOption<String>(value: 'ive', label: 'Ive Tian'),
];

/// 选项列表（输入框内部不用 SingleChildScrollView）。
final Finder _list = find.byType(SingleChildScrollView);

/// 列表中的某一行（文本在输入框里也可能出现，因此限定在列表里找）。
Finder _row(String label) => find.descendant(of: _list, matching: find.text(label));

bool get _open => _list.evaluate().isNotEmpty;

/// 桌面端：点击输入框外部会让输入框失焦。
final TargetPlatformVariant _desktop = TargetPlatformVariant.only(TargetPlatform.macOS);

void main() {
  final RaThemeData theme = RaThemeData.light();

  Future<String?> pumpCombobox(WidgetTester tester, {String? initial = 'ada'}) async {
    String? value = initial;
    await pumpRa(
      tester,
      Padding(
        padding: const EdgeInsets.all(40),
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              RaCombobox<String>(
                label: '负责人',
                width: 280,
                options: _people,
                value: value,
                emptyText: '没有匹配的成员',
                onChanged: (String v) => setState(() => value = v),
              ),
              RaButton(onPressed: () {}, child: Text('当前：$value')),
            ],
          ),
        ),
      ),
    );
    return value;
  }

  String fieldText(WidgetTester tester) =>
      tester.widget<EditableText>(find.byType(EditableText)).controller.text;

  testWidgets('focus opens all options under the field, as wide as the field', (
    WidgetTester tester,
  ) async {
    await pumpCombobox(tester);
    expect(fieldText(tester), 'Ada Lovelace');
    await tester.tap(find.byType(EditableText));
    await tester.pumpAndSettle();
    expect(_open, isTrue);
    expect(_row('Ive Tian'), findsOneWidget);
    final Rect field = tester.getRect(find.byType(RaAnimatedSurface).first);
    final Rect list = tester.getRect(
      find.ancestor(of: _list, matching: find.byType(RaNoDragRegion)).first,
    );
    expect(list.width, closeTo(field.width, 0.01));
    expect(list.top - field.bottom, closeTo(theme.menu.sideOffset, 0.01));
    // 行高 32；当前选中项行尾对勾。
    expect(
      tester
          .getSize(find.ancestor(of: _row('Alan Turing'), matching: find.byType(Container)).first)
          .height,
      32,
    );
    expect(
      find.descendant(
        of: find.ancestor(of: _row('Ada Lovelace'), matching: find.byType(Row)).first,
        matching: find.byType(RaIcon),
      ),
      findsOneWidget,
    );
  });

  testWidgets('typing filters; arrows skip disabled; Enter picks and closes', (
    WidgetTester tester,
  ) async {
    await pumpCombobox(tester);
    await tester.tap(find.byType(EditableText));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), 'a');
    await tester.pumpAndSettle();
    // Ada / Alan / Grace / Ive Tian 都含 a。
    expect(_row('Ive Tian'), findsOneWidget);
    await tester.enterText(find.byType(EditableText), 'tu');
    await tester.pumpAndSettle();
    expect(_row('Alan Turing'), findsOneWidget);
    expect(_row('Ada Lovelace'), findsNothing);

    await tester.enterText(find.byType(EditableText), 'i');
    await tester.pumpAndSettle();
    // 匹配：Alan Turing（第一项，已高亮）、Ive Tian；Grace 不含 i。
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('当前：ive'), findsOneWidget);
    expect(fieldText(tester), 'Ive Tian');
    expect(_open, isFalse);
  });

  testWidgets('arrow wraps and skips the disabled option', (WidgetTester tester) async {
    await pumpCombobox(tester, initial: 'alan');
    await tester.tap(find.byType(EditableText));
    await tester.pumpAndSettle();
    // 高亮从 Alan 开始；↓ 跳过 Grace 到 Ive，再 ↓ 回到 Ada。
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('当前：ada'), findsOneWidget);
  });

  testWidgets('clicking an option picks it and keeps focus in the field', variant: _desktop, (
    WidgetTester tester,
  ) async {
    await pumpCombobox(tester);
    await tester.tap(find.byType(EditableText));
    await tester.pumpAndSettle();
    await tester.tap(_row('Alan Turing'));
    await tester.pumpAndSettle();
    expect(find.text('当前：alan'), findsOneWidget);
    expect(_open, isFalse);
    final EditableTextState editable = tester.state<EditableTextState>(find.byType(EditableText));
    expect(editable.widget.focusNode.hasFocus, isTrue);
    // 点击禁用项不生效。
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    await tester.tap(_row('Grace Hopper'));
    await tester.pumpAndSettle();
    expect(find.text('当前：alan'), findsOneWidget);
  });

  testWidgets(
    'Esc closes; no matches shows the empty text; blur restores the label',
    variant: _desktop,
    (WidgetTester tester) async {
      await pumpCombobox(tester);
      await tester.tap(find.byType(EditableText));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(_open, isFalse);

      await tester.enterText(find.byType(EditableText), 'zzz');
      await tester.pumpAndSettle();
      expect(find.text('没有匹配的成员'), findsOneWidget);

      // 点别处失焦：恢复为选中项名称，值不变。
      await tester.tapAt(const Offset(1200, 800));
      await tester.pumpAndSettle();
      expect(fieldText(tester), 'Ada Lovelace');
      expect(find.text('没有匹配的成员'), findsNothing);
      expect(find.text('当前：ada'), findsOneWidget);
    },
  );

  group('RaAutocomplete', () {
    testWidgets('suggestions filter; Enter without highlight submits free text', (
      WidgetTester tester,
    ) async {
      String? selected;
      String? submitted;
      await pumpRa(
        tester,
        SizedBox(
          width: 300,
          child: RaAutocomplete(
            label: '标签',
            suggestions: const <String>['bug', 'billing', 'design'],
            onSelected: (String v) => selected = v,
            onSubmitted: (String v) => submitted = v,
          ),
        ),
      );
      await tester.tap(find.byType(EditableText));
      await tester.pumpAndSettle();
      expect(find.text('design'), findsOneWidget);
      await tester.enterText(find.byType(EditableText), 'bi');
      await tester.pumpAndSettle();
      expect(find.text('billing'), findsOneWidget);
      expect(find.text('design'), findsNothing);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(selected, 'billing');
      expect(tester.widget<EditableText>(find.byType(EditableText)).controller.text, 'billing');

      await tester.enterText(find.byType(EditableText), 'new-tag');
      await tester.pumpAndSettle();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(submitted, 'new-tag');
    });

    testWidgets('optionsBuilder and click to pick', (WidgetTester tester) async {
      String? selected;
      await pumpRa(
        tester,
        SizedBox(
          width: 300,
          child: RaAutocomplete(
            optionsBuilder: (String q) => <String>['$q@example.com', '$q@orra.dev'],
            onSelected: (String v) => selected = v,
          ),
        ),
      );
      await tester.tap(find.byType(EditableText));
      await tester.enterText(find.byType(EditableText), 'ive');
      await tester.pumpAndSettle();
      await tester.tap(find.text('ive@orra.dev'));
      await tester.pumpAndSettle();
      expect(selected, 'ive@orra.dev');
      expect(find.text('ive@example.com'), findsNothing);
    });
  });
}
