import 'dart:convert';
import 'dart:io';
import 'dart:ui' show Rect;

import 'package:flutter_test/flutter_test.dart';
import 'package:orra_desktop_shell/orra_desktop_shell.dart';

void main() {
  group('RaWindowState.tryParse 校验格式', () {
    test('合法数据', () {
      expect(
        RaWindowState.tryParse(<String, Object>{
          'x': 10,
          'y': 20.5,
          'width': 1280,
          'height': 820,
          'maximized': true,
        }),
        const RaWindowState(x: 10, y: 20.5, width: 1280, height: 820, maximized: true),
      );
    });
    test('缺字段、类型错误、非有限数、非正尺寸都视为无效', () {
      expect(RaWindowState.tryParse(null), isNull);
      expect(RaWindowState.tryParse('x'), isNull);
      expect(RaWindowState.tryParse(<String, Object>{'x': 0, 'y': 0, 'width': 100}), isNull);
      expect(
        RaWindowState.tryParse(<String, Object>{'x': '0', 'y': 0, 'width': 100, 'height': 100}),
        isNull,
      );
      expect(
        RaWindowState.tryParse(<String, Object>{
          'x': double.nan,
          'y': 0,
          'width': 100,
          'height': 100,
        }),
        isNull,
      );
      expect(
        RaWindowState.tryParse(<String, Object>{'x': 0, 'y': 0, 'width': 0, 'height': 100}),
        isNull,
      );
      expect(
        RaWindowState.tryParse(<String, Object>{
          'x': 0,
          'y': 0,
          'width': 100,
          'height': 100,
          'maximized': 'yes',
        }),
        isNull,
      );
    });
  });

  group('显示器可见性', () {
    const Rect main = Rect.fromLTWH(0, 25, 1440, 875);
    const Rect external = Rect.fromLTWH(1440, 0, 2560, 1440);

    test('至少 100×50 落在某个显示器内才恢复', () {
      const RaWindowState onExternal = RaWindowState(x: 2000, y: 100, width: 1280, height: 820);
      expect(onExternal.isVisibleOn(<Rect>[main, external]), isTrue);
      // 外接显示器拔掉后不可见 → 回到默认尺寸。
      expect(onExternal.isVisibleOn(<Rect>[main]), isFalse);
      // 只露出 99px 宽不算可见。
      const RaWindowState edge = RaWindowState(x: 1341, y: 100, width: 800, height: 600);
      expect(edge.isVisibleOn(<Rect>[main]), isFalse);
      const RaWindowState justEnough = RaWindowState(x: 1340, y: 100, width: 800, height: 600);
      expect(justEnough.isVisibleOn(<Rect>[main]), isTrue);
    });

    test('尺寸不小于最小尺寸', () {
      const RaWindowState small = RaWindowState(x: 0, y: 0, width: 400, height: 300);
      final RaWindowState clamped = small.clampSize(900, 600);
      expect(clamped.width, 900);
      expect(clamped.height, 600);
    });
  });

  group('RaWindowStateStore', () {
    late Directory dir;
    setUp(() => dir = Directory.systemTemp.createTempSync('orra_window_state'));
    tearDown(() => dir.deleteSync(recursive: true));

    test('防抖写入：连续多次只写最后一次；flush 立即写入', () async {
      final File file = File('${dir.path}/state.json');
      final RaWindowStateStore store = RaWindowStateStore(
        file,
        debounce: const Duration(milliseconds: 50),
      );
      store.schedule(const RaWindowState(x: 1, y: 1, width: 900, height: 600));
      store.schedule(const RaWindowState(x: 2, y: 2, width: 1000, height: 700));
      expect(file.existsSync(), isFalse);
      await Future<void>.delayed(const Duration(milliseconds: 120));
      expect(await store.load(), const RaWindowState(x: 2, y: 2, width: 1000, height: 700));

      store.schedule(const RaWindowState(x: 3, y: 3, width: 1100, height: 800, maximized: true));
      await store.flush();
      final Object? json = jsonDecode(file.readAsStringSync());
      expect(RaWindowState.tryParse(json)?.maximized, isTrue);
      store.dispose();
    });

    test('文件损坏时返回 null', () async {
      final File file = File('${dir.path}/state.json')..writeAsStringSync('{not json');
      expect(await RaWindowStateStore(file).load(), isNull);
    });
  });
}
