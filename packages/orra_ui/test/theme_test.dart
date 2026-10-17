import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orra_ui/orra_ui.dart';

class _AppTokens extends RaThemeExtension {
  const _AppTokens(this.width);
  final double width;
}

void main() {
  group('semantic colors', () {
    test('light matches the Linear table', () {
      final RaColors c = RaThemeData.light().colors;
      expect(c.ground, const Color(0xFFEFEFF0));
      expect(c.surfaceWindow, const Color(0xFFEFEFF0));
      expect(c.surfaceCanvas, const Color(0xFFF9F9FA));
      expect(c.surface, const Color(0xFFFFFFFF));
      expect(c.ink, const Color(0xFF1B1B1B));
      expect(c.ink2, const Color(0xFF5C5C5E));
      expect(c.ink3, const Color(0xFF9C9D9F));
      expect(c.border, const Color(0xFFE2E2E2));
      expect(c.borderPopover, const Color(0xFFE8E8E8));
      expect(c.accent, const Color(0xFF6D78D5));
      expect(c.accentHover, const Color(0xFF5E6AC1));
      expect(c.fillTranslucentHover, const Color(0x09000000));
      expect(c.fillTranslucentSelected, const Color(0x0F000000));
      expect(c.fillTranslucentActive, const Color(0x14000000));
      expect(c.danger, const Color(0xFFC0322B));
    });

    test('dark is separately chosen', () {
      final RaThemeData dark = RaThemeData.dark();
      final RaColors c = dark.colors;
      expect(dark.brightness, Brightness.dark);
      expect(c.ground, const Color(0xFF09090A));
      expect(c.surfaceCanvas, const Color(0xFF121213));
      expect(c.surface, const Color(0xFF19191B));
      expect(c.ink, const Color(0xFFF7F8F8));
      expect(c.accent, const Color(0xFF7A84E0));
      expect(c.accentHover, const Color(0xFF8F98EA));
      expect(c.fillTranslucentHover, const Color(0x0AFFFFFF));
      expect(c.fillTranslucentSelected, const Color(0x14FFFFFF));
      expect(dark.chrome.chrome, const Color(0xFF09090A));
    });
  });

  test('chrome tokens derive from semantic layer', () {
    final RaThemeData t = RaThemeData.light();
    expect(t.chrome.chrome, t.colors.surfaceWindow);
    expect(t.chrome.chromeHover, t.colors.fillTranslucentHover);
    expect(t.chrome.canvas, t.colors.surfaceCanvas);
  });

  test('copyWith(colors) re-derives non-overridden component themes', () {
    const Color brand = Color(0xFF0E7C66);
    final RaThemeData base = RaThemeData.light();
    final RaMenuThemeData customMenu = RaMenuThemeData.fallback(base.tokens);
    final RaThemeData withMenu = base.copyWith(menu: customMenu);
    final RaThemeData branded = withMenu.copyWith(colors: base.colors.copyWith(accent: brand));
    final Color? primaryBg = branded.button
        .resolve(RaButtonVariant.primary, RaButtonSize.md)
        .backgroundColor!
        .resolve(<WidgetState>{});
    expect(primaryBg, brand);
    expect(branded.field.borderColor.resolve(<WidgetState>{WidgetState.focused}), brand);
    // 显式覆盖的组件主题保持不变。
    expect(identical(branded.menu, customMenu), isTrue);
    expect(branded.menu.checkColor, base.colors.accent);
  });

  test('extension falls back when not registered', () {
    final RaThemeData plain = RaThemeData.light();
    expect(plain.extension<_AppTokens>((_) => const _AppTokens(1)).width, 1);
    final RaThemeData registered = RaThemeData.light(
      extensions: const <RaThemeExtension>[_AppTokens(42)],
    );
    expect(registered.extension<_AppTokens>((_) => const _AppTokens(1)).width, 42);
  });

  test('typography uses pixel line heights', () {
    final TextStyle body = RaThemeData.light().typography.body;
    expect(body.fontSize, 13);
    expect(body.height! * body.fontSize!, closeTo(20, 1e-9));
    expect(body.fontWeight, const FontWeight(450));
  });

  test('hairline snaps to physical pixels', () {
    expect(RaHairline.snapFor(0.5, 2), 0.5);
    expect(RaHairline.snapFor(0.5, 1), 1);
    expect(RaHairline.snapFor(0.5, 3), closeTo(2 / 3, 1e-9));
  });

  test('premultiplied lerp keeps hue when fading to transparent', () {
    const Color c = Color(0x0F000000);
    final Color mid = raLerpColor(const Color(0xFFFFFFFF), c, 0.5);
    // 预乘插值：中途仍是浅色（非 50% 灰）。
    expect(mid.r, greaterThan(0.9));
    final Color fade = raLerpColor(const Color(0xFF6D78D5), const Color(0x00000000), 0.5);
    expect(fade.a, closeTo(0.5, 1e-6));
    expect((fade.r * 255).round(), 0x6D);
  });

  testWidgets('RaTheme.of falls back to light without ancestor', (WidgetTester tester) async {
    late RaThemeData seen;
    await tester.pumpWidget(
      Builder(
        builder: (BuildContext context) {
          seen = RaTheme.of(context);
          return const SizedBox();
        },
      ),
    );
    expect(seen.brightness, Brightness.light);
  });

  test('motion: transitions run at 50 / 75 / 125 / 150 ms; delays stay put', () {
    final RaThemeData theme = RaThemeData.light();
    expect(theme.motion.fast, const Duration(milliseconds: 50));
    expect(theme.motion.base, const Duration(milliseconds: 75));
    expect(theme.motion.slow, const Duration(milliseconds: 125));
    expect(theme.motion.layout, const Duration(milliseconds: 150));
    expect(theme.menu.submenuHoverDelay, const Duration(milliseconds: 150));
    expect(theme.tooltip.showDelay, const Duration(milliseconds: 600));
  });
}
