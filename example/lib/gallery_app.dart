import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:orra_desktop_shell/orra_desktop_shell.dart';
import 'package:orra_ui/orra_ui.dart';

import 'brand_themes.dart';
import 'gallery_layout.dart';
import 'pages/buttons_page.dart';
import 'pages/controls_page.dart';
import 'pages/display_page.dart';
import 'pages/fields_page.dart';
import 'pages/menus_page.dart';
import 'pages/overlays_page.dart';
import 'pages/sidebar_page.dart';
import 'pages/structure_page.dart';
import 'pages/tokens_page.dart';
import 'pages/values_page.dart';

/// 展示页。
enum GalleryRoute {
  tokens('设计变量', LucideIcons.swatchBook),
  buttons('按钮', LucideIcons.mousePointerClick),
  fields('输入框', LucideIcons.textCursorInput),
  controls('选择控件', LucideIcons.squareCheck),
  display('数据展示', LucideIcons.tags),
  numbers('数值与进度', LucideIcons.slidersHorizontal),
  structure('工具栏与分组', LucideIcons.panelTop),
  menus('菜单', LucideIcons.menu),
  overlays('对话框与提示', LucideIcons.messageSquare),
  sidebar('侧栏', LucideIcons.panelLeft);

  const GalleryRoute(this.label, this.icon);

  final String label;
  final IconData icon;

  Widget build() => switch (this) {
    GalleryRoute.tokens => const TokensPage(),
    GalleryRoute.buttons => const ButtonsPage(),
    GalleryRoute.fields => const FieldsPage(),
    GalleryRoute.controls => const ControlsPage(),
    GalleryRoute.display => const DisplayPage(),
    GalleryRoute.numbers => const ValuesPage(),
    GalleryRoute.structure => const StructurePage(),
    GalleryRoute.menus => const MenusPage(),
    GalleryRoute.overlays => const OverlaysPage(),
    GalleryRoute.sidebar => const SidebarPage(),
  };
}

class GalleryApp extends StatefulWidget {
  const GalleryApp({super.key});

  @override
  State<GalleryApp> createState() => _GalleryAppState();
}

class _GalleryAppState extends State<GalleryApp> {
  RaThemeMode _mode = RaThemeMode.system;
  Brand _brand = Brand.indigo;

  RaThemeData _theme(bool dark) {
    final RaThemeData base = brandTheme(_brand, dark: dark);
    return base.copyWith(extensions: <RaThemeExtension>[GalleryLayout.fallback(base)]);
  }

  @override
  Widget build(BuildContext context) {
    return RaApp(
      title: 'orra gallery',
      theme: _theme(false),
      darkTheme: _theme(true),
      themeMode: _mode,
      debugShowCheckedModeBanner: false,
      home: GalleryHome(
        mode: _mode,
        brand: _brand,
        onModeChanged: (RaThemeMode m) => setState(() => _mode = m),
        onBrandChanged: (Brand b) => setState(() => _brand = b),
      ),
    );
  }
}

class GalleryHome extends StatefulWidget {
  const GalleryHome({
    super.key,
    required this.mode,
    required this.brand,
    required this.onModeChanged,
    required this.onBrandChanged,
  });

  final RaThemeMode mode;
  final Brand brand;
  final ValueChanged<RaThemeMode> onModeChanged;
  final ValueChanged<Brand> onBrandChanged;

  @override
  State<GalleryHome> createState() => _GalleryHomeState();
}

class _GalleryHomeState extends State<GalleryHome> {
  final List<GalleryRoute> _history = <GalleryRoute>[GalleryRoute.tokens];
  int _index = 0;
  bool _sidebarOpen = true;

  GalleryRoute get _current => _history[_index];
  bool get _canBack => _index > 0;
  bool get _canForward => _index < _history.length - 1;

  void _go(GalleryRoute route) {
    if (route == _current) return;
    setState(() {
      _history.removeRange(_index + 1, _history.length);
      _history.add(route);
      _index = _history.length - 1;
    });
  }

  void _back() {
    if (_canBack) setState(() => _index--);
  }

  void _forward() {
    if (_canForward) setState(() => _index++);
  }

  void _toggleSidebar() => setState(() => _sidebarOpen = !_sidebarOpen);

  @override
  Widget build(BuildContext context) {
    final RaShellStrings strings = RaShellStrings.of(context);
    return RaAppMenuBar(
      appName: 'orra gallery',
      menus: <RaMenuBarMenu>[
        RaMenuBarMenu(
          label: '显示',
          entries: <RaMenuBarEntry>[
            RaCommand(
              label: _sidebarOpen ? strings.collapseSidebar : strings.expandSidebar,
              shortcut: raPrimaryShortcut(LogicalKeyboardKey.backslash),
              onInvoked: _toggleSidebar,
            ),
            const RaCommandDivider(),
            const RaSystemMenuItem(PlatformProvidedMenuItemType.toggleFullScreen),
          ],
        ),
        RaMenuBarMenu(
          label: '前往',
          entries: <RaMenuBarEntry>[
            RaCommand(
              label: strings.back,
              shortcut: raPrimaryShortcut(LogicalKeyboardKey.bracketLeft),
              enabled: _canBack,
              onInvoked: _back,
            ),
            RaCommand(
              label: strings.forward,
              shortcut: raPrimaryShortcut(LogicalKeyboardKey.bracketRight),
              enabled: _canForward,
              onInvoked: _forward,
            ),
            const RaCommandDivider(),
            for (final GalleryRoute route in GalleryRoute.values)
              RaCommand(
                label: route.label,
                shortcut: raPrimaryShortcut(
                  LogicalKeyboardKey(LogicalKeyboardKey.digit1.keyId + route.index),
                ),
                onInvoked: () => _go(route),
              ),
          ],
        ),
        const RaMenuBarMenu(
          label: '窗口',
          entries: <RaMenuBarEntry>[
            RaSystemMenuItem(PlatformProvidedMenuItemType.minimizeWindow),
            RaSystemMenuItem(PlatformProvidedMenuItemType.zoomWindow),
            RaCommandDivider(),
            RaSystemMenuItem(PlatformProvidedMenuItemType.arrangeWindowsInFront),
          ],
        ),
      ],
      child: RaDesktopFrame(
        sidebarOpen: _sidebarOpen,
        onToggleSidebar: _toggleSidebar,
        onBack: _canBack ? _back : null,
        onForward: _canForward ? _forward : null,
        sidebar: _GallerySidebar(current: _current, onSelect: _go),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            RaPanelHeader(
              leading: RaBreadcrumb(
                items: <RaBreadcrumbItem>[
                  RaBreadcrumbItem(label: '组件', onPressed: () => _go(GalleryRoute.tokens)),
                  RaBreadcrumbItem(label: _current.label, current: true),
                ],
              ),
              trailing: _AppearanceMenu(
                mode: widget.mode,
                brand: widget.brand,
                onModeChanged: widget.onModeChanged,
                onBrandChanged: widget.onBrandChanged,
              ),
            ),
            Expanded(
              child: KeyedSubtree(key: ValueKey<GalleryRoute>(_current), child: _current.build()),
            ),
          ],
        ),
      ),
    );
  }
}

class _GallerySidebar extends StatelessWidget {
  const _GallerySidebar({required this.current, required this.onSelect});

  final GalleryRoute current;
  final ValueChanged<GalleryRoute> onSelect;

  @override
  Widget build(BuildContext context) {
    final RaThemeData theme = RaTheme.of(context);
    final GalleryLayout layout = GalleryLayout.of(context);
    Widget routeItem(GalleryRoute route) => RaSidebarItem(
      label: route.label,
      icon: RaIcon(route.icon),
      selected: current == route,
      onPressed: () => onSelect(route),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        RaMenu(
          side: RaPopoverSide.bottom,
          align: RaPopoverAlign.start,
          items: <Widget>[
            const RaMenuHeader(title: Text('orra gallery'), child: Text('orra_ui 组件展示')),
            const RaMenuSeparator(),
            RaMenuItem(
              onPressed: () => RaToast.of(context).success('设置页将在后续版本提供'),
              shortcut: '⌘,',
              child: const Text('设置'),
            ),
          ],
          child: RaMenuTrigger(
            variant: RaMenuTriggerVariant.row,
            leading: Container(
              width: layout.badgeSize,
              height: layout.badgeSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colors.accent,
                borderRadius: BorderRadius.circular(layout.badgeRadius),
              ),
              child: Text(
                'O',
                style: theme.typography.captionMedium.copyWith(color: theme.colors.onAccent),
              ),
            ),
            child: const Text('orra gallery'),
          ),
        ),
        SizedBox(height: layout.sidebarGap),
        RaSidebarItem(
          label: '新建',
          tone: RaSidebarItemTone.primary,
          icon: const RaIcon(LucideIcons.squarePen),
          shortcut: '⌘N',
          onPressed: () => RaToast.of(context).success('新建'),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                RaSidebarSection(title: '基础', children: <Widget>[routeItem(GalleryRoute.tokens)]),
                RaSidebarSection(
                  title: '组件',
                  children: <Widget>[
                    for (final GalleryRoute route in GalleryRoute.values.skip(1)) routeItem(route),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 头部右侧：外观菜单（深浅模式 + 品牌色），演示「可配置设计系统」。
class _AppearanceMenu extends StatelessWidget {
  const _AppearanceMenu({
    required this.mode,
    required this.brand,
    required this.onModeChanged,
    required this.onBrandChanged,
  });

  final RaThemeMode mode;
  final Brand brand;
  final ValueChanged<RaThemeMode> onModeChanged;
  final ValueChanged<Brand> onBrandChanged;

  @override
  Widget build(BuildContext context) {
    const Map<RaThemeMode, String> modes = <RaThemeMode, String>{
      RaThemeMode.system: '跟随系统',
      RaThemeMode.light: '浅色',
      RaThemeMode.dark: '深色',
    };
    return RaMenu(
      items: <Widget>[
        const RaMenuHeader(child: Text('界面主题')),
        for (final MapEntry<RaThemeMode, String> e in modes.entries)
          RaMenuRadioItem<RaThemeMode>(
            value: e.key,
            groupValue: mode,
            onChanged: onModeChanged,
            child: Text(e.value),
          ),
        const RaMenuSeparator(),
        const RaMenuHeader(child: Text('品牌色')),
        for (final Brand b in Brand.values)
          RaMenuRadioItem<Brand>(
            value: b,
            groupValue: brand,
            onChanged: onBrandChanged,
            child: Text(b.label),
          ),
      ],
      child: Builder(
        builder: (BuildContext context) {
          final RaMenuHandle menu = RaMenu.of(context);
          return RaIconButton(
            label: '外观',
            icon: const RaIcon(LucideIcons.palette),
            selected: menu.isOpen,
            onPressed: menu.toggle,
          );
        },
      ),
    );
  }
}
