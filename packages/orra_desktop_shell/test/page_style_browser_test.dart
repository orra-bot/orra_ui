@TestOn('browser')
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orra_desktop_shell/orra_desktop_shell.dart';
import 'package:orra_ui/orra_ui.dart';
import 'package:web/web.dart' as web;

/// 真实浏览器中运行：flutter test --platform chrome test/page_style_browser_test.dart
void main() {
  String? themeColor() =>
      web.document.querySelector('meta[name="theme-color"]')?.getAttribute('content');

  test('默认窗口实现是浏览器实现', () {
    expect(RaShellPlatform.current, RaShellPlatform.web);
    expect(raDefaultWindowController, same(RaBrowserWindowController.instance));
  });

  test('index.html 中按深浅模式写的多个 theme-color 合并为一个', () async {
    for (final String scheme in <String>['light', 'dark']) {
      final web.Element meta = web.document.createElement('meta')
        ..setAttribute('name', 'theme-color')
        ..setAttribute('media', '(prefers-color-scheme: $scheme)')
        ..setAttribute('content', '#ffffff');
      web.document.head!.append(meta);
    }
    await RaBrowserWindowController.instance.setBackgroundColor(const Color(0xFF09090A));
    final web.NodeList metas = web.document.querySelectorAll('meta[name="theme-color"]');
    expect(metas.length, 1);
    final web.Element meta = metas.item(0)! as web.Element;
    expect(meta.hasAttribute('media'), isFalse);
    expect(meta.getAttribute('content'), '#09090a');
  });

  test('窗口底色写入 <body> 背景与 theme-color', () async {
    await RaBrowserWindowController.instance.setBackgroundColor(const Color(0xFFEFEFF0));
    expect(web.document.body!.style.backgroundColor, 'rgb(239, 239, 240)');
    expect(themeColor(), '#efeff0');

    // 再次设置复用同一个 meta。
    await RaBrowserWindowController.instance.setBackgroundColor(const Color(0xFF09090A));
    expect(web.document.body!.style.backgroundColor, 'rgb(9, 9, 10)');
    expect(web.document.querySelectorAll('meta[name="theme-color"]').length, 1);
    expect(themeColor(), '#09090a');
  });

  testWidgets('RaDesktopFrame 在浏览器中把页面底色同步为主题 chrome', (WidgetTester tester) async {
    await tester.pumpWidget(
      RaApp(
        themeMode: RaThemeMode.dark,
        debugShowCheckedModeBanner: false,
        home: const RaDesktopFrame(sidebar: SizedBox.expand(), child: SizedBox.expand()),
      ),
    );
    expect(find.byType(RaWindowCaptionButtons), findsNothing);
    expect(web.document.body!.style.backgroundColor, 'rgb(9, 9, 10)');
  });
}
