import 'package:flutter/widgets.dart';

/// 尊重系统「减弱动态效果」：开启时所有过渡与动画时长归零。
abstract final class RaReducedMotion {
  static bool of(BuildContext context) => MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// 返回实际使用的时长：减弱动效时为 0。
  static Duration resolve(BuildContext context, Duration duration) =>
      of(context) ? Duration.zero : duration;
}
