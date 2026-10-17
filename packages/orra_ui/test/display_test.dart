import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orra_ui/orra_ui.dart';

import 'helpers.dart';

/// 抽屉面板（标题最近的 DecoratedBox 祖先）。
Finder _panel(String title) =>
    find.ancestor(of: find.text(title), matching: find.byType(DecoratedBox)).first;

void main() {
  final RaThemeData theme = RaThemeData.light();

  testWidgets('RaTag: 20 high pill, tone colors; outline draws a dashed border', (
    WidgetTester tester,
  ) async {
    await pumpRa(
      tester,
      const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          RaTag(label: '运行中', tone: RaTagTone.success, dot: true),
          RaTag(label: '未开放', tone: RaTagTone.outline),
        ],
      ),
    );
    final Finder success = find.widgetWithText(RaTag, '运行中');
    expect(tester.getSize(success).height, 20);
    expect(decoratedColor(tester, success), theme.colors.successSoft);
    expect(
      find.descendant(of: find.widgetWithText(RaTag, '未开放'), matching: find.byType(RaDashedBorder)),
      findsOneWidget,
    );
  });

  testWidgets('RaCountTag hides at 0 and caps at max', (WidgetTester tester) async {
    await pumpRa(
      tester,
      const Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          RaCountTag(count: 0, semanticLabel: '无未读'),
          RaCountTag(count: 120, semanticLabel: '120 条未读'),
        ],
      ),
    );
    expect(find.text('0'), findsNothing);
    expect(find.text('99+'), findsOneWidget);
  });

  testWidgets('RaSideCard collapses; property rows have a 90px label column', (
    WidgetTester tester,
  ) async {
    await pumpRa(
      tester,
      const SizedBox(
        width: 304,
        child: RaSideCard(
          title: '它做什么',
          children: <Widget>[
            RaPropertyRow(label: '负责人', child: Text('Ive')),
            RaPropertyRow(
              label: '状态',
              child: RaTag(label: '运行中'),
            ),
          ],
        ),
      ),
    );
    final Rect row = tester.getRect(find.widgetWithText(RaPropertyRow, '负责人'));
    expect(row.height, 28);
    expect(tester.getTopLeft(find.text('Ive')).dx - row.left, 98);
    final double expandedHeight = tester.getSize(find.byType(RaSideCard)).height;

    await tester.tap(find.text('它做什么'));
    await tester.pumpAndSettle();
    final double collapsedHeight = tester.getSize(find.byType(RaSideCard)).height;
    // 收起后只剩标题行（28）+ 上下内边距（6 + 6）。
    expect(collapsedHeight, 40);
    expect(collapsedHeight, lessThan(expandedHeight));
  });

  testWidgets('RaCollapsible toggles its panel', (WidgetTester tester) async {
    await pumpRa(
      tester,
      const SizedBox(
        width: 400,
        child: RaCollapsible(title: Text('高级选项'), child: Text('内容')),
      ),
    );
    final Finder panel = find.byType(RaCollapsiblePanel);
    expect(tester.getSize(panel).height, 0);
    await tester.tap(find.text('高级选项'));
    await tester.pumpAndSettle();
    expect(tester.getSize(panel).height, greaterThan(0));
  });

  testWidgets('state blocks: loading, empty, error with retry', (WidgetTester tester) async {
    int retries = 0;
    await pumpRa(
      tester,
      SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const RaLoadingState(),
            const RaEmptyState(title: '还没有运行记录', description: Text('运行一次后会出现在这里。')),
            RaErrorState(message: '网络连接已断开。', onRetry: () => retries++),
          ],
        ),
      ),
    );
    expect(find.byType(RaSkeleton), findsNWidgets(3));
    expect(find.byType(RaDashedBorder), findsOneWidget);
    // 测试环境的语言是英文。
    expect(find.text(const RaLocalizationsEn().loadFailed), findsOneWidget);
    await tester.tap(find.text(const RaLocalizationsEn().retry));
    expect(retries, 1);
  });

  testWidgets('drawer slides in from the right, 360 wide; Esc closes', (WidgetTester tester) async {
    await pumpRa(
      tester,
      Builder(
        builder: (BuildContext context) => RaButton(
          onPressed: () => showRaDrawer<void>(
            context: context,
            builder: (BuildContext context) => const RaDrawer(title: '详情', child: Text('内容')),
          ),
          child: const Text('打开'),
        ),
      ),
    );
    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();
    final Rect drawer = tester.getRect(_panel('详情'));
    expect(drawer.width, 360);
    expect(drawer.right, 1280);
    expect(drawer.height, 820);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('详情'), findsNothing);
  });

  testWidgets('narrow window: drawer is 92% of the window', (WidgetTester tester) async {
    await pumpRa(
      tester,
      Builder(
        builder: (BuildContext context) => RaButton(
          onPressed: () => showRaDrawer<void>(
            context: context,
            builder: (BuildContext context) => const RaDrawer(title: '详情', child: SizedBox()),
          ),
          child: const Text('打开'),
        ),
      ),
      size: const Size(300, 600),
    );
    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();
    expect(tester.getSize(_panel('详情')).width, closeTo(276, 0.01));
  });
}
