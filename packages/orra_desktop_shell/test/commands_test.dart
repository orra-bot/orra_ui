import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orra_desktop_shell/orra_desktop_shell.dart';
import 'package:orra_ui/orra_ui.dart';

void main() {
  late List<String> invoked;

  Widget app() => RaApp(
    debugShowCheckedModeBanner: false,
    home: RaAppMenuBar(
      appName: 'Gallery',
      menus: <RaMenuBarMenu>[
        RaMenuBarMenu(
          label: '文件',
          entries: <RaMenuBarEntry>[
            RaCommand(
              label: '新建标签页',
              shortcut: const SingleActivator(LogicalKeyboardKey.keyT, meta: true),
              onInvoked: () => invoked.add('new-tab'),
            ),
            const RaCommandDivider(),
            RaCommand(
              label: '第 1 个标签页',
              shortcut: const SingleActivator(LogicalKeyboardKey.digit1, meta: true),
              visible: false,
              onInvoked: () => invoked.add('tab-1'),
            ),
            RaCommand(
              label: '已禁用',
              enabled: false,
              shortcut: const SingleActivator(LogicalKeyboardKey.keyD, meta: true),
              onInvoked: () => invoked.add('disabled'),
            ),
          ],
        ),
      ],
      child: const SizedBox.expand(),
    ),
  );

  setUp(() => invoked = <String>[]);

  testWidgets(
    'Windows / Linux：快捷键全局生效，禁用命令不触发',
    (WidgetTester tester) async {
      await tester.pumpWidget(app());
      await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyT);
      await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyD);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
      expect(invoked, <String>['new-tab', 'tab-1']);
      expect(find.byType(PlatformMenuBar), findsNothing);
    },
    variant: const TargetPlatformVariant(<TargetPlatform>{
      TargetPlatform.windows,
      TargetPlatform.linux,
    }),
  );

  testWidgets('macOS：生成原生菜单栏；可见命令的快捷键交给系统菜单，隐藏命令仍响应', (WidgetTester tester) async {
    await tester.pumpWidget(app());
    expect(find.byType(PlatformMenuBar), findsOneWidget);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyT);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
    expect(invoked, <String>['tab-1']);
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));
}
