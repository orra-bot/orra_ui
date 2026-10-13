import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:orra_guardrails/orra_guardrails.dart';

/// 设计变量三层约束 + 禁用规则（见 orra_guardrails）。
void main() {
  test('orra_ui 源码遵守三层设计变量与禁用规则', () {
    final List<GuardrailViolation> violations = runGuardrails(
      GuardrailConfig(
        root: Directory.current.path,
        bannedImports: <String>[
          ...GuardrailConfig.defaultBannedImports,
          // 组件库是纯展示层：不依赖平台 IO 与窗口插件。
          'dart:io',
          'package:window_manager',
          'package:orra_desktop_shell',
        ],
        targets: const <GuardrailTarget>[
          GuardrailTarget(GuardrailLayer.primitive, <String>['lib/src/tokens/primitives.dart']),
          GuardrailTarget(GuardrailLayer.semantic, <String>[
            'lib/src/tokens/colors.dart',
            'lib/src/tokens/semantic.dart',
            // 主题装配与 RaApp 负责按明暗选择语义层。
            'lib/src/theme',
            'lib/src/foundation/app.dart',
          ]),
          GuardrailTarget(GuardrailLayer.componentTokens, <String>[
            'lib/src/tokens/components.dart',
          ]),
          GuardrailTarget(GuardrailLayer.exempt, <String>['lib/src/icons/ra_glyph.dart']),
          GuardrailTarget(GuardrailLayer.component, <String>[
            'lib/src/components',
            'lib/src/foundation',
            'lib/src/icons',
          ]),
        ],
        extraPrimitiveUsageRoots: <String>['../orra_desktop_shell/lib', '../../example/lib'],
      ),
    );
    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}
