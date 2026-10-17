import 'package:flutter/widgets.dart';

import '../foundation/hairline.dart';
import '../foundation/localizations.dart';
import '../foundation/motion.dart';
import '../foundation/pressable.dart';
import '../theme/theme.dart';
import '../theme/theme_data.dart';
import '../tokens/components.dart';
import 'button.dart';

/// 打开一个对话框（遮罩 + 居中卡片）。点击遮罩或按 Esc 关闭；[barrierDismissible] 为 false 时两者都不关闭。
///
/// [builder] 通常返回 [RaDialog]。
Future<T?> showRaDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
}) {
  final RaThemeData theme = RaTheme.of(context);
  return Navigator.of(context, rootNavigator: useRootNavigator).push<T>(
    RaDialogRoute<T>(
      builder: builder,
      theme: theme,
      barrierDismissible: barrierDismissible,
      barrierLabel: RaLocalizations.of(context).close,
      duration: RaReducedMotion.resolve(context, theme.dialog.duration),
      settings: routeSettings,
    ),
  );
}

/// 对话框路由：遮罩淡入；卡片从 0.96 缩放到 1 并淡入，关闭时反向。
class RaDialogRoute<T> extends PopupRoute<T> {
  RaDialogRoute({
    required this.builder,
    required this.theme,
    required this.duration,
    this.barrierDismissible = true,
    this.barrierLabel,
    super.settings,
  });

  final WidgetBuilder builder;
  final RaThemeData theme;
  final Duration duration;

  @override
  final bool barrierDismissible;

  @override
  final String? barrierLabel;

  @override
  Color? get barrierColor => theme.dialog.barrierColor;

  @override
  Duration get transitionDuration => duration;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondary) {
    return RaTheme(
      data: theme,
      child: Builder(builder: builder),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(begin: theme.dialog.scale, end: 1).animate(animation),
        child: child,
      ),
    );
  }
}

/// 对话框卡片：标题、说明、内容与底部按钮。宽 min(460, 窗口宽 − 32)，最高窗口高 − 64，超出滚动。
class RaDialog extends StatelessWidget {
  const RaDialog({
    super.key,
    required this.title,
    this.description,
    this.child,
    this.actions,
    this.width,
  });

  final String title;
  final Widget? description;
  final Widget? child;

  /// 底部按钮（右对齐，间距 8）。
  final List<Widget>? actions;

  /// 覆盖默认宽度上限。
  final double? width;

  @override
  Widget build(BuildContext context) {
    final RaThemeData theme = RaTheme.of(context);
    final RaDialogThemeData d = theme.dialog;
    final Size screen = MediaQuery.sizeOf(context);
    final double maxWidth = (screen.width - d.screenMargin * 2).clamp(0.0, width ?? d.width);
    final double maxHeight = (screen.height - d.verticalMargin * 2).clamp(0.0, double.infinity);
    return Center(
      child: RaNoDragRegion(
        child: ConstrainedBox(
          constraints: BoxConstraints.tightFor(width: maxWidth).copyWith(maxHeight: maxHeight),
          child: Semantics(
            scopesRoute: true,
            namesRoute: true,
            explicitChildNodes: true,
            label: title,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: d.backgroundColor,
                borderRadius: BorderRadius.circular(d.radius),
                border: Border.all(
                  color: d.borderColor,
                  width: RaHairline.snap(context, theme.sizing.borderWidth),
                ),
                boxShadow: d.shadows,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(d.radius),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(d.padding),
                  child: DefaultTextStyle(
                    style: theme.typography.body.copyWith(color: theme.colors.ink),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: d.gap,
                      children: <Widget>[
                        Semantics(header: true, child: Text(title, style: d.titleStyle)),
                        if (description != null)
                          DefaultTextStyle(style: d.descriptionStyle, child: description!),
                        ?child,
                        if (actions != null && actions!.isNotEmpty)
                          RaDialogFooter(children: actions!),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 对话框底部按钮行：右对齐、间距 8，空间不足时换行。
class RaDialogFooter extends StatelessWidget {
  const RaDialogFooter({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final RaDialogThemeData d = RaTheme.of(context).dialog;
    return Padding(
      padding: EdgeInsets.only(top: d.footerTopGap),
      child: Wrap(
        alignment: WrapAlignment.end,
        spacing: d.footerGap,
        runSpacing: d.footerGap,
        children: children,
      ),
    );
  }
}

/// 确认操作的语气：主操作或危险操作（删除、归档）。
enum RaConfirmTone { primary, danger }

/// 需要用户明确确认的操作。取代 `confirm()`。
///
/// [onConfirm] 执行期间按钮显示转圈与 [pendingLabel]；抛出异常时在对话框内显示错误（[errorText] 可定制文案），
/// 不关闭对话框。返回 true 表示已确认且 [onConfirm] 成功完成。
Future<bool> showRaConfirmDialog({
  required BuildContext context,
  required String title,
  required Widget description,
  required String confirmLabel,
  String? cancelLabel,
  String? pendingLabel,
  RaConfirmTone tone = RaConfirmTone.primary,
  Future<void> Function()? onConfirm,
  String Function(Object error)? errorText,
}) async {
  final bool? result = await showRaDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => _ConfirmDialog(
      title: title,
      description: description,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      pendingLabel: pendingLabel,
      tone: tone,
      onConfirm: onConfirm,
      errorText: errorText,
    ),
  );
  return result ?? false;
}

class _ConfirmDialog extends StatefulWidget {
  const _ConfirmDialog({
    required this.title,
    required this.description,
    required this.confirmLabel,
    this.cancelLabel,
    this.pendingLabel,
    required this.tone,
    this.onConfirm,
    this.errorText,
  });

  final String title;
  final Widget description;
  final String confirmLabel;
  final String? cancelLabel;
  final String? pendingLabel;
  final RaConfirmTone tone;
  final Future<void> Function()? onConfirm;
  final String Function(Object error)? errorText;

  @override
  State<_ConfirmDialog> createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<_ConfirmDialog> {
  bool _pending = false;
  String? _error;

  Future<void> _confirm() async {
    final Future<void> Function()? onConfirm = widget.onConfirm;
    if (onConfirm == null) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _pending = true;
      _error = null;
    });
    try {
      await onConfirm();
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _pending = false;
        _error = widget.errorText?.call(error) ?? error.toString();
      });
    }
  }

  void _cancel() {
    if (!_pending) Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final RaThemeData theme = RaTheme.of(context);
    final RaLocalizations l10n = RaLocalizations.of(context);
    return Actions(
      actions: <Type, Action<Intent>>{
        DismissIntent: CallbackAction<DismissIntent>(onInvoke: (_) => _cancel()),
      },
      child: Focus(
        autofocus: true,
        child: RaDialog(
          title: widget.title,
          description: widget.description,
          actions: <Widget>[
            RaButton(
              onPressed: _pending ? null : _cancel,
              child: Text(widget.cancelLabel ?? l10n.cancel),
            ),
            RaButton(
              autofocus: true,
              onPressed: _confirm,
              loading: _pending,
              variant: widget.tone == RaConfirmTone.danger
                  ? RaButtonVariant.dangerSolid
                  : RaButtonVariant.primary,
              child: Text(
                _pending ? (widget.pendingLabel ?? l10n.processing) : widget.confirmLabel,
              ),
            ),
          ],
          child: _error == null
              ? null
              : Semantics(liveRegion: true, child: Text(_error!, style: theme.field.errorStyle)),
        ),
      ),
    );
  }
}
