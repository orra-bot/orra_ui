# Contributing to orra_ui

Thanks for your interest in orra_ui! Issues and pull requests are welcome, in English or 中文.

By participating you agree to follow the [Code of Conduct](CODE_OF_CONDUCT.md). To report a security issue, see [SECURITY.md](SECURITY.md) instead of opening a public issue.

## Before you start

- **Bugs:** search [existing issues](https://github.com/orra-bot/orra_ui/issues), then open a [bug report](https://github.com/orra-bot/orra_ui/issues/new?template=bug_report.yml).
- **Small fixes** (typos, docs, an obvious bug) can go straight to a pull request.
- **New components** must start as a [component proposal](https://github.com/orra-bot/orra_ui/issues/new?template=component_proposal.yml). Please wait until the design is agreed before writing code, so your work doesn't go to waste.
- **Larger changes** to tokens, theming, or the window shell: open a [feature request](https://github.com/orra-bot/orra_ui/issues/new?template=feature_request.yml) first.

## Development setup

You need Flutter **3.47** or newer (Dart 3.13). For desktop builds, also install the [platform toolchain](https://docs.flutter.dev/get-started/install) for your OS. For browser tests, install Chrome.

```sh
git clone https://github.com/orra-bot/orra_ui && cd orra_ui
flutter pub get            # resolves the whole pub workspace
cd example && flutter run -d macos   # or -d windows / -d linux / -d chrome
```

The repository is a [pub workspace](https://dart.dev/tools/pub/workspaces):

| Path | What lives there |
| --- | --- |
| `packages/orra_ui` | Tokens, theme, and components. Widgets layer only: no `dart:io`, no Material, no Cupertino. |
| `packages/orra_desktop_shell` | Window shell, window state, menu bar, shortcuts, and the macOS plugin. |
| `packages/orra_guardrails` | Static checks run from unit tests. Pure Dart. |
| `example` | `orra_gallery`, the living component gallery. |

## House rules

These keep the design system coherent. Reviewers will ask for changes that break them.

1. **Compose before you add.** Page layouts belong in apps, not in `orra_ui`.
2. **No literals outside primitives.** Add a semantic token when the purpose is shared, or a component token when it isn't. Dark-mode values go in the semantic layer only.
3. **Translucent fills on chrome.** Hover, selected, and pressed states on the sidebar and title bar use overlay colors, never solid fills.
4. **No focus rings.** This is a deliberate product decision. Focused inputs show it by changing their border color instead.
5. **Build on the widgets layer.** Use the framework's headless primitives (`RawMenuAnchor`, `RawTooltip`, `EditableText`, …) inside the library only; apps go through `Ra…` components.
6. **Respect reduced motion.** Every animation must be instant when `prefers-reduced-motion` is on.
7. **Prove it with tests.** Assert geometry and state (sizes, insets, centerlines, per-frame curves), not screenshots.

## Checks

CI runs all of these on every pull request. Run them locally before pushing:

```sh
# at the repository root
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos

# tests (VM)
(cd packages/orra_guardrails && dart test)
(cd packages/orra_ui && flutter test)
(cd packages/orra_desktop_shell && flutter test)
(cd example && flutter test)

# tests (headless Chrome), when your change can affect the web
(cd packages/orra_ui && flutter test --platform chrome)
(cd packages/orra_desktop_shell && flutter test --platform chrome test/web_test.dart test/page_style_browser_test.dart)
(cd example && flutter test --platform chrome)
```

CI also builds the gallery for macOS, Windows, Linux, and the web (JavaScript and Wasm).

## Pull requests

- Keep each PR focused on one change. Fill in the PR template.
- Add an entry under **Unreleased** in the `CHANGELOG.md` of every package you changed.
- If you change public API or behavior, update both `README.md` and `README.zh-CN.md`. A rough translation is fine; a maintainer can polish it.
- For visual changes, attach before/after screenshots in light and dark mode, and say which gallery page shows the change.
- Commit messages: a short summary line in the imperative mood, optionally prefixed with the package (`orra_ui: add RaSegmentedControl`). Squash fixups before review, or let the maintainer squash on merge.
- Dependencies are pinned to exact versions. Don't bump them in an unrelated PR; Dependabot handles routine updates.

## License

By contributing, you agree that your contributions are licensed under the [MIT License](LICENSE).
