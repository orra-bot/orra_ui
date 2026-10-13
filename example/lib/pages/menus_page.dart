import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:orra_ui/orra_ui.dart';

import '../gallery_layout.dart';
import 'page_scaffold.dart';

/// 菜单、子菜单、单选、右键菜单。
class MenusPage extends StatefulWidget {
  const MenusPage({super.key});

  @override
  State<MenusPage> createState() => _MenusPageState();
}

class _MenusPageState extends State<MenusPage> {
  String _assignee = 'new';
  String _workspace = 'orra';
  String _sort = '更新时间';

  void _toast(String text) => RaToast.of(context).success(text);

  @override
  Widget build(BuildContext context) {
    final RaThemeData theme = RaTheme.of(context);
    final GalleryLayout layout = GalleryLayout.of(context);
    return GalleryPage(
      title: '菜单',
      description:
          '1:1 对照 Linear：圆角 12、选项高 32、文字距左缘 14、高亮块缩进 6、分隔线贯穿全宽、对勾在行尾、子菜单实心 ▸。'
          '键盘：↑ ↓ 移动、→ 展开子菜单、← 收起、Enter 执行、Esc 关闭。',
      sections: <GallerySection>[
        GallerySection(
          title: '账户菜单（胶囊触发）',
          child: DemoWrap(
            children: <Widget>[
              RaMenu(
                align: RaPopoverAlign.start,
                items: <Widget>[
                  const RaMenuHeader(title: Text('Patrick'), child: Text('patrick@orra.dev')),
                  const RaMenuSeparator(),
                  RaMenuItem(
                    onPressed: () => _toast('打开设置'),
                    shortcut: '⌘,',
                    leading: const RaIcon(LucideIcons.settings),
                    child: const Text('设置'),
                  ),
                  RaMenuItem(
                    onPressed: () => _toast('邀请成员'),
                    leading: const RaIcon(LucideIcons.users),
                    child: const Text('邀请和管理成员'),
                  ),
                  RaSubmenu(
                    label: const Text('切换 Workspace'),
                    leading: const RaIcon(LucideIcons.layers),
                    items: <Widget>[
                      for (final String ws in <String>['orra', 'Diotia', 'Playground'])
                        RaMenuRadioItem<String>(
                          value: ws,
                          groupValue: _workspace,
                          closeOnActivate: true,
                          onChanged: (String v) => setState(() => _workspace = v),
                          child: Text(ws),
                        ),
                      const RaMenuSeparator(),
                      RaMenuItem(
                        onPressed: () => _toast('新建 Workspace'),
                        leading: const RaIcon(LucideIcons.plus),
                        child: const Text('新建 Workspace'),
                      ),
                    ],
                  ),
                  const RaMenuSeparator(),
                  RaMenuItem(
                    onPressed: () => _toast('已退出登录'),
                    danger: true,
                    leading: const RaIcon(LucideIcons.logOut),
                    child: const Text('退出登录'),
                  ),
                ],
                child: RaMenuTrigger(
                  leading: const RaAvatar(name: 'Patrick'),
                  child: Text(_workspace),
                ),
              ),
            ],
          ),
        ),
        GallerySection(
          title: '选择器（输入框上方的胶囊）与选择框',
          child: DemoWrap(
            children: <Widget>[
              RaMenu(
                align: RaPopoverAlign.start,
                items: <Widget>[
                  for (final (String, String) option in <(String, String)>[
                    ('new', '新对象'),
                    ('agent-a', '客户反馈助手'),
                    ('agent-b', '周报生成器'),
                  ])
                    RaMenuRadioItem<String>(
                      value: option.$1,
                      groupValue: _assignee,
                      onChanged: (String v) => setState(() => _assignee = v),
                      child: Text(option.$2),
                    ),
                ],
                child: RaMenuTrigger(
                  variant: RaMenuTriggerVariant.chip,
                  leading: const RaIcon(LucideIcons.bot),
                  trailing: RaIcon.glyph(theme.icons.chevronDown, size: theme.sizing.iconXs),
                  child: Text('交给：${_assignee == 'new' ? '新对象' : _assignee}'),
                ),
              ),
              RaMenu(
                align: RaPopoverAlign.start,
                items: <Widget>[
                  for (final String option in <String>['更新时间', '创建时间', '名称'])
                    RaMenuRadioItem<String>(
                      value: option,
                      groupValue: _sort,
                      closeOnActivate: true,
                      onChanged: (String v) => setState(() => _sort = v),
                      child: Text(option),
                    ),
                ],
                child: RaMenuTrigger(
                  trailing: RaIcon.glyph(theme.icons.chevronDown, size: theme.sizing.iconXs),
                  child: Text('排序：$_sort'),
                ),
              ),
              RaMenu(
                items: <Widget>[
                  RaMenuItem(onPressed: () => _toast('已复制链接'), child: const Text('复制链接')),
                  RaMenuItem(onPressed: () => _toast('已归档'), child: const Text('归档')),
                  const RaMenuItem(onPressed: null, child: Text('导出（暂不可用）')),
                ],
                child: Builder(
                  builder: (BuildContext context) {
                    final RaMenuHandle menu = RaMenu.of(context);
                    return RaIconButton(
                      label: '更多',
                      icon: const RaIcon(LucideIcons.ellipsis),
                      selected: menu.isOpen,
                      onPressed: menu.toggle,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        GallerySection(
          title: '右键菜单',
          child: RaContextMenu(
            items: <Widget>[
              RaMenuItem(onPressed: () => _toast('在新标签页中打开'), child: const Text('在新标签页中打开')),
              RaMenuItem(onPressed: () => _toast('已复制'), shortcut: '⌘C', child: const Text('复制')),
              const RaMenuSeparator(),
              RaMenuItem(onPressed: () => _toast('已删除'), danger: true, child: const Text('删除')),
            ],
            child: Container(
              height: layout.contextAreaHeight,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colors.sunken,
                borderRadius: BorderRadius.circular(theme.radii.md),
              ),
              child: const DemoCaption('在这个区域里点右键'),
            ),
          ),
        ),
      ],
    );
  }
}
