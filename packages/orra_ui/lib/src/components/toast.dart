import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../foundation/hairline.dart';
import '../foundation/localizations.dart';
import '../foundation/motion.dart';
import '../foundation/pressable.dart';
import '../foundation/surface.dart';
import '../icons/ra_icon.dart';
import '../theme/theme.dart';
import '../theme/theme_data.dart';
import '../tokens/components.dart';

enum RaToastType { success, error }

/// 一条提示。
@immutable
class RaToastEntry {
  RaToastEntry({required this.title, this.description, this.type = RaToastType.success})
    : id = _nextId++;

  static int _nextId = 0;

  final int id;
  final String title;
  final String? description;
  final RaToastType type;
}

/// 提示队列。由 [RaToastViewport]（RaApp 内置）持有；业务侧用 `RaToast.of(context)`。
class RaToastController extends ChangeNotifier {
  RaToastController({this.limit = 3});

  /// 同时显示的最多条数，超出时最早的一条被移除。
  final int limit;

  final List<RaToastEntry> _entries = <RaToastEntry>[];
  final Set<int> _closing = <int>{};

  List<RaToastEntry> get entries => List<RaToastEntry>.unmodifiable(_entries);

  bool isClosing(int id) => _closing.contains(id);

  RaToastEntry show(RaToastEntry entry) {
    _entries.add(entry);
    final int overflow =
        _entries.where((RaToastEntry e) => !_closing.contains(e.id)).length - limit;
    if (overflow > 0) {
      for (final RaToastEntry e in _entries.take(overflow)) {
        _closing.add(e.id);
      }
    }
    notifyListeners();
    return entry;
  }

  /// 成功提示。
  RaToastEntry success(String title, {String? description}) =>
      show(RaToastEntry(title: title, description: description));

  /// 错误提示（说清发生了什么与下一步）。
  RaToastEntry error(String title, {String? description}) =>
      show(RaToastEntry(title: title, description: description, type: RaToastType.error));

  /// 开始关闭（播放退场动画后移除）。
  void dismiss(int id) {
    if (_closing.add(id)) notifyListeners();
  }

  void _remove(int id) {
    _entries.removeWhere((RaToastEntry e) => e.id == id);
    _closing.remove(id);
    notifyListeners();
  }
}

/// 业务侧入口：`RaToast.of(context).success('已保存')`。
abstract final class RaToast {
  static RaToastController of(BuildContext context) {
    final _ToastScope? scope = context.getInheritedWidgetOfExactType<_ToastScope>();
    assert(scope != null, 'RaToast.of() 找不到 RaToastViewport：请使用 RaApp，或自行放置 RaToastViewport。');
    return scope!.controller;
  }
}

class _ToastScope extends InheritedWidget {
  const _ToastScope({required this.controller, required super.child});

  final RaToastController controller;

  @override
  bool updateShouldNotify(_ToastScope old) => controller != old.controller;
}

/// 提示视口：在 [child] 之上、窗口右下角渲染提示。RaApp 已内置。
class RaToastViewport extends StatefulWidget {
  const RaToastViewport({super.key, this.controller, required this.child});

  final RaToastController? controller;
  final Widget child;

  @override
  State<RaToastViewport> createState() => _RaToastViewportState();
}

class _RaToastViewportState extends State<RaToastViewport> {
  RaToastController? _own;
  RaToastController get _controller => widget.controller ?? (_own ??= RaToastController());

  /// 悬停在任意提示上时暂停所有计时。
  final ValueNotifier<bool> _paused = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _own?.dispose();
    _paused.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final RaThemeData theme = RaTheme.of(context);
    final RaToastThemeData t = theme.toast;
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double width = (screenWidth - t.viewportMargin * 2).clamp(0.0, t.width);
    return _ToastScope(
      controller: _controller,
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: widget.child),
          Positioned(
            right: t.viewportMargin,
            bottom: t.viewportMargin,
            width: width,
            child: MouseRegion(
              onEnter: (_) => _paused.value = true,
              onExit: (_) => _paused.value = false,
              child: ListenableBuilder(
                listenable: _controller,
                builder: (BuildContext context, _) {
                  final List<RaToastEntry> entries = _controller.entries;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      for (final RaToastEntry e in entries)
                        _ToastItem(
                          key: ValueKey<int>(e.id),
                          entry: e,
                          controller: _controller,
                          paused: _paused,
                          isLast: identical(e, entries.last),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToastItem extends StatefulWidget {
  const _ToastItem({
    super.key,
    required this.entry,
    required this.controller,
    required this.paused,
    required this.isLast,
  });

  final RaToastEntry entry;
  final RaToastController controller;
  final ValueListenable<bool> paused;
  final bool isLast;

  @override
  State<_ToastItem> createState() => _ToastItemState();
}

class _ToastItemState extends State<_ToastItem> with SingleTickerProviderStateMixin {
  late final AnimationController _animation = AnimationController(vsync: this);
  Timer? _timer;

  /// 剩余停留时间；悬停暂停时按单调时钟扣除已经过的时间。
  Duration? _remaining;
  final Stopwatch _running = Stopwatch();
  bool _removing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final RaToastThemeData t = RaTheme.of(context).toast;
    _animation.duration = RaReducedMotion.resolve(context, t.duration);
    if (_remaining == null) {
      _remaining = t.displayDuration;
      _animation.forward();
      _resume();
    }
  }

  @override
  void initState() {
    super.initState();
    widget.paused.addListener(_onPausedChanged);
    widget.controller.addListener(_onControllerChanged);
  }

  void _onPausedChanged() {
    if (widget.paused.value) {
      _pause();
    } else {
      _resume();
    }
  }

  void _onControllerChanged() {
    if (!_removing && widget.controller.isClosing(widget.entry.id)) _close();
  }

  void _resume() {
    if (_removing || widget.paused.value || _timer != null) return;
    _running
      ..reset()
      ..start();
    _timer = Timer(_remaining!, () => widget.controller.dismiss(widget.entry.id));
  }

  void _pause() {
    if (_timer == null) return;
    _timer!.cancel();
    _timer = null;
    _running.stop();
    final Duration left = _remaining! - _running.elapsed;
    _remaining = left.isNegative ? Duration.zero : left;
  }

  Future<void> _close() async {
    _removing = true;
    _timer?.cancel();
    _timer = null;
    await _animation.reverse();
    if (mounted) widget.controller._remove(widget.entry.id);
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.paused.removeListener(_onPausedChanged);
    widget.controller.removeListener(_onControllerChanged);
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final RaThemeData theme = RaTheme.of(context);
    final RaToastThemeData t = theme.toast;
    final bool error = widget.entry.type == RaToastType.error;
    final Widget toast = DecoratedBox(
      decoration: BoxDecoration(
        color: t.backgroundColor,
        borderRadius: BorderRadius.circular(t.radius),
        border: Border.all(
          color: t.borderColor,
          width: RaHairline.snap(context, theme.sizing.borderWidth),
        ),
        boxShadow: t.shadows,
      ),
      child: Padding(
        padding: EdgeInsets.all(t.padding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: t.gap,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: t.iconTopOffset),
              child: RaIcon.glyph(
                error ? theme.icons.circleX : theme.icons.circleCheck,
                size: t.iconSize,
                color: error ? t.errorColor : t.successColor,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: t.contentGap,
                children: <Widget>[
                  Text(widget.entry.title, style: t.titleStyle),
                  if (widget.entry.description != null)
                    Text(widget.entry.description!, style: t.descriptionStyle),
                ],
              ),
            ),
            _ToastClose(onPressed: () => widget.controller.dismiss(widget.entry.id), theme: theme),
          ],
        ),
      ),
    );
    final Widget live = Semantics(
      liveRegion: true,
      container: true,
      child: Padding(
        padding: EdgeInsets.only(bottom: widget.isLast ? 0 : t.stackGap),
        child: toast,
      ),
    );
    return SizeTransition(
      sizeFactor: _animation,
      alignment: Alignment.bottomCenter,
      child: FadeTransition(
        opacity: _animation,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (BuildContext context, Widget? child) => Transform.translate(
            offset: Offset(0, t.enterOffset * (1 - _animation.value)),
            child: child,
          ),
          child: live,
        ),
      ),
    );
  }
}

class _ToastClose extends StatelessWidget {
  const _ToastClose({required this.onPressed, required this.theme});

  final VoidCallback onPressed;
  final RaThemeData theme;

  @override
  Widget build(BuildContext context) {
    final RaToastThemeData t = theme.toast;
    return RaPressable(
      onPressed: onPressed,
      semanticLabel: RaLocalizations.of(context).dismissNotification,
      canRequestFocus: true,
      builder: (BuildContext context, RaPressState state) => RaAnimatedSurface(
        duration: state.transition,
        foregroundColor: state.hovered ? t.closeHoverColor : t.closeColor,
        radius: t.closeRadius,
        constraints: BoxConstraints.tight(Size.square(t.closeSize)),
        alignment: Alignment.center,
        child: RaIcon.glyph(theme.icons.close, size: t.closeIconSize),
      ),
    );
  }
}
