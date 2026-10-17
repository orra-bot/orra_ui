import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../foundation/pressable.dart';
import '../foundation/surface.dart';
import '../icons/ra_glyph.dart';
import '../icons/ra_icon.dart';
import '../theme/theme.dart';
import '../theme/theme_data.dart';
import '../tokens/components.dart';
import 'text_field.dart';

/// 数字输入框（Base UI Number Field）：输入框右侧内嵌 − / + 按钮。
///
/// 只能输入数字、小数点与负号。↑ ↓ 加减 [step]，Shift + ↑ ↓ 加减 [largeStep]；
/// 失焦或回车时解析、夹到 [min]..[max] 并按 [decimals] 格式化回写，无法解析时恢复上一个有效值。
class RaNumberField extends StatefulWidget {
  const RaNumberField({
    super.key,
    required this.value,
    required this.onChanged,
    this.min,
    this.max,
    this.step = 1,
    this.largeStep,
    this.decimals,
    this.label,
    this.hideLabel = false,
    this.description,
    this.placeholder,
    this.error,
    this.enabled = true,
    this.focusNode,
    this.autofocus = false,
    this.incrementLabel = '+',
    this.decrementLabel = '−',
  });

  final num? value;

  /// 提交（按钮、方向键、失焦、回车）时触发；为空时只读。
  final ValueChanged<num?>? onChanged;
  final num? min;
  final num? max;
  final num step;

  /// 大步；默认 10 × [step]。
  final num? largeStep;

  /// 小数位；为空时按 [step] 推断（整数步长为 0 位）。
  final int? decimals;
  final String? label;
  final bool hideLabel;
  final String? description;
  final String? placeholder;
  final String? error;
  final bool enabled;
  final FocusNode? focusNode;
  final bool autofocus;

  /// 加减按钮的无障碍名称。
  final String incrementLabel;
  final String decrementLabel;

  @override
  State<RaNumberField> createState() => _RaNumberFieldState();
}

class _RaNumberFieldState extends State<RaNumberField> {
  late final TextEditingController _controller = TextEditingController(text: _format(widget.value));
  FocusNode? _ownFocusNode;

  FocusNode get _focusNode => widget.focusNode ?? (_ownFocusNode ??= FocusNode());

  bool get _active => widget.enabled && widget.onChanged != null;

  int get _decimals {
    if (widget.decimals != null) return widget.decimals!;
    final num step = widget.step;
    if (step is int || step == step.roundToDouble()) return 0;
    final String text = step.toString();
    final int dot = text.indexOf('.');
    return dot < 0 ? 0 : text.length - dot - 1;
  }

  String _format(num? v) {
    if (v == null) return '';
    final int d = _decimals;
    return d == 0 ? v.round().toString() : v.toStringAsFixed(d);
  }

  num _clamp(num v) {
    num result = v;
    if (widget.min != null) result = math.max(result, widget.min!);
    if (widget.max != null) result = math.min(result, widget.max!);
    final int d = _decimals;
    return d == 0 ? result.round() : double.parse(result.toStringAsFixed(d));
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocus);
  }

  @override
  void didUpdateWidget(RaNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _ownFocusNode)?.removeListener(_handleFocus);
      _focusNode.addListener(_handleFocus);
    }
    if (widget.value != oldWidget.value && !_focusNode.hasFocus) {
      _controller.text = _format(widget.value);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocus);
    _ownFocusNode?.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleFocus() {
    if (!_focusNode.hasFocus) _commitText();
  }

  /// 解析输入框文字并提交；非法时恢复上一个有效值。
  void _commitText() {
    final String text = _controller.text.trim();
    if (text.isEmpty) {
      if (widget.value != null) widget.onChanged?.call(null);
      return;
    }
    final num? parsed = num.tryParse(text);
    if (parsed == null) {
      _controller.text = _format(widget.value);
      return;
    }
    _set(_clamp(parsed));
  }

  void _set(num next) {
    final String text = _format(next);
    if (_controller.text != text) {
      _controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
    if (next != widget.value) widget.onChanged?.call(next);
  }

  /// 以当前输入（或值）为基准加减。
  void _stepBy(num delta) {
    final num base = num.tryParse(_controller.text.trim()) ?? widget.value ?? widget.min ?? 0;
    _set(_clamp(base + delta));
  }

  num get _current => num.tryParse(_controller.text.trim()) ?? widget.value ?? 0;

  bool get _canDecrement => _active && (widget.min == null || _current > widget.min!);
  bool get _canIncrement => _active && (widget.max == null || _current < widget.max!);

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (!_active || (event is! KeyDownEvent && event is! KeyRepeatEvent)) {
      return KeyEventResult.ignored;
    }
    final num step = HardwareKeyboard.instance.isShiftPressed
        ? (widget.largeStep ?? widget.step * 10)
        : widget.step;
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _stepBy(step);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _stepBy(-step);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final RaThemeData theme = RaTheme.of(context);
    final bool allowNegative = widget.min == null || widget.min! < 0;
    final bool allowDecimal = _decimals > 0;
    final RegExp allowed = RegExp(
      allowDecimal
          ? (allowNegative ? r'[0-9.\-]' : r'[0-9.]')
          : (allowNegative ? r'[0-9\-]' : r'[0-9]'),
    );
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: _handleKey,
      child: ListenableBuilder(
        listenable: _controller,
        builder: (BuildContext context, Widget? child) => RaTextField(
          label: widget.label,
          hideLabel: widget.hideLabel,
          controller: _controller,
          focusNode: _focusNode,
          autofocus: widget.autofocus,
          placeholder: widget.placeholder,
          description: widget.description,
          error: widget.error,
          enabled: widget.enabled,
          readOnly: widget.onChanged == null,
          keyboardType: TextInputType.numberWithOptions(
            signed: allowNegative,
            decimal: allowDecimal,
          ),
          inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(allowed)],
          onSubmitted: (_) => _commitText(),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: theme.numberField.buttonGap,
            children: <Widget>[
              _StepButton(
                glyphLabel: widget.decrementLabel,
                icon: theme.icons.minus,
                onPressed: _canDecrement ? () => _stepBy(-widget.step) : null,
              ),
              _StepButton(
                glyphLabel: widget.incrementLabel,
                icon: theme.icons.plus,
                onPressed: _canIncrement ? () => _stepBy(widget.step) : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// − / + 小按钮：不抢输入框焦点。
class _StepButton extends StatelessWidget {
  const _StepButton({required this.glyphLabel, required this.icon, required this.onPressed});

  final String glyphLabel;
  final RaGlyph icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final RaNumberFieldThemeData s = RaTheme.of(context).numberField;
    return SizedBox.square(dimension: s.buttonSize, child: _button(s));
  }

  Widget _button(RaNumberFieldThemeData s) {
    return RaPressable(
      onPressed: onPressed,
      canRequestFocus: false,
      semanticLabel: glyphLabel,
      excludeSemantics: true,
      builder: (BuildContext context, RaPressState state) => RaAnimatedSurface(
        duration: state.transition,
        backgroundColor: state.hovered && !state.disabled ? s.buttonHoverBackground : null,
        foregroundColor: state.disabled
            ? s.buttonDisabledColor
            : state.hovered
            ? s.buttonHoverColor
            : s.buttonColor,
        radius: s.buttonRadius,
        constraints: BoxConstraints.tightFor(width: s.buttonSize, height: s.buttonSize),
        alignment: Alignment.center,
        child: Builder(
          builder: (BuildContext context) =>
              RaIcon.glyph(icon, size: s.iconSize, color: IconTheme.of(context).color),
        ),
      ),
    );
  }
}
