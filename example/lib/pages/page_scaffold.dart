import 'package:flutter/widgets.dart';
import 'package:orra_ui/orra_ui.dart';

import '../gallery_layout.dart';

/// 展示页：居中、最宽 820，标题 + 说明 + 若干小节。
class GalleryPage extends StatelessWidget {
  const GalleryPage({
    super.key,
    required this.title,
    required this.description,
    required this.sections,
  });

  final String title;
  final String description;
  final List<GallerySection> sections;

  @override
  Widget build(BuildContext context) {
    final RaThemeData theme = RaTheme.of(context);
    final GalleryLayout layout = GalleryLayout.of(context);
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: layout.pageMaxWidth),
          child: Padding(
            padding: layout.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(title, style: theme.typography.display.copyWith(color: theme.colors.ink)),
                SizedBox(height: layout.pageTitleGap),
                Text(description, style: theme.typography.body.copyWith(color: theme.colors.ink2)),
                for (final GallerySection section in sections) ...<Widget>[
                  SizedBox(height: layout.sectionGap),
                  section,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 一个小节：标题、说明、演示区（白底卡片）。
class GallerySection extends StatelessWidget {
  const GallerySection({super.key, required this.title, this.description, required this.child});

  final String title;
  final String? description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final RaThemeData theme = RaTheme.of(context);
    final GalleryLayout layout = GalleryLayout.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(title, style: theme.typography.title.copyWith(color: theme.colors.ink)),
        if (description != null) ...<Widget>[
          SizedBox(height: theme.spacing.xs2),
          Text(description!, style: theme.typography.body.copyWith(color: theme.colors.ink2)),
        ],
        SizedBox(height: layout.sectionHeadGap),
        DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colors.surface,
            borderRadius: BorderRadius.circular(layout.demoRadius),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: theme.colors.borderTranslucent,
                spreadRadius: RaHairline.snap(context, theme.sizing.borderWidth),
              ),
              ...theme.shadows.raised,
            ],
          ),
          child: Padding(padding: layout.demoPadding, child: child),
        ),
      ],
    );
  }
}

/// 演示区内横向排列、可换行。
class DemoWrap extends StatelessWidget {
  const DemoWrap({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final GalleryLayout layout = GalleryLayout.of(context);
    return Wrap(
      spacing: layout.demoGap,
      runSpacing: layout.demoGap,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }
}

/// 演示区内的说明文字（12px 弱色）。
class DemoCaption extends StatelessWidget {
  const DemoCaption(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final RaThemeData theme = RaTheme.of(context);
    return Text(text, style: theme.typography.caption.copyWith(color: theme.colors.ink3));
  }
}
