import 'package:flutter/widgets.dart';

import '../theme/theme.dart';
import '../tokens/components.dart';
import 'checkbox.dart';

/// 复选框组的一项。
@immutable
class RaCheckboxOption<T> {
  const RaCheckboxOption({
    required this.value,
    required this.label,
    this.description,
    this.enabled = true,
  });

  final T value;
  final String label;
  final String? description;
  final bool enabled;
}

/// 复选框组（Base UI Checkbox Group）：一组复选框共享选中集合。
///
/// 给了 [parentLabel] 时在顶部放一个「全选」父复选框：子项全选 / 全不选 / 部分选中（横线），
/// 点击父项全选或全部取消（只影响可用的子项）；子项缩进到与父项文字对齐。
class RaCheckboxGroup<T> extends StatelessWidget {
  const RaCheckboxGroup({
    super.key,
    required this.options,
    required this.values,
    required this.onChanged,
    this.parentLabel,
    this.semanticLabel,
  });

  final List<RaCheckboxOption<T>> options;
  final Set<T> values;
  final ValueChanged<Set<T>>? onChanged;
  final String? parentLabel;
  final String? semanticLabel;

  /// 父项状态按可用的子项计算：全选 true、全不选 false、其余 null（部分选中）。
  bool? get _parentValue {
    final List<RaCheckboxOption<T>> enabled = options
        .where((RaCheckboxOption<T> o) => o.enabled)
        .toList();
    final List<RaCheckboxOption<T>> scope = enabled.isEmpty ? options : enabled;
    final int selected = scope.where((RaCheckboxOption<T> o) => values.contains(o.value)).length;
    if (selected == 0) return false;
    if (selected == scope.length) return true;
    return null;
  }

  void _setAll(bool selected) {
    final Set<T> next = <T>{...values};
    for (final RaCheckboxOption<T> o in options) {
      if (!o.enabled) continue;
      if (selected) {
        next.add(o.value);
      } else {
        next.remove(o.value);
      }
    }
    onChanged?.call(next);
  }

  void _set(T value, bool selected) {
    final Set<T> next = <T>{...values};
    if (selected) {
      next.add(value);
    } else {
      next.remove(value);
    }
    onChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final RaControlThemeData s = RaTheme.of(context).control;
    final Widget children = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: s.groupGap,
      children: <Widget>[
        for (final RaCheckboxOption<T> o in options)
          RaCheckbox(
            value: values.contains(o.value),
            onChanged: onChanged != null && o.enabled ? (bool v) => _set(o.value, v) : null,
            label: Text(o.label),
            description: o.description == null ? null : Text(o.description!),
          ),
      ],
    );
    return Semantics(
      container: true,
      label: semanticLabel,
      explicitChildNodes: true,
      child: parentLabel == null
          ? children
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: s.groupGap,
              children: <Widget>[
                RaCheckbox(
                  value: _parentValue,
                  onChanged: onChanged == null ? null : _setAll,
                  label: Text(parentLabel!),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.only(start: s.groupIndent),
                  child: children,
                ),
              ],
            ),
    );
  }
}
