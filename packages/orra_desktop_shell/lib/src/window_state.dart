import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' show Rect;

import 'package:flutter/foundation.dart';

/// 保存的窗口位置与尺寸。
@immutable
class RaWindowState {
  const RaWindowState({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.maximized = false,
  });

  final double x;
  final double y;
  final double width;
  final double height;
  final bool maximized;

  Rect get bounds => Rect.fromLTWH(x, y, width, height);

  Map<String, Object> toJson() => <String, Object>{
    'x': x,
    'y': y,
    'width': width,
    'height': height,
    'maximized': maximized,
  };

  /// 解析并校验；格式不对时返回 null（回到默认尺寸）。
  static RaWindowState? tryParse(Object? json) {
    if (json is! Map) return null;
    double? number(String key) {
      final Object? v = json[key];
      if (v is! num) return null;
      final double d = v.toDouble();
      return d.isFinite ? d : null;
    }

    final double? x = number('x');
    final double? y = number('y');
    final double? width = number('width');
    final double? height = number('height');
    final Object? maximized = json['maximized'];
    if (x == null || y == null || width == null || height == null) return null;
    if (width <= 0 || height <= 0) return null;
    if (maximized != null && maximized is! bool) return null;
    return RaWindowState(x: x, y: y, width: width, height: height, maximized: maximized == true);
  }

  /// 窗口至少有 [minVisible]（默认 100×50）落在某个显示器的可用区域内。
  bool isVisibleOn(
    Iterable<Rect> displays, {
    double minVisibleWidth = 100,
    double minVisibleHeight = 50,
  }) {
    for (final Rect display in displays) {
      final Rect overlap = bounds.intersect(display);
      if (overlap.width >= minVisibleWidth && overlap.height >= minVisibleHeight) return true;
    }
    return false;
  }

  /// 尺寸不小于 [minWidth] × [minHeight]。
  RaWindowState clampSize(double minWidth, double minHeight) => RaWindowState(
    x: x,
    y: y,
    width: width < minWidth ? minWidth : width,
    height: height < minHeight ? minHeight : height,
    maximized: maximized,
  );

  @override
  bool operator ==(Object other) =>
      other is RaWindowState &&
      other.x == x &&
      other.y == y &&
      other.width == width &&
      other.height == height &&
      other.maximized == maximized;

  @override
  int get hashCode => Object.hash(x, y, width, height, maximized);

  @override
  String toString() => 'RaWindowState($x, $y, $width × $height, maximized: $maximized)';
}

/// 把窗口状态存成 JSON 文件；写入防抖。
class RaWindowStateStore {
  RaWindowStateStore(this.file, {this.debounce = const Duration(milliseconds: 400)});

  final File file;

  /// 调整大小 / 移动时的写入防抖。
  final Duration debounce;
  Timer? _timer;
  RaWindowState? _pending;

  Future<RaWindowState?> load() async {
    try {
      if (!await file.exists()) return null;
      return RaWindowState.tryParse(jsonDecode(await file.readAsString()));
    } on FormatException {
      return null;
    } on FileSystemException {
      return null;
    }
  }

  /// 防抖写入。
  void schedule(RaWindowState state) {
    _pending = state;
    _timer?.cancel();
    _timer = Timer(debounce, flush);
  }

  /// 立即写入（关闭窗口时）。
  Future<void> flush() async {
    _timer?.cancel();
    _timer = null;
    final RaWindowState? state = _pending;
    _pending = null;
    if (state == null) return;
    await save(state);
  }

  Future<void> save(RaWindowState state) async {
    try {
      await file.parent.create(recursive: true);
      await file.writeAsString(jsonEncode(state.toJson()));
    } on FileSystemException {
      // 写入失败不影响使用。
    }
  }

  void dispose() => _timer?.cancel();
}
