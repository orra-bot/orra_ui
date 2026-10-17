<div align="center">

# orra_ui

**面向 Flutter 桌面端与网页端的可配置设计系统。**

用来做像原生应用一样的 SaaS 应用，支持 macOS、Windows、Linux，同一个应用也能在浏览器中运行。默认主题取法 Linear，每个设计变量都可以覆盖。

[![CI](https://github.com/orra-bot/orra_ui/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/orra-bot/orra_ui/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-6d78d5.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-%E2%89%A53.47-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-%E2%89%A53.13-0175C2?logo=dart&logoColor=white)](https://dart.dev)
![Platforms](https://img.shields.io/badge/platforms-macOS%20%7C%20Windows%20%7C%20Linux%20%7C%20Web-lightgrey)
![No Material](https://img.shields.io/badge/material-not%20required-1b1b1b)
[![PRs welcome](https://img.shields.io/badge/PRs-welcome-6d78d5.svg)](CONTRIBUTING.md)

[English](README.md) · **简体中文**

</div>

---

多数 Flutter 桌面应用看起来像「装在窗口里的网页」。orra_ui 想让它们看起来像真正的桌面应用：

- 无标题栏窗口，底色是实色
- 浮起的圆角内容面板
- 紧凑的 13px 字号，0.5px 细线，极淡的阴影
- 交互以键盘为先

整体结构参考 Linear、Cursor 和 ChatGPT 桌面端。

orra_ui **只依赖 Flutter 的 widgets 层**，不引入 Material，也不引入 Cupertino。交互底座用的是框架自带的无样式组件（`RawMenuAnchor`、`RawTooltip`、`EditableText`、`RawScrollbar`、`PopupRoute`），之上的每一个像素都由 orra_ui 自己绘制。

## 目录

- [特性](#特性)
- [包结构](#包结构)
- [快速开始](#快速开始)
- [组件](#组件)
- [窗口外壳](#窗口外壳)
- [主题配置](#主题配置)
- [图标](#图标)
- [守护规则](#守护规则)
- [测试](#测试)
- [平台支持](#平台支持)
- [路线图](#路线图)
- [参与贡献](#参与贡献)
- [致谢](#致谢)
- [许可证](#许可证)

## 特性

- **三层设计变量**：基础层（值）→ 语义层（用途，深色模式只在这一层赋值）→ 组件层（由语义层推导，可以覆盖）。改一个灰，所有用到它的地方都会跟着变。
- **可以细到单个实例**：可以换品牌色，可以单独改某个按钮变体，也可以通过主题扩展登记应用自己的变量。
- **真正的桌面外壳**：
  - 无标题栏窗口，标题栏 44px；红绿灯、窗口按钮组、标签栏共用 22px 中线。
  - 侧栏可开合，动画过程中内容被裁切而不是挤压重排。
  - 记住窗口位置；macOS 有原生菜单栏；所有平台都有全局快捷键。
- **交互细节到位**：
  - 悬停底色立即出现，移开后 150ms 淡出。
  - 颜色按预乘 alpha 插值，与 CSS 一致。
  - 菜单从触发位置展开。
  - 全面尊重系统的「减弱动态效果」设置。
- **一套代码，桌面与网页**：同一套组件和窗口外壳可以在浏览器中运行（JavaScript 或 Wasm）。网页端的标题栏变成页面顶栏，只属于窗口的功能自动让开；快捷键跟随用户的操作系统（Mac 浏览器用 ⌘，其他用 Ctrl）。
- **不绑定图标库**：组件内部用内置的 Lucide 风格图标；业务内容可以用任意图标字体或 SVG。
- **规则靠自动化执行**：有人写死颜色、引入 Material 或绕过组件库时，`orra_guardrails` 会让测试失败。
- **用几何测量验证，不靠截图**：widget 测试会测量中线、边距，以及逐帧的动画曲线。

## 包结构

本仓库是一个 [pub workspace](https://dart.dev/tools/pub/workspaces)：

| 包 | 说明 |
| --- | --- |
| [`orra_ui`](packages/orra_ui) | 设计变量、主题与组件。纯展示层，不依赖 `dart:io` 和窗口插件。 |
| [`orra_desktop_shell`](packages/orra_desktop_shell) | 窗口外壳：框架、侧栏、内容面板、窗口按钮、窗口状态、菜单栏。附带一个 macOS 原生插件。也可在网页端运行，窗口相关操作在网页端不执行。 |
| [`orra_guardrails`](packages/orra_guardrails) | 源码静态检查，在单元测试中运行。 |
| [`example`](example) | `orra_gallery` 组件展示应用，用于查阅和视觉验收。 |

## 快速开始

### 环境要求

- Flutter **3.47** 或更高版本（Dart 3.13）
- 桌面平台（macOS 12+、Windows 10+，或 Linux（GTK 3）），或网页端（较新的 Chrome、Edge、Firefox、Safari）

### 安装

目前尚未发布到 pub.dev，请通过 Git 依赖安装。`orra_desktop_shell` 在同一仓库内依赖 `orra_ui`，所以需要用 `dependency_overrides` 固定 `orra_ui`，让两者解析到同一份代码：

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

### macOS 配置

修改 `macos/Runner/MainFlutterWindow.swift`，作用有两个：窗口在首帧渲染前保持隐藏；原生窗口底色与主题的窗口底色一致。完整写法见 [`example/macos/Runner/MainFlutterWindow.swift`](example/macos/Runner/MainFlutterWindow.swift)。

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

### 网页端配置

同一份 `main` 可以直接在浏览器中运行：网页端的 `RaDesktopWindow.ensureInitialized` 不调用任何窗口插件，只把页面底色设为窗口底色。添加 web 平台后运行：

```sh
flutter create --platforms=web .
flutter run -d chrome
flutter build web --wasm   # 或用 `flutter build web` 编译为 JavaScript
```

为了避免 Flutter 启动前闪白，在 `web/index.html` 中按深浅模式写入窗口底色，完整写法见 [`example/web/index.html`](example/web/index.html)：

```html
<meta name="theme-color" content="#efeff0" media="(prefers-color-scheme: light)">
<meta name="theme-color" content="#09090a" media="(prefers-color-scheme: dark)">
<style>
  html, body { margin: 0; height: 100%; }
  body { background-color: #efeff0; }
  @media (prefers-color-scheme: dark) { body { background-color: #09090a; } }
</style>
```

应用启动后，`RaDesktopFrame` 会让 `<body>` 背景和 `theme-color` 跟随当前主题。

### 最小示例

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
        RaMenuBarMenu(label: '显示', entries: [
          RaCommand(
            label: '切换侧栏',
            shortcut: raPrimaryShortcut(LogicalKeyboardKey.backslash), // ⌘\ 或 Ctrl+\
            onInvoked: _toggleSidebar,
          ),
        ]),
      ],
      child: RaDesktopFrame(
        sidebarOpen: _sidebarOpen,
        onToggleSidebar: _toggleSidebar,
        sidebar: RaSidebarSection(title: 'Workspace', children: [
          RaSidebarItem(label: '收件箱', trailing: const Text('3'), selected: true, onPressed: () {}),
        ]),
        child: Column(children: [
          RaPanelHeader(
            leading: const RaPanelTitle('收件箱'),
            trailing: RaIconButton(
              label: '全部标为已读',
              shortcut: '⌘⇧A',
              icon: RaIcon.glyph(RaGlyphs.check),
              onPressed: () => RaToast.of(context).success('已全部处理'),
            ),
          ),
          Expanded(
            child: Center(
              child: RaButton(
                variant: RaButtonVariant.danger,
                onPressed: () => showRaConfirmDialog(
                  context: context,
                  title: '删除这个项目？',
                  description: const Text('删除后无法恢复。'),
                  confirmLabel: '删除',
                  tone: RaConfirmTone.danger,
                  onConfirm: () async {/* 调用接口 */},
                ),
                child: const Text('删除项目'),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
```

### 运行展示应用

```sh
git clone https://github.com/orra-bot/orra_ui && cd orra_ui
flutter pub get
cd example && flutter run -d macos   # 或 -d windows / -d linux / -d chrome
```

## 组件

| 组件 | 说明 |
| --- | --- |
| `RaButton` | 变体：`primary` · `secondary` · `ghost` · `quiet` · `danger` · `dangerSolid` · `card` · `item` · `chip` · `send` · `icon`。尺寸 28 / 32 / 40。`loading` 时显示转圈，但仍可聚焦。 |
| `RaIconButton` | 28px 圆形按钮。`label` 必填，同时用作提示文字和无障碍名称；可带快捷键提示。 |
| `RaTooltip` | 白底、0.5px 描边、11px 文字，悬停 600ms 后出现。取代原生 `title`。 |
| `RaTextField` / `RaForm` | 标签、说明、错误。聚焦时边框变为强调色（无焦点环）。失焦后开始校验，之后随输入实时更新。支持搜索样式和多行。 |
| `RaMenu` / `RaContextMenu` | 对照 Linear：圆角 12、选项高 32、文字距左缘 14、高亮块缩进 6。支持子菜单、单选项、菜单头、贯穿全宽的分隔线；键盘 ↑ ↓ ← → Enter Esc。 |
| `RaMenuTrigger` | 触发器样式：胶囊、输入框上方的小胶囊、侧栏整行。 |
| `RaDialog` / `showRaDialog` / `showRaConfirmDialog` | 宽 `min(460, 窗口宽 − 32)`。确认框自带进行中和出错状态，取代 `confirm()`。 |
| `RaToast` | 显示在右下角，5 秒后自动消失，悬停时暂停；最多同时 3 条。 |
| `RaSidebarSection` / `RaSidebarItem` / `RaStatusDot` | 行高 28。悬停、选中、按下都只用半透明叠加色。 |
| `RaScrollbar`、`RaSeparator`、`RaAvatar`、`RaSpinner`、`RaSidebarIcon` | 配套组件。 |

底层构件同样公开：

- `RaPressable`：处理悬停、按下、聚焦，过渡时长与 CSS 节奏一致
- `RaAnimatedSurface`
- `RaPopoverPositioner`
- `RaHairline`

## 窗口外壳

```
┌──────────────────────── 标题栏 · 44px · 可拖动 ────────────────────────┐
│ ● ● ●   [⊟]          [‹][›] │ [标签栏 / 自定义内容]        [—][□][×] │  ← 22px 中线
├──────────────────────────────┬──────────────────────────────────────────┤
│ 侧栏 · 238px                  │ ╭─ 内容面板 · 圆角 12 · 0.5px 描边 ─╮ │
│（实色窗口底）                  │ │ RaPanelHeader · 44px · 可拖动      │ │
│                              │ │                                    │ │
│ RaSidebarSection             │ │ 你的视图                            │ │
│   RaSidebarItem              │ │                                    │ │
│                              │ ╰────────────────────────────────────╯ │
└──────────────────────────────┴──────────────── 距窗口边缘 8px ──────────┘
```

- **侧栏**：在 238 ↔ 8px 之间过渡，300ms，缓动 `cubic-bezier(0.22, 1, 0.36, 1)`。展开和收起都是先快后慢，中途可以反向。内容被裁切而不是重排。收起后对鼠标、焦点和读屏都隐藏。
- **macOS**：红绿灯由附带的原生插件对齐到 44px 标题栏的中线；窗口缩放、全屏切换后会自动重新定位。
- **Windows / Linux**：最小化、最大化、关闭按钮由外壳绘制，关闭按钮悬停时显示系统红。
- **网页端**：布局相同。没有红绿灯和窗口按钮，按钮组从左 12px 开始；拖动、双击标题栏不执行任何操作。用 `RaShellPlatform.current` 判断当前宿主。
- **拖动区**：用 `RaWindowDragArea` 在空白处可以拖动窗口，双击最大化。可交互组件会自动排除，从按钮上开始拖动不会移动窗口。
- **窗口状态**：位置与尺寸防抖写入磁盘。恢复时会对照当前显示器校验，拔掉外接显示器后窗口不会跑到屏幕外。
- **菜单栏**：`RaAppMenuBar` 在 macOS 上生成原生菜单栏，在 Windows / Linux / 网页端让同一套快捷键全局生效。主修饰键（⌘ 或 Ctrl）用 `raPrimaryShortcut` 生成，网页端按用户的操作系统选择。在浏览器中，被处理的快捷键会阻止浏览器默认行为（如 ⌘[ 后退）；但浏览器保留的组合键（⌘W、⌘T、⌘N 等）页面收不到。
- **网页端右键菜单**：指针位于 `RaContextMenu` 上时禁用浏览器自带的右键菜单，避免盖住应用菜单；其他区域（包括输入框）仍是浏览器菜单。

## 主题配置

```dart
// 1. 品牌色：只覆盖语义层的强调色系列
final light = RaThemeData.light(
  colors: const RaColors.light(
    accent: Color(0xFF0E7C66),
    accentHover: Color(0xFF0B6655),
    accentSoft: Color(0xFFE2F4F0),
    accentInk: Color(0xFF0B6655),
  ),
);

// 2. 某个组件：在推导出的主题上修改一个变体
final base = RaThemeData.light();
final pillButtons = base.copyWith(
  button: base.button.withVariant(
    RaButtonVariant.primary,
    RaButtonStyle(radius: base.radii.pill),
  ),
);

// 3. 单个实例
RaButton(style: const RaButtonStyle(/* ... */), onPressed: save, child: const Text('保存'));

RaApp(theme: light, darkTheme: RaThemeData.dark(/* ... */), themeMode: RaThemeMode.system, home: ...);
```

| 层 | 位置 | 规则 |
| --- | --- | --- |
| **基础层** | `RaPalette`、`RaSizes`、`RaFontScale`、`RaDurations`、`RaCurves` | 唯一允许写字面量的地方。 |
| **语义层** | `RaColors`（浅 / 深）、`RaTypography`、`RaSpacing`、`RaRadii`、`RaSizing`、`RaShadows`、`RaMotion` | 只引用基础层；深色模式只在这里赋值。 |
| **组件层** | `RaButtonThemeData`、`RaMenuThemeData`、`RaFieldThemeData`……以及应用自己的 `RaThemeExtension` | 默认由语义层推导，可以覆盖。 |

修改语义层时，没有单独覆盖的组件主题会自动重新推导。应用可以通过 `RaThemeExtension` 登记自己的变量，参考 `RaShellThemeData` 和 [`example/lib/gallery_layout.dart`](example/lib/gallery_layout.dart)。

## 图标

orra_ui 不绑定任何图标库：

- **组件内部图标**：对勾、箭头、关闭、搜索、窗口按钮等都放在 `RaIconSet`（`theme.icons`）里。默认是按 Lucide 几何绘制的内置图标，每一个都可以替换：

  ```dart
  base.copyWith(icons: base.icons.copyWith(check: const RaGlyph.icon(MyIcons.check)));
  ```

- **业务内容**：任意 `IconData` 都可以直接用 `RaIcon(LucideIcons.inbox)` 显示，任意 Widget 可以通过 `RaGlyph.builder` 接入。图标默认 14px，放在 16px 的图标位里，颜色跟随组件的前景色。

## 守护规则

规范要靠自动化执行，不能靠记忆。`orra_guardrails` 用 Dart analyzer 解析源码，在 `flutter test` 中运行：

```dart
test('应用遵守三层设计变量', () {
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

会拦截以下情况：

- 基础层以外出现颜色、时长、缓动、字重字面量
- 语义层出现数字
- 组件代码写死尺寸
- 组件直接引用基础层
- 组件判断明暗
- 基础层有闲置值
- 导入 `material.dart` / `cupertino.dart`
- 应用层直接使用底层组件（`EditableText`、`RawMenuAnchor`、`RawTooltip`、`showGeneralDialog`……）

## 测试

布局通过几何测量验证，不比对截图。测试中的例子：

- 窗口按钮中心在 y = 22，面板顶边在 y = 44。
- 面板距窗口右、下边缘各 8px。
- 侧栏收起过程逐帧采样：
  - 单调变化，并且有中间帧；
  - 前半程移动距离是后半程的 3 倍以上（先快后慢）；
  - 中途反向时连续，不跳变；
  - 减弱动效时直接到位。
- 浅色和深色主题下，侧栏各状态的填充都是半透明的。
- 菜单项高 32，文字距浮层左缘 14，高亮块缩进 6。
- 对话框宽 460；窄窗口下为窗口宽 − 32。
- macOS 原生窗口底色、`web/index.html` 中的页面底色都等于主题的窗口底色，首帧不闪色。
- 网页端：没有窗口按钮、不调用窗口插件、Mac 浏览器中使用 ⌘。这些在 VM 中用 `debugRaIsWebOverride` 模拟，并在真实浏览器中再跑一遍。

```sh
# 在 packages/orra_ui、packages/orra_desktop_shell、example 中
flutter analyze && flutter test
# 在 packages/orra_guardrails 中
dart analyze && dart test

# 同一批测试编译为网页端，在无头 Chrome 中运行
cd packages/orra_ui && flutter test --platform chrome
cd example && flutter test --platform chrome
cd packages/orra_desktop_shell && flutter test --platform chrome test/web_test.dart test/page_style_browser_test.dart
```

## 平台支持

| | macOS | Windows | Linux | 网页 |
| --- | :---: | :---: | :---: | :---: |
| 组件 | ✅ | ✅ | ✅ | ✅ |
| 无标题栏窗口与外壳 | ✅ 原生红绿灯 | ✅ 自绘窗口按钮 | ✅ 自绘窗口按钮 | ✅ 布局相同，无窗口按钮 |
| 原生菜单栏 | ✅ | —（仅快捷键） | —（仅快捷键） | —（仅快捷键） |
| 记住窗口位置 | ✅ | ✅ | ✅ | —（由浏览器决定） |
| 编译验证 | ✅ | ⏳ | ⏳ | ✅ JavaScript 与 Wasm |

⏳ 表示 Dart 代码已有测试覆盖，原生工程尚未在 CI 中编译。

## 路线图

- [x] 设计变量、主题与扩展
- [x] Button、IconButton、Tooltip、TextField / Form、Menu、Dialog、Toast、侧栏组件
- [x] 窗口外壳、窗口状态、菜单栏与快捷键
- [x] 守护规则与展示应用
- [x] 网页端支持（同一套组件与外壳在浏览器中运行）
- [ ] Chrome 式标签栏（每个标签页有独立历史、拖动排序、重新打开已关闭的标签页）
- [ ] 命令面板（⌘K）
- [ ] Tabs、SegmentedControl、SideCard / PropertyRow、Drawer
- [ ] Composer、对话列表、Markdown
- [ ] 设置页版式
- [ ] 主题编辑器（OKLCH 推导自定义主题）
- [ ] macOS、Windows、Linux、网页端的 CI 编译
- [ ] 发布到 pub.dev

## 参与贡献

欢迎提交 Issue 和 Pull Request，开始前请先阅读 [CONTRIBUTING.md](CONTRIBUTING.md)。要点如下：

1. **先组合，再新增**：新组件请先提交[组件提案](https://github.com/orra-bot/orra_ui/issues/new?template=component_proposal.yml)。页面版式放在应用侧，不进入 `orra_ui`。
2. **基础层以外不写字面量**：多处共用的用途加语义变量，只属于某个组件的加组件变量；深色值只写在语义层。
3. **窗口底上只用半透明叠加色**：侧栏和标题栏的悬停、选中、按下都用叠加色，不用实色。
4. **不显示焦点环**：这是刻意的产品决定。输入框聚焦以边框变色表示。
5. **用测试证明**：断言几何与状态。CI 会在 macOS、Windows、Linux 和 Chrome 上检查格式、静态分析并运行全部测试。

本项目遵守[行为准则](CODE_OF_CONDUCT.md)。安全问题请按 [SECURITY.md](SECURITY.md) 私下报告。

## 致谢

- 视觉语言参考 [Linear](https://linear.app)，窗口结构参考 Cursor 与 ChatGPT 桌面端。
- 随包附带 Rasmus Andersson 的 [Inter](https://rsms.me/inter/) 字体（SIL OFL 1.1）。
- 内置图标的几何取自 [Lucide](https://lucide.dev)（ISC）。
- 窗口管理基于 [window_manager](https://pub.dev/packages/window_manager)。

完整的第三方许可证见 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)。

## 许可证

[MIT](LICENSE) © 2026 orra-bot and contributors
