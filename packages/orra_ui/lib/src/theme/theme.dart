import 'package:flutter/widgets.dart';

import 'theme_data.dart';

/// 向下提供 [RaThemeData]。通常由 RaApp 放在根部；局部换主题时可嵌套使用。
class RaTheme extends InheritedTheme {
  const RaTheme({super.key, required this.data, required super.child});

  final RaThemeData data;

  static final RaThemeData _fallback = RaThemeData.light();

  /// 当前主题；树上没有 RaTheme 时返回默认浅色主题。
  static RaThemeData of(BuildContext context) {
    final RaTheme? theme = context.dependOnInheritedWidgetOfExactType<RaTheme>();
    return theme?.data ?? _fallback;
  }

  @override
  Widget wrap(BuildContext context, Widget child) => RaTheme(data: data, child: child);

  @override
  bool updateShouldNotify(RaTheme oldWidget) => !identical(data, oldWidget.data);
}
