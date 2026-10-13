import 'package:orra_guardrails/orra_guardrails.dart';
import 'package:test/test.dart';

List<String> rules(String source, GuardrailLayer layer) =>
    checkSource(source, layer: layer).map((GuardrailViolation v) => v.rule).toList();

void main() {
  group('导入', () {
    test('任何非基础层都不得导入 Material / Cupertino', () {
      expect(rules("import 'package:flutter/material.dart';", GuardrailLayer.component), <String>[
        'banned-import',
      ]);
      expect(rules("import 'package:flutter/cupertino.dart';", GuardrailLayer.app), <String>[
        'banned-import',
      ]);
      expect(rules("import 'package:flutter/widgets.dart';", GuardrailLayer.app), isEmpty);
    });
  });

  group('颜色字面量', () {
    test('组件代码与应用层不得写颜色，全透明除外', () {
      expect(rules('final c = Color(0xFF6D78D5);', GuardrailLayer.component), <String>[
        'color-literal',
      ]);
      expect(rules('const c = Color(0xFF6D78D5);', GuardrailLayer.app), <String>['color-literal']);
      expect(rules('const c = Color(0x00000000);', GuardrailLayer.component), isEmpty);
      expect(rules('final c = Colors.red;', GuardrailLayer.app), <String>['color-literal']);
    });
    test('组件层也不得写颜色', () {
      expect(rules('final c = Color(0xFF000000);', GuardrailLayer.componentTokens), <String>[
        'color-literal',
      ]);
    });
    test('基础层可以写颜色', () {
      expect(rules('const c = Color(0xFF6D78D5);', GuardrailLayer.primitive), isEmpty);
    });
  });

  group('尺寸 / 时长 / 字重', () {
    test('组件代码不得写尺寸、字号、圆角、时长数字', () {
      expect(rules('final e = EdgeInsets.all(8);', GuardrailLayer.component), <String>[
        'design-literal',
      ]);
      expect(rules('final e = EdgeInsets.zero;', GuardrailLayer.component), isEmpty);
      expect(rules('final e = EdgeInsets.all(0);', GuardrailLayer.component), isEmpty);
      expect(
        rules('final b = SizedBox(width: 12);', GuardrailLayer.component),
        contains('design-literal'),
      );
      expect(
        rules('final s = TextStyle(fontSize: 13);', GuardrailLayer.component),
        contains('design-literal'),
      );
      expect(
        rules('final d = Duration(milliseconds: 150);', GuardrailLayer.component),
        contains('design-literal'),
      );
      expect(rules('final w = FontWeight(450);', GuardrailLayer.component), <String>[
        'design-literal',
      ]);
      expect(rules('final c = Cubic(0.2, 1, 0.3, 1);', GuardrailLayer.component), <String>[
        'design-literal',
      ]);
      expect(rules('final i = RaIcon(x, size: 14);', GuardrailLayer.app), <String>[
        'design-literal',
      ]);
    });
    test('应用层的时长属于业务逻辑，不检查', () {
      expect(rules('final d = Duration(seconds: 2);', GuardrailLayer.app), isEmpty);
      expect(rules('final d = Duration(milliseconds: 150);', GuardrailLayer.component), isNotEmpty);
    });
    test('组件层可以写布局几何，但不写时长', () {
      expect(rules('final e = EdgeInsets.all(14);', GuardrailLayer.componentTokens), isEmpty);
      expect(
        rules('const d = Duration(milliseconds: 150);', GuardrailLayer.componentTokens),
        <String>['design-literal'],
      );
    });
    test('语义层只允许 0 / 1', () {
      expect(rules('const x = RaSizes.s8;', GuardrailLayer.semantic), isEmpty);
      expect(rules('const x = 8;', GuardrailLayer.semantic), <String>['semantic-literal']);
      expect(rules('const x = 0;', GuardrailLayer.semantic), isEmpty);
    });
  });

  group('引用基础层 / 明暗', () {
    test('组件代码不得直接引用基础层', () {
      expect(rules('final c = RaPalette.white;', GuardrailLayer.component), <String>[
        'primitive-in-component',
      ]);
      expect(
        rules('final s = RaShadowMath.css(0, 1, 1, 0, x);', GuardrailLayer.component),
        <String>['primitive-in-component'],
      );
      expect(rules('final c = RaPalette.white;', GuardrailLayer.semantic), isEmpty);
      expect(rules('final c = RaPalette.white;', GuardrailLayer.componentTokens), isEmpty);
    });
    test('组件代码不感知明暗', () {
      expect(rules('final dark = b == Brightness.dark;', GuardrailLayer.component), <String>[
        'brightness-in-component',
      ]);
    });
  });

  group('应用层禁用底层组件', () {
    test('EditableText / RawMenuAnchor / showGeneralDialog', () {
      expect(
        rules('Widget f() => EditableText(controller: c);', GuardrailLayer.app),
        contains('raw-widget'),
      );
      expect(
        rules('final m = RawMenuAnchor(controller: c);', GuardrailLayer.app),
        contains('raw-widget'),
      );
      expect(
        rules('void f() { showGeneralDialog(context: c); }', GuardrailLayer.app),
        contains('raw-widget'),
      );
      expect(
        rules('Widget f() => EditableText(controller: c);', GuardrailLayer.component),
        isEmpty,
      );
    });
  });
}
