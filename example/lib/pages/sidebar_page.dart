import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:orra_ui/orra_ui.dart';

import '../gallery_layout.dart';
import 'page_scaffold.dart';

/// 侧栏组件（放在与窗口底同色的区域里展示）。
class SidebarPage extends StatefulWidget {
  const SidebarPage({super.key});

  @override
  State<SidebarPage> createState() => _SidebarPageState();
}

class _SidebarPageState extends State<SidebarPage> {
  String _current = 'running';

  @override
  Widget build(BuildContext context) {
    final RaThemeData theme = RaTheme.of(context);
    Widget item(
      String id,
      String label, {
      Widget? icon,
      Widget? trailing,
      RaSidebarItemTone tone = RaSidebarItemTone.normal,
    }) => RaSidebarItem(
      label: label,
      icon: icon,
      trailing: trailing,
      tone: tone,
      selected: _current == id,
      onPressed: () => setState(() => _current = id),
    );
    return GalleryPage(
      title: '侧栏',
      description: '行高 28、圆角 8；默认次要色，悬停 / 选中变正文色；底色只用半透明叠加色（叠在窗口底上）。左侧真实侧栏同样由这些组件组成。',
      sections: <GallerySection>[
        GallerySection(
          title: '按状态组织的分组',
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: GalleryLayout.of(context).demoSidebarWidth,
              padding: EdgeInsets.all(theme.spacing.lg),
              decoration: BoxDecoration(
                color: theme.chrome.chrome,
                borderRadius: BorderRadius.circular(theme.radii.lg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: theme.sidebar.rowGap,
                children: <Widget>[
                  item(
                    'new',
                    '新建',
                    icon: const RaIcon(LucideIcons.squarePen),
                    tone: RaSidebarItemTone.primary,
                  ),
                  RaSidebarSection(
                    title: '需要处理',
                    children: <Widget>[
                      item(
                        'attention',
                        '审批：退款申请',
                        icon: const RaStatusDot(tone: RaStatusTone.attention, label: '需要处理'),
                        trailing: const Text('2'),
                      ),
                    ],
                  ),
                  RaSidebarSection(
                    title: '运行中',
                    action: RaIconButton(
                      label: '新建',
                      icon: const RaIcon(LucideIcons.plus),
                      onPressed: () {},
                    ),
                    children: <Widget>[
                      item(
                        'running',
                        '周报生成器',
                        icon: const RaStatusDot(tone: RaStatusTone.running, label: '运行中'),
                        trailing: const Text('3 分钟前'),
                      ),
                      item('child', '本周汇总', tone: RaSidebarItemTone.child),
                    ],
                  ),
                  RaSidebarSection(
                    title: '已归档',
                    initiallyExpanded: false,
                    children: <Widget>[
                      item(
                        'archived',
                        '旧版客服助手',
                        icon: const RaIcon(LucideIcons.archive),
                        tone: RaSidebarItemTone.muted,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
