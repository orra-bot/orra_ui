/// orra_ui 的守护规则：在单元测试中静态检查源码（基于 analyzer 的语法树，不需要类型解析）。
///
/// 对应原规范的两部分：
/// 1. 设计变量三层约束（基础层只写字面量 → 语义层只引用基础层 → 组件层不写颜色 / 时长 / 字重；
///    组件代码不写设计字面量、不直接引用基础层、不感知明暗）；
/// 2. 禁用「原生控件」：应用层不得引入 Material / Cupertino，不得直接使用未封装的底层组件
///    （EditableText、RawMenuAnchor、RawTooltip、showGeneralDialog……），统一走 orra_ui 组件。
library;

import 'dart:io';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:path/path.dart' as p;

/// 文件所属的层。
enum GuardrailLayer {
  /// 基础层：唯一允许字面量的地方。
  primitive,

  /// 语义层：只引用基础层；数字只允许 0 / 1。
  semantic,

  /// 组件层（组件变量）：可写布局几何，不写颜色、时长、缓动、字重。
  componentTokens,

  /// 组件代码：不写任何设计字面量，不直接引用基础层，不感知明暗。
  component,

  /// 应用层：只用组件库；不引入 Material / Cupertino，不写颜色。
  app,

  /// 不检查（例如图标几何数据）。
  exempt,
}

/// 一条违规。
class GuardrailViolation {
  GuardrailViolation(this.file, this.line, this.rule, this.message);

  final String file;
  final int line;
  final String rule;
  final String message;

  @override
  String toString() => '$file:$line [$rule] $message';
}

/// 一组检查目标。
class GuardrailTarget {
  const GuardrailTarget(this.layer, this.paths, {this.exclude = const <String>[]});

  final GuardrailLayer layer;

  /// 文件或目录（目录递归包含所有 .dart 文件），相对于 [GuardrailConfig.root]。
  final List<String> paths;

  /// 排除的文件或目录（同样相对于根目录）。
  final List<String> exclude;
}

/// 守护规则配置。
class GuardrailConfig {
  const GuardrailConfig({
    required this.root,
    required this.targets,
    this.primitiveClasses = defaultPrimitiveClasses,
    this.bannedImports = defaultBannedImports,
    this.appBannedIdentifiers = defaultAppBannedIdentifiers,
    this.checkUnusedPrimitives = true,
    this.extraPrimitiveUsageRoots = const <String>[],
  });

  /// 包根目录（绝对路径）。
  final String root;
  final List<GuardrailTarget> targets;

  /// 基础层的类名（组件代码不得直接引用）。
  final Set<String> primitiveClasses;

  /// 所有非基础层文件禁止的导入（前缀匹配）。
  final List<String> bannedImports;

  /// 应用层禁止直接使用的底层组件 / 函数。
  final Set<String> appBannedIdentifiers;

  /// 检查基础层是否有闲置值。
  final bool checkUnusedPrimitives;

  /// 统计基础层引用时额外扫描的目录（例如其他包对基础层的使用）。
  final List<String> extraPrimitiveUsageRoots;

  static const Set<String> defaultPrimitiveClasses = <String>{
    'RaPalette',
    'RaSizes',
    'RaFontScale',
    'RaDurations',
    'RaCurves',
    'RaNumbers',
    'RaShadowMath',
  };

  static const List<String> defaultBannedImports = <String>[
    'package:flutter/material.dart',
    'package:flutter/cupertino.dart',
  ];

  /// 对应原规范禁止的原生元素：统一走 orra_ui 封装。
  static const Set<String> defaultAppBannedIdentifiers = <String>{
    'EditableText',
    'RawMenuAnchor',
    'RawTooltip',
    'RawScrollbar',
    'RawAutocomplete',
    'RawRadio',
    'RawDialogRoute',
    'showGeneralDialog',
    'showRawDialog',
  };
}

/// 运行全部检查。
List<GuardrailViolation> runGuardrails(GuardrailConfig config) {
  final List<GuardrailViolation> violations = <GuardrailViolation>[];
  final Map<String, GuardrailLayer> files = _collectFiles(config);
  final Map<String, Set<String>> declaredPrimitives = <String, Set<String>>{};
  final Set<String> usedPrimitives = <String>{};

  for (final MapEntry<String, GuardrailLayer> entry in files.entries) {
    if (entry.value == GuardrailLayer.exempt) {
      _collectPrimitiveUsage(entry.key, config, usedPrimitives);
      continue;
    }
    final String content = File(entry.key).readAsStringSync();
    violations.addAll(
      checkSource(
        content,
        layer: entry.value,
        path: p.relative(entry.key, from: config.root),
        config: config,
        declaredPrimitives: declaredPrimitives,
        usedPrimitives: usedPrimitives,
      ),
    );
  }

  for (final String extra in config.extraPrimitiveUsageRoots) {
    final Directory dir = Directory(p.join(config.root, extra));
    if (!dir.existsSync()) continue;
    for (final File f in dir.listSync(recursive: true).whereType<File>()) {
      if (f.path.endsWith('.dart')) _collectPrimitiveUsage(f.path, config, usedPrimitives);
    }
  }

  if (config.checkUnusedPrimitives) {
    for (final MapEntry<String, Set<String>> entry in declaredPrimitives.entries) {
      for (final String member in entry.value) {
        if (!usedPrimitives.contains(member)) {
          violations.add(
            GuardrailViolation(entry.key, 0, 'unused-primitive', '基础层值 $member 未被任何地方引用，应删除'),
          );
        }
      }
    }
  }
  return violations;
}

Map<String, GuardrailLayer> _collectFiles(GuardrailConfig config) {
  final Map<String, GuardrailLayer> result = <String, GuardrailLayer>{};
  for (final GuardrailTarget target in config.targets) {
    final Set<String> excluded = target.exclude
        .map((String e) => p.normalize(p.join(config.root, e)))
        .toSet();
    bool isExcluded(String path) => excluded.any((String e) => path == e || p.isWithin(e, path));
    for (final String rel in target.paths) {
      final String abs = p.normalize(p.join(config.root, rel));
      if (FileSystemEntity.isDirectorySync(abs)) {
        for (final File f in Directory(abs).listSync(recursive: true).whereType<File>()) {
          if (f.path.endsWith('.dart') && !isExcluded(f.path)) {
            result.putIfAbsent(p.normalize(f.path), () => target.layer);
          }
        }
      } else if (File(abs).existsSync() && !isExcluded(abs)) {
        result.putIfAbsent(abs, () => target.layer);
      }
    }
  }
  return result;
}

void _collectPrimitiveUsage(String path, GuardrailConfig config, Set<String> used) {
  final ParseStringResult parsed = parseString(
    content: File(path).readAsStringSync(),
    path: path,
    throwIfDiagnostics: false,
  );
  parsed.unit.accept(_PrimitiveUsageVisitor(config.primitiveClasses, used));
}

/// 检查一段源码（测试中也可直接用来验证规则本身）。
List<GuardrailViolation> checkSource(
  String content, {
  required GuardrailLayer layer,
  String path = '<source>',
  GuardrailConfig config = const GuardrailConfig(root: '', targets: <GuardrailTarget>[]),
  Map<String, Set<String>>? declaredPrimitives,
  Set<String>? usedPrimitives,
}) {
  final ParseStringResult parsed = parseString(
    content: content,
    path: path,
    throwIfDiagnostics: false,
  );
  final _GuardrailVisitor visitor = _GuardrailVisitor(
    layer: layer,
    path: path,
    unit: parsed,
    config: config,
  );
  parsed.unit.accept(visitor);
  if (layer == GuardrailLayer.primitive && declaredPrimitives != null) {
    declaredPrimitives[path] = visitor.declaredPrimitives;
  }
  usedPrimitives?.addAll(visitor.usedPrimitives);
  return visitor.violations;
}

class _PrimitiveUsageVisitor extends RecursiveAstVisitor<void> {
  _PrimitiveUsageVisitor(this.classes, this.used);

  final Set<String> classes;
  final Set<String> used;

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    if (classes.contains(node.prefix.name)) used.add('${node.prefix.name}.${node.identifier.name}');
    super.visitPrefixedIdentifier(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final Expression? target = node.target;
    if (target is SimpleIdentifier && classes.contains(target.name)) {
      used.add('${target.name}.${node.methodName.name}');
    }
    super.visitMethodInvocation(node);
  }
}

/// 构造或调用时会产生「设计值」的类型：参数里不能出现非 0 数字。
const Set<String> _lengthTypes = <String>{
  'EdgeInsets',
  'EdgeInsetsDirectional',
  'BorderRadius',
  'BorderRadiusDirectional',
  'Radius',
  'SizedBox',
  'BoxConstraints',
  'Size',
  'BorderSide',
  'Border',
  'BoxShadow',
  'Positioned',
  'PositionedDirectional',
  'Padding',
  'Container',
  'TextStyle',
  'StrutStyle',
  'Duration',
  'Gap',
};

/// 带设计含义的命名参数：数字只允许 0。
const Set<String> _designNamedArgs = <String>{
  'width',
  'height',
  'size',
  'dimension',
  'radius',
  'fontSize',
  'letterSpacing',
  'wordSpacing',
  'blurRadius',
  'spreadRadius',
  'spacing',
  'runSpacing',
  'gap',
  'thickness',
  'elevation',
  'strokeWidth',
  'minWidth',
  'maxWidth',
  'minHeight',
  'maxHeight',
  'milliseconds',
  'microseconds',
  'seconds',
};

class _GuardrailVisitor extends RecursiveAstVisitor<void> {
  _GuardrailVisitor({
    required this.layer,
    required this.path,
    required this.unit,
    required this.config,
  });

  final GuardrailLayer layer;
  final String path;
  final ParseStringResult unit;
  final GuardrailConfig config;
  final List<GuardrailViolation> violations = <GuardrailViolation>[];
  final Set<String> declaredPrimitives = <String>{};
  final Set<String> usedPrimitives = <String>{};

  String? _currentClass;

  int _line(AstNode node) => unit.lineInfo.getLocation(node.offset).lineNumber;

  void _report(AstNode node, String rule, String message) {
    violations.add(GuardrailViolation(path, _line(node), rule, message));
  }

  bool get _isPrimitive => layer == GuardrailLayer.primitive;
  bool get _isComponentCode => layer == GuardrailLayer.component || layer == GuardrailLayer.app;

  // ---------- 导入 ----------

  @override
  void visitImportDirective(ImportDirective node) {
    final String? uri = node.uri.stringValue;
    if (uri != null) {
      for (final String banned in config.bannedImports) {
        if (uri.startsWith(banned)) {
          _report(node, 'banned-import', '不得导入 $uri：组件库只依赖 widgets 层，界面统一用 orra_ui 组件');
        }
      }
    }
    super.visitImportDirective(node);
  }

  // ---------- 基础层登记 ----------

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final String? previous = _currentClass;
    _currentClass = node.namePart.typeName.lexeme;
    super.visitClassDeclaration(node);
    _currentClass = previous;
  }

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    if (_isPrimitive &&
        node.isStatic &&
        _currentClass != null &&
        config.primitiveClasses.contains(_currentClass)) {
      for (final VariableDeclaration v in node.fields.variables) {
        declaredPrimitives.add('$_currentClass.${v.name.lexeme}');
      }
    }
    super.visitFieldDeclaration(node);
  }

  // ---------- 引用基础层 ----------

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    final String prefix = node.prefix.name;
    if (config.primitiveClasses.contains(prefix)) {
      usedPrimitives.add('$prefix.${node.identifier.name}');
      if (_isComponentCode) {
        _report(node, 'primitive-in-component', '组件代码不得直接引用基础层 ${node.toSource()}，请经语义层或组件层');
      }
    }
    if (_isComponentCode && prefix == 'Brightness') {
      _report(node, 'brightness-in-component', '组件代码不感知明暗（${node.toSource()}），深色只在语义层赋值');
    }
    if (layer == GuardrailLayer.app && prefix == 'Colors') {
      _report(node, 'color-literal', '应用层不得写颜色（${node.toSource()}）');
    }
    super.visitPrefixedIdentifier(node);
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (layer == GuardrailLayer.app && config.appBannedIdentifiers.contains(node.name)) {
      final AstNode? parent = node.parent;
      final bool isDeclaration = parent is Declaration;
      if (!isDeclaration) {
        _report(node, 'raw-widget', '应用层不得直接使用 ${node.name}，请用 orra_ui 封装的组件');
      }
    }
    super.visitSimpleIdentifier(node);
  }

  @override
  void visitNamedType(NamedType node) {
    if (layer == GuardrailLayer.app && config.appBannedIdentifiers.contains(node.name.lexeme)) {
      _report(node, 'raw-widget', '应用层不得直接使用 ${node.name.lexeme}，请用 orra_ui 封装的组件');
    }
    super.visitNamedType(node);
  }

  // ---------- 构造 / 调用 ----------

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final String type = node.constructorName.type.name.lexeme;
    _checkCreation(node, type, node.argumentList);
    super.visitInstanceCreationExpression(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final Expression? target = node.target;
    if (target is SimpleIdentifier) {
      if (config.primitiveClasses.contains(target.name)) {
        usedPrimitives.add('${target.name}.${node.methodName.name}');
        if (_isComponentCode) {
          _report(
            node,
            'primitive-in-component',
            '组件代码不得直接引用基础层 ${target.name}.${node.methodName.name}',
          );
        }
      }
      // 未解析的 `EdgeInsets.all(8)` 是方法调用形式。
      _checkCreation(node, target.name, node.argumentList);
    } else if (target == null) {
      // 未解析的 `Color(0xFF…)` / `Duration(…)` 是无目标的方法调用形式。
      final String name = node.methodName.name;
      if (name.isNotEmpty && name[0].toUpperCase() == name[0] && name[0] != '_') {
        _checkCreation(node, name, node.argumentList);
      }
    }
    super.visitMethodInvocation(node);
  }

  void _checkCreation(AstNode node, String type, ArgumentList args) {
    if (_isPrimitive || layer == GuardrailLayer.exempt) return;

    if (type == 'Color') {
      if (_hasNonTrivialNumber(args, allowOne: false) && !_isTransparentColor(args)) {
        _report(node, 'color-literal', '只有基础层可以写颜色字面量：${node.toSource()}');
      }
      return;
    }
    if (type == 'Cubic' || type == 'FontWeight' || type == 'FontVariation') {
      if (_hasNonTrivialNumber(args, allowOne: false)) {
        _report(node, 'design-literal', '只有基础层可以写缓动 / 字重字面量：${node.toSource()}');
      }
      return;
    }
    if (type == 'Duration') {
      // 应用层的时长多是业务逻辑（超时、模拟延迟），不属于设计变量。
      if (layer != GuardrailLayer.app && _hasNonTrivialNumber(args, allowOne: false)) {
        _report(node, 'design-literal', '只有基础层可以写时长字面量：${node.toSource()}');
      }
      return;
    }
    // 组件层可以写布局几何；语义层与组件代码不行。
    if (layer == GuardrailLayer.componentTokens) return;
    if (_lengthTypes.contains(type) && _hasNonTrivialNumber(args, allowOne: false)) {
      _report(node, 'design-literal', '尺寸 / 字号 / 圆角请引用主题变量：${node.toSource()}');
    }
  }

  @override
  void visitNamedArgument(NamedArgument node) {
    if (!_isPrimitive &&
        layer != GuardrailLayer.exempt &&
        layer != GuardrailLayer.componentTokens) {
      final String name = node.name.lexeme;
      final bool timing = name == 'milliseconds' || name == 'microseconds' || name == 'seconds';
      if (timing && layer == GuardrailLayer.app) {
        super.visitNamedArgument(node);
        return;
      }
      if (_designNamedArgs.contains(name) && _isNonZeroNumber(node.argumentExpression)) {
        _report(node, 'design-literal', '$name 请引用主题变量，不要写数字：${node.toSource()}');
      }
    }
    super.visitNamedArgument(node);
  }

  @override
  void visitIntegerLiteral(IntegerLiteral node) {
    _checkSemanticNumber(node, node.value?.toDouble());
    super.visitIntegerLiteral(node);
  }

  @override
  void visitDoubleLiteral(DoubleLiteral node) {
    _checkSemanticNumber(node, node.value);
    super.visitDoubleLiteral(node);
  }

  void _checkSemanticNumber(AstNode node, double? value) {
    if (layer != GuardrailLayer.semantic || value == null) return;
    if (value == 0 || value == 1) return;
    _report(node, 'semantic-literal', '语义层只引用基础层，不写数字：${node.toSource()}');
  }

  bool _isTransparentColor(ArgumentList args) {
    if (args.arguments.length != 1) return false;
    final Expression e = args.arguments.first.argumentExpression;
    return e is IntegerLiteral && (e.value ?? -1) == 0;
  }

  bool _isNonZeroNumber(Expression e) {
    Expression inner = e;
    if (inner is PrefixExpression && inner.operator.lexeme == '-') inner = inner.operand;
    if (inner is IntegerLiteral) return (inner.value ?? 0) != 0;
    if (inner is DoubleLiteral) return inner.value != 0;
    return false;
  }

  bool _hasNonTrivialNumber(ArgumentList args, {required bool allowOne}) {
    for (final Argument arg in args.arguments) {
      Expression inner = arg.argumentExpression;
      if (inner is PrefixExpression && inner.operator.lexeme == '-') inner = inner.operand;
      double? v;
      if (inner is IntegerLiteral) v = inner.value?.toDouble();
      if (inner is DoubleLiteral) v = inner.value;
      if (v == null) continue;
      if (v == 0) continue;
      if (allowOne && v == 1) continue;
      return true;
    }
    return false;
  }
}
