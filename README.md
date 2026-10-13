# orra_ui

面向 Flutter 桌面端（macOS / Windows / Linux）的可配置设计系统与组件库。默认主题对照 Linear，移植自 `saas-desktop-ui-framework` skill（原为 Electron + React + Base UI）。

只依赖 Flutter 的 widgets 层，不引入 Material / Cupertino。交互底座使用 widgets 层自带的无样式组件：`RawMenuAnchor`、`RawTooltip`、`EditableText`、`RawScrollbar`、`PopupRoute`。这对应原方案里 Base UI 的角色。

## 仓库结构（pub workspace）

```
packages/
  orra_ui/              组件库（纯展示层，不依赖窗口插件 / dart:io）
    lib/src/tokens/     三层设计变量：primitives → colors + semantic → components
    lib/src/theme/      RaThemeData / RaTheme（含主题扩展）
    lib/src/foundation/ RaApp、RaPressable（悬停 / 按下 / 焦点 / 过渡时长）、浮层定位、细线取整……
    lib/src/icons/      RaGlyph（不绑定图标库）、内置线条图标、RaIcon、转圈、侧栏开关图标
    lib/src/components/ Button、IconButton、Tooltip、TextField / Form、Menu、Dialog、Toast、Sidebar、Scrollbar、Separator
    fonts/              Inter 可变字体（OFL，随包打包）
  orra_desktop_shell/   窗口外壳（依赖 window_manager；含 macOS 原生插件：红绿灯定位）
  orra_guardrails/      守护规则：基于 analyzer 语法树的源码检查，在单元测试中运行
example/                展示应用 orra_gallery（视觉验收入口）
```

## 用法

```dart
Future<void> main() async {
  await RaDesktopWindow.ensureInitialized(const RaWindowOptions(title: 'My App'));
  runApp(
    RaApp(
      home: RaDesktopFrame(
        sidebarOpen: open,
        onToggleSidebar: toggle,
        sidebar: Column(children: [
          RaSidebarSection(title: '运行中', children: [
            RaSidebarItem(label: '周报生成器', onPressed: () {}, selected: true),
          ]),
        ]),
        child: Column(children: [
          RaPanelHeader(leading: RaPanelTitle('收件箱'), trailing: RaIconButton(...)),
          Expanded(child: ...),
        ]),
      ),
    ),
  );
}
```

业务侧提示与确认统一通过组件库：

- `RaToast.of(context).success('已保存')`
- `showRaConfirmDialog(...)`
- 菜单用 `RaMenu`，提示气泡用 `RaTooltip`

## 配置主题（可配置设计系统）

| 想改什么 | 怎么改 |
| --- | --- |
| 品牌色 | `RaThemeData.light(colors: const RaColors.light(accent: …, accentHover: …, accentSoft: …, accentInk: …, selection: …))`。深色用 `RaColors.dark(...)` 另配一套。 |
| 中性灰、字体、圆角 | `RaThemeData(typography: …, radii: …)`。没有单独覆盖的组件主题会随语义层重新推导。 |
| 某个组件 | `base.copyWith(button: base.button.withVariant(RaButtonVariant.primary, RaButtonStyle(...)))`。菜单、输入框、Toast 等组件同理。 |
| 单个实例 | `RaButton(style: RaButtonStyle(...))` |
| 应用自己的组件变量 | 继承 `RaThemeExtension`，放进 `RaThemeData(extensions: [...])`。可参考 `RaShellThemeData` 和 `example/lib/gallery_layout.dart`。 |
| 图标 | 组件内部用到的图标在 `theme.icons`（`RaIconSet`）里，默认是内置的 Lucide 同款线条图标。可以用 `RaGlyph.icon(任意 IconData)` 或 `RaGlyph.builder(...)` 逐个替换。业务图标直接写 `RaIcon(LucideIcons.inbox)`，任意图标库都可以。 |

`example/lib/brand_palette.dart → brand_themes.dart` 演示了应用侧如何按三层结构换品牌色。

## 守护规则

`orra_guardrails` 在单元测试里静态检查源码，三个包和示例应用都已接入（各自的 `test/guardrails_test.dart`）。它检查以下几类问题：

- **三层约束**
  - 只有基础层能写颜色、时长、缓动、字重字面量。
  - 语义层只允许出现数字 0 / 1。
  - 组件层可以写布局几何，但不写颜色和时长。
  - 组件代码不写尺寸 / 字号 / 圆角数字，不直接引用基础层，不感知明暗。
  - 基础层不留闲置值。
- **禁用规则**
  - 任何层都不得导入 `material.dart` / `cupertino.dart`。
  - 组件库不得导入 `dart:io`、`window_manager`。
  - 应用层不得直接使用 `EditableText`、`RawMenuAnchor`、`RawTooltip`、`showGeneralDialog` 等未封装的底层组件，也不写颜色。

新应用接入：复制 `example/test/guardrails_test.dart`，把 `targets` 改成自己的目录即可。

## 验证

```sh
# 每个包分别执行
flutter analyze && flutter test          # packages/orra_ui、packages/orra_desktop_shell、example
dart analyze && dart test                # packages/orra_guardrails
cd example && flutter build macos --debug
```

几何与状态用测试测量，不靠截图：

- 标题栏中线 22、面板顶边 44
- 侧栏开合逐帧单调、有中间帧；减弱动效时没有中间帧
- 侧栏只用半透明填充
- 菜单 32 / 14 / 6 规格
- 对话框 min(460, w−32)
- 原生窗口底色等于主题 chrome

## 与原 skill 的差异

| 原方案 | 这里 |
| --- | --- |
| Base UI | widgets 层的 Raw* 组件，外观与交互由 orra_ui 自己实现 |
| CSS 变量三层 | Dart 常量（基础层）+ `RaColors` / `RaTypography` 等（语义层，浅 / 深各一套）+ `Ra*ThemeData`（组件层，由语义层推导、可覆盖） |
| ESLint + tokens.test.ts | `orra_guardrails`（analyzer 语法树），在 `flutter test` 中执行 |
| Playwright E2E 几何断言 | widget 测试（`tester.getRect` 等） |
| Electron `trafficLightPosition` | `orra_desktop_shell` 自带的 macOS 原生插件，在缩放、全屏切换后会重新定位 |
| Windows `titleBarOverlay` | Flutter 自绘的最小化 / 最大化 / 关闭按钮（`RaWindowCaptionButtons`） |
| CSS 过渡 | `RaPressable` 按状态变化给出时长：悬停出现 0、移开 150ms、按下 100ms。颜色按预乘 alpha 插值，与 CSS 一致。 |
| 0.5px 细线 | 按设备像素比取整：2 倍屏为 1 物理像素，1 倍屏为 1px |
| Nucleo 付费图标 | 不绑定图标库，默认内置 Lucide 同款几何 |

## 第一期范围

已完成：

- 设计变量三层
- 主题与扩展
- 组件：Button / IconButton / Tooltip / TextField + Form / Menu（子菜单、单选、右键菜单、触发器）/ Dialog + 确认框 / Toast / 侧栏组件 / 滚动条
- 窗口外壳：无标题栏、侧栏开合、内容面板、面板顶栏与面包屑、窗口按钮、窗口状态记忆、原生菜单栏与快捷键
- 守护规则
- 展示应用

后续可做：

- 标签栏（Chrome 式）
- 命令面板 ⌘K
- Tabs / SegmentedControl / SideCard
- Composer / Chat / Markdown
- 设置页版式
- 主题编辑器（OKLCH 推导）
- Windows / Linux 的原生编译验证（需要在对应系统上构建）
