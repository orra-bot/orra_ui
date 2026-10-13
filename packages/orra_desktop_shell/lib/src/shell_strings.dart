import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// 外壳内置文案（中文 / 英文，按当前 Locale 选择）。
@immutable
class RaShellStrings {
  const RaShellStrings._({
    required this.windowControls,
    required this.collapseSidebar,
    required this.expandSidebar,
    required this.back,
    required this.forward,
    required this.isMac,
  });

  static RaShellStrings of(BuildContext context) {
    final bool en = Localizations.maybeLocaleOf(context)?.languageCode == 'en';
    final bool mac = defaultTargetPlatform == TargetPlatform.macOS;
    return en
        ? RaShellStrings._(
            windowControls: 'Window',
            collapseSidebar: 'Collapse sidebar',
            expandSidebar: 'Expand sidebar',
            back: 'Back',
            forward: 'Forward',
            isMac: mac,
          )
        : RaShellStrings._(
            windowControls: '窗口',
            collapseSidebar: '收起侧栏',
            expandSidebar: '展开侧栏',
            back: '后退',
            forward: '前进',
            isMac: mac,
          );
  }

  final String windowControls;
  final String collapseSidebar;
  final String expandSidebar;
  final String back;
  final String forward;
  final bool isMac;

  /// 快捷键显示：macOS「⌘K」，其他平台「Ctrl+K」。
  String shortcut(String key, {bool shift = false}) =>
      isMac ? '${shift ? '⇧' : ''}⌘$key' : 'Ctrl+${shift ? 'Shift+' : ''}$key';
}
