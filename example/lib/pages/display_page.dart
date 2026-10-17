import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:orra_ui/orra_ui.dart';

import '../gallery_layout.dart';
import 'page_scaffold.dart';

/// 数据展示：标签、右侧栏卡片、折叠面板、状态块、抽屉。
class DisplayPage extends StatefulWidget {
  const DisplayPage({super.key});

  @override
  State<DisplayPage> createState() => _DisplayPageState();
}

class _DisplayPageState extends State<DisplayPage> {
  bool _retrying = false;

  Future<void> _retry() async {
    setState(() => _retrying = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => _retrying = false);
  }

  void _openDrawer() {
    showRaDrawer<void>(
      context: context,
      builder: (BuildContext context) => const RaDrawer(
        title: '客户反馈助手',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            RaPropertyRow(
              label: '状态',
              child: RaTag(label: '运行中', tone: RaTagTone.success, dot: true),
            ),
            RaPropertyRow(label: '负责人', child: Text('Ive Tian')),
            RaPropertyRow(label: '最近运行', child: Text('3 分钟前')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final RaThemeData theme = RaTheme.of(context);
    final GalleryLayout layout = GalleryLayout.of(context);
    return GalleryPage(
      title: '数据展示',
      description: '标签、右侧栏属性卡片、折叠面板、加载 / 空 / 错误状态，以及窄窗口下代替右侧栏的抽屉。',
      sections: <GallerySection>[
        const GallerySection(
          title: '标签',
          description: '成功 / 失败的区分靠颜色与圆点；「未开放」用虚线描边如实标注。',
          child: DemoWrap(
            children: <Widget>[
              RaTag(label: '草稿'),
              RaTag(label: '运行中', tone: RaTagTone.success, dot: true),
              RaTag(label: '需要处理', tone: RaTagTone.attention, dot: true),
              RaTag(label: '新', tone: RaTagTone.accent),
              RaTag(label: '失败', tone: RaTagTone.danger),
              RaTag(label: '未开放', tone: RaTagTone.outline),
              RaTag(label: '已归档', tone: RaTagTone.muted),
              RaCountTag(count: 3, semanticLabel: '3 条未读'),
              RaCountTag(count: 128, semanticLabel: '128 条未读'),
            ],
          ),
        ),
        GallerySection(
          title: '右侧栏卡片',
          description: '标题可折叠，右侧可放一个操作；内容是「标签：值」属性行（标签列 90）。',
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: SizedBox(
              width: layout.sideCardWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: theme.spacing.sm,
                children: <Widget>[
                  RaSideCard(
                    title: '它做什么',
                    action: RaIconButton(
                      label: '编辑',
                      icon: const RaIcon(LucideIcons.pencil),
                      onPressed: () {},
                    ),
                    children: const <Widget>[
                      RaPropertyRow(
                        label: '状态',
                        child: RaTag(label: '运行中', tone: RaTagTone.success, dot: true),
                      ),
                      RaPropertyRow(label: '负责人', child: Text('Ive Tian')),
                      RaPropertyRow(label: '触发方式', child: Text('每天 09:00')),
                    ],
                  ),
                  const RaSideCard(
                    title: '能访问什么',
                    initiallyExpanded: false,
                    children: <Widget>[
                      RaPropertyRow(label: '邮箱', child: Text('只读')),
                      RaPropertyRow(
                        label: '日历',
                        child: RaTag(label: '未开放', tone: RaTagTone.outline),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        GallerySection(
          title: '折叠面板',
          child: RaCollapsible(
            title: const Text('高级选项'),
            child: Padding(
              padding: EdgeInsets.only(top: theme.spacing.sm),
              child: const DemoCaption('超时、重试次数、并发上限等不常改的设置放在这里。'),
            ),
          ),
        ),
        GallerySection(
          title: '加载 / 空 / 错误',
          description: '列表与详情统一用这三种状态块；错误带重试。',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: layout.demoGap,
            children: <Widget>[
              const RaLoadingState(),
              RaEmptyState(
                title: '还没有运行记录',
                description: const Text('运行一次后，结果会出现在这里。'),
                action: RaButton(
                  size: RaButtonSize.sm,
                  variant: RaButtonVariant.primary,
                  onPressed: () {},
                  child: const Text('立即运行'),
                ),
              ),
              RaErrorState(message: '网络连接已断开，请检查网络后重试。', onRetry: _retry, retrying: _retrying),
            ],
          ),
        ),
        GallerySection(
          title: '抽屉',
          description: '窄窗口下，右侧栏改为从右侧滑出的抽屉。点遮罩或按 Esc 关闭。',
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: RaButton(onPressed: _openDrawer, child: const Text('打开抽屉')),
          ),
        ),
      ],
    );
  }
}
