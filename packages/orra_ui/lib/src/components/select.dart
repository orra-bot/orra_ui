import 'package:flutter/widgets.dart';

import '../foundation/popover_layout.dart';
import '../icons/ra_icon.dart';
import '../theme/theme.dart';
import '../tokens/components.dart';
import 'button.dart';
import 'menu.dart';

/// 选择框的一个选项。
@immutable
class RaSelectOption<T> {
  const RaSelectOption({
    required this.value,
    required this.label,
    this.leading,
    this.enabled = true,
  });

  final T value;
  final String label;

  /// 选项左侧的预览（例如主题样张、图标）。
  final Widget? leading;
  final bool enabled;
}

/// 选择框（Base UI Select 的桌面形态）：30 高触发按钮 + 菜单单选，选中后关闭。
///
/// 选项多、需要搜索时改用命令面板式的选择器。
class RaSelect<T> extends StatelessWidget {
  const RaSelect({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.placeholder,
    this.width,
    this.semanticLabel,
  });

  final List<RaSelectOption<T>> options;
  final T? value;
  final ValueChanged<T>? onChanged;

  /// 没有选中项时显示的文字。
  final String? placeholder;

  /// 固定宽度；为空时随内容，最宽 [RaSelectThemeData.maxWidth]。
  final double? width;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final RaSelectThemeData s = RaTheme.of(context).select;
    RaSelectOption<T>? current;
    for (final RaSelectOption<T> o in options) {
      if (o.value == value) current = o;
    }
    return RaMenu(
      align: RaPopoverAlign.start,
      items: <Widget>[
        for (final RaSelectOption<T> o in options)
          RaMenuRadioItem<T>(
            value: o.value,
            groupValue: value,
            onChanged: onChanged,
            enabled: o.enabled,
            leading: o.leading,
            closeOnActivate: true,
            child: Text(o.label),
          ),
      ],
      child: ConstrainedBox(
        constraints: width == null
            ? BoxConstraints(maxWidth: s.maxWidth)
            : BoxConstraints.tightFor(width: width),
        child: Builder(
          builder: (BuildContext context) {
            final RaMenuHandle menu = RaMenu.of(context);
            return RaButton(
              onPressed: onChanged == null ? null : menu.toggle,
              selected: menu.isOpen,
              style: s.trigger,
              expand: width != null,
              semanticLabel: semanticLabel,
              leading: current?.leading,
              trailing: RaIcon.glyph(
                RaTheme.of(context).icons.chevronDown,
                size: s.caretSize,
                color: s.caretColor,
              ),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                widthFactor: width == null ? 1 : null,
                child: Text(
                  current?.label ?? placeholder ?? '',
                  style: current == null ? TextStyle(color: s.placeholderColor) : null,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
