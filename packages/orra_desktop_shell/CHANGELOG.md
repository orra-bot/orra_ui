## Unreleased

* Web support. `RaDesktopFrame` keeps its layout in the browser without traffic lights or caption buttons. `RaDesktopWindow.ensureInitialized` skips the window plugins, and window operations become no-ops through `RaBrowserWindowController`.
* `RaShellPlatform` describes the host: macOS, Windows, Linux, or web.
* On the web, the page background and `theme-color` follow the theme's chrome color.
* **Breaking:** `RaShellThemeData.controlsLeftFor` now takes a `RaShellPlatform`.
* `raPrimaryShortcut` and `RaShellStrings.shortcut` use ⌘ in a Mac browser, so the hint matches the real shortcut.

## 0.1.0

* Initial release.
