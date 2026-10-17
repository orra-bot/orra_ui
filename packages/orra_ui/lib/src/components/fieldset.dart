import 'package:flutter/widgets.dart';

import '../theme/theme.dart';
import '../theme/theme_data.dart';
import '../tokens/components.dart';

/// 字段组（Base UI Fieldset）：标题 + 可选说明 + 一组控件。
///
/// [enabled] 为 false 时整组不可点击、不可聚焦，并以禁用透明度显示。
class RaFieldset extends StatelessWidget {
  const RaFieldset({
    super.key,
    required this.legend,
    required this.children,
    this.description,
    this.enabled = true,
  });

  final String legend;
  final Widget? description;
  final List<Widget> children;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final RaThemeData theme = RaTheme.of(context);
    final RaFieldsetThemeData s = theme.fieldset;
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: s.gap,
      children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: s.legendGap,
          children: <Widget>[
            Semantics(header: true, child: Text(legend, style: s.legendStyle)),
            if (description != null)
              DefaultTextStyle(style: s.descriptionStyle, child: description!),
          ],
        ),
        ...children,
      ],
    );
    if (!enabled) {
      content = Opacity(
        opacity: theme.control.disabledOpacity,
        child: AbsorbPointer(child: ExcludeFocus(child: content)),
      );
    }
    return Semantics(
      container: true,
      label: legend,
      enabled: enabled,
      explicitChildNodes: true,
      child: content,
    );
  }
}
