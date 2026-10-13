// 设计变量 · 第三层：组件（Component）。
//
// 某个组件专用的取值（高度、内边距、圆角、各状态颜色……）。默认值由语义层推导（`fallback`），
// 可以引用语义层或基础层的尺寸刻度，也可以直接写组件独有的布局几何（px 宽度等）；
// 不写颜色、字号、字重、时长等字面量，也不做明暗切换（明暗由语义层负责）。
//
// 每个组件主题都可以整体替换（RaThemeData(button: …)），或在 fallback 结果上 copyWith。

import 'package:flutter/widgets.dart';

import '../icons/ra_glyph.dart';
import 'colors.dart';
import 'primitives.dart';
import 'semantic.dart';

/// 语义层整体：组件主题由它推导。
@immutable
class RaTokens {
  const RaTokens({
    required this.colors,
    required this.typography,
    required this.spacing,
    required this.radii,
    required this.sizing,
    required this.shadows,
    required this.motion,
    required this.opacity,
  });

  final RaColors colors;
  final RaTypography typography;
  final RaSpacing spacing;
  final RaRadii radii;
  final RaSizing sizing;
  final RaShadows shadows;
  final RaMotion motion;
  final RaOpacity opacity;
}

// ---------------------------------------------------------------------------
// 窗口外壳表面（侧栏所在的实色窗口底与内容面板）
// ---------------------------------------------------------------------------

/// 窗口底（`chrome`）与内容面板（`canvas`）。侧栏上的悬停 / 选中 / 按下只用半透明叠加色。
@immutable
class RaChromeThemeData {
  const RaChromeThemeData({
    required this.chrome,
    required this.chromeHover,
    required this.chromeSelected,
    required this.chromeActive,
    required this.chromeBorder,
    required this.chromeInk2,
    required this.chromeInk3,
    required this.canvas,
    required this.canvasBorder,
  });

  factory RaChromeThemeData.fallback(RaTokens t) => RaChromeThemeData(
    chrome: t.colors.surfaceWindow,
    chromeHover: t.colors.fillTranslucentHover,
    chromeSelected: t.colors.fillTranslucentSelected,
    chromeActive: t.colors.fillTranslucentActive,
    chromeBorder: t.colors.borderTranslucent,
    chromeInk2: t.colors.inkWindow2,
    chromeInk3: t.colors.inkWindow3,
    canvas: t.colors.surfaceCanvas,
    canvasBorder: t.colors.borderCanvas,
  );

  final Color chrome;
  final Color chromeHover;
  final Color chromeSelected;
  final Color chromeActive;
  final Color chromeBorder;
  final Color chromeInk2;
  final Color chromeInk3;
  final Color canvas;
  final Color canvasBorder;
}

// ---------------------------------------------------------------------------
// Button
// ---------------------------------------------------------------------------

/// 按钮变体。
enum RaButtonVariant {
  /// 主按钮（强调色）。
  primary,

  /// 次要按钮（默认）：白底 + 细线 + 淡阴影。
  secondary,

  /// 文字按钮（强调色文字）。
  ghost,

  /// 安静按钮：透明底、次要色文字。
  quiet,

  /// 危险（描边）。
  danger,

  /// 危险（实心）。
  dangerSolid,

  /// 卡片：整块可点击的结构化内容（纵向排列、自适应高度）。
  card,

  /// 列表项：整行可点击（纵向排列、自适应高度）。
  item,

  /// 输入框内的胶囊按钮。
  chip,

  /// 发送按钮（24px 圆形）。
  send,

  /// 只有图标的工具栏按钮（28px 圆形）；通常通过 RaIconButton 使用。
  icon,
}

enum RaButtonSize { sm, md, lg }

/// 内容排布：单行（固定高度）或块状（纵向排列、自适应高度）。
enum RaButtonLayout { inline, block }

/// 按钮样式。所有字段可空：空表示「沿用上一层」，用 [merge] 叠加（后者优先）。
@immutable
class RaButtonStyle {
  const RaButtonStyle({
    this.layout,
    this.height,
    this.square,
    this.padding,
    this.radius,
    this.gap,
    this.textStyle,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.shadows,
    this.disabledOpacity,
  });

  final RaButtonLayout? layout;

  /// 单行布局的高度。
  final double? height;

  /// 宽 = 高（图标按钮、发送按钮）。
  final bool? square;
  final EdgeInsetsGeometry? padding;
  final double? radius;

  /// 图标与文字的间距（块状布局为行距）。
  final double? gap;
  final TextStyle? textStyle;
  final WidgetStateProperty<Color?>? backgroundColor;
  final WidgetStateProperty<Color?>? foregroundColor;
  final WidgetStateProperty<Color?>? borderColor;
  final WidgetStateProperty<List<BoxShadow>?>? shadows;

  /// 禁用时整体透明度（图标按钮）。
  final double? disabledOpacity;

  RaButtonStyle merge(RaButtonStyle? other) {
    if (other == null) return this;
    return RaButtonStyle(
      layout: other.layout ?? layout,
      height: other.height ?? height,
      square: other.square ?? square,
      padding: other.padding ?? padding,
      radius: other.radius ?? radius,
      gap: other.gap ?? gap,
      textStyle: other.textStyle ?? textStyle,
      backgroundColor: other.backgroundColor ?? backgroundColor,
      foregroundColor: other.foregroundColor ?? foregroundColor,
      borderColor: other.borderColor ?? borderColor,
      shadows: other.shadows ?? shadows,
      disabledOpacity: other.disabledOpacity ?? disabledOpacity,
    );
  }

  RaButtonStyle copyWith({
    RaButtonLayout? layout,
    double? height,
    bool? square,
    EdgeInsetsGeometry? padding,
    double? radius,
    double? gap,
    TextStyle? textStyle,
    WidgetStateProperty<Color?>? backgroundColor,
    WidgetStateProperty<Color?>? foregroundColor,
    WidgetStateProperty<Color?>? borderColor,
    WidgetStateProperty<List<BoxShadow>?>? shadows,
    double? disabledOpacity,
  }) {
    return merge(
      RaButtonStyle(
        layout: layout,
        height: height,
        square: square,
        padding: padding,
        radius: radius,
        gap: gap,
        textStyle: textStyle,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        borderColor: borderColor,
        shadows: shadows,
        disabledOpacity: disabledOpacity,
      ),
    );
  }
}

/// 按状态取颜色的小工具：按顺序匹配第一个命中的状态。
WidgetStateProperty<Color?> raStateColor(
  Color? idle, {
  Color? hovered,
  Color? pressed,
  Color? selected,
  Color? disabled,
  bool disabledOverrides = true,
}) {
  return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) return disabledOverrides ? disabled ?? idle : idle;
    if (pressed != null && states.contains(WidgetState.pressed)) return pressed;
    if (selected != null && states.contains(WidgetState.selected)) return selected;
    if (hovered != null && states.contains(WidgetState.hovered)) return hovered;
    return idle;
  });
}

@immutable
class RaButtonThemeData {
  const RaButtonThemeData({
    required this.base,
    required this.sizes,
    required this.variants,
    required this.spinnerSize,
    required this.spinnerStrokeWidth,
  });

  factory RaButtonThemeData.fallback(RaTokens t) {
    final RaColors c = t.colors;
    final RaTypography ty = t.typography;
    final List<BoxShadow> raised = t.shadows.raised;
    final WidgetStateProperty<List<BoxShadow>?> raisedShadow =
        WidgetStatePropertyAll<List<BoxShadow>?>(raised);
    return RaButtonThemeData(
      spinnerSize: t.sizing.iconMd,
      spinnerStrokeWidth: t.sizing.iconStrokeBold,
      base: RaButtonStyle(
        layout: RaButtonLayout.inline,
        square: false,
        radius: t.radii.md,
        gap: t.spacing.sm,
        textStyle: ty.bodyMedium,
        disabledOpacity: 1,
      ),
      sizes: <RaButtonSize, RaButtonStyle>{
        RaButtonSize.sm: RaButtonStyle(
          height: RaSizes.s28,
          padding: EdgeInsets.symmetric(horizontal: t.spacing.md),
        ),
        RaButtonSize.md: RaButtonStyle(
          height: RaSizes.s32,
          padding: const EdgeInsets.symmetric(horizontal: RaSizes.s14),
        ),
        RaButtonSize.lg: RaButtonStyle(
          height: RaSizes.s40,
          padding: const EdgeInsets.symmetric(horizontal: RaSizes.s18),
          radius: t.radii.lg,
          textStyle: ty.style(
            size: ty.sizeMd,
            lineHeight: ty.lineHeightSm,
            weight: ty.weightMedium,
          ),
        ),
      },
      variants: <RaButtonVariant, RaButtonStyle>{
        RaButtonVariant.primary: RaButtonStyle(
          backgroundColor: raStateColor(c.accent, hovered: c.accentHover, disabled: c.disabledBg),
          foregroundColor: raStateColor(c.onAccent, disabled: c.disabledInk),
          shadows: raisedShadow,
        ),
        RaButtonVariant.secondary: RaButtonStyle(
          backgroundColor: raStateColor(
            c.surface,
            hovered: c.hover,
            disabled: RaPalette.transparent,
          ),
          foregroundColor: raStateColor(c.ink, disabled: c.disabledInk),
          borderColor: WidgetStatePropertyAll<Color?>(c.border),
          shadows: raisedShadow,
        ),
        RaButtonVariant.ghost: RaButtonStyle(
          padding: EdgeInsets.symmetric(horizontal: t.spacing.xs),
          backgroundColor: raStateColor(null, hovered: c.accentSoft),
          foregroundColor: raStateColor(c.accent, hovered: c.accentHover, disabled: c.disabledInk),
        ),
        RaButtonVariant.quiet: RaButtonStyle(
          padding: EdgeInsets.symmetric(horizontal: t.spacing.sm),
          backgroundColor: raStateColor(null, hovered: c.hover, selected: c.hover),
          foregroundColor: raStateColor(
            c.ink2,
            hovered: c.ink,
            selected: c.ink,
            disabled: c.disabledInk,
          ),
        ),
        RaButtonVariant.danger: RaButtonStyle(
          backgroundColor: raStateColor(
            c.surface,
            hovered: c.dangerWash,
            disabled: RaPalette.transparent,
          ),
          foregroundColor: raStateColor(c.danger, disabled: c.disabledInk),
          borderColor: WidgetStatePropertyAll<Color?>(c.dangerBorder),
        ),
        RaButtonVariant.dangerSolid: RaButtonStyle(
          backgroundColor: raStateColor(c.danger, disabled: c.disabledBg),
          foregroundColor: raStateColor(c.onDanger, disabled: c.disabledInk),
        ),
        RaButtonVariant.card: RaButtonStyle(
          layout: RaButtonLayout.block,
          padding: EdgeInsets.fromLTRB(RaSizes.s16, RaSizes.s16, RaSizes.s16, t.spacing.lg),
          radius: t.radii.md,
          gap: t.spacing.sm,
          textStyle: ty.body,
          backgroundColor: raStateColor(null, hovered: c.hover),
          foregroundColor: WidgetStatePropertyAll<Color?>(c.ink),
          borderColor: WidgetStatePropertyAll<Color?>(c.border),
        ),
        RaButtonVariant.item: RaButtonStyle(
          layout: RaButtonLayout.block,
          padding: EdgeInsets.symmetric(horizontal: t.spacing.lg, vertical: t.spacing.md),
          gap: t.spacing.xs3,
          textStyle: ty.body,
          backgroundColor: raStateColor(null, hovered: c.hover, selected: c.hover),
          foregroundColor: WidgetStatePropertyAll<Color?>(c.ink),
        ),
        RaButtonVariant.chip: RaButtonStyle(
          height: RaSizes.s24,
          padding: EdgeInsets.only(left: t.spacing.xs2, right: t.spacing.xs),
          gap: t.spacing.xs2,
          radius: t.radii.pill,
          textStyle: ty.captionMedium,
          backgroundColor: raStateColor(
            null,
            hovered: c.fillTranslucentHover,
            selected: c.fillTranslucentHover,
          ),
          foregroundColor: raStateColor(
            c.ink2,
            hovered: c.ink,
            selected: c.ink,
            disabled: c.disabledInk,
          ),
        ),
        RaButtonVariant.send: RaButtonStyle(
          height: RaSizes.s24,
          square: true,
          padding: EdgeInsets.zero,
          radius: t.radii.pill,
          backgroundColor: raStateColor(c.accent, hovered: c.accentHover, disabled: c.disabledBg),
          foregroundColor: raStateColor(c.onAccent, disabled: c.disabledInk),
          shadows: raisedShadow,
        ),
        RaButtonVariant.icon: RaButtonStyle(
          height: RaSizes.s28,
          square: true,
          padding: EdgeInsets.zero,
          radius: t.radii.pill,
          backgroundColor: raStateColor(
            null,
            hovered: c.fillTranslucentSelected,
            selected: c.fillTranslucentSelected,
            pressed: c.fillTranslucentActive,
          ),
          foregroundColor: raStateColor(
            c.inkWindow2,
            hovered: c.ink,
            selected: c.ink,
            pressed: c.ink,
            disabled: c.disabledInk,
          ),
          disabledOpacity: t.opacity.disabled,
        ),
      },
    );
  }

  /// 所有按钮共用。
  final RaButtonStyle base;

  /// 尺寸：sm 28 / md 32 / lg 40。
  final Map<RaButtonSize, RaButtonStyle> sizes;

  /// 变体：颜色与特殊几何。
  final Map<RaButtonVariant, RaButtonStyle> variants;
  final double spinnerSize;
  final double spinnerStrokeWidth;

  /// 解析某个变体 + 尺寸的最终样式（顺序：共用 → 尺寸 → 变体 → 实例）。
  RaButtonStyle resolve(RaButtonVariant variant, RaButtonSize size, [RaButtonStyle? override]) {
    return base.merge(sizes[size]).merge(variants[variant]).merge(override);
  }

  RaButtonThemeData copyWith({
    RaButtonStyle? base,
    Map<RaButtonSize, RaButtonStyle>? sizes,
    Map<RaButtonVariant, RaButtonStyle>? variants,
    double? spinnerSize,
    double? spinnerStrokeWidth,
  }) {
    return RaButtonThemeData(
      base: base ?? this.base,
      sizes: sizes ?? this.sizes,
      variants: variants ?? this.variants,
      spinnerSize: spinnerSize ?? this.spinnerSize,
      spinnerStrokeWidth: spinnerStrokeWidth ?? this.spinnerStrokeWidth,
    );
  }

  /// 只改某个变体（与默认样式叠加）。
  RaButtonThemeData withVariant(RaButtonVariant variant, RaButtonStyle style) {
    return copyWith(
      variants: <RaButtonVariant, RaButtonStyle>{
        ...variants,
        variant: (variants[variant] ?? const RaButtonStyle()).merge(style),
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Field
// ---------------------------------------------------------------------------

@immutable
class RaFieldThemeData {
  const RaFieldThemeData({
    required this.height,
    required this.radius,
    required this.padding,
    required this.multilinePadding,
    required this.gap,
    required this.formGap,
    required this.textStyle,
    required this.labelStyle,
    required this.descriptionStyle,
    required this.errorStyle,
    required this.placeholderColor,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    required this.shadows,
    required this.cursorColor,
    required this.selectionColor,
    required this.cursorWidth,
    required this.searchIconSize,
    required this.searchIconInset,
    required this.searchPaddingLeft,
    required this.searchIconColor,
  });

  factory RaFieldThemeData.fallback(RaTokens t) {
    final RaColors c = t.colors;
    return RaFieldThemeData(
      height: RaSizes.s32,
      radius: t.radii.md,
      padding: EdgeInsets.symmetric(horizontal: t.spacing.md, vertical: t.spacing.xs),
      multilinePadding: EdgeInsets.symmetric(horizontal: t.spacing.md, vertical: t.spacing.sm),
      gap: t.spacing.xs,
      formGap: t.spacing.xl,
      textStyle: t.typography.body,
      labelStyle: t.typography.bodyMedium.copyWith(color: c.ink),
      descriptionStyle: t.typography.caption.copyWith(color: c.ink3),
      errorStyle: t.typography.caption.copyWith(color: c.danger),
      placeholderColor: c.ink3,
      backgroundColor: raStateColor(c.surface, disabled: c.sunken),
      foregroundColor: raStateColor(c.ink, disabled: c.disabledInk),
      borderColor: WidgetStateProperty.resolveWith((Set<WidgetState> s) {
        if (s.contains(WidgetState.disabled)) return c.border;
        if (s.contains(WidgetState.error)) return c.danger;
        if (s.contains(WidgetState.focused)) return c.accent;
        if (s.contains(WidgetState.hovered)) return c.borderStrong;
        return c.border;
      }),
      shadows: t.shadows.raised,
      cursorColor: c.ink,
      selectionColor: c.selection,
      cursorWidth: RaSizes.s1,
      searchIconSize: t.sizing.iconMd,
      searchIconInset: t.spacing.md,
      searchPaddingLeft: RaSizes.s32,
      searchIconColor: c.ink3,
    );
  }

  final double height;
  final double radius;
  final EdgeInsets padding;
  final EdgeInsets multilinePadding;

  /// 标签、输入框、说明之间的间距。
  final double gap;

  /// 表单内字段之间的间距。
  final double formGap;
  final TextStyle textStyle;
  final TextStyle labelStyle;
  final TextStyle descriptionStyle;
  final TextStyle errorStyle;
  final Color placeholderColor;
  final WidgetStateProperty<Color?> backgroundColor;
  final WidgetStateProperty<Color?> foregroundColor;

  /// 状态：hovered → 较强描边；focused → 强调色；error → 危险色（无焦点环）。
  final WidgetStateProperty<Color?> borderColor;
  final List<BoxShadow> shadows;
  final Color cursorColor;
  final Color selectionColor;
  final double cursorWidth;
  final double searchIconSize;
  final double searchIconInset;
  final double searchPaddingLeft;
  final Color searchIconColor;
}

// ---------------------------------------------------------------------------
// Tooltip
// ---------------------------------------------------------------------------

@immutable
class RaTooltipThemeData {
  const RaTooltipThemeData({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    required this.shadows,
    required this.radius,
    required this.padding,
    required this.maxWidth,
    required this.textStyle,
    required this.shortcutStyle,
    required this.shortcutGap,
    required this.sideOffset,
    required this.screenMargin,
    required this.showDelay,
    required this.duration,
    required this.scale,
  });

  factory RaTooltipThemeData.fallback(RaTokens t) => RaTooltipThemeData(
    backgroundColor: t.colors.surface,
    foregroundColor: t.colors.ink,
    borderColor: t.colors.borderPopover,
    shadows: t.shadows.raised,
    radius: t.radii.md,
    padding: EdgeInsets.symmetric(vertical: RaSizes.s5, horizontal: t.spacing.sm),
    maxWidth: 280,
    textStyle: t.typography.micro,
    shortcutStyle: t.typography.kbd.copyWith(color: t.colors.ink2),
    shortcutGap: t.spacing.sm,
    sideOffset: t.spacing.xs,
    screenMargin: t.spacing.sm,
    showDelay: RaDurations.ms600,
    duration: t.motion.fast,
    scale: t.motion.scalePop,
  );

  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;
  final List<BoxShadow> shadows;
  final double radius;
  final EdgeInsets padding;
  final double maxWidth;
  final TextStyle textStyle;
  final TextStyle shortcutStyle;
  final double shortcutGap;

  /// 与触发元素的距离。
  final double sideOffset;

  /// 与窗口边缘的最小距离。
  final double screenMargin;

  /// 悬停多久后出现。
  final Duration showDelay;
  final Duration duration;
  final double scale;
}

// ---------------------------------------------------------------------------
// Menu
// ---------------------------------------------------------------------------

/// 菜单：1:1 对照 Linear 下拉菜单（圆角 12、上下内边距 6、行高 32、文字距浮层左缘 14、
/// 高亮块左右缩进 6 且圆角 6、分隔线贯穿全宽且上下各 6、快捷键 / 附注 12px 常规灰、子菜单实心 ▸、对勾在行尾）。
@immutable
class RaMenuThemeData {
  const RaMenuThemeData({
    required this.backgroundColor,
    required this.borderColor,
    required this.shadows,
    required this.minWidth,
    required this.maxWidth,
    required this.radius,
    required this.padding,
    required this.itemHeight,
    required this.itemPaddingX,
    required this.itemRadius,
    required this.itemGap,
    required this.itemTextStyle,
    required this.itemColor,
    required this.highlightColor,
    required this.disabledColor,
    required this.dangerColor,
    required this.headerPadding,
    required this.headerStyle,
    required this.headerStrongStyle,
    required this.metaStyle,
    required this.metaGap,
    required this.indicatorSize,
    required this.checkColor,
    required this.submenuIconSize,
    required this.submenuIconColor,
    required this.separatorColor,
    required this.separatorGap,
    required this.sideOffset,
    required this.screenMargin,
    required this.enterOffset,
    required this.scale,
    required this.duration,
    required this.submenuHoverDelay,
    required this.triggerPill,
    required this.triggerChip,
    required this.triggerRow,
    required this.avatarSize,
    required this.avatarBackground,
    required this.avatarForeground,
    required this.avatarTextStyle,
  });

  factory RaMenuThemeData.fallback(RaTokens t) {
    final RaColors c = t.colors;
    final RaTypography ty = t.typography;
    return RaMenuThemeData(
      backgroundColor: c.surface,
      borderColor: c.borderPopover,
      shadows: t.shadows.popup,
      minWidth: 224,
      maxWidth: 360,
      radius: t.radii.xl,
      padding: t.spacing.xs,
      itemHeight: RaSizes.s32,
      itemPaddingX: t.spacing.sm,
      itemRadius: t.radii.sm,
      itemGap: t.spacing.sm,
      itemTextStyle: ty.body,
      itemColor: c.ink,
      highlightColor: c.hover,
      disabledColor: c.disabledInk,
      dangerColor: c.danger,
      headerPadding: EdgeInsets.symmetric(vertical: t.spacing.xs, horizontal: t.spacing.sm),
      headerStyle: ty.caption.copyWith(color: c.ink3),
      headerStrongStyle: ty.body.copyWith(color: c.ink),
      metaStyle: ty.caption.copyWith(color: c.ink2),
      metaGap: t.spacing.xl,
      indicatorSize: t.sizing.iconSm,
      checkColor: c.accent,
      submenuIconSize: t.sizing.iconXs,
      submenuIconColor: c.ink3,
      separatorColor: c.border,
      separatorGap: t.spacing.xs,
      sideOffset: t.spacing.xs,
      screenMargin: t.spacing.sm,
      enterOffset: RaSizes.s4,
      scale: t.motion.scalePop,
      duration: t.motion.fast,
      submenuHoverDelay: t.motion.base,
      triggerPill: RaButtonStyle(
        height: RaSizes.s36,
        padding: EdgeInsets.only(left: t.spacing.xs2, right: t.spacing.md),
        gap: t.spacing.sm,
        radius: t.radii.pill,
        textStyle: ty.body,
        backgroundColor: raStateColor(c.surface, hovered: c.hover, selected: c.hover),
        foregroundColor: raStateColor(c.ink, disabled: c.disabledInk),
        borderColor: WidgetStatePropertyAll<Color?>(c.border),
        shadows: WidgetStatePropertyAll<List<BoxShadow>?>(t.shadows.raised),
      ),
      triggerChip: RaButtonStyle(
        height: RaSizes.s24,
        padding: EdgeInsets.only(left: t.spacing.xs2, right: t.spacing.xs),
        gap: t.spacing.xs2,
        radius: t.radii.pill,
        textStyle: ty.captionMedium,
        backgroundColor: raStateColor(
          null,
          hovered: c.fillTranslucentHover,
          selected: c.fillTranslucentHover,
        ),
        foregroundColor: raStateColor(
          c.ink2,
          hovered: c.ink,
          selected: c.ink,
          disabled: c.disabledInk,
        ),
      ),
      triggerRow: RaButtonStyle(
        height: RaSizes.s36,
        padding: EdgeInsets.symmetric(horizontal: t.spacing.xs),
        gap: t.spacing.xs,
        radius: t.radii.md,
        textStyle: ty.bodyMedium,
        backgroundColor: raStateColor(
          null,
          hovered: c.fillTranslucentHover,
          pressed: c.fillTranslucentActive,
          selected: c.fillTranslucentActive,
        ),
        foregroundColor: WidgetStatePropertyAll<Color?>(c.ink),
      ),
      avatarSize: RaSizes.s28,
      avatarBackground: c.accentSoft,
      avatarForeground: c.accentInk,
      avatarTextStyle: ty.style(
        size: ty.sizeXs,
        lineHeight: ty.lineHeightXs,
        weight: ty.weightBold,
      ),
    );
  }

  final Color backgroundColor;
  final Color borderColor;
  final List<BoxShadow> shadows;
  final double minWidth;
  final double maxWidth;
  final double radius;

  /// 浮层上下左右内边距（也是高亮块的左右缩进）。
  final double padding;
  final double itemHeight;

  /// 选项文字距高亮块左缘（与 [padding] 相加 = 文字距浮层左缘 14）。
  final double itemPaddingX;
  final double itemRadius;
  final double itemGap;
  final TextStyle itemTextStyle;
  final Color itemColor;
  final Color highlightColor;
  final Color disabledColor;
  final Color dangerColor;
  final EdgeInsets headerPadding;
  final TextStyle headerStyle;
  final TextStyle headerStrongStyle;

  /// 快捷键 / 附注。
  final TextStyle metaStyle;
  final double metaGap;

  /// 行尾对勾、子菜单箭头的图标位。
  final double indicatorSize;
  final Color checkColor;
  final double submenuIconSize;
  final Color submenuIconColor;
  final Color separatorColor;
  final double separatorGap;
  final double sideOffset;
  final double screenMargin;

  /// 进场位移：向下弹出时从上方来，向上弹出时从下方来。
  final double enterOffset;
  final double scale;
  final Duration duration;

  /// 悬停子菜单入口多久后展开。
  final Duration submenuHoverDelay;

  /// 触发按钮：账户等胶囊按钮。
  final RaButtonStyle triggerPill;

  /// 触发按钮：输入框上方的选择器。
  final RaButtonStyle triggerChip;

  /// 触发按钮：侧栏整行（如 Workspace 选择器）。
  final RaButtonStyle triggerRow;
  final double avatarSize;
  final Color avatarBackground;
  final Color avatarForeground;
  final TextStyle avatarTextStyle;
}

// ---------------------------------------------------------------------------
// Dialog
// ---------------------------------------------------------------------------

@immutable
class RaDialogThemeData {
  const RaDialogThemeData({
    required this.width,
    required this.screenMargin,
    required this.verticalMargin,
    required this.radius,
    required this.padding,
    required this.gap,
    required this.backgroundColor,
    required this.borderColor,
    required this.shadows,
    required this.barrierColor,
    required this.titleStyle,
    required this.descriptionStyle,
    required this.footerGap,
    required this.footerTopGap,
    required this.enterOffsetFraction,
    required this.duration,
  });

  factory RaDialogThemeData.fallback(RaTokens t) => RaDialogThemeData(
    width: 460,
    screenMargin: RaSizes.s16,
    verticalMargin: RaSizes.s32,
    radius: t.radii.xl,
    padding: t.spacing.xl3,
    gap: t.spacing.lg,
    backgroundColor: t.colors.surface,
    borderColor: t.colors.borderPopover,
    shadows: t.shadows.dialog,
    barrierColor: t.colors.overlay,
    titleStyle: t.typography.title.copyWith(color: t.colors.ink),
    descriptionStyle: t.typography.body.copyWith(color: t.colors.ink2),
    footerGap: t.spacing.sm,
    footerTopGap: t.spacing.sm,
    enterOffsetFraction: RaNumbers.fraction2,
    duration: t.motion.base,
  );

  /// 宽度上限：min(460, 窗口宽 - 2 × [screenMargin])。
  final double width;
  final double screenMargin;

  /// 最大高度：窗口高 - 2 × [verticalMargin]。
  final double verticalMargin;
  final double radius;
  final double padding;
  final double gap;
  final Color backgroundColor;
  final Color borderColor;
  final List<BoxShadow> shadows;
  final Color barrierColor;
  final TextStyle titleStyle;
  final TextStyle descriptionStyle;
  final double footerGap;
  final double footerTopGap;

  /// 进场时向下偏移自身高度的比例（2%）。
  final double enterOffsetFraction;
  final Duration duration;
}

// ---------------------------------------------------------------------------
// Toast
// ---------------------------------------------------------------------------

@immutable
class RaToastThemeData {
  const RaToastThemeData({
    required this.backgroundColor,
    required this.borderColor,
    required this.shadows,
    required this.radius,
    required this.padding,
    required this.gap,
    required this.contentGap,
    required this.width,
    required this.viewportMargin,
    required this.stackGap,
    required this.iconSize,
    required this.iconTopOffset,
    required this.successColor,
    required this.errorColor,
    required this.titleStyle,
    required this.descriptionStyle,
    required this.closeSize,
    required this.closeIconSize,
    required this.closeRadius,
    required this.closeColor,
    required this.closeHoverColor,
    required this.enterOffset,
    required this.duration,
    required this.displayDuration,
  });

  factory RaToastThemeData.fallback(RaTokens t) => RaToastThemeData(
    backgroundColor: t.colors.surface,
    borderColor: t.colors.borderPopover,
    shadows: t.shadows.popup,
    radius: t.radii.xl,
    padding: t.spacing.lg,
    gap: t.spacing.md,
    contentGap: t.spacing.xs3,
    width: 360,
    viewportMargin: t.spacing.xl2,
    stackGap: t.spacing.sm,
    iconSize: t.sizing.iconMd,
    iconTopOffset: t.spacing.xs3,
    successColor: t.colors.success,
    errorColor: t.colors.danger,
    titleStyle: t.typography.bodyMedium.copyWith(color: t.colors.ink),
    descriptionStyle: t.typography.body.copyWith(color: t.colors.ink2),
    closeSize: RaSizes.s20,
    closeIconSize: t.sizing.iconSm,
    closeRadius: t.radii.sm,
    closeColor: t.colors.ink3,
    closeHoverColor: t.colors.ink,
    enterOffset: RaSizes.s8,
    duration: t.motion.base,
    displayDuration: RaDurations.s5,
  );

  final Color backgroundColor;
  final Color borderColor;
  final List<BoxShadow> shadows;
  final double radius;
  final double padding;
  final double gap;
  final double contentGap;

  /// 宽度上限：min(360, 窗口宽 - 2 × [viewportMargin])。
  final double width;
  final double viewportMargin;
  final double stackGap;
  final double iconSize;

  /// 16px 图标与首行（20px 行高）垂直居中。
  final double iconTopOffset;
  final Color successColor;
  final Color errorColor;
  final TextStyle titleStyle;
  final TextStyle descriptionStyle;
  final double closeSize;
  final double closeIconSize;
  final double closeRadius;
  final Color closeColor;
  final Color closeHoverColor;
  final double enterOffset;
  final Duration duration;

  /// 自动消失前的停留时间（悬停时暂停）。
  final Duration displayDuration;
}

// ---------------------------------------------------------------------------
// Sidebar
// ---------------------------------------------------------------------------

/// 侧栏（Linear：行高 28、行距 1、圆角 8；左内边距 8 + 图标 14 + 间距 6 = 文字左缘 28）。
@immutable
class RaSidebarThemeData {
  const RaSidebarThemeData({
    required this.rowGap,
    required this.sectionGap,
    required this.sectionHeadHeight,
    required this.sectionHeadPadding,
    required this.sectionHeadBottomGap,
    required this.sectionToggleGap,
    required this.sectionTitleStyle,
    required this.sectionTitleColor,
    required this.caretSize,
    required this.caretColor,
    required this.sectionActionSize,
    required this.itemHeight,
    required this.itemPaddingX,
    required this.itemGap,
    required this.itemRadius,
    required this.itemIndentChild,
    required this.itemIconSize,
    required this.itemTextStyle,
    required this.itemColor,
    required this.itemMutedColor,
    required this.itemActiveColor,
    required this.hoverColor,
    required this.selectedColor,
    required this.pressedColor,
    required this.trailingStyle,
    required this.shortcutStyle,
    required this.dotSize,
    required this.dotSizeSmall,
    required this.dotHaloWidth,
    required this.dotAttention,
    required this.dotRunning,
    required this.dotRunningHalo,
    required this.dotOnline,
    required this.dotOffline,
    required this.emptyStyle,
  });

  factory RaSidebarThemeData.fallback(RaTokens t) {
    final RaColors c = t.colors;
    return RaSidebarThemeData(
      rowGap: RaSizes.s1,
      sectionGap: t.spacing.xl,
      sectionHeadHeight: RaSizes.s28,
      sectionHeadPadding: EdgeInsets.only(left: RaSizes.s9, right: t.spacing.xs2),
      sectionHeadBottomGap: t.spacing.xs3,
      sectionToggleGap: t.spacing.xs2,
      sectionTitleStyle: t.typography.captionMedium,
      sectionTitleColor: c.inkWindow2,
      caretSize: t.sizing.icon2xs,
      caretColor: c.inkWindow3,
      sectionActionSize: RaSizes.s22,
      itemHeight: RaSizes.s28,
      itemPaddingX: t.spacing.sm,
      itemGap: t.spacing.xs,
      itemRadius: t.radii.md,
      itemIndentChild: RaSizes.s28,
      itemIconSize: t.sizing.iconSm,
      itemTextStyle: t.typography.bodyMedium,
      itemColor: c.inkWindow2,
      itemMutedColor: c.inkWindow3,
      itemActiveColor: c.ink,
      hoverColor: c.fillTranslucentHover,
      selectedColor: c.fillTranslucentSelected,
      pressedColor: c.fillTranslucentActive,
      trailingStyle: t.typography.caption.copyWith(color: c.inkWindow3),
      shortcutStyle: t.typography.kbd.copyWith(color: c.ink2),
      dotSize: RaSizes.s7,
      dotSizeSmall: RaSizes.s6,
      dotHaloWidth: RaSizes.s3,
      dotAttention: c.attention,
      dotRunning: c.success,
      dotRunningHalo: c.successSoft,
      dotOnline: c.success,
      dotOffline: c.ink3,
      emptyStyle: t.typography.caption.copyWith(color: c.inkWindow3),
    );
  }

  final double rowGap;
  final double sectionGap;
  final double sectionHeadHeight;
  final EdgeInsets sectionHeadPadding;
  final double sectionHeadBottomGap;
  final double sectionToggleGap;
  final TextStyle sectionTitleStyle;
  final Color sectionTitleColor;

  /// 分组 / 树形展开用的实心小三角。
  final double caretSize;
  final Color caretColor;
  final double sectionActionSize;
  final double itemHeight;
  final double itemPaddingX;
  final double itemGap;
  final double itemRadius;

  /// 子项文字左缩进（与带图标行文字左缘对齐）。
  final double itemIndentChild;
  final double itemIconSize;
  final TextStyle itemTextStyle;

  /// 默认次要色，悬停 / 选中变为 [itemActiveColor]。
  final Color itemColor;
  final Color itemMutedColor;
  final Color itemActiveColor;

  /// 半透明叠加色（不得用实色）。
  final Color hoverColor;
  final Color selectedColor;
  final Color pressedColor;
  final TextStyle trailingStyle;
  final TextStyle shortcutStyle;
  final double dotSize;
  final double dotSizeSmall;
  final double dotHaloWidth;
  final Color dotAttention;
  final Color dotRunning;
  final Color dotRunningHalo;
  final Color dotOnline;
  final Color dotOffline;
  final TextStyle emptyStyle;
}

// ---------------------------------------------------------------------------
// Scrollbar
// ---------------------------------------------------------------------------

@immutable
class RaScrollbarThemeData {
  const RaScrollbarThemeData({
    required this.thickness,
    required this.margin,
    required this.radius,
    required this.thumbColor,
    required this.fadeDuration,
    required this.timeToFade,
  });

  factory RaScrollbarThemeData.fallback(RaTokens t) => RaScrollbarThemeData(
    thickness: RaSizes.s4,
    margin: t.spacing.xs3,
    radius: t.radii.pill,
    thumbColor: t.colors.scrollbarThumb,
    fadeDuration: t.motion.base,
    timeToFade: RaDurations.ms600,
  );

  /// 滑块粗细（滚动条宽 8 = 滑块 4 + 两侧各 2）。
  final double thickness;
  final double margin;
  final double radius;
  final Color thumbColor;
  final Duration fadeDuration;
  final Duration timeToFade;
}

// ---------------------------------------------------------------------------
// Icon
// ---------------------------------------------------------------------------

/// 组件内部用到的图标（对勾、箭头、关闭……）。默认是内置的 Lucide 同款线条，
/// 可以逐个替换成任意图标库：`RaIconSet.fallback().copyWith(check: RaGlyph.icon(MyIcons.check))`。
@immutable
class RaIconSet {
  const RaIconSet({
    required this.check,
    required this.chevronDown,
    required this.chevronRight,
    required this.chevronLeft,
    required this.caretDown,
    required this.caretRight,
    required this.close,
    required this.search,
    required this.circleCheck,
    required this.circleX,
    required this.windowMinimize,
    required this.windowMaximize,
    required this.windowRestore,
    required this.windowClose,
  });

  factory RaIconSet.fallback() => const RaIconSet(
    check: RaGlyphs.check,
    chevronDown: RaGlyphs.chevronDown,
    chevronRight: RaGlyphs.chevronRight,
    chevronLeft: RaGlyphs.chevronLeft,
    caretDown: RaGlyphs.caretDown,
    caretRight: RaGlyphs.caretRight,
    close: RaGlyphs.x,
    search: RaGlyphs.search,
    circleCheck: RaGlyphs.circleCheck,
    circleX: RaGlyphs.circleX,
    windowMinimize: RaGlyphs.windowMinimize,
    windowMaximize: RaGlyphs.windowMaximize,
    windowRestore: RaGlyphs.windowRestore,
    windowClose: RaGlyphs.windowClose,
  );

  final RaGlyph check;
  final RaGlyph chevronDown;
  final RaGlyph chevronRight;
  final RaGlyph chevronLeft;

  /// 实心小三角 ▾（侧栏分组）。
  final RaGlyph caretDown;

  /// 实心小三角 ▸（子菜单）。
  final RaGlyph caretRight;
  final RaGlyph close;
  final RaGlyph search;
  final RaGlyph circleCheck;
  final RaGlyph circleX;
  final RaGlyph windowMinimize;
  final RaGlyph windowMaximize;
  final RaGlyph windowRestore;
  final RaGlyph windowClose;

  RaIconSet copyWith({
    RaGlyph? check,
    RaGlyph? chevronDown,
    RaGlyph? chevronRight,
    RaGlyph? chevronLeft,
    RaGlyph? caretDown,
    RaGlyph? caretRight,
    RaGlyph? close,
    RaGlyph? search,
    RaGlyph? circleCheck,
    RaGlyph? circleX,
    RaGlyph? windowMinimize,
    RaGlyph? windowMaximize,
    RaGlyph? windowRestore,
    RaGlyph? windowClose,
  }) {
    return RaIconSet(
      check: check ?? this.check,
      chevronDown: chevronDown ?? this.chevronDown,
      chevronRight: chevronRight ?? this.chevronRight,
      chevronLeft: chevronLeft ?? this.chevronLeft,
      caretDown: caretDown ?? this.caretDown,
      caretRight: caretRight ?? this.caretRight,
      close: close ?? this.close,
      search: search ?? this.search,
      circleCheck: circleCheck ?? this.circleCheck,
      circleX: circleX ?? this.circleX,
      windowMinimize: windowMinimize ?? this.windowMinimize,
      windowMaximize: windowMaximize ?? this.windowMaximize,
      windowRestore: windowRestore ?? this.windowRestore,
      windowClose: windowClose ?? this.windowClose,
    );
  }
}
