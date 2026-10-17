import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orra_desktop_shell/orra_desktop_shell.dart';
import 'package:orra_ui/orra_ui.dart';

import 'fake_window.dart';

const ValueKey<String> kToggle = ValueKey<String>('ra-sidebar-toggle');
const ValueKey<String> kBack = ValueKey<String>('ra-back');
const ValueKey<String> kForward = ValueKey<String>('ra-forward');
const ValueKey<String> kPanel = ValueKey<String>('ra-panel');
const ValueKey<String> kShell = ValueKey<String>('ra-sidebar-shell');
const ValueKey<String> kTitlebar = ValueKey<String>('ra-titlebar');

/// 让 RaApp 的 home 打开时 frame 能随 sidebarOpen 变化重建。
class _Host extends StatefulWidget {
  const _Host({required this.window, this.reduceMotion = false});

  final FakeWindow window;
  final bool reduceMotion;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  bool open = true;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: widget.reduceMotion),
      child: RaWindowScope(
        controller: widget.window,
        child: RaDesktopFrame(
          sidebarOpen: open,
          onToggleSidebar: () => setState(() => open = !open),
          sidebar: Column(
            children: <Widget>[
              RaSidebarItem(label: 'Inbox', onPressed: () {}, selected: true),
              RaSidebarItem(label: 'Archive', onPressed: () {}),
            ],
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

Future<void> pumpHost(WidgetTester tester, {bool reduceMotion = false}) async {
  tester.view.devicePixelRatio = 2;
  tester.view.physicalSize = const Size(1280, 820) * 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    RaApp(
      themeMode: RaThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: _Host(window: FakeWindow(), reduceMotion: reduceMotion),
    ),
  );
}

void main() {
  group('标题栏几何（macOS）', () {
    testWidgets('窗口按钮中心与标题栏中线 22 对齐，面板顶边在 44', (WidgetTester tester) async {
      await pumpFrame(tester);
      expect(tester.getSize(find.byKey(kTitlebar)).height, 44);
      for (final ValueKey<String> key in <ValueKey<String>>[kToggle, kBack, kForward]) {
        expect(tester.getCenter(find.byKey(key)).dy, 22, reason: '$key');
        expect(tester.getSize(find.byKey(key)), const Size(28, 28));
      }
      expect(tester.getTopLeft(find.byKey(kPanel)).dy, 44);
    }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

    testWidgets('macOS 窗口按钮组紧跟红绿灯：左缘 84；展开时右缘对齐侧栏内容右缘', (WidgetTester tester) async {
      await pumpFrame(tester);
      expect(tester.getTopLeft(find.byKey(kToggle)).dx, 84);
      // 侧栏宽 238 - 右内边距 12 = 226。
      expect(tester.getTopRight(find.byKey(kForward)).dx, 226);
      expect(find.byType(RaWindowCaptionButtons), findsNothing);
    }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

    testWidgets('内容面板距窗口右 / 下 8，左缘 = 侧栏宽 238', (WidgetTester tester) async {
      await pumpFrame(tester);
      final Rect panel = tester.getRect(find.byKey(kPanel));
      expect(panel.left, 238);
      expect(panel.right, 1280 - 8);
      expect(panel.bottom, 820 - 8);
    }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));
  });

  group('Windows / Linux', () {
    for (final TargetPlatform platform in <TargetPlatform>[
      TargetPlatform.windows,
      TargetPlatform.linux,
    ]) {
      testWidgets('$platform：窗口按钮组左缘 12，右上角有最小化 / 最大化 / 关闭', (WidgetTester tester) async {
        final FakeWindow window = await pumpFrame(tester);
        expect(tester.getTopLeft(find.byKey(kToggle)).dx, 12);
        expect(find.byType(RaWindowCaptionButtons), findsOneWidget);
        final Rect caption = tester.getRect(find.byType(RaWindowCaptionButtons));
        expect(caption.right, 1280);
        expect(caption.height, 44);
        expect(caption.width, 46 * 3);

        await tester.tapAt(caption.centerRight - const Offset(23, 0));
        await tester.pump();
        expect(window.closes, 1);
        await tester.tapAt(caption.centerLeft + const Offset(23, 0));
        await tester.pump();
        expect(window.minimizes, 1);
        await tester.tapAt(caption.center);
        await tester.pump();
        expect(window.maximizeToggles, 1);
        await tester.pump(const Duration(seconds: 1));
      }, variant: TargetPlatformVariant.only(platform));
    }
  });

  group('侧栏开合', () {
    testWidgets('宽度逐帧连续、单调、有中间帧；收起后隐藏、面板左间隙 8、开关位置不变', (WidgetTester tester) async {
      await pumpHost(tester);
      final Offset toggleBefore = tester.getTopLeft(find.byKey(kToggle));
      await tester.tap(find.byKey(kToggle));
      final List<double> widths = <double>[];
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        widths.add(tester.getSize(find.byKey(kShell)).width);
      }
      await tester.pumpAndSettle();
      widths.add(tester.getSize(find.byKey(kShell)).width);
      expect(widths.last, 8);
      expect(widths.where((double w) => w > 8 && w < 238), isNotEmpty, reason: '应有中间帧');
      for (int i = 1; i < widths.length; i++) {
        expect(widths[i], lessThanOrEqualTo(widths[i - 1]), reason: '收起应单调');
      }
      expect(tester.getRect(find.byKey(kPanel)).left, 8);
      expect(tester.getTopLeft(find.byKey(kToggle)), toggleBefore);

      // 收起后侧栏不可见、不可点击。
      final Visibility visibility = tester.widget<Visibility>(
        find.ancestor(
          of: find.byKey(const ValueKey<String>('ra-sidebar')),
          matching: find.byType(Visibility),
        ),
      );
      expect(visibility.visible, isFalse);
      expect(find.text('Inbox').hitTestable(), findsNothing);

      // 标题栏内容紧跟窗口按钮组：84 + 88 + 12。
      expect(tester.getTopRight(find.byKey(kForward)).dx, 84 + 88);

      // 展开时立即可见。
      await tester.tap(find.byKey(kToggle));
      await tester.pump(const Duration(milliseconds: 16));
      final Visibility opening = tester.widget<Visibility>(
        find.ancestor(
          of: find.byKey(const ValueKey<String>('ra-sidebar')),
          matching: find.byType(Visibility),
        ),
      );
      expect(opening.visible, isTrue);
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byKey(kShell)).width, 238);
    }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

    testWidgets('展开与收起都是先快后慢（缓动按时间正向套用）', (WidgetTester tester) async {
      await pumpHost(tester);
      double width() => tester.getSize(find.byKey(kShell)).width;

      Future<void> expectFastThenSlow() async {
        final double start = width();
        await tester.tap(find.byKey(kToggle));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 150));
        final double half = width();
        await tester.pumpAndSettle();
        final double end = width();
        final double firstHalf = (half - start).abs();
        final double secondHalf = (end - half).abs();
        expect(
          firstHalf,
          greaterThan(secondHalf * 3),
          reason: '前 150ms 走了 $firstHalf，后 150ms 走了 $secondHalf',
        );
      }

      await expectFastThenSlow(); // 收起
      expect(width(), 8);
      await expectFastThenSlow(); // 展开
      expect(width(), 238);
    }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

    testWidgets('中途反向时从当前位置连续过渡，不跳变', (WidgetTester tester) async {
      await pumpHost(tester);
      double width() => tester.getSize(find.byKey(kShell)).width;
      await tester.tap(find.byKey(kToggle));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      final double beforeReverse = width();
      expect(beforeReverse, inExclusiveRange(8, 238));

      await tester.tap(find.byKey(kToggle));
      await tester.pump();
      expect((width() - beforeReverse).abs(), lessThan(1), reason: '反向瞬间不应跳变');
      double previous = width();
      for (int i = 0; i < 25; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        final double w = width();
        expect(w, greaterThanOrEqualTo(previous), reason: '反向后应单调展开');
        previous = w;
      }
      await tester.pumpAndSettle();
      expect(width(), 238);
    }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

    testWidgets('减弱动态效果时没有中间帧', (WidgetTester tester) async {
      await pumpHost(tester, reduceMotion: true);
      await tester.tap(find.byKey(kToggle));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      expect(tester.getSize(find.byKey(kShell)).width, 8);
    }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

    testWidgets('内部侧栏保持 238 宽被裁切而不是重排', (WidgetTester tester) async {
      await pumpHost(tester);
      await tester.tap(find.byKey(kToggle));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.getSize(find.byKey(const ValueKey<String>('ra-sidebar'))).width, 238);
      await tester.pumpAndSettle();
    }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));
  });

  group('侧栏填充只用半透明叠加色', () {
    List<Color> sidebarFills(WidgetTester tester) {
      final Finder roots = find.byKey(const ValueKey<String>('ra-sidebar'));
      final List<Color> colors = <Color>[];
      for (final Element e
          in find.descendant(of: roots, matching: find.byType(DecoratedBox)).evaluate()) {
        final Decoration d = (e.widget as DecoratedBox).decoration;
        if (d is BoxDecoration && d.color != null && d.color!.a > 0) colors.add(d.color!);
      }
      return colors;
    }

    for (final RaThemeMode mode in <RaThemeMode>[RaThemeMode.light, RaThemeMode.dark]) {
      testWidgets('$mode：空闲 / 悬停 / 选中 / 按下都无不透明实色，且确有半透明填充', (WidgetTester tester) async {
        await pumpFrame(
          tester,
          mode: mode,
          sidebar: Column(
            children: <Widget>[
              RaSidebarItem(label: 'Selected', onPressed: () {}, selected: true),
              RaSidebarItem(label: 'Hover', onPressed: () {}),
              RaSidebarItem(label: 'Press', onPressed: () {}),
            ],
          ),
        );
        final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await mouse.addPointer(location: tester.getCenter(find.text('Hover')));
        await tester.pump();
        final TestGesture press = await tester.startGesture(tester.getCenter(find.text('Press')));
        await tester.pump(const Duration(milliseconds: 200));
        await tester.pump(const Duration(milliseconds: 150));

        final List<Color> fills = sidebarFills(tester);
        expect(fills.length, greaterThanOrEqualTo(3));
        for (final Color c in fills) {
          expect(c.a, lessThan(1), reason: '侧栏不得出现不透明实色：$c');
        }
        await press.up();
        await mouse.removePointer();
        await tester.pumpAndSettle();
      }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));
    }

    testWidgets('窗口按钮悬停 / 按下不铺底色', (WidgetTester tester) async {
      await pumpFrame(tester);
      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: tester.getCenter(find.byKey(kBack)));
      await tester.pump();
      final BoxDecoration? d = tester
          .widgetList<DecoratedBox>(
            find.descendant(of: find.byKey(kBack), matching: find.byType(DecoratedBox)),
          )
          .map((DecoratedBox b) => b.decoration)
          .whereType<BoxDecoration>()
          .firstOrNull;
      expect(d?.color?.a ?? 0, 0);
      await mouse.removePointer();
      await tester.pump(const Duration(seconds: 1));
    }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));
  });

  group('窗口底色与拖动', () {
    testWidgets('窗口底色与 chrome 一致（浅 #efeff0 / 深 #09090a）', (WidgetTester tester) async {
      final FakeWindow light = await pumpFrame(tester);
      expect(light.backgrounds.last, const Color(0xFFEFEFF0));
      final FakeWindow dark = await pumpFrame(tester, mode: RaThemeMode.dark, window: FakeWindow());
      expect(dark.backgrounds.last, const Color(0xFF09090A));
    }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

    testWidgets('标题栏空白处拖动窗口、双击最大化；从按钮上开始的拖动不移动窗口', (WidgetTester tester) async {
      final FakeWindow window = await pumpFrame(tester);
      final Offset empty = tester.getRect(find.byKey(kTitlebar)).center + const Offset(200, 0);
      await tester.dragFrom(empty, const Offset(40, 10));
      await tester.pump();
      expect(window.drags, 1);

      await tester.dragFrom(tester.getCenter(find.byKey(kBack)), const Offset(40, 10));
      await tester.pump();
      expect(window.drags, 1);

      await tester.tapAt(empty);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tapAt(empty);
      await tester.pump();
      expect(window.maximizeToggles, 1);
      await tester.pump(const Duration(seconds: 1));
    }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

    testWidgets('标题栏按钮点击立即生效（拖动区不延迟单击）', (WidgetTester tester) async {
      int toggles = 0;
      await pumpFrame(tester, onToggle: () => toggles++);
      await tester.tap(find.byKey(kToggle));
      await tester.pump();
      expect(toggles, 1);
      await tester.pump(const Duration(seconds: 1));
    }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

    testWidgets('面板顶栏：44 高、可拖动、三段中间居中', (WidgetTester tester) async {
      final FakeWindow window = await pumpFrame(
        tester,
        child: const Column(
          children: <Widget>[
            RaPanelHeader(
              leading: RaPanelTitle('Inbox'),
              center: Text('CENTER'),
              trailing: Text('trailing-wide-content'),
              bordered: true,
            ),
            Expanded(child: SizedBox.expand()),
          ],
        ),
      );
      final Rect header = tester.getRect(find.byType(RaPanelHeader));
      expect(header.height, 44);
      final Rect panel = tester.getRect(find.byKey(kPanel));
      expect(tester.getCenter(find.text('CENTER')).dx, closeTo(panel.center.dx, 1));
      await tester.dragFrom(header.center + const Offset(100, 0), const Offset(30, 0));
      await tester.pump();
      expect(window.drags, 1);
    }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));
  });
}
