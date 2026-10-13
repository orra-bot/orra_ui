import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../theme/theme.dart';
import '../tokens/components.dart';

/// 细滚动条：宽 8（滑块 4 + 两侧各 2）、半透明灰、胶囊形；
/// 鼠标在滚动区域内或正在滚动时显示，其余时间淡出。
class RaScrollbar extends StatefulWidget {
  const RaScrollbar({super.key, required this.child, this.controller});

  final Widget child;
  final ScrollController? controller;

  @override
  State<RaScrollbar> createState() => _RaScrollbarState();
}

class _RaScrollbarState extends State<RaScrollbar> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final RaScrollbarThemeData t = RaTheme.of(context).scrollbar;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: RawScrollbar(
        controller: widget.controller,
        thumbVisibility: _hovered,
        thickness: t.thickness,
        crossAxisMargin: t.margin,
        mainAxisMargin: t.margin,
        radius: Radius.circular(t.radius),
        thumbColor: t.thumbColor,
        fadeDuration: t.fadeDuration,
        timeToFade: t.timeToFade,
        child: widget.child,
      ),
    );
  }
}

/// 桌面滚动行为：细滚动条、无回弹拉伸效果；鼠标不能拖动内容滚动（与原生一致）。
class RaScrollBehavior extends ScrollBehavior {
  const RaScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const <PointerDeviceKind>{
    PointerDeviceKind.touch,
    PointerDeviceKind.stylus,
    PointerDeviceKind.invertedStylus,
    PointerDeviceKind.trackpad,
  };

  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    return RaScrollbar(controller: details.controller, child: child);
  }

  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) =>
      child;
}
