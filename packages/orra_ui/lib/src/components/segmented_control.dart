import 'package:flutter/widgets.dart';

import '../foundation/motion.dart';
import '../foundation/pressable.dart';
import '../foundation/roving_focus.dart';
import '../foundation/surface.dart';
import '../theme/theme.dart';
import '../theme/theme_data.dart';
import '../tokens/components.dart';

/// 分段切换的一段。
@immutable
class RaSegment<T> {
  const RaSegment({required this.value, required this.label, this.icon, this.enabled = true});

  final T value;
  final String label;
  final Widget? icon;
  final bool enabled;
}

/// 分段切换（Base UI ToggleGroup，单选）：模式切换，如「对话 | 调整」。
///
/// 选中滑块在段之间滑动（减弱动效时直接跳过去）。
/// 再次点击当前段不会取消选中。键盘：← → 移动并选中，Home / End 跳到首尾。
class RaSegmentedControl<T> extends StatefulWidget {
  const RaSegmentedControl({
    super.key,
    required this.segments,
    required this.value,
    required this.onChanged,
    required this.semanticLabel,
  });

  final List<RaSegment<T>> segments;
  final T value;
  final ValueChanged<T>? onChanged;

  /// 整组的无障碍名称（例如「模式」）。
  final String semanticLabel;

  @override
  State<RaSegmentedControl<T>> createState() => _RaSegmentedControlState<T>();
}

class _RaSegmentedControlState<T> extends State<RaSegmentedControl<T>> {
  final List<FocusNode> _nodes = <FocusNode>[];
  final List<GlobalKey> _keys = <GlobalKey>[];
  final GlobalKey _rowKey = GlobalKey();

  /// 选中段相对于段落行的位置（布局后测得）；为空表示还没测量，先不画滑块。
  Rect? _thumb;

  /// 第一次测得位置时不做动画。
  bool _animateThumb = false;

  void _syncNodes() {
    while (_nodes.length < widget.segments.length) {
      _nodes.add(FocusNode(debugLabel: 'RaSegment ${_nodes.length}'));
      _keys.add(GlobalKey());
    }
    while (_nodes.length > widget.segments.length) {
      _nodes.removeLast().dispose();
      _keys.removeLast();
    }
  }

  /// 布局完成后测量选中段的位置，变化时移动滑块。
  void _measureThumb() {
    if (!mounted) return;
    final int index = widget.segments.indexWhere((RaSegment<T> s) => s.value == widget.value);
    final RenderBox? row = _rowKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? box = index < 0
        ? null
        : _keys[index].currentContext?.findRenderObject() as RenderBox?;
    final Rect? next = row == null || box == null || !box.hasSize
        ? null
        : box.localToGlobal(Offset.zero, ancestor: row) & box.size;
    if (next == _thumb) return;
    setState(() {
      _animateThumb = _thumb != null && next != null;
      _thumb = next;
    });
  }

  @override
  void dispose() {
    for (final FocusNode node in _nodes) {
      node.dispose();
    }
    super.dispose();
  }

  bool _enabled(int i) => widget.onChanged != null && widget.segments[i].enabled;

  int _currentIndex() {
    final int focused = _nodes.indexWhere((FocusNode n) => n.hasPrimaryFocus);
    if (focused >= 0) return focused;
    return widget.segments.indexWhere((RaSegment<T> s) => s.value == widget.value);
  }

  void _select(int index) {
    final T value = widget.segments[index].value;
    if (value != widget.value) widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    _syncNodes();
    final RaThemeData theme = RaTheme.of(context);
    final RaSegmentedControlThemeData s = theme.segmentedControl;
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureThumb());
    final Rect? thumb = _thumb;
    return Semantics(
      container: true,
      label: widget.semanticLabel,
      explicitChildNodes: true,
      child: RaRovingGroup(
        axis: Axis.horizontal,
        count: widget.segments.length,
        currentIndex: _currentIndex,
        isEnabled: _enabled,
        onMove: (int i) {
          _nodes[i].requestFocus();
          _select(i);
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: s.backgroundColor,
            borderRadius: BorderRadius.circular(s.radius),
          ),
          child: Padding(
            padding: EdgeInsets.all(s.padding),
            child: Stack(
              children: <Widget>[
                if (thumb != null)
                  AnimatedPositioned.fromRect(
                    rect: thumb,
                    duration: _animateThumb
                        ? RaReducedMotion.resolve(context, s.thumbDuration)
                        : Duration.zero,
                    curve: s.thumbCurve,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: s.selectedBackgroundColor,
                        borderRadius: BorderRadius.circular(s.itemRadius),
                        boxShadow: s.selectedShadows,
                      ),
                    ),
                  ),
                Row(
                  key: _rowKey,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    for (int i = 0; i < widget.segments.length; i++)
                      KeyedSubtree(
                        key: _keys[i],
                        child: _segment(context, widget.segments[i], i, s, theme, thumb == null),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _segment(
    BuildContext context,
    RaSegment<T> segment,
    int index,
    RaSegmentedControlThemeData s,
    RaThemeData theme,
    bool paintSelected,
  ) {
    final bool selected = segment.value == widget.value;
    return RaPressable(
      onPressed: _enabled(index)
          ? () {
              _nodes[index].requestFocus();
              _select(index);
            }
          : null,
      selected: selected,
      focusNode: _nodes[index],
      semanticsInMutuallyExclusiveGroup: true,
      semanticsChecked: selected,
      semanticLabel: segment.label,
      excludeSemantics: true,
      builder: (BuildContext context, RaPressState state) {
        final Color foreground = state.disabled
            ? s.disabledColor
            : selected
            ? s.selectedColor
            : state.hovered
            ? s.hoverColor
            : s.color;
        return RaAnimatedSurface(
          duration: state.transition,
          // 滑块测量好之前（首帧），由选中段自己画底色。
          backgroundColor: selected && paintSelected ? s.selectedBackgroundColor : null,
          foregroundColor: foreground,
          textStyle: selected ? s.selectedTextStyle : s.textStyle,
          iconSize: theme.sizing.iconSm,
          radius: s.itemRadius,
          shadows: selected && paintSelected ? s.selectedShadows : null,
          constraints: BoxConstraints.tightFor(height: s.itemHeight),
          padding: EdgeInsets.symmetric(horizontal: s.itemPaddingX),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: theme.spacing.xs,
            children: <Widget>[?segment.icon, Text(segment.label, maxLines: 1, softWrap: false)],
          ),
        );
      },
    );
  }
}
