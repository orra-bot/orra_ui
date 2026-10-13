import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orra_ui/orra_ui.dart';

import 'helpers.dart';

Finder _control(String label) => find.descendant(
  of: find.ancestor(of: find.text(label), matching: find.byType(RaTextField)),
  matching: find.byType(RaAnimatedSurface),
);

BoxDecoration _decoration(WidgetTester tester, String label) =>
    firstBoxDecoration(tester, _control(label))!;

Color _borderColor(WidgetTester tester, String label) =>
    (_decoration(tester, label).border! as Border).top.color;

/// 光标闪烁会持续调度帧，这里用固定时长代替 pumpAndSettle。
/// 第一帧启动动画计时，第二次推进到动画结束。
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  final RaThemeData theme = RaThemeData.light();

  Widget field({
    String label = '名称',
    RaValidator? validator,
    bool enabled = true,
    bool search = false,
    String? placeholder,
    String? description,
  }) => SizedBox(
    width: 320,
    child: RaTextField(
      label: label,
      validator: validator,
      enabled: enabled,
      search: search,
      placeholder: placeholder,
      description: description,
    ),
  );

  testWidgets('single line is 32 high with label gap 6', (WidgetTester tester) async {
    await pumpRa(tester, field(description: '最多 20 个字'));
    expect(tester.getSize(_control('名称')).height, 32);
    final Rect label = tester.getRect(find.text('名称'));
    final Rect control = tester.getRect(_control('名称'));
    expect(control.top - label.bottom, closeTo(6, 0.01));
    expect(_decoration(tester, '名称').borderRadius, BorderRadius.circular(8));
    expect(_borderColor(tester, '名称'), theme.colors.border);
    expect(find.text('最多 20 个字'), findsOneWidget);
  });

  testWidgets('hover strengthens border; focus uses accent', (WidgetTester tester) async {
    await pumpRa(tester, Padding(padding: const EdgeInsets.all(40), child: field()));
    final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: const Offset(1200, 800));
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(_control('名称')));
    await _settle(tester);
    expect(_borderColor(tester, '名称'), theme.colors.borderStrong);
    await tester.tap(_control('名称'));
    await _settle(tester);
    expect(_borderColor(tester, '名称'), theme.colors.accent);
  });

  testWidgets('validator runs after blur, then live', (WidgetTester tester) async {
    String? required(String v) => v.trim().isEmpty ? '请填写名称' : null;
    await pumpRa(
      tester,
      Column(
        children: <Widget>[
          field(validator: required),
          const SizedBox(width: 320, child: RaTextField(label: '其他')),
        ],
      ),
    );
    await tester.tap(_control('名称'));
    await _settle(tester);
    expect(find.text('请填写名称'), findsNothing);
    await tester.tap(_control('其他'));
    await _settle(tester);
    expect(find.text('请填写名称'), findsOneWidget);
    expect(_borderColor(tester, '名称'), theme.colors.danger);

    await tester.enterText(
      find.descendant(of: _control('名称'), matching: find.byType(EditableText)),
      'Orra',
    );
    await _settle(tester);
    expect(find.text('请填写名称'), findsNothing);
  });

  testWidgets('RaForm.validate checks every field', (WidgetTester tester) async {
    final GlobalKey<RaFormState> form = GlobalKey<RaFormState>();
    await pumpRa(
      tester,
      SizedBox(
        width: 320,
        child: RaForm(
          key: form,
          children: <Widget>[
            RaTextField(label: '名称', validator: (String v) => v.isEmpty ? '请填写名称' : null),
            RaTextField(label: '邮箱', validator: (String v) => v.contains('@') ? null : '邮箱格式不对'),
          ],
        ),
      ),
    );
    expect(form.currentState!.validate(), isFalse);
    await _settle(tester);
    expect(find.text('请填写名称'), findsOneWidget);
    expect(find.text('邮箱格式不对'), findsOneWidget);
    // 字段间距 16。
    final double gap =
        tester.getTopLeft(find.text('邮箱')).dy - tester.getBottomLeft(find.text('请填写名称')).dy;
    expect(gap, closeTo(16, 0.01));
  });

  testWidgets('placeholder hides once text is entered', (WidgetTester tester) async {
    await pumpRa(tester, field(placeholder: '输入名称'));
    expect(find.text('输入名称'), findsOneWidget);
    await tester.enterText(find.byType(EditableText), 'x');
    await _settle(tester);
    expect(find.text('输入名称'), findsNothing);
  });

  testWidgets('disabled is read-only on sunken background', (WidgetTester tester) async {
    await pumpRa(tester, field(enabled: false));
    expect(tester.widget<EditableText>(find.byType(EditableText)).readOnly, isTrue);
    expect(_decoration(tester, '名称').color, theme.colors.sunken);
  });

  testWidgets('search: icon at 10, text starts at 32', (WidgetTester tester) async {
    await pumpRa(tester, field(search: true));
    final Rect control = tester.getRect(_control('名称'));
    final Rect text = tester.getRect(find.byType(EditableText));
    expect(text.left - control.left, closeTo(32, 0.01));
    final Rect icon = tester.getRect(
      find.descendant(of: find.byType(RaTextField), matching: find.byType(RaIcon)),
    );
    expect(icon.left - control.left, closeTo(10, 0.01));
    expect(icon.width, 16);
  });

  testWidgets('multiline defaults to 3 rows', (WidgetTester tester) async {
    await pumpRa(
      tester,
      const SizedBox(width: 320, child: RaTextField(label: '描述', multiline: true)),
    );
    // 3 行 × 20 + 上下内边距 8 × 2。
    expect(tester.getSize(_control('描述')).height, closeTo(76, 0.01));
  });
}
