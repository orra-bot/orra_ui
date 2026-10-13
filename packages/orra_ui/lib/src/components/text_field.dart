import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../foundation/localizations.dart';
import '../foundation/motion.dart';
import '../foundation/pressable.dart';
import '../foundation/surface.dart';
import '../icons/ra_icon.dart';
import '../theme/theme.dart';
import '../theme/theme_data.dart';
import '../tokens/components.dart';
import 'menu.dart';

/// 校验函数：返回错误文案，或 null 表示通过。
typedef RaValidator = String? Function(String value);

/// 文本输入框：标签 + 输入框 + 说明 + 错误。
///
/// 聚焦以边框变为强调色表示（无焦点环）；悬停边框加深；错误时边框为危险色。
/// [validator] 在失焦后、或 [RaForm.validate] 时首次执行，之后随输入实时更新。
class RaTextField extends StatefulWidget {
  const RaTextField({
    super.key,
    this.label,
    this.hideLabel = false,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.placeholder,
    this.description,
    this.error,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.multiline = false,
    this.minLines = 3,
    this.maxLines,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLength,
    this.search = false,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.autofillHints,
  });

  /// 标签文字；同时作为无障碍名称。
  final String? label;

  /// 视觉上隐藏标签（仍对读屏可见）。
  final bool hideLabel;
  final TextEditingController? controller;
  final String? initialValue;
  final FocusNode? focusNode;
  final String? placeholder;
  final String? description;

  /// 外部错误（如服务端返回）：强制显示为无效。
  final String? error;
  final RaValidator? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onEditingComplete;

  /// 多行输入（默认 [minLines] 行，超过 [maxLines] 后滚动）。
  final bool multiline;
  final int minLines;
  final int? maxLines;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final int? maxLength;

  /// 搜索样式：左侧放大镜。
  final bool search;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;

  @override
  State<RaTextField> createState() => RaTextFieldState();
}

class RaTextFieldState extends State<RaTextField>
    implements TextSelectionGestureDetectorBuilderDelegate {
  final GlobalKey<EditableTextState> _editableKey = GlobalKey<EditableTextState>();
  late final TextSelectionGestureDetectorBuilder _gestures = TextSelectionGestureDetectorBuilder(
    delegate: this,
  );

  TextEditingController? _ownController;
  FocusNode? _ownFocusNode;
  _RaFormState? _form;

  bool _hovered = false;
  bool _touched = false;
  String? _validationError;

  TextEditingController get controller =>
      widget.controller ?? (_ownController ??= TextEditingController(text: widget.initialValue));
  FocusNode get _focusNode => widget.focusNode ?? (_ownFocusNode ??= FocusNode());

  /// 当前显示的错误（外部错误优先）。
  String? get errorText => widget.error ?? _validationError;

  @override
  GlobalKey<EditableTextState> get editableTextKey => _editableKey;

  @override
  bool get forcePressEnabled => false;

  @override
  bool get selectionEnabled => true;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final _RaFormState? form = _RaFormScope.maybeOf(context);
    if (form != _form) {
      _form?._unregister(this);
      _form = form;
      _form?._register(this);
    }
  }

  @override
  void didUpdateWidget(RaTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _ownFocusNode)?.removeListener(_handleFocusChanged);
      _focusNode.addListener(_handleFocusChanged);
    }
  }

  @override
  void dispose() {
    _form?._unregister(this);
    _focusNode.removeListener(_handleFocusChanged);
    _ownController?.dispose();
    _ownFocusNode?.dispose();
    super.dispose();
  }

  void _handleFocusChanged() {
    if (!_focusNode.hasFocus && !_touched) {
      _touched = true;
      _runValidator();
    }
    setState(() {});
  }

  void _runValidator() {
    final RaValidator? validator = widget.validator;
    _validationError = validator?.call(controller.text);
  }

  /// 立即校验并显示结果；返回是否通过（外部错误也算不通过）。
  bool validate() {
    setState(() {
      _touched = true;
      _runValidator();
    });
    return errorText == null;
  }

  void _handleChanged(String value) {
    if (_touched) setState(_runValidator);
    widget.onChanged?.call(value);
  }

  Widget _buildContextMenu(BuildContext context, EditableTextState editable) {
    final RaLocalizations l10n = RaLocalizations.of(context);
    String? labelFor(ContextMenuButtonItem item) => switch (item.type) {
      ContextMenuButtonType.cut => l10n.cut,
      ContextMenuButtonType.copy => l10n.copy,
      ContextMenuButtonType.paste => l10n.paste,
      ContextMenuButtonType.selectAll => l10n.selectAll,
      _ => item.label,
    };
    final List<Widget> items = <Widget>[
      for (final ContextMenuButtonItem item in editable.contextMenuButtonItems)
        if (labelFor(item) != null)
          RaMenuItem(
            closeOnActivate: false,
            onPressed: item.onPressed,
            child: Text(labelFor(item)!),
          ),
    ];
    if (items.isEmpty) return const SizedBox.shrink();
    return CustomSingleChildLayout(
      delegate: DesktopTextSelectionToolbarLayoutDelegate(
        anchor: editable.contextMenuAnchors.primaryAnchor,
      ),
      child: TextFieldTapRegion(child: RaMenuSurface(children: items)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final RaThemeData theme = RaTheme.of(context);
    final RaFieldThemeData f = theme.field;
    final bool enabled = widget.enabled;
    final String? error = errorText;
    final Set<WidgetState> states = <WidgetState>{
      if (_hovered) WidgetState.hovered,
      if (_focusNode.hasFocus) WidgetState.focused,
      if (error != null) WidgetState.error,
      if (!enabled) WidgetState.disabled,
    };
    final Color foreground = f.foregroundColor.resolve(states) ?? theme.colors.ink;
    final TextStyle textStyle = f.textStyle.copyWith(color: foreground);
    final bool multiline = widget.multiline;

    Widget editable = EditableText(
      key: _editableKey,
      controller: controller,
      focusNode: _focusNode,
      readOnly: widget.readOnly || !enabled,
      obscureText: widget.obscureText,
      autofocus: widget.autofocus,
      style: textStyle,
      strutStyle: StrutStyle.fromTextStyle(textStyle, forceStrutHeight: true),
      cursorColor: f.cursorColor,
      cursorWidth: f.cursorWidth,
      cursorOpacityAnimates: !RaReducedMotion.of(context),
      backgroundCursorColor: f.placeholderColor,
      selectionColor: _focusNode.hasFocus ? f.selectionColor : null,
      maxLines: multiline ? widget.maxLines : 1,
      minLines: multiline ? widget.minLines : null,
      keyboardType:
          widget.keyboardType ?? (multiline ? TextInputType.multiline : TextInputType.text),
      textInputAction: widget.textInputAction,
      inputFormatters: <TextInputFormatter>[
        ...?widget.inputFormatters,
        if (widget.maxLength != null) LengthLimitingTextInputFormatter(widget.maxLength),
      ],
      autofillHints: widget.autofillHints,
      onChanged: _handleChanged,
      onSubmitted: widget.onSubmitted,
      onEditingComplete: widget.onEditingComplete,
      rendererIgnoresPointer: true,
      enableInteractiveSelection: true,
      contextMenuBuilder: enabled ? _buildContextMenu : null,
      mouseCursor: enabled ? SystemMouseCursors.text : SystemMouseCursors.forbidden,
    );

    if (widget.placeholder != null) {
      editable = Stack(
        children: <Widget>[
          Positioned.fill(
            child: IgnorePointer(
              child: ListenableBuilder(
                listenable: controller,
                builder: (BuildContext context, _) => controller.text.isEmpty
                    ? Text(
                        widget.placeholder!,
                        style: f.textStyle.copyWith(color: f.placeholderColor),
                        maxLines: multiline ? null : 1,
                        overflow: multiline ? null : TextOverflow.ellipsis,
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
          editable,
        ],
      );
    }

    final EdgeInsets padding = multiline ? f.multilinePadding : f.padding;
    final EdgeInsets resolvedPadding = widget.search
        ? padding.copyWith(left: f.searchPaddingLeft)
        : padding;

    Widget control = RaAnimatedSurface(
      duration: RaReducedMotion.resolve(context, theme.motion.fast),
      backgroundColor: f.backgroundColor.resolve(states),
      borderColor: f.borderColor.resolve(states),
      borderWidth: theme.sizing.borderWidth,
      radius: f.radius,
      shadows: f.shadows,
      constraints: multiline
          ? const BoxConstraints()
          : BoxConstraints(minHeight: f.height, maxHeight: f.height),
      child: Padding(
        padding: resolvedPadding,
        child: Align(
          alignment: multiline ? Alignment.topLeft : Alignment.centerLeft,
          heightFactor: multiline ? 1 : null,
          child: _gestures.buildGestureDetector(
            behavior: HitTestBehavior.translucent,
            child: editable,
          ),
        ),
      ),
    );

    if (widget.search) {
      control = Stack(
        alignment: Alignment.centerLeft,
        children: <Widget>[
          control,
          Positioned(
            left: f.searchIconInset,
            child: IgnorePointer(
              child: RaIcon.glyph(
                theme.icons.search,
                size: f.searchIconSize,
                color: f.searchIconColor,
              ),
            ),
          ),
        ],
      );
    }

    control = MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: enabled ? SystemMouseCursors.text : SystemMouseCursors.forbidden,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: enabled ? (_) => _focusNode.requestFocus() : null,
        child: control,
      ),
    );

    final String? label = widget.label;
    final String? description = widget.description;
    return RaNoDragRegion(
      child: Semantics(
        container: true,
        label: label,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: f.gap,
          children: <Widget>[
            if (label != null && !widget.hideLabel)
              ExcludeSemantics(child: Text(label, style: f.labelStyle)),
            control,
            if (description != null) Text(description, style: f.descriptionStyle),
            if (error != null) Semantics(liveRegion: true, child: Text(error, style: f.errorStyle)),
          ],
        ),
      ),
    );
  }
}

/// 表单：纵向排列字段（间距 16），并能一次校验所有 [RaTextField]。
///
/// ```dart
/// final formKey = GlobalKey<RaFormState>();
/// RaForm(key: formKey, children: [...]);
/// if (formKey.currentState!.validate()) { ... }
/// ```
class RaForm extends StatefulWidget {
  const RaForm({super.key, required this.children, this.gap});

  final List<Widget> children;

  /// 字段间距，默认取主题的 formGap（16）。
  final double? gap;

  static RaFormState? maybeOf(BuildContext context) => _RaFormScope.maybeOf(context);

  @override
  State<RaForm> createState() => _RaFormState();
}

/// 表单状态：[validate] 校验全部字段。
abstract class RaFormState extends State<RaForm> {
  bool validate();
}

class _RaFormState extends RaFormState {
  final Set<RaTextFieldState> _fields = <RaTextFieldState>{};

  void _register(RaTextFieldState field) => _fields.add(field);
  void _unregister(RaTextFieldState field) => _fields.remove(field);

  @override
  bool validate() {
    bool ok = true;
    for (final RaTextFieldState field in _fields) {
      ok = field.validate() && ok;
    }
    return ok;
  }

  @override
  Widget build(BuildContext context) {
    final RaFieldThemeData f = RaTheme.of(context).field;
    return _RaFormScope(
      state: this,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: widget.gap ?? f.formGap,
        children: widget.children,
      ),
    );
  }
}

class _RaFormScope extends InheritedWidget {
  const _RaFormScope({required this.state, required super.child});

  final _RaFormState state;

  static _RaFormState? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_RaFormScope>()?.state;

  @override
  bool updateShouldNotify(_RaFormScope old) => state != old.state;
}
