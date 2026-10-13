import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:orra_guardrails/orra_guardrails.dart';

void main() {
  test('orra_desktop_shell 源码遵守三层设计变量与禁用规则', () {
    final List<GuardrailViolation> violations = runGuardrails(
      GuardrailConfig(
        root: Directory.current.path,
        checkUnusedPrimitives: false,
        targets: const <GuardrailTarget>[
          GuardrailTarget(GuardrailLayer.componentTokens, <String>['lib/src/shell_theme.dart']),
          // 窗口初始化与状态存储不渲染界面：默认窗口尺寸、写入防抖、按系统深浅选择启动底色属于平台配置。
          GuardrailTarget(GuardrailLayer.exempt, <String>[
            'lib/src/desktop_window.dart',
            'lib/src/window_state.dart',
          ]),
          GuardrailTarget(GuardrailLayer.component, <String>['lib']),
        ],
      ),
    );
    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}
