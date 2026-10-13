import 'package:flutter/widgets.dart';
import 'package:orra_ui/orra_ui.dart';

import '../gallery_layout.dart';
import 'page_scaffold.dart';

/// 设计变量：语义颜色、字体角色、间距与圆角。
class TokensPage extends StatelessWidget {
  const TokensPage({super.key});

  @override
  Widget build(BuildContext context) {
    final RaThemeData theme = RaTheme.of(context);
    final RaColors c = theme.colors;
    final RaTypography t = theme.typography;
    final Map<String, Color> surfaces = <String, Color>{
      'surfaceWindow 窗口底': c.surfaceWindow,
      'surfaceCanvas 内容面板': c.surfaceCanvas,
      'surface 卡片 / 浮层': c.surface,
      'sunken 下沉面': c.sunken,
      'border 描边': c.border,
      'borderPopover 浮层描边': c.borderPopover,
    };
    final Map<String, Color> inks = <String, Color>{
      'ink 正文': c.ink,
      'ink2 次要文字': c.ink2,
      'ink3 弱文字': c.ink3,
      'accent 强调': c.accent,
      'accentHover 强调悬停': c.accentHover,
      'accentSoft 强调浅底': c.accentSoft,
    };
    final Map<String, Color> status = <String, Color>{
      'success 成功': c.success,
      'attention 注意': c.attention,
      'danger 危险': c.danger,
      'fillTranslucentHover 叠加 · 悬停': c.fillTranslucentHover,
      'fillTranslucentSelected 叠加 · 选中': c.fillTranslucentSelected,
      'fillTranslucentActive 叠加 · 按下': c.fillTranslucentActive,
    };
    final Map<String, TextStyle> type = <String, TextStyle>{
      'display 24 / 32 · 500': t.display,
      'title 15 / 22 · 600': t.title,
      'input 15 / 24 · 450': t.input,
      'bodyMedium 13 / 20 · 500': t.bodyMedium,
      'body 13 / 20 · 450': t.body,
      'caption 12 / 18 · 450': t.caption,
      'micro 11 / 18 · 450': t.micro,
      'mono 13 / 20': t.mono,
    };
    return GalleryPage(
      title: '设计变量',
      description:
          '三层结构：基础层（值）→ 语义层（用途，深色只在这里赋值）→ 组件层（各组件专用）。'
          '切换右上角的主题与品牌色，这一页的取值会随之变化。',
      sections: <GallerySection>[
        GallerySection(
          title: '表面与描边',
          child: _Swatches(colors: surfaces),
        ),
        GallerySection(
          title: '文字与强调',
          child: _Swatches(colors: inks),
        ),
        GallerySection(
          title: '状态与半透明叠加',
          description: '侧栏与标签栏上的悬停 / 选中 / 按下只用半透明叠加色。',
          child: _Swatches(colors: status),
        ),
        GallerySection(
          title: '字体角色',
          description: 'Inter（随包打包），中文回落苹方 / 微软雅黑 / Noto。',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: theme.spacing.lg,
            children: <Widget>[
              for (final MapEntry<String, TextStyle> e in type.entries)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    DemoCaption(e.key),
                    Text('桌面端 SaaS 界面 Desktop UI 0123', style: e.value.copyWith(color: c.ink)),
                  ],
                ),
            ],
          ),
        ),
        GallerySection(
          title: '间距与圆角',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: theme.spacing.sm,
            children: <Widget>[
              for (final (String, double) s in <(String, double)>[
                ('xs3', theme.spacing.xs3),
                ('xs2', theme.spacing.xs2),
                ('xs', theme.spacing.xs),
                ('sm', theme.spacing.sm),
                ('md', theme.spacing.md),
                ('lg', theme.spacing.lg),
                ('xl', theme.spacing.xl),
                ('xl2', theme.spacing.xl2),
                ('xl3', theme.spacing.xl3),
                ('xl4', theme.spacing.xl4),
              ])
                Row(
                  spacing: theme.spacing.lg,
                  children: <Widget>[
                    SizedBox(
                      width: GalleryLayout.of(context).swatchSize * 2,
                      child: DemoCaption('${s.$1} · ${s.$2.toInt()}'),
                    ),
                    Container(width: s.$2, height: theme.spacing.sm, color: c.accent),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Swatches extends StatelessWidget {
  const _Swatches({required this.colors});

  final Map<String, Color> colors;

  @override
  Widget build(BuildContext context) {
    final RaThemeData theme = RaTheme.of(context);
    final GalleryLayout layout = GalleryLayout.of(context);
    return Wrap(
      spacing: layout.demoGap,
      runSpacing: layout.demoGap,
      children: <Widget>[
        for (final MapEntry<String, Color> e in colors.entries)
          SizedBox(
            width: layout.swatchColumnWidth,
            child: Row(
              spacing: theme.spacing.md,
              children: <Widget>[
                Container(
                  width: layout.swatchSize,
                  height: layout.swatchSize,
                  decoration: BoxDecoration(
                    color: e.value,
                    borderRadius: BorderRadius.circular(theme.radii.md),
                    border: Border.all(
                      color: theme.colors.borderTranslucent,
                      width: RaHairline.snap(context, theme.sizing.borderWidth),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(e.key, style: theme.typography.body.copyWith(color: theme.colors.ink)),
                      DemoCaption(_hex(e.value)),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  static String _hex(Color color) {
    final int argb = color.toARGB32();
    final String rgb = (argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0');
    final int alpha = (argb >> 24) & 0xFF;
    return alpha == 0xFF ? '#$rgb' : '#$rgb · ${(alpha * 100 / 255).toStringAsFixed(1)}%';
  }
}
