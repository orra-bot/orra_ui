import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'shell_platform.dart';

/// 菜单栏中的一项。
@immutable
sealed class RaMenuBarEntry {
  const RaMenuBarEntry();
}

/// 命令：菜单项 + 快捷键。
class RaCommand extends RaMenuBarEntry {
  const RaCommand({
    required this.label,
    required this.onInvoked,
    this.shortcut,
    this.visible = true,
    this.enabled = true,
  });

  final String label;
  final VoidCallback onInvoked;
  final SingleActivator? shortcut;

  /// 不在菜单中显示、只保留快捷键（如 ⌘1–⌘9）。
  final bool visible;
  final bool enabled;
}

/// 分隔线。
class RaCommandDivider extends RaMenuBarEntry {
  const RaCommandDivider();
}

/// 子菜单。
class RaCommandSubmenu extends RaMenuBarEntry {
  const RaCommandSubmenu({required this.label, required this.entries});

  final String label;
  final List<RaMenuBarEntry> entries;
}

/// 系统提供的菜单项（macOS：最小化、缩放、全屏……）。其他平台忽略。
class RaSystemMenuItem extends RaMenuBarEntry {
  const RaSystemMenuItem(this.type);

  final PlatformProvidedMenuItemType type;
}

/// 顶层菜单（文件、编辑、显示、前往、标签页、窗口……）。
@immutable
class RaMenuBarMenu {
  const RaMenuBarMenu({required this.label, required this.entries});

  final String label;
  final List<RaMenuBarEntry> entries;
}

/// 应用菜单栏与快捷键（「桌面习惯优先」）。
///
/// - macOS：生成原生菜单栏（第一个菜单为应用菜单：关于 / 隐藏 / 退出），快捷键由系统菜单提供；
/// - Windows / Linux / 网页：不显示菜单栏，同一套快捷键全局生效。
///   网页端被处理的按键会阻止浏览器默认行为（如 ⌘[ 后退）；浏览器保留的组合键（⌘W、⌘T、⌘N 等）页面收不到。
///
/// 只需要快捷键、不需要显示的命令设 `visible: false`。
class RaAppMenuBar extends StatefulWidget {
  const RaAppMenuBar({super.key, required this.appName, required this.menus, required this.child});

  final String appName;
  final List<RaMenuBarMenu> menus;
  final Widget child;

  @override
  State<RaAppMenuBar> createState() => _RaAppMenuBarState();
}

class _RaAppMenuBarState extends State<RaAppMenuBar> {
  bool get _nativeMenus => RaShellPlatform.current.hasNativeMenuBar;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKey);
    super.dispose();
  }

  Iterable<RaCommand> _commands(List<RaMenuBarEntry> entries) sync* {
    for (final RaMenuBarEntry e in entries) {
      switch (e) {
        case RaCommand():
          yield e;
        case RaCommandSubmenu(:final List<RaMenuBarEntry> entries):
          yield* _commands(entries);
        case RaCommandDivider() || RaSystemMenuItem():
          break;
      }
    }
  }

  bool _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    for (final RaMenuBarMenu menu in widget.menus) {
      for (final RaCommand command in _commands(menu.entries)) {
        final SingleActivator? shortcut = command.shortcut;
        if (shortcut == null || !command.enabled) continue;
        // macOS 上可见命令的快捷键由原生菜单负责，避免触发两次。
        if (_nativeMenus && command.visible) continue;
        if (shortcut.accepts(event, HardwareKeyboard.instance)) {
          command.onInvoked();
          return true;
        }
      }
    }
    return false;
  }

  List<PlatformMenuItem> _platformItems(List<RaMenuBarEntry> entries) {
    final List<PlatformMenuItem> groups = <PlatformMenuItem>[];
    List<PlatformMenuItem> current = <PlatformMenuItem>[];
    void closeGroup() {
      if (current.isNotEmpty) groups.add(PlatformMenuItemGroup(members: current));
      current = <PlatformMenuItem>[];
    }

    for (final RaMenuBarEntry e in entries) {
      switch (e) {
        case RaCommandDivider():
          closeGroup();
        case RaCommand(:final bool visible) when !visible:
          break;
        case RaCommand():
          current.add(
            PlatformMenuItem(
              label: e.label,
              shortcut: e.shortcut,
              onSelected: e.enabled ? e.onInvoked : null,
            ),
          );
        case RaCommandSubmenu():
          current.add(PlatformMenu(label: e.label, menus: _platformItems(e.entries)));
        case RaSystemMenuItem():
          if (PlatformProvidedMenuItem.hasMenu(e.type)) {
            current.add(PlatformProvidedMenuItem(type: e.type));
          }
      }
    }
    closeGroup();
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    if (!_nativeMenus) return widget.child;
    return PlatformMenuBar(
      menus: <PlatformMenuItem>[
        PlatformMenu(
          label: widget.appName,
          menus: _platformItems(const <RaMenuBarEntry>[
            RaSystemMenuItem(PlatformProvidedMenuItemType.about),
            RaCommandDivider(),
            RaSystemMenuItem(PlatformProvidedMenuItemType.servicesSubmenu),
            RaCommandDivider(),
            RaSystemMenuItem(PlatformProvidedMenuItemType.hide),
            RaSystemMenuItem(PlatformProvidedMenuItemType.hideOtherApplications),
            RaSystemMenuItem(PlatformProvidedMenuItemType.showAllApplications),
            RaCommandDivider(),
            RaSystemMenuItem(PlatformProvidedMenuItemType.quit),
          ]),
        ),
        for (final RaMenuBarMenu menu in widget.menus)
          PlatformMenu(label: menu.label, menus: _platformItems(menu.entries)),
      ],
      child: widget.child,
    );
  }
}

/// 平台主修饰键的快捷键：macOS 为 ⌘，Windows / Linux 为 Ctrl；网页端按用户的操作系统选择。
SingleActivator raPrimaryShortcut(LogicalKeyboardKey key, {bool shift = false, bool alt = false}) {
  final bool mac = raUsesCommandKey;
  return SingleActivator(key, meta: mac, control: !mac, shift: shift, alt: alt);
}
