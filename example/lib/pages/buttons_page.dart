import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:orra_ui/orra_ui.dart';

import 'page_scaffold.dart';

/// 按钮与图标按钮。
class ButtonsPage extends StatefulWidget {
  const ButtonsPage({super.key});

  @override
  State<ButtonsPage> createState() => _ButtonsPageState();
}

class _ButtonsPageState extends State<ButtonsPage> {
  bool _loading = false;
  bool _pinned = false;

  Future<void> _simulateLoading() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    void noop() {}
    final RaThemeData theme = RaTheme.of(context);
    return GalleryPage(
      title: '按钮',
      description: '悬停底色立即出现、移开 150ms 淡出；按下 100ms。全局不显示焦点环，键盘 Tab / Enter / Space 仍可用。',
      sections: <GallerySection>[
        GallerySection(
          title: '变体',
          child: DemoWrap(
            children: <Widget>[
              RaButton(variant: RaButtonVariant.primary, onPressed: noop, child: const Text('主按钮')),
              RaButton(onPressed: noop, child: const Text('次要按钮')),
              RaButton(variant: RaButtonVariant.ghost, onPressed: noop, child: const Text('文字按钮')),
              RaButton(variant: RaButtonVariant.quiet, onPressed: noop, child: const Text('安静按钮')),
              RaButton(variant: RaButtonVariant.danger, onPressed: noop, child: const Text('删除')),
              RaButton(
                variant: RaButtonVariant.dangerSolid,
                onPressed: noop,
                child: const Text('永久删除'),
              ),
            ],
          ),
        ),
        GallerySection(
          title: '尺寸',
          description: 'sm 28 / md 32 / lg 40，圆角 8（lg 为 10）。',
          child: DemoWrap(
            children: <Widget>[
              for (final RaButtonSize size in RaButtonSize.values)
                RaButton(
                  variant: RaButtonVariant.primary,
                  size: size,
                  onPressed: noop,
                  leading: const RaIcon(LucideIcons.plus),
                  child: Text('新建 · ${size.name}'),
                ),
            ],
          ),
        ),
        GallerySection(
          title: '状态',
          child: DemoWrap(
            children: <Widget>[
              RaButton(
                variant: RaButtonVariant.primary,
                loading: _loading,
                onPressed: _simulateLoading,
                child: Text(_loading ? '保存中…' : '点击后加载 2 秒'),
              ),
              const RaButton(variant: RaButtonVariant.primary, onPressed: null, child: Text('禁用')),
              const RaButton(onPressed: null, child: Text('禁用')),
              RaButton(
                variant: RaButtonVariant.chip,
                onPressed: noop,
                leading: const RaIcon(LucideIcons.bot),
                child: const Text('胶囊按钮'),
              ),
              RaButton(
                variant: RaButtonVariant.send,
                onPressed: noop,
                semanticLabel: '发送',
                child: const RaIcon(LucideIcons.arrowUp),
              ),
            ],
          ),
        ),
        GallerySection(
          title: '图标按钮 + 提示',
          description: '28px 圆形；悬停 600ms 出现提示气泡（白底、0.5px 描边、11px），可带快捷键。',
          child: DemoWrap(
            children: <Widget>[
              RaIconButton(
                label: '搜索',
                shortcut: '⌘K',
                icon: const RaIcon(LucideIcons.search),
                onPressed: noop,
              ),
              RaIconButton(
                label: _pinned ? '取消置顶' : '置顶',
                icon: const RaIcon(LucideIcons.pin),
                selected: _pinned,
                onPressed: () => setState(() => _pinned = !_pinned),
              ),
              RaIconButton(label: '归档', icon: const RaIcon(LucideIcons.archive), onPressed: noop),
              const RaIconButton(label: '不可用', icon: RaIcon(LucideIcons.trash2), onPressed: null),
              RaTooltip(
                message: '任意组件都可以加提示（取代原生 title）',
                child: Text(
                  '悬停这段文字',
                  style: theme.typography.body.copyWith(color: theme.colors.accentInk),
                ),
              ),
            ],
          ),
        ),
        GallerySection(
          title: '卡片与列表项',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: theme.spacing.sm,
            children: <Widget>[
              RaButton(
                variant: RaButtonVariant.card,
                onPressed: noop,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: theme.spacing.xs2,
                  children: <Widget>[
                    Text('整理本周的客户反馈', style: theme.typography.bodyMedium),
                    Text(
                      '卡片按钮：0.5px 描边、圆角 8、内边距 16，悬停铺浅灰。',
                      style: theme.typography.caption.copyWith(color: theme.colors.ink2),
                    ),
                  ],
                ),
              ),
              RaButton(
                variant: RaButtonVariant.item,
                selected: true,
                onPressed: noop,
                child: const Text('列表项（当前）'),
              ),
              RaButton(variant: RaButtonVariant.item, onPressed: noop, child: const Text('列表项')),
            ],
          ),
        ),
      ],
    );
  }
}
