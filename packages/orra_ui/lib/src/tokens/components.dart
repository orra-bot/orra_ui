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
            hovered: c.surfaceHover,
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
    required this.trailingPaddingRight,
    required this.trailingGap,
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
      trailingPaddingRight: t.spacing.xs2,
      trailingGap: t.spacing.xs,
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

  /// 输入框内带尾部控件（RaTextField.trailing）时的右内边距与间距。
  final double trailingPaddingRight;
  final double trailingGap;
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
    required this.triggerPillPlainPadding,
    required this.triggerChipPlainPadding,
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
      submenuHoverDelay: RaDurations.ms150,
      triggerPill: RaButtonStyle(
        height: RaSizes.s36,
        padding: EdgeInsets.only(left: t.spacing.xs2, right: t.spacing.md),
        gap: t.spacing.sm,
        radius: t.radii.pill,
        textStyle: ty.body,
        backgroundColor: raStateColor(c.surface, hovered: c.surfaceHover, selected: c.surfaceHover),
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
      triggerPillPlainPadding: EdgeInsets.only(left: t.spacing.lg, right: t.spacing.md),
      triggerChipPlainPadding: EdgeInsets.only(left: t.spacing.sm, right: t.spacing.xs),
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

  /// 胶囊 / chip 触发器没有前置图标时的内边距（有图标时左侧收紧到 4，贴合头像）。
  final EdgeInsets triggerPillPlainPadding;
  final EdgeInsets triggerChipPlainPadding;
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
    required this.scale,
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
    scale: t.motion.scalePop,
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

  /// 打开 / 关闭时的起止缩放（0.96 ↔ 1，配合淡入淡出）。
  final double scale;
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
    required this.hoverExitDuration,
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
      hoverExitDuration: t.motion.instant,
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

  /// 悬停移开时底色消失的时长（侧栏不做淡出，直接消失）。
  final Duration hoverExitDuration;
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
// Tabs
// ---------------------------------------------------------------------------

/// 页面内标签（横排或竖排）：32px 行、圆角 8；默认次要色，悬停 / 当前项变为正文色，底色只用半透明叠加色。
@immutable
class RaTabsThemeData {
  const RaTabsThemeData({
    required this.height,
    required this.paddingX,
    required this.gap,
    required this.radius,
    required this.listGap,
    required this.iconSize,
    required this.textStyle,
    required this.color,
    required this.activeColor,
    required this.disabledColor,
    required this.hoverColor,
    required this.selectedColor,
    required this.pressedColor,
  });

  factory RaTabsThemeData.fallback(RaTokens t) => RaTabsThemeData(
    height: RaSizes.s32,
    paddingX: t.spacing.lg,
    gap: t.spacing.md,
    radius: t.radii.md,
    listGap: t.spacing.xs3,
    iconSize: t.sizing.iconSm,
    textStyle: t.typography.bodyMedium,
    color: t.colors.ink2,
    activeColor: t.colors.ink,
    disabledColor: t.colors.disabledInk,
    hoverColor: t.colors.fillTranslucentHover,
    selectedColor: t.colors.fillTranslucentSelected,
    pressedColor: t.colors.fillTranslucentActive,
  );

  final double height;
  final double paddingX;

  /// 图标与文字的间距。
  final double gap;
  final double radius;

  /// 标签之间的间距。
  final double listGap;
  final double iconSize;
  final TextStyle textStyle;
  final Color color;
  final Color activeColor;
  final Color disabledColor;
  final Color hoverColor;
  final Color selectedColor;
  final Color pressedColor;
}

// ---------------------------------------------------------------------------
// SegmentedControl
// ---------------------------------------------------------------------------

/// 分段切换：凹陷底槽（内边距 2、圆角 8），选中段为白底 + 淡阴影的滑块（圆角 6、高 26），切换时滑到新位置。
@immutable
class RaSegmentedControlThemeData {
  const RaSegmentedControlThemeData({
    required this.padding,
    required this.radius,
    required this.backgroundColor,
    required this.itemHeight,
    required this.itemPaddingX,
    required this.itemRadius,
    required this.textStyle,
    required this.selectedTextStyle,
    required this.color,
    required this.hoverColor,
    required this.selectedColor,
    required this.disabledColor,
    required this.selectedBackgroundColor,
    required this.selectedShadows,
    required this.thumbDuration,
    required this.thumbCurve,
  });

  factory RaSegmentedControlThemeData.fallback(RaTokens t) => RaSegmentedControlThemeData(
    padding: t.spacing.xs3,
    radius: t.radii.md,
    backgroundColor: t.colors.sunken,
    itemHeight: RaSizes.s26,
    itemPaddingX: t.spacing.xl,
    itemRadius: t.radii.sm,
    textStyle: t.typography.body,
    selectedTextStyle: t.typography.bodyMedium,
    color: t.colors.ink2,
    hoverColor: t.colors.ink,
    selectedColor: t.colors.ink,
    disabledColor: t.colors.disabledInk,
    selectedBackgroundColor: t.colors.surface,
    selectedShadows: t.shadows.raised,
    thumbDuration: t.motion.slow,
    thumbCurve: t.motion.emphasized,
  );

  final double padding;
  final double radius;
  final Color backgroundColor;
  final double itemHeight;
  final double itemPaddingX;
  final double itemRadius;
  final TextStyle textStyle;
  final TextStyle selectedTextStyle;
  final Color color;
  final Color hoverColor;
  final Color selectedColor;
  final Color disabledColor;
  final Color selectedBackgroundColor;
  final List<BoxShadow> selectedShadows;

  /// 选中滑块移到新位置的时长与缓动。
  final Duration thumbDuration;
  final Curve thumbCurve;
}

// ---------------------------------------------------------------------------
// Tag
// ---------------------------------------------------------------------------

/// 标签语气：neutral 中性 · success 成功 · attention 需要处理 · accent 强调 · danger 危险 ·
/// outline 虚线描边（未开放 / 占位）· muted 弱化。
enum RaTagTone { neutral, success, attention, accent, danger, outline, muted }

/// 一种语气的配色。
@immutable
class RaTagStyle {
  const RaTagStyle({
    required this.foregroundColor,
    this.backgroundColor,
    this.borderColor,
    this.dashed = false,
  });

  final Color foregroundColor;
  final Color? backgroundColor;
  final Color? borderColor;

  /// 描边为虚线。
  final bool dashed;
}

/// 状态标签（20 高胶囊、12px / 500、可带 6px 圆点）与计数徽标。
@immutable
class RaTagThemeData {
  const RaTagThemeData({
    required this.height,
    required this.paddingX,
    required this.gap,
    required this.radius,
    required this.dotSize,
    required this.textStyle,
    required this.tones,
    required this.dashLength,
    required this.dashGap,
    required this.countSize,
    required this.countPaddingX,
    required this.countBackgroundColor,
    required this.countTextStyle,
  });

  factory RaTagThemeData.fallback(RaTokens t) {
    final RaColors c = t.colors;
    return RaTagThemeData(
      height: RaSizes.s20,
      paddingX: t.spacing.sm,
      gap: t.spacing.xs,
      radius: t.radii.pill,
      dotSize: RaSizes.s6,
      textStyle: t.typography.captionMedium,
      tones: <RaTagTone, RaTagStyle>{
        RaTagTone.neutral: RaTagStyle(backgroundColor: c.sunken, foregroundColor: c.ink2),
        RaTagTone.success: RaTagStyle(backgroundColor: c.successSoft, foregroundColor: c.success),
        RaTagTone.attention: RaTagStyle(
          backgroundColor: c.attentionSoft,
          foregroundColor: c.attentionInk,
        ),
        RaTagTone.accent: RaTagStyle(backgroundColor: c.accentSoft, foregroundColor: c.accentInk),
        RaTagTone.danger: RaTagStyle(backgroundColor: c.dangerWash, foregroundColor: c.dangerInk),
        RaTagTone.outline: RaTagStyle(
          borderColor: c.borderStrong,
          foregroundColor: c.ink3,
          dashed: true,
        ),
        RaTagTone.muted: RaTagStyle(
          backgroundColor: c.ground,
          borderColor: c.border,
          foregroundColor: c.ink3,
        ),
      },
      dashLength: RaSizes.s3,
      dashGap: RaSizes.s2,
      countSize: RaSizes.s20,
      countPaddingX: t.spacing.xs,
      countBackgroundColor: c.attention,
      countTextStyle: t.typography.style(
        size: t.typography.sizeXs,
        lineHeight: t.typography.lineHeightXs,
        weight: t.typography.weightBold,
        color: c.surface,
        tabularFigures: true,
      ),
    );
  }

  final double height;
  final double paddingX;
  final double gap;
  final double radius;
  final double dotSize;
  final TextStyle textStyle;
  final Map<RaTagTone, RaTagStyle> tones;

  /// 虚线描边的线段与间隔长度。
  final double dashLength;
  final double dashGap;
  final double countSize;
  final double countPaddingX;
  final Color countBackgroundColor;
  final TextStyle countTextStyle;

  RaTagStyle styleOf(RaTagTone tone) => tones[tone] ?? tones[RaTagTone.neutral]!;
}

// ---------------------------------------------------------------------------
// SideCard / PropertyRow
// ---------------------------------------------------------------------------

/// 右侧栏属性卡片（Linear）：白底、0.5px 描边、圆角 10；标题 28 高可折叠；属性行 28 高、标签列 90。
@immutable
class RaSideCardThemeData {
  const RaSideCardThemeData({
    required this.backgroundColor,
    required this.borderColor,
    required this.shadows,
    required this.radius,
    required this.padding,
    required this.headHeight,
    required this.headGap,
    required this.titleStyle,
    required this.titleColor,
    required this.titleHoverColor,
    required this.caretSize,
    required this.caretColor,
    required this.actionSize,
    required this.bodyPaddingY,
    required this.rowGap,
    required this.rowHeight,
    required this.rowColumnGap,
    required this.labelWidth,
    required this.labelStyle,
    required this.valueStyle,
    required this.valueGap,
  });

  factory RaSideCardThemeData.fallback(RaTokens t) => RaSideCardThemeData(
    backgroundColor: t.colors.surface,
    borderColor: t.colors.borderPopover,
    shadows: t.shadows.raised,
    radius: t.radii.lg,
    padding: EdgeInsets.symmetric(horizontal: t.spacing.lg, vertical: t.spacing.xs),
    headHeight: RaSizes.s28,
    headGap: t.spacing.xs,
    titleStyle: t.typography.bodyMedium,
    titleColor: t.colors.ink2,
    titleHoverColor: t.colors.ink,
    caretSize: t.sizing.icon2xs,
    caretColor: t.colors.ink3,
    actionSize: RaSizes.s28,
    bodyPaddingY: t.spacing.xs,
    rowGap: t.spacing.sm,
    rowHeight: RaSizes.s28,
    rowColumnGap: t.spacing.sm,
    labelWidth: 90,
    labelStyle: t.typography.caption.copyWith(color: t.colors.ink2),
    valueStyle: t.typography.caption.copyWith(color: t.colors.ink),
    valueGap: t.spacing.xs,
  );

  final Color backgroundColor;
  final Color borderColor;
  final List<BoxShadow> shadows;
  final double radius;
  final EdgeInsets padding;
  final double headHeight;

  /// 标题与小三角的间距。
  final double headGap;
  final TextStyle titleStyle;
  final Color titleColor;
  final Color titleHoverColor;
  final double caretSize;
  final Color caretColor;
  final double actionSize;

  /// 内容区上下留白（与卡片内边距相加，标题与首行、末行与卡片底各 12）。
  final double bodyPaddingY;
  final double rowGap;
  final double rowHeight;
  final double rowColumnGap;
  final double labelWidth;
  final TextStyle labelStyle;
  final TextStyle valueStyle;

  /// 值内多个元素（图标 + 文字、标签……）的间距。
  final double valueGap;
}

// ---------------------------------------------------------------------------
// State blocks（加载 / 空 / 错误）
// ---------------------------------------------------------------------------

@immutable
class RaStateBlockThemeData {
  const RaStateBlockThemeData({
    required this.radius,
    required this.padding,
    required this.gap,
    required this.titleStyle,
    required this.errorTitleColor,
    required this.textStyle,
    required this.actionTopGap,
    required this.loadingBackgroundColor,
    required this.loadingBorderColor,
    required this.emptyBorderColor,
    required this.errorBackgroundColor,
    required this.errorBorderColor,
    required this.dashLength,
    required this.dashGap,
    required this.skeletonHeight,
    required this.skeletonRadius,
    required this.skeletonColor,
    required this.skeletonWidths,
  });

  factory RaStateBlockThemeData.fallback(RaTokens t) {
    final RaColors c = t.colors;
    final RaTypography ty = t.typography;
    return RaStateBlockThemeData(
      radius: t.radii.xl,
      padding: t.spacing.xl2,
      gap: t.spacing.sm,
      titleStyle: ty.style(
        size: ty.sizeMd,
        lineHeight: ty.lineHeightMd,
        weight: ty.weightSemibold,
        color: c.ink,
      ),
      errorTitleColor: c.dangerInk,
      textStyle: ty.body.copyWith(color: c.ink2),
      actionTopGap: t.spacing.xs3,
      loadingBackgroundColor: c.surface,
      loadingBorderColor: c.border,
      emptyBorderColor: c.borderStrong,
      errorBackgroundColor: c.dangerWash,
      errorBorderColor: c.dangerBorder,
      dashLength: RaSizes.s4,
      dashGap: RaSizes.s3,
      skeletonHeight: RaSizes.s12,
      skeletonRadius: t.radii.sm,
      skeletonColor: c.sunken,
      skeletonWidths: const <double>[0.6, 0.85, 0.4],
    );
  }

  final double radius;
  final double padding;
  final double gap;
  final TextStyle titleStyle;
  final Color errorTitleColor;
  final TextStyle textStyle;
  final double actionTopGap;
  final Color loadingBackgroundColor;
  final Color loadingBorderColor;

  /// 空状态为虚线描边。
  final Color emptyBorderColor;
  final Color errorBackgroundColor;
  final Color errorBorderColor;
  final double dashLength;
  final double dashGap;
  final double skeletonHeight;
  final double skeletonRadius;
  final Color skeletonColor;

  /// 加载骨架各行的宽度（占可用宽度的比例）。
  final List<double> skeletonWidths;
}

// ---------------------------------------------------------------------------
// Drawer
// ---------------------------------------------------------------------------

/// 抽屉：从窗口右侧滑出，宽 min(360, 窗口宽 × 92%)。
@immutable
class RaDrawerThemeData {
  const RaDrawerThemeData({
    required this.width,
    required this.maxWidthFraction,
    required this.padding,
    required this.gap,
    required this.backgroundColor,
    required this.shadows,
    required this.barrierColor,
    required this.titleStyle,
    required this.duration,
    required this.curve,
  });

  factory RaDrawerThemeData.fallback(RaTokens t) => RaDrawerThemeData(
    width: 360,
    maxWidthFraction: 0.92,
    padding: t.spacing.xl2,
    gap: t.spacing.xl,
    backgroundColor: t.colors.surface,
    shadows: t.shadows.dialog,
    barrierColor: t.colors.overlay,
    titleStyle: t.typography.title.copyWith(color: t.colors.ink),
    duration: t.motion.slow,
    curve: t.motion.emphasized,
  );

  final double width;
  final double maxWidthFraction;
  final double padding;

  /// 标题行与内容的间距。
  final double gap;
  final Color backgroundColor;
  final List<BoxShadow> shadows;
  final Color barrierColor;
  final TextStyle titleStyle;
  final Duration duration;
  final Curve curve;
}

// ---------------------------------------------------------------------------
// Checkbox / Radio / Switch
// ---------------------------------------------------------------------------

/// 复选框、单选框与开关：14px 方框（圆角 4）/ 圆框，选中为强调色实心；开关 28×16、滑块 12。
@immutable
class RaControlThemeData {
  const RaControlThemeData({
    required this.boxSize,
    required this.boxRadius,
    required this.indicatorSize,
    required this.radioDotSize,
    required this.backgroundColor,
    required this.borderColor,
    required this.hoverBorderColor,
    required this.checkedColor,
    required this.checkedHoverColor,
    required this.onCheckedColor,
    required this.shadows,
    required this.switchWidth,
    required this.switchHeight,
    required this.switchThumbSize,
    required this.switchTrackColor,
    required this.switchTrackHoverColor,
    required this.switchThumbColor,
    required this.switchThumbShadows,
    required this.labelGap,
    required this.labelStyle,
    required this.descriptionStyle,
    required this.disabledOpacity,
    required this.groupGap,
    required this.groupIndent,
    required this.duration,
  });

  factory RaControlThemeData.fallback(RaTokens t) {
    final RaColors c = t.colors;
    return RaControlThemeData(
      boxSize: t.sizing.iconSm,
      boxRadius: RaSizes.s4,
      indicatorSize: t.sizing.icon2xs,
      radioDotSize: RaSizes.s6,
      backgroundColor: c.surface,
      borderColor: c.borderStrong,
      hoverBorderColor: c.ink3,
      checkedColor: c.accent,
      checkedHoverColor: c.accentHover,
      onCheckedColor: c.onAccent,
      shadows: t.shadows.raised,
      switchWidth: RaSizes.s28,
      switchHeight: RaSizes.s16,
      switchThumbSize: RaSizes.s12,
      switchTrackColor: c.borderStrong,
      switchTrackHoverColor: c.ink3,
      switchThumbColor: c.surface,
      switchThumbShadows: t.shadows.raised,
      labelGap: t.spacing.sm,
      labelStyle: t.typography.body.copyWith(color: c.ink),
      descriptionStyle: t.typography.caption.copyWith(color: c.ink2),
      disabledOpacity: t.opacity.disabled,
      groupGap: t.spacing.md,
      groupIndent: RaSizes.s22,
      duration: t.motion.fast,
    );
  }

  final double boxSize;
  final double boxRadius;

  /// 对勾 / 横线图标尺寸。
  final double indicatorSize;
  final double radioDotSize;
  final Color backgroundColor;
  final Color borderColor;
  final Color hoverBorderColor;
  final Color checkedColor;
  final Color checkedHoverColor;
  final Color onCheckedColor;
  final List<BoxShadow> shadows;
  final double switchWidth;
  final double switchHeight;
  final double switchThumbSize;

  /// 关闭时的轨道色。
  final Color switchTrackColor;
  final Color switchTrackHoverColor;
  final Color switchThumbColor;
  final List<BoxShadow> switchThumbShadows;
  final double labelGap;
  final TextStyle labelStyle;
  final TextStyle descriptionStyle;
  final double disabledOpacity;

  /// 单选组各项的间距。
  final double groupGap;

  /// 复选框组中子项的缩进（方框 14 + 间距 8，子项方框与父项文字对齐）。
  final double groupIndent;

  /// 勾选 / 开合的过渡。
  final Duration duration;
}

// ---------------------------------------------------------------------------
// Select
// ---------------------------------------------------------------------------

/// 选择框（设置页）：30 高、圆角 8、13 / 450，右侧小箭头；弹出与菜单同外观。
@immutable
class RaSelectThemeData {
  const RaSelectThemeData({
    required this.trigger,
    required this.maxWidth,
    required this.caretSize,
    required this.caretColor,
    required this.placeholderColor,
  });

  factory RaSelectThemeData.fallback(RaTokens t) {
    final RaColors c = t.colors;
    return RaSelectThemeData(
      trigger: RaButtonStyle(
        layout: RaButtonLayout.inline,
        height: RaSizes.s30,
        padding: EdgeInsets.only(left: t.spacing.md, right: t.spacing.sm),
        gap: t.spacing.sm,
        radius: t.radii.md,
        textStyle: t.typography.body,
        backgroundColor: raStateColor(c.surface, hovered: c.surfaceHover, selected: c.surfaceHover),
        foregroundColor: raStateColor(c.ink, disabled: c.disabledInk),
        borderColor: WidgetStatePropertyAll<Color?>(c.border),
        shadows: WidgetStatePropertyAll<List<BoxShadow>?>(t.shadows.raised),
      ),
      maxWidth: 280,
      caretSize: t.sizing.iconXs,
      caretColor: c.ink3,
      placeholderColor: c.ink3,
    );
  }

  final RaButtonStyle trigger;
  final double maxWidth;
  final double caretSize;
  final Color caretColor;
  final Color placeholderColor;
}

// ---------------------------------------------------------------------------
// Popover / PreviewCard
// ---------------------------------------------------------------------------

/// 弹出面板（Base UI Popover）：与菜单同一层次的白底浮层（圆角 12、0.5px 描边、弹层阴影），
/// 内边距 12，可带标题与说明；悬停预览卡（PreviewCard）共用外观。
@immutable
class RaPopoverThemeData {
  const RaPopoverThemeData({
    required this.backgroundColor,
    required this.borderColor,
    required this.shadows,
    required this.radius,
    required this.padding,
    required this.maxWidth,
    required this.gap,
    required this.titleStyle,
    required this.descriptionStyle,
    required this.sideOffset,
    required this.screenMargin,
    required this.enterOffset,
    required this.scale,
    required this.duration,
    required this.previewWidth,
    required this.previewOpenDelay,
    required this.previewCloseDelay,
  });

  factory RaPopoverThemeData.fallback(RaTokens t) => RaPopoverThemeData(
    backgroundColor: t.colors.surface,
    borderColor: t.colors.borderPopover,
    shadows: t.shadows.popup,
    radius: t.radii.xl,
    padding: EdgeInsets.all(t.spacing.lg),
    maxWidth: 360,
    gap: t.spacing.xs2,
    titleStyle: t.typography.bodyMedium.copyWith(color: t.colors.ink),
    descriptionStyle: t.typography.body.copyWith(color: t.colors.ink2),
    sideOffset: t.spacing.xs,
    screenMargin: t.spacing.sm,
    enterOffset: RaSizes.s4,
    scale: t.motion.scalePop,
    duration: t.motion.fast,
    previewWidth: 320,
    previewOpenDelay: RaDurations.ms600,
    previewCloseDelay: RaDurations.ms300,
  );

  final Color backgroundColor;
  final Color borderColor;
  final List<BoxShadow> shadows;
  final double radius;
  final EdgeInsets padding;
  final double maxWidth;

  /// 标题、说明、内容之间的间距。
  final double gap;
  final TextStyle titleStyle;
  final TextStyle descriptionStyle;
  final double sideOffset;
  final double screenMargin;
  final double enterOffset;
  final double scale;
  final Duration duration;

  /// 预览卡宽度。
  final double previewWidth;

  /// 悬停多久后打开预览卡。
  final Duration previewOpenDelay;

  /// 指针离开（触发元素与卡片）多久后关闭预览卡。
  final Duration previewCloseDelay;
}

// ---------------------------------------------------------------------------
// Combobox / Autocomplete
// ---------------------------------------------------------------------------

/// 可搜索的选择框 / 自动补全：输入框 + 下方选项列表（外观与菜单相同，宽度与输入框一致）。
@immutable
class RaComboboxThemeData {
  const RaComboboxThemeData({
    required this.maxListHeight,
    required this.emptyStyle,
    required this.emptyPadding,
    required this.caretSize,
    required this.caretColor,
  });

  factory RaComboboxThemeData.fallback(RaTokens t) => RaComboboxThemeData(
    maxListHeight: 300,
    emptyStyle: t.typography.body.copyWith(color: t.colors.ink3),
    emptyPadding: EdgeInsets.symmetric(horizontal: t.spacing.sm, vertical: t.spacing.xs),
    caretSize: t.sizing.iconXs,
    caretColor: t.colors.ink3,
  );

  /// 列表最高（超出滚动）。
  final double maxListHeight;

  /// 没有匹配项时的提示。
  final TextStyle emptyStyle;
  final EdgeInsets emptyPadding;
  final double caretSize;
  final Color caretColor;
}

// ---------------------------------------------------------------------------
// Slider
// ---------------------------------------------------------------------------

/// 滑杆：4px 轨道（凹陷色）+ 强调色进度；14px 白色滑块带描边与淡阴影。命中区高 20。
@immutable
class RaSliderThemeData {
  const RaSliderThemeData({
    required this.height,
    required this.trackHeight,
    required this.trackColor,
    required this.fillColor,
    required this.thumbSize,
    required this.thumbColor,
    required this.thumbBorderColor,
    required this.thumbHoverBorderColor,
    required this.thumbShadows,
    required this.disabledOpacity,
  });

  factory RaSliderThemeData.fallback(RaTokens t) => RaSliderThemeData(
    height: RaSizes.s20,
    trackHeight: RaSizes.s4,
    trackColor: t.colors.sunken,
    fillColor: t.colors.accent,
    thumbSize: t.sizing.iconSm,
    thumbColor: t.colors.surface,
    thumbBorderColor: t.colors.borderStrong,
    thumbHoverBorderColor: t.colors.ink3,
    thumbShadows: t.shadows.raised,
    disabledOpacity: t.opacity.disabled,
  );

  /// 整体（命中区）高度。
  final double height;
  final double trackHeight;
  final Color trackColor;
  final Color fillColor;
  final double thumbSize;
  final Color thumbColor;
  final Color thumbBorderColor;
  final Color thumbHoverBorderColor;
  final List<BoxShadow> thumbShadows;
  final double disabledOpacity;
}

// ---------------------------------------------------------------------------
// Progress / Meter
// ---------------------------------------------------------------------------

/// 计量条的语气（Meter）：normal 强调色 · attention 接近上限 · danger 超限。
enum RaMeterTone { normal, attention, danger }

/// 进度条与计量条：4px 胶囊轨道；上方可带标签与数值（12px 次要色、等宽数字）。
@immutable
class RaProgressThemeData {
  const RaProgressThemeData({
    required this.trackHeight,
    required this.radius,
    required this.trackColor,
    required this.fillColor,
    required this.meterColors,
    required this.labelStyle,
    required this.valueStyle,
    required this.labelGap,
    required this.indeterminateFraction,
    required this.indeterminatePeriod,
    required this.duration,
  });

  factory RaProgressThemeData.fallback(RaTokens t) {
    final RaColors c = t.colors;
    return RaProgressThemeData(
      trackHeight: RaSizes.s4,
      radius: t.radii.pill,
      trackColor: c.sunken,
      fillColor: c.accent,
      meterColors: <RaMeterTone, Color>{
        RaMeterTone.normal: c.accent,
        RaMeterTone.attention: c.attention,
        RaMeterTone.danger: c.danger,
      },
      labelStyle: t.typography.caption.copyWith(color: c.ink2),
      valueStyle: t.typography.caption.copyWith(color: c.ink2, fontFeatures: _tabular),
      labelGap: t.spacing.xs,
      indeterminateFraction: 0.4,
      indeterminatePeriod: t.motion.spin,
      duration: t.motion.slow,
    );
  }

  static const List<FontFeature> _tabular = <FontFeature>[FontFeature.tabularFigures()];

  final double trackHeight;
  final double radius;
  final Color trackColor;
  final Color fillColor;
  final Map<RaMeterTone, Color> meterColors;
  final TextStyle labelStyle;
  final TextStyle valueStyle;

  /// 标签行与轨道的间距。
  final double labelGap;

  /// 不确定进度时滑动段占轨道宽度的比例。
  final double indeterminateFraction;

  /// 不确定进度滑动一次的时长。
  final Duration indeterminatePeriod;

  /// 数值变化时进度的过渡。
  final Duration duration;
}

// ---------------------------------------------------------------------------
// NumberField
// ---------------------------------------------------------------------------

/// 数字输入框：输入框右侧内嵌 − / + 小按钮（20px 方形、圆角 6，正好放进 32 高输入框的内容区）。
@immutable
class RaNumberFieldThemeData {
  const RaNumberFieldThemeData({
    required this.buttonSize,
    required this.buttonRadius,
    required this.buttonGap,
    required this.iconSize,
    required this.buttonColor,
    required this.buttonHoverColor,
    required this.buttonHoverBackground,
    required this.buttonDisabledColor,
  });

  factory RaNumberFieldThemeData.fallback(RaTokens t) => RaNumberFieldThemeData(
    buttonSize: RaSizes.s20,
    buttonRadius: t.radii.sm,
    buttonGap: t.spacing.xs3,
    iconSize: t.sizing.iconXs,
    buttonColor: t.colors.ink2,
    buttonHoverColor: t.colors.ink,
    buttonHoverBackground: t.colors.hover,
    buttonDisabledColor: t.colors.disabledInk,
  );

  final double buttonSize;
  final double buttonRadius;
  final double buttonGap;
  final double iconSize;
  final Color buttonColor;
  final Color buttonHoverColor;
  final Color buttonHoverBackground;
  final Color buttonDisabledColor;
}

// ---------------------------------------------------------------------------
// Toolbar
// ---------------------------------------------------------------------------

/// 工具栏：一行按钮 / 开关按钮 / 选择器，间距 2；竖向分隔线 16 高、左右各留 4。
@immutable
class RaToolbarThemeData {
  const RaToolbarThemeData({
    required this.gap,
    required this.separatorHeight,
    required this.separatorMargin,
    required this.separatorColor,
  });

  factory RaToolbarThemeData.fallback(RaTokens t) => RaToolbarThemeData(
    gap: t.spacing.xs3,
    separatorHeight: RaSizes.s16,
    separatorMargin: t.spacing.xs2,
    separatorColor: t.colors.border,
  );

  final double gap;
  final double separatorHeight;
  final double separatorMargin;
  final Color separatorColor;
}

// ---------------------------------------------------------------------------
// Accordion
// ---------------------------------------------------------------------------

/// 手风琴：40 高标题行（13 / 500、右侧箭头展开时朝上），行间 0.5px 分隔线；内容 13px 次要色。
@immutable
class RaAccordionThemeData {
  const RaAccordionThemeData({
    required this.headerHeight,
    required this.headerPadding,
    required this.headerRadius,
    required this.hoverColor,
    required this.titleStyle,
    required this.titleColor,
    required this.disabledColor,
    required this.chevronSize,
    required this.chevronColor,
    required this.panelPadding,
    required this.contentStyle,
    required this.separatorColor,
  });

  factory RaAccordionThemeData.fallback(RaTokens t) => RaAccordionThemeData(
    headerHeight: RaSizes.s40,
    headerPadding: EdgeInsets.symmetric(horizontal: t.spacing.sm),
    headerRadius: t.radii.md,
    hoverColor: t.colors.fillTranslucentHover,
    titleStyle: t.typography.bodyMedium,
    titleColor: t.colors.ink,
    disabledColor: t.colors.disabledInk,
    chevronSize: t.sizing.iconSm,
    chevronColor: t.colors.ink3,
    panelPadding: EdgeInsets.fromLTRB(t.spacing.sm, 0, t.spacing.sm, t.spacing.lg),
    contentStyle: t.typography.body.copyWith(color: t.colors.ink2),
    separatorColor: t.colors.border,
  );

  final double headerHeight;
  final EdgeInsets headerPadding;
  final double headerRadius;
  final Color hoverColor;
  final TextStyle titleStyle;
  final Color titleColor;
  final Color disabledColor;
  final double chevronSize;
  final Color chevronColor;
  final EdgeInsets panelPadding;
  final TextStyle contentStyle;
  final Color separatorColor;
}

// ---------------------------------------------------------------------------
// Fieldset
// ---------------------------------------------------------------------------

/// 字段组：标题（13 / 500）+ 可选说明（12px 次要色），下方为一组控件。
@immutable
class RaFieldsetThemeData {
  const RaFieldsetThemeData({
    required this.legendStyle,
    required this.descriptionStyle,
    required this.legendGap,
    required this.gap,
  });

  factory RaFieldsetThemeData.fallback(RaTokens t) => RaFieldsetThemeData(
    legendStyle: t.typography.bodyMedium.copyWith(color: t.colors.ink),
    descriptionStyle: t.typography.caption.copyWith(color: t.colors.ink2),
    legendGap: t.spacing.xs3,
    gap: t.spacing.lg,
  );

  final TextStyle legendStyle;
  final TextStyle descriptionStyle;

  /// 标题与说明的间距。
  final double legendGap;

  /// 标题区与控件、控件之间的间距。
  final double gap;
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
    required this.minus,
    required this.plus,
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
    minus: RaGlyphs.minus,
    plus: RaGlyphs.plus,
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

  /// 横线（复选框的「部分选中」）。
  final RaGlyph minus;

  /// 加号（数字输入框）。
  final RaGlyph plus;
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
    RaGlyph? minus,
    RaGlyph? plus,
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
      minus: minus ?? this.minus,
      plus: plus ?? this.plus,
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
