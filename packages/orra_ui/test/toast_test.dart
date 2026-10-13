import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orra_ui/orra_ui.dart';

import 'helpers.dart';

Future<RaToastController> _host(WidgetTester tester) async {
  await pumpRa(tester, const SizedBox(width: 10, height: 10, key: ValueKey<String>('host')));
  return RaToast.of(tester.element(find.byKey(const ValueKey<String>('host'))));
}

Finder _toastCard(String title) =>
    find.ancestor(of: find.text(title), matching: find.byType(DecoratedBox)).last;

void main() {
  final RaThemeData theme = RaThemeData.light();

  testWidgets('success / error appear bottom-right with icon colors', (WidgetTester tester) async {
    final RaToastController toast = await _host(tester);
    toast.success('已保存');
    toast.error('保存失败', description: '网络不可用，请稍后重试');
    await tester.pumpAndSettle();
    expect(find.text('已保存'), findsOneWidget);
    expect(find.text('网络不可用，请稍后重试'), findsOneWidget);

    RaIcon iconOf(String title) => tester.widget<RaIcon>(
      find
          .descendant(
            of: find.ancestor(of: find.text(title), matching: find.byType(Row)).first,
            matching: find.byType(RaIcon),
          )
          .first,
    );
    expect(iconOf('已保存').color, theme.colors.success);
    expect(iconOf('保存失败').color, theme.colors.danger);

    final Rect last = tester.getRect(_toastCard('保存失败'));
    expect(last.right, closeTo(1280 - 20, 0.01));
    expect(last.bottom, closeTo(820 - 20, 0.01));
    expect(last.width, 360);
    final Rect first = tester.getRect(_toastCard('已保存'));
    expect(last.top - first.bottom, closeTo(8, 0.01));
    final BoxDecoration d =
        tester.widget<DecoratedBox>(_toastCard('已保存')).decoration as BoxDecoration;
    expect(d.borderRadius, BorderRadius.circular(12));
    expect(d.color, theme.colors.surface);
  });

  testWidgets('auto dismiss after 5s', (WidgetTester tester) async {
    final RaToastController toast = await _host(tester);
    toast.success('已保存');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 4900));
    expect(find.text('已保存'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();
    expect(find.text('已保存'), findsNothing);
    expect(toast.entries, isEmpty);
  });

  testWidgets('hovering pauses the countdown', (WidgetTester tester) async {
    final RaToastController toast = await _host(tester);
    toast.success('已保存');
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: tester.getCenter(find.text('已保存')));
    addTearDown(mouse.removePointer);
    await tester.pump();
    await tester.pump(const Duration(seconds: 10));
    expect(find.text('已保存'), findsOneWidget);
    // 移开后继续计时（剩余时间按单调时钟计算，测试的假时钟下按满额计），最多 5s 内消失。
    await mouse.moveTo(const Offset(10, 10));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 5100));
    await tester.pumpAndSettle();
    expect(find.text('已保存'), findsNothing);
  });

  testWidgets('close button dismisses', (WidgetTester tester) async {
    final RaToastController toast = await _host(tester);
    toast.success('已保存');
    await tester.pumpAndSettle();
    final Finder close = find.descendant(
      of: find.ancestor(of: find.text('已保存'), matching: find.byType(Row)).first,
      matching: find.byType(RaPressable),
    );
    expect(tester.getSize(close), const Size(20, 20));
    await tester.tap(close);
    await tester.pumpAndSettle();
    expect(find.text('已保存'), findsNothing);
  });

  testWidgets('at most 3 toasts; the oldest leaves first', (WidgetTester tester) async {
    final RaToastController toast = await _host(tester);
    for (int i = 1; i <= 4; i++) {
      toast.success('提示 $i');
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pumpAndSettle();
    expect(find.text('提示 1'), findsNothing);
    for (int i = 2; i <= 4; i++) {
      expect(find.text('提示 $i'), findsOneWidget);
    }
  });
}
