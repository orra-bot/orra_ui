import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orra_ui/orra_ui.dart';

import 'helpers.dart';

void main() {
  final RaThemeData theme = RaThemeData.light();

  group('RaCheckbox', () {
    testWidgets('14px box; tapping the label toggles; null shows mixed', (
      WidgetTester tester,
    ) async {
      bool? value = false;
      await pumpRa(
        tester,
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) => RaCheckbox(
            value: value,
            onChanged: (bool v) => setState(() => value = v),
            label: const Text('自动归档'),
          ),
        ),
      );
      final Finder box = find.byType(AnimatedContainer);
      expect(tester.getSize(box), const Size(14, 14));
      await tester.tap(find.text('自动归档'));
      await tester.pumpAndSettle();
      expect(value, isTrue);
      expect(
        (tester.widget<AnimatedContainer>(box).decoration! as BoxDecoration).color,
        theme.colors.accent,
      );

      value = null;
      await pumpRa(
        tester,
        RaCheckbox(value: value, onChanged: (bool v) => value = v, semanticLabel: '全选'),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('全选')),
        isSemantics(label: '全选', hasCheckedState: true, isCheckStateMixed: true),
      );
      await tester.tap(find.byType(RaCheckbox));
      expect(value, isTrue);
    });
  });

  group('RaSwitch', () {
    testWidgets('28×16 track; thumb moves to the end when on', (WidgetTester tester) async {
      bool value = false;
      await pumpRa(
        tester,
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) => RaSwitch(
            value: value,
            onChanged: (bool v) => setState(() => value = v),
            semanticLabel: '通知',
          ),
        ),
      );
      final Finder track = find.byType(RaAnimatedSurface);
      expect(tester.getSize(track), const Size(28, 16));
      final Finder thumb = find.descendant(of: track, matching: find.byType(Container));
      expect(tester.getTopLeft(thumb).dx - tester.getTopLeft(track).dx, 2);
      await tester.tap(find.byType(RaSwitch));
      await tester.pumpAndSettle();
      expect(value, isTrue);
      expect(tester.getTopRight(track).dx - tester.getTopRight(thumb).dx, 2);
    });
  });

  group('RaRadioGroup', () {
    testWidgets('tap selects; arrow keys move and select, skipping disabled', (
      WidgetTester tester,
    ) async {
      String value = 'a';
      await pumpRa(
        tester,
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) => RaRadioGroup<String>(
            value: value,
            onChanged: (String v) => setState(() => value = v),
            options: const <RaRadioOption<String>>[
              RaRadioOption<String>(value: 'a', label: '跟随系统'),
              RaRadioOption<String>(value: 'b', label: '浅色', enabled: false),
              RaRadioOption<String>(value: 'c', label: '深色'),
            ],
          ),
        ),
      );
      await tester.tap(find.text('深色'));
      await tester.pump();
      expect(value, 'c');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(value, 'a');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(value, 'c', reason: '跳过禁用项');
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump();
      expect(value, 'a');
    });
  });

  group('RaSelect', () {
    testWidgets('30 high trigger; picking an option closes the menu', (WidgetTester tester) async {
      String value = 'system';
      await pumpRa(
        tester,
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) => RaSelect<String>(
            value: value,
            onChanged: (String v) => setState(() => value = v),
            options: const <RaSelectOption<String>>[
              RaSelectOption<String>(value: 'system', label: '跟随系统'),
              RaSelectOption<String>(value: 'dark', label: '深色'),
            ],
          ),
        ),
      );
      expect(tester.getSize(find.byType(RaButton)).height, 30);
      await tester.tap(find.byType(RaButton));
      await tester.pumpAndSettle();
      expect(find.byType(RaMenuSurface), findsOneWidget);
      await tester.tap(find.text('深色'));
      await tester.pumpAndSettle();
      expect(value, 'dark');
      expect(find.byType(RaMenuSurface), findsNothing);
      expect(find.text('深色'), findsOneWidget);
    });

    testWidgets('placeholder when nothing is selected', (WidgetTester tester) async {
      await pumpRa(
        tester,
        RaSelect<int>(
          value: null,
          placeholder: '选择成员',
          onChanged: (_) {},
          options: const <RaSelectOption<int>>[RaSelectOption<int>(value: 1, label: '一')],
        ),
      );
      expect(find.text('选择成员'), findsOneWidget);
    });
  });

  group('RaTabs', () {
    testWidgets('32 high tabs; selected uses the selected overlay; arrows move', (
      WidgetTester tester,
    ) async {
      String value = 'overview';
      await pumpRa(
        tester,
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) => RaTabs<String>(
            value: value,
            onChanged: (String v) => setState(() => value = v),
            tabs: const <RaTab<String>>[
              RaTab<String>(value: 'overview', label: '概览'),
              RaTab<String>(value: 'runs', label: '运行记录'),
              RaTab<String>(value: 'settings', label: '设置'),
            ],
          ),
        ),
      );
      final Finder tabs = find.byType(RaAnimatedSurface);
      expect(tester.getSize(tabs.first).height, 32);
      expect(
        tester.widget<RaAnimatedSurface>(tabs.first).backgroundColor,
        theme.colors.fillTranslucentSelected,
      );
      // 横排，间距 2。
      expect(tester.getTopLeft(tabs.at(1)).dx - tester.getTopRight(tabs.first).dx, 2);

      await tester.tap(find.text('运行记录'));
      await tester.pump();
      expect(value, 'runs');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(value, 'settings');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(value, 'overview', reason: '首尾循环');
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      expect(value, 'settings');
    });

    testWidgets('withPanels builds only the current panel', (WidgetTester tester) async {
      await pumpRa(
        tester,
        SizedBox(
          width: 600,
          child: RaTabs.withPanels<int>(
            value: 1,
            onChanged: (_) {},
            tabs: const <RaTab<int>>[
              RaTab<int>(value: 0, label: 'A'),
              RaTab<int>(value: 1, label: 'B'),
            ],
            panelBuilder: (BuildContext context, int v) => Text('panel $v'),
          ),
        ),
      );
      expect(find.text('panel 1'), findsOneWidget);
      expect(find.text('panel 0'), findsNothing);
    });
  });

  group('RaSegmentedControl', () {
    testWidgets('26 high segments in a 2px sunken track; selected is raised', (
      WidgetTester tester,
    ) async {
      String value = 'chat';
      await pumpRa(
        tester,
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) => RaSegmentedControl<String>(
            semanticLabel: '模式',
            value: value,
            onChanged: (String v) => setState(() => value = v),
            segments: const <RaSegment<String>>[
              RaSegment<String>(value: 'chat', label: '对话'),
              RaSegment<String>(value: 'tune', label: '调整'),
            ],
          ),
        ),
      );
      final Finder segments = find.byType(RaAnimatedSurface);
      final Rect track = tester.getRect(find.byType(RaSegmentedControl<String>));
      expect(tester.getSize(segments.first).height, 26);
      expect(track.height, 30);
      expect(tester.getTopLeft(segments.first) - track.topLeft, const Offset(2, 2));
      await tester.pump();
      // 选中滑块：白底 + 淡阴影，与选中段重合。
      final Finder thumb = find.byType(AnimatedPositioned);
      final BoxDecoration thumbBox =
          tester
                  .widget<DecoratedBox>(
                    find.descendant(of: thumb, matching: find.byType(DecoratedBox)),
                  )
                  .decoration
              as BoxDecoration;
      expect(thumbBox.color, theme.colors.surface);
      expect(thumbBox.boxShadow, theme.shadows.raised);
      expect(tester.getRect(thumb), tester.getRect(segments.first));

      await tester.tap(find.text('调整'));
      await tester.pump();
      expect(value, 'tune');
      // 滑块从「对话」滑向「调整」：中途位于两者之间，结束时与「调整」重合。
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      final double midway = tester.getTopLeft(thumb).dx;
      expect(midway, greaterThan(tester.getTopLeft(segments.first).dx));
      expect(midway, lessThan(tester.getTopLeft(segments.at(1)).dx));
      await tester.pumpAndSettle();
      expect(tester.getRect(thumb), tester.getRect(segments.at(1)));
      // 再点当前段不会取消。
      await tester.tap(find.text('调整'));
      await tester.pump();
      expect(value, 'tune');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(value, 'chat');
    });
  });
}
