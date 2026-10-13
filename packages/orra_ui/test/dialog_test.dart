import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orra_ui/orra_ui.dart';

import 'helpers.dart';

Finder get _card =>
    find.descendant(of: find.byType(RaDialog), matching: find.byType(DecoratedBox)).first;

Future<BuildContext> _host(WidgetTester tester, {Size size = const Size(1280, 820)}) async {
  await pumpRa(
    tester,
    const SizedBox(width: 10, height: 10, key: ValueKey<String>('host')),
    size: size,
  );
  return tester.element(find.byKey(const ValueKey<String>('host')));
}

void main() {
  final RaThemeData theme = RaThemeData.light();

  testWidgets('dialog is 460 wide, centered, with Linear surface', (WidgetTester tester) async {
    final BuildContext context = await _host(tester);
    unawaited(
      showRaDialog<void>(
        context: context,
        builder: (_) => const RaDialog(title: '重命名', description: Text('输入新名称')),
      ),
    );
    await tester.pumpAndSettle();
    final Rect card = tester.getRect(_card);
    expect(card.width, 460);
    expect(card.center.dx, closeTo(640, 0.01));
    expect(card.center.dy, closeTo(410, 0.01));
    final BoxDecoration d = firstBoxDecoration(tester, find.byType(RaDialog))!;
    expect(d.borderRadius, BorderRadius.circular(12));
    expect(d.color, theme.colors.surface);
    // 标题距卡片左上 24。
    expect(tester.getTopLeft(find.text('重命名')).dx - card.left, closeTo(24, 0.01));
  });

  testWidgets('narrow window: width = window - 32', (WidgetTester tester) async {
    final BuildContext context = await _host(tester, size: const Size(400, 600));
    unawaited(
      showRaDialog<void>(
        context: context,
        builder: (_) => const RaDialog(title: 'T'),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.getSize(_card).width, 368);
  });

  testWidgets('Esc and barrier tap close; barrierDismissible false keeps it', (
    WidgetTester tester,
  ) async {
    final BuildContext context = await _host(tester);
    unawaited(
      showRaDialog<void>(
        context: context,
        builder: (_) => const RaDialog(title: 'A'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('A'), findsNothing);

    unawaited(
      showRaDialog<void>(
        context: context,
        builder: (_) => const RaDialog(title: 'B'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();
    expect(find.text('B'), findsNothing);

    unawaited(
      showRaDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const RaDialog(title: 'C'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();
    expect(find.text('C'), findsOneWidget);
  });

  testWidgets('footer actions are right aligned with 8 gap', (WidgetTester tester) async {
    final BuildContext context = await _host(tester);
    unawaited(
      showRaDialog<void>(
        context: context,
        builder: (_) => RaDialog(
          title: 'T',
          actions: <Widget>[
            RaButton(onPressed: () {}, child: const Text('取消')),
            RaButton(onPressed: () {}, child: const Text('确定')),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    final Rect card = tester.getRect(_card);
    final Rect ok = tester.getRect(
      find.ancestor(of: find.text('确定'), matching: find.byType(RaButton)),
    );
    final Rect cancel = tester.getRect(
      find.ancestor(of: find.text('取消'), matching: find.byType(RaButton)),
    );
    expect(card.right - ok.right, closeTo(24, 0.01));
    expect(ok.left - cancel.right, closeTo(8, 0.01));
  });

  testWidgets('confirm: pending, error keeps dialog open, then success', (
    WidgetTester tester,
  ) async {
    final BuildContext context = await _host(tester);
    Completer<void> work = Completer<void>();
    bool? result;
    unawaited(
      showRaConfirmDialog(
        context: context,
        title: '删除？',
        description: const Text('无法撤销'),
        confirmLabel: '删除',
        pendingLabel: '删除中…',
        tone: RaConfirmTone.danger,
        onConfirm: () => work.future,
        errorText: (Object e) => '删除失败：$e',
      ).then((bool v) => result = v),
    );
    await tester.pumpAndSettle();
    final BoxDecoration confirmDecoration = firstBoxDecoration(
      tester,
      find.ancestor(of: find.text('删除'), matching: find.byType(RaButton)),
    )!;
    expect(confirmDecoration.color, theme.colors.danger);

    await tester.tap(find.text('删除'));
    await tester.pump();
    expect(find.text('删除中…'), findsOneWidget);
    expect(find.byType(RaSpinner), findsOneWidget);
    // 进行中 Esc 不关闭。
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('删除？'), findsOneWidget);

    work.completeError('网络错误');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('删除失败：网络错误'), findsOneWidget);
    expect(find.text('删除？'), findsOneWidget);
    expect(result, isNull);

    work = Completer<void>()..complete();
    await tester.tap(find.text('删除'));
    await tester.pumpAndSettle();
    expect(find.text('删除？'), findsNothing);
    expect(result, isTrue);
  });

  testWidgets('confirm: cancel and Esc return false', (WidgetTester tester) async {
    final BuildContext context = await _host(tester);
    final List<bool> results = <bool>[];
    unawaited(
      showRaConfirmDialog(
        context: context,
        title: '归档？',
        description: const Text('可以恢复'),
        confirmLabel: '归档',
      ).then(results.add),
    );
    await tester.pumpAndSettle();
    // 测试环境语言为英文，内置文案随之切换。
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    unawaited(
      showRaConfirmDialog(
        context: context,
        title: '归档？',
        description: const Text('可以恢复'),
        confirmLabel: '归档',
      ).then(results.add),
    );
    await tester.pumpAndSettle();
    // 点击遮罩不关闭确认框。
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();
    expect(find.text('归档？'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(results, <bool>[false, false]);
  });

  testWidgets('confirm without onConfirm returns true', (WidgetTester tester) async {
    final BuildContext context = await _host(tester);
    bool? result;
    unawaited(
      showRaConfirmDialog(
        context: context,
        title: 'Q',
        description: const Text('d'),
        confirmLabel: '好',
      ).then((bool v) => result = v),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('好'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
  });
}
