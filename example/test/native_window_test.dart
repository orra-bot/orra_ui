@TestOn('vm')
library;

import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orra_ui/orra_ui.dart';

/// 原规范硬规则 8：主进程（原生）窗口底色必须与 chrome（浅 / 深）一致，否则首帧闪色。网页端同理：首帧前的页面底色。
void main() {
  test('macOS 原生窗口底色与 RaColors 的 surfaceWindow 一致', () {
    final String swift = File('macos/Runner/MainFlutterWindow.swift').readAsStringSync();
    Color read(String name) {
      final RegExpMatch? m = RegExp('$name: UInt32 = 0x([0-9A-Fa-f]{6})').firstMatch(swift);
      expect(m, isNotNull, reason: '找不到 $name');
      return Color(0xFF000000 | int.parse(m!.group(1)!, radix: 16));
    }

    expect(read('chromeLight'), const RaColors.light().surfaceWindow);
    expect(read('chromeDark'), const RaColors.dark().surfaceWindow);
    expect(RaThemeData.light().chrome.chrome, const RaColors.light().surfaceWindow);
    expect(RaThemeData.dark().chrome.chrome, const RaColors.dark().surfaceWindow);
  });

  test('网页首帧底色（web/index.html）与 RaColors 的 surfaceWindow 一致', () {
    final String html = File('web/index.html').readAsStringSync();
    Color css(String name) {
      final RegExpMatch? m = RegExp('--$name: #([0-9A-Fa-f]{6});').firstMatch(html);
      expect(m, isNotNull, reason: '找不到 --$name');
      return Color(0xFF000000 | int.parse(m!.group(1)!, radix: 16));
    }

    Color meta(String scheme) {
      final RegExpMatch? m = RegExp(
        'name="theme-color" content="#([0-9A-Fa-f]{6})" media="\\(prefers-color-scheme: $scheme\\)"',
      ).firstMatch(html);
      expect(m, isNotNull, reason: '找不到 $scheme theme-color');
      return Color(0xFF000000 | int.parse(m!.group(1)!, radix: 16));
    }

    expect(css('ra-chrome-light'), const RaColors.light().surfaceWindow);
    expect(css('ra-chrome-dark'), const RaColors.dark().surfaceWindow);
    expect(meta('light'), const RaColors.light().surfaceWindow);
    expect(meta('dark'), const RaColors.dark().surfaceWindow);
  });
}
