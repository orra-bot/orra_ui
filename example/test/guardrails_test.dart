@TestOn('vm')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:orra_guardrails/orra_guardrails.dart';

/// 应用侧同样遵守三层变量与禁用规则：
/// 品牌色板（基础层）→ 品牌主题（语义层）→ 布局变量（组件层）→ 页面（应用层，只用 orra_ui 组件）。
void main() {
  test('示例应用遵守三层设计变量与禁用规则', () {
    final List<GuardrailViolation> violations = runGuardrails(
      GuardrailConfig(
        root: Directory.current.path,
        primitiveClasses: <String>{...GuardrailConfig.defaultPrimitiveClasses, 'BrandPalette'},
        targets: const <GuardrailTarget>[
          GuardrailTarget(GuardrailLayer.primitive, <String>['lib/brand_palette.dart']),
          GuardrailTarget(GuardrailLayer.semantic, <String>['lib/brand_themes.dart']),
          GuardrailTarget(GuardrailLayer.componentTokens, <String>['lib/gallery_layout.dart']),
          GuardrailTarget(GuardrailLayer.app, <String>['lib']),
        ],
      ),
    );
    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}
