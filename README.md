<div align="center">

# orra_ui

**A configurable design system for Flutter desktop and web apps.**

Native-feeling SaaS apps for macOS, Windows, and Linux, with the same app running in the browser. Ships with a Linear-inspired default theme, and every token can be overridden.

[![License: MIT](https://img.shields.io/badge/license-MIT-6d78d5.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-%E2%89%A53.47-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-%E2%89%A53.13-0175C2?logo=dart&logoColor=white)](https://dart.dev)
![Platforms](https://img.shields.io/badge/platforms-macOS%20%7C%20Windows%20%7C%20Linux%20%7C%20Web-lightgrey)
![No Material](https://img.shields.io/badge/material-not%20required-1b1b1b)

**English** · [简体中文](README.zh-CN.md)

</div>

---

Most Flutter desktop apps feel like a website in a window. orra_ui is meant to make them feel like real desktop apps instead: a frameless window with a solid chrome background, a floating rounded content panel, a dense 13 px type scale, 0.5 px hairlines, barely-there shadows, and keyboard-first interactions. It takes its cues from Linear, Cursor, and the ChatGPT desktop app.

orra_ui is built **only on Flutter's widgets layer**: no Material, no Cupertino. Interaction primitives come from the framework's headless building blocks (`RawMenuAnchor`, `RawTooltip`, `EditableText`, `RawScrollbar`, `PopupRoute`), and orra_ui owns every pixel on top of them.

## Contents

- [Highlights](#highlights)
- [Packages](#packages)
- [Getting started](#getting-started)
- [Components](#components)
- [Window shell](#window-shell)
- [Theming](#theming)
- [Icons](#icons)
- [Guardrails](#guardrails)
- [Testing](#testing)
- [Platform support](#platform-support)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [Acknowledgements](#acknowledgements)
- [License](#license)

## Highlights

- **Three-layer design tokens.** Primitives (raw values) → semantic tokens (purpose; dark mode is defined only here) → component tokens (derived, overridable). Change one gray and everything that uses it follows.
- **Configurable down to the instance.** Swap the brand color, re-skin a single button variant, or attach your own tokens through theme extensions.
- **A real desktop shell.**
  - Frameless window with a 44 px title bar. Traffic lights, window controls, and tabs share a 22 px centerline.
  - Collapsible sidebar that is clipped, not reflowed, while it animates.
  - Remembered window bounds, a native macOS menu bar, and global shortcuts on every platform.
- **Interaction details done right.**
  - Hover appears instantly and fades out over 150 ms.
  - Colors interpolate in premultiplied alpha, like CSS.
  - Menus grow from their trigger.
  - `prefers-reduced-motion` is respected everywhere.
- **One codebase, desktop and web.** The same widgets and window shell run in the browser (JavaScript or Wasm). On the web the title bar becomes a page header, window-only features step aside, and shortcuts follow the user's OS (⌘ in a Mac browser, Ctrl elsewhere).
- **Icon-agnostic.** Built-in Lucide-style glyphs for internal UI. Bring any icon font or SVG for your own content.
- **Enforced, not remembered.** `orra_guardrails` fails your test suite when someone hard-codes a color, imports Material, or bypasses a component.
- **Verified by geometry, not screenshots.** Widget tests measure centerlines, insets, and per-frame animation curves.

## Packages

This repository is a [pub workspace](https://dart.dev/tools/pub/workspaces):

| Package | Description |
| --- | --- |
| [`orra_ui`](packages/orra_ui) | Design tokens, theme, and components. Pure presentation: no `dart:io`, no window plugins. |
| [`orra_desktop_shell`](packages/orra_desktop_shell) | Window shell: frame, sidebar, panel, caption buttons, window state, and menu bar. Includes a small macOS plugin. Also runs on the web, where window features are no-ops. |
| [`orra_guardrails`](packages/orra_guardrails) | Static checks over your source, run from unit tests. |
| [`example`](example) | `orra_gallery`, a living component gallery for reference and visual QA. |

## Getting started

### Requirements

- Flutter **3.47** or newer (Dart 3.13)
- A desktop target (macOS 12+, Windows 10+, or Linux with GTK 3) or the web (current Chrome, Edge, Firefox, or Safari)

### Install

The packages are not on pub.dev yet; depend on them from Git. Because `orra_desktop_shell` depends on `orra_ui` inside the same repository, pin `orra_ui` with an override so both resolve to one checkout:

```yaml
dependencies:
  orra_ui:
    git:
      url: https://github.com/orra-bot/orra_ui
      path: packages/orra_ui
  orra_desktop_shell:
    git:
      url: https://github.com/orra-bot/orra_ui
      path: packages/orra_desktop_shell

dependency_overrides:
  orra_ui:
    git:
      url: https://github.com/orra-bot/orra_ui
      path: packages/orra_ui
```

### macOS setup

To keep the window hidden until the first frame is ready, and to paint the native window in the same color as the chrome, update `macos/Runner/MainFlutterWindow.swift`. Use [`example/macos/Runner/MainFlutterWindow.swift`](example/macos/Runner/MainFlutterWindow.swift) as the reference:

```swift
import window_manager

class MainFlutterWindow: NSWindow {
  // ...
  override public func order(_ place: NSWindow.OrderingMode, relativeTo otherWin: Int) {
    super.order(place, relativeTo: otherWin)
    hiddenWindowAtLaunch()
  }
}
```

### Web setup

The same `main` runs in the browser: on the web, `RaDesktopWindow.ensureInitialized` skips the window plugins and only paints the page in the chrome color. Add the web platform and run it:

```sh
flutter create --platforms=web .
flutter run -d chrome
flutter build web --wasm   # or plain `flutter build web` for JavaScript
```

To avoid a white flash before Flutter boots, give `web/index.html` the chrome color in both modes. Use [`example/web/index.html`](example/web/index.html) as the reference:

```html
<meta name="theme-color" content="#efeff0" media="(prefers-color-scheme: light)">
<meta name="theme-color" content="#09090a" media="(prefers-color-scheme: dark)">
<style>
  html, body { margin: 0; height: 100%; }
  body { background-color: #efeff0; }
  @media (prefers-color-scheme: dark) { body { background-color: #09090a; } }
</style>
```

Once the app is running, `RaDesktopFrame` keeps `<body>` and `theme-color` in sync with the active theme.

### Hello, desktop

```dart
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:orra_desktop_shell/orra_desktop_shell.dart';
import 'package:orra_ui/orra_ui.dart';

Future<void> main() async {
  await RaDesktopWindow.ensureInitialized(const RaWindowOptions(title: 'Acme'));
  runApp(const RaApp(title: 'Acme', home: Home()));
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _sidebarOpen = true;

  void _toggleSidebar() => setState(() => _sidebarOpen = !_sidebarOpen);

  @override
  Widget build(BuildContext context) {
    return RaAppMenuBar(
      appName: 'Acme',
      menus: [
        RaMenuBarMenu(label: 'View', entries: [
          RaCommand(
            label: 'Toggle Sidebar',
            shortcut: raPrimaryShortcut(LogicalKeyboardKey.backslash), // ⌘\ or Ctrl+\
            onInvoked: _toggleSidebar,
          ),
        ]),
      ],
      child: RaDesktopFrame(
        sidebarOpen: _sidebarOpen,
        onToggleSidebar: _toggleSidebar,
        sidebar: RaSidebarSection(title: 'Workspace', children: [
          RaSidebarItem(label: 'Inbox', trailing: const Text('3'), selected: true, onPressed: () {}),
        ]),
        child: Column(children: [
          RaPanelHeader(
            leading: const RaPanelTitle('Inbox'),
            trailing: RaIconButton(
              label: 'Mark all as read',
              shortcut: '⌘⇧A',
              icon: RaIcon.glyph(RaGlyphs.check),
              onPressed: () => RaToast.of(context).success('All caught up'),
            ),
          ),
          Expanded(
            child: Center(
              child: RaButton(
                variant: RaButtonVariant.danger,
                onPressed: () => showRaConfirmDialog(
                  context: context,
                  title: 'Delete project?',
                  description: const Text('This cannot be undone.'),
                  confirmLabel: 'Delete',
                  tone: RaConfirmTone.danger,
                  onConfirm: () async {/* call your API */},
                ),
                child: const Text('Delete project'),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
```

### Run the gallery

```sh
git clone https://github.com/orra-bot/orra_ui && cd orra_ui
flutter pub get
cd example && flutter run -d macos   # or -d windows / -d linux / -d chrome
```

## Components

| Component | Notes |
| --- | --- |
| `RaButton` | Variants: `primary`, `secondary`, `ghost`, `quiet`, `danger`, `dangerSolid`, `card`, `item`, `chip`, `send`, `icon`. Sizes 28 / 32 / 40. With `loading`, the button shows a spinner and stays focusable. |
| `RaIconButton` | 28 px round button with a required `label`, used as both the tooltip and the accessible name. Optional shortcut hint. |
| `RaTooltip` | White bubble, 0.5 px border, 11 px text, 600 ms delay. Replaces native `title`. |
| `RaTextField` / `RaForm` | Label, description, and error. The focus border uses the accent color (no focus ring). Validation starts after blur, then runs live. Search style and multiline. |
| `RaMenu` / `RaContextMenu` | Matches Linear's menus: radius 12, 32 px rows, 14 px text inset, 6 px highlight inset. Submenus, radio items, headers, full-width separators. Keyboard: ↑ ↓ ← → Enter Esc. |
| `RaMenuTrigger` | Pill, chip, and full-row trigger styles. |
| `RaDialog` / `showRaDialog` / `showRaConfirmDialog` | Width is `min(460, window − 32)`. The confirm dialog handles pending and error states and replaces `confirm()`. |
| `RaToast` | Bottom-right, 5 s auto-dismiss that pauses on hover. At most 3 at a time. |
| `RaSidebarSection` / `RaSidebarItem` / `RaStatusDot` | 28 px rows. Hover, selected, and pressed states use translucent overlays only. |
| `RaScrollbar`, `RaSeparator`, `RaAvatar`, `RaSpinner`, `RaSidebarIcon` | Supporting pieces. |

Lower-level building blocks are public too: `RaPressable` (hover, press, and focus states with CSS-like transition timing), `RaAnimatedSurface`, `RaPopoverPositioner`, `RaHairline`.

## Window shell

```
┌───────────────────────── title bar · 44 px · draggable ─────────────────────────┐
│ ● ● ●   [⊟]          [‹][›] │ [tabs / custom content]               [—][□][×] │  ← 22 px centerline
├──────────────────────────────┬───────────────────────────────────────────────────┤
│ sidebar · 238 px             │ ╭─ content panel · radius 12 · 0.5 px border ─╮ │
│ (solid chrome background)    │ │ RaPanelHeader · 44 px · draggable            │ │
│                              │ │                                              │ │
│ RaSidebarSection             │ │ your view                                    │ │
│   RaSidebarItem              │ │                                              │ │
│                              │ ╰──────────────────────────────────────────────╯ │
└──────────────────────────────┴──────────────── 8 px from window edges ─────────┘
```

- **Sidebar.** Animates 238 ↔ 8 px over 300 ms with `cubic-bezier(0.22, 1, 0.36, 1)`, easing out in both directions and reversible mid-flight. The content is clipped, not reflowed. Once collapsed it is hidden from pointer, focus, and screen readers.
- **macOS.** Traffic lights are re-centered on the 44 px title bar by the bundled native plugin, which re-applies the layout after resize and full screen.
- **Windows / Linux.** Minimize, maximize, and close buttons are drawn by the shell. Hovering close turns it system red.
- **Web.** The layout is the same. There are no traffic lights or caption buttons, so the controls start 12 px from the left. Dragging and double-clicking the title bar do nothing. `RaShellPlatform.current` tells you which host you are on.
- **Drag regions.** `RaWindowDragArea` moves the window from empty space and maximizes on double-click. Interactive widgets opt out automatically, so a drag that starts on a button never moves the window.
- **Window state.** Bounds are debounced to disk and validated against connected displays on restore. Unplugging an external monitor never strands the window off-screen.
- **Menu bar.** `RaAppMenuBar` builds a native macOS menu bar. On Windows, Linux, and the web the same shortcuts work globally. Use `raPrimaryShortcut` for ⌘ / Ctrl; on the web it follows the user's OS. In the browser, handled shortcuts suppress the browser's default action (for example ⌘[ for Back), but shortcuts the browser reserves, such as ⌘W, ⌘T, and ⌘N, never reach the page.
- **Context menus on the web.** While the pointer is over a `RaContextMenu`, the browser's own context menu is disabled so it does not cover yours. Everywhere else, including text fields, the browser menu still works.

## Theming

```dart
// 1. Brand color: override only the semantic accent family.
final light = RaThemeData.light(
  colors: const RaColors.light(
    accent: Color(0xFF0E7C66),
    accentHover: Color(0xFF0B6655),
    accentSoft: Color(0xFFE2F4F0),
    accentInk: Color(0xFF0B6655),
  ),
);

// 2. One component: start from the derived theme and tweak a variant.
final base = RaThemeData.light();
final pillButtons = base.copyWith(
  button: base.button.withVariant(
    RaButtonVariant.primary,
    RaButtonStyle(radius: base.radii.pill),
  ),
);

// 3. One instance.
RaButton(style: const RaButtonStyle(/* ... */), onPressed: save, child: const Text('Save'));

RaApp(theme: light, darkTheme: RaThemeData.dark(/* ... */), themeMode: RaThemeMode.system, home: ...);
```

| Layer | Where | Rules |
| --- | --- | --- |
| **Primitive** | `RaPalette`, `RaSizes`, `RaFontScale`, `RaDurations`, `RaCurves` | The only place literals live. |
| **Semantic** | `RaColors` (light / dark), `RaTypography`, `RaSpacing`, `RaRadii`, `RaSizing`, `RaShadows`, `RaMotion` | References primitives only. Dark mode is defined here and nowhere else. |
| **Component** | `RaButtonThemeData`, `RaMenuThemeData`, `RaFieldThemeData`, … plus your own `RaThemeExtension`s | Derived from semantic tokens by default and recomputed when you change them, unless you override them. |

Changing a semantic token re-derives every component theme you have not explicitly overridden. Apps add their own tokens through `RaThemeExtension`: see `RaShellThemeData` and [`example/lib/gallery_layout.dart`](example/lib/gallery_layout.dart).

## Icons

orra_ui is not tied to any icon library.

- **Internal icons.** Checkmarks, chevrons, close, search, and the window caption glyphs live in `RaIconSet` (`theme.icons`). They default to built-in vector glyphs that match Lucide's geometry, and each one can be swapped:

  ```dart
  base.copyWith(icons: base.icons.copyWith(check: const RaGlyph.icon(MyIcons.check)));
  ```

- **Your own content.** Use any `IconData` with `RaIcon(LucideIcons.inbox)`, or any widget through `RaGlyph.builder`. Icons render at 14 px in a 16 px slot and inherit the component's foreground color.

## Guardrails

Conventions only hold if something enforces them. `orra_guardrails` parses your sources with the Dart analyzer and runs inside `flutter test`:

```dart
test('app follows the token layers', () {
  final violations = runGuardrails(GuardrailConfig(
    root: Directory.current.path,
    targets: const [
      GuardrailTarget(GuardrailLayer.primitive, ['lib/theme/palette.dart']),
      GuardrailTarget(GuardrailLayer.semantic, ['lib/theme/brand.dart']),
      GuardrailTarget(GuardrailLayer.componentTokens, ['lib/theme/layout.dart']),
      GuardrailTarget(GuardrailLayer.app, ['lib']),
    ],
  ));
  expect(violations, isEmpty, reason: violations.join('\n'));
});
```

It flags:

- Color, duration, curve, and font-weight literals outside primitives.
- Numbers in the semantic layer.
- Hard-coded sizes in component code.
- Direct references to primitives from components.
- Brightness checks in components.
- Unused primitives.
- Imports of `material.dart` or `cupertino.dart`.
- Raw widgets (`EditableText`, `RawMenuAnchor`, `RawTooltip`, `showGeneralDialog`, …) used from app code.

## Testing

Layout is verified by measuring geometry, not by comparing screenshots. Examples from the suite:

- Window controls center on y = 22, and the panel's top edge sits at y = 44.
- The panel is inset 8 px from the window's right and bottom edges.
- The sidebar collapse is sampled frame by frame:
  - monotonic, with intermediate frames;
  - more than 3× faster in the first half than in the second (ease-out);
  - continuous when reversed mid-flight;
  - instant under reduced motion.
- Every sidebar fill in every state, in light and dark mode, is translucent.
- Menu rows are 32 px, text starts 14 px from the edge, and the highlight is inset 6 px.
- The dialog is 460 px wide, or `window − 32` on narrow windows.
- The native macOS window color and the colors in `web/index.html` equal the theme's chrome color, so there is no flash on the first frame.
- On the web, the frame has no caption buttons, the window plugins are never called, and ⌘ is used in a Mac browser. These run in the VM with `debugRaIsWebOverride`, and again in a real browser.

```sh
# in packages/orra_ui, packages/orra_desktop_shell, example
flutter analyze && flutter test
# in packages/orra_guardrails
dart analyze && dart test

# the same suites compiled for the web, in headless Chrome
cd packages/orra_ui && flutter test --platform chrome
cd example && flutter test --platform chrome
cd packages/orra_desktop_shell && flutter test --platform chrome test/web_test.dart test/page_style_browser_test.dart
```

## Platform support

| | macOS | Windows | Linux | Web |
| --- | :---: | :---: | :---: | :---: |
| Components | ✅ | ✅ | ✅ | ✅ |
| Frameless window and shell | ✅ native traffic lights | ✅ drawn caption buttons | ✅ drawn caption buttons | ✅ same layout, no window buttons |
| Native menu bar | ✅ | — (shortcuts only) | — (shortcuts only) | — (shortcuts only) |
| Remembered window bounds | ✅ | ✅ | ✅ | — (the browser decides) |
| Build verified | ✅ | ⏳ | ⏳ | ✅ JavaScript and Wasm |

⏳ means the Dart code is covered by tests on every platform, but the native runner has not yet been built in CI.

## Roadmap

- [x] Design tokens, theming, and extensions
- [x] Button, IconButton, Tooltip, TextField / Form, Menu, Dialog, Toast, sidebar widgets
- [x] Window shell, window state, menu bar, and shortcuts
- [x] Guardrails and the gallery app
- [x] Web support (same widgets and shell in the browser)
- [ ] Chrome-style tab strip (per-tab history, drag to reorder, reopen closed tab)
- [ ] Command palette (⌘K)
- [ ] Tabs, SegmentedControl, SideCard / PropertyRow, Drawer
- [ ] Composer, chat log, Markdown
- [ ] Settings page layout
- [ ] Theme editor (OKLCH-derived custom themes)
- [ ] CI for macOS, Windows, Linux, and web builds
- [ ] Publish to pub.dev

## Contributing

Issues and pull requests are welcome. A few house rules keep the system coherent:

1. **Compose before you add.** New components should be discussed in an issue first. Page layouts belong in apps, not in `orra_ui`.
2. **No literals outside primitives.** Add a semantic token when the purpose is shared, or a component token when it isn't. Dark-mode values go in the semantic layer only.
3. **Translucent fills on chrome.** Hover, selected, and pressed states on the sidebar and title bar use overlay colors, never solid fills.
4. **No focus rings.** This is a deliberate product decision. Focused inputs show it by changing their border color instead.
5. **Prove it with tests.** Assert geometry and state. Run `flutter analyze` and `flutter test` in every package before opening a PR.

## Acknowledgements

- Visual language inspired by [Linear](https://linear.app); window structure informed by Cursor and the ChatGPT desktop app.
- [Inter](https://rsms.me/inter/) by Rasmus Andersson (SIL OFL 1.1), bundled.
- Built-in glyph geometry from [Lucide](https://lucide.dev) (ISC).
- Window management by [window_manager](https://pub.dev/packages/window_manager).

See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) for the full license texts.

## License

[MIT](LICENSE) © 2026 orra-bot and contributors
