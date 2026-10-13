import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// 组件内置文案。内置中文与英文；其他语言可以继承本类并提供自己的 [LocalizationsDelegate]。
abstract class RaLocalizations {
  const RaLocalizations();

  String get cancel;
  String get confirm;
  String get close;
  String get processing;
  String get dismissNotification;
  String get cut;
  String get copy;
  String get paste;
  String get selectAll;
  String get minimizeWindow;
  String get maximizeWindow;
  String get restoreWindow;
  String get closeWindow;

  static const LocalizationsDelegate<RaLocalizations> delegate = _RaLocalizationsDelegate();

  static const List<Locale> supportedLocales = <Locale>[Locale('zh'), Locale('en')];

  /// 当前文案；没有登记时按中文。
  static RaLocalizations of(BuildContext context) =>
      Localizations.of<RaLocalizations>(context, RaLocalizations) ?? const RaLocalizationsZh();
}

class RaLocalizationsZh extends RaLocalizations {
  const RaLocalizationsZh();

  @override
  String get cancel => '取消';
  @override
  String get confirm => '确定';
  @override
  String get close => '关闭';
  @override
  String get processing => '处理中…';
  @override
  String get dismissNotification => '关闭提示';
  @override
  String get cut => '剪切';
  @override
  String get copy => '拷贝';
  @override
  String get paste => '粘贴';
  @override
  String get selectAll => '全选';
  @override
  String get minimizeWindow => '最小化';
  @override
  String get maximizeWindow => '最大化';
  @override
  String get restoreWindow => '还原';
  @override
  String get closeWindow => '关闭';
}

class RaLocalizationsEn extends RaLocalizations {
  const RaLocalizationsEn();

  @override
  String get cancel => 'Cancel';
  @override
  String get confirm => 'OK';
  @override
  String get close => 'Close';
  @override
  String get processing => 'Working…';
  @override
  String get dismissNotification => 'Dismiss';
  @override
  String get cut => 'Cut';
  @override
  String get copy => 'Copy';
  @override
  String get paste => 'Paste';
  @override
  String get selectAll => 'Select All';
  @override
  String get minimizeWindow => 'Minimize';
  @override
  String get maximizeWindow => 'Maximize';
  @override
  String get restoreWindow => 'Restore';
  @override
  String get closeWindow => 'Close';
}

class _RaLocalizationsDelegate extends LocalizationsDelegate<RaLocalizations> {
  const _RaLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<RaLocalizations> load(Locale locale) => SynchronousFuture<RaLocalizations>(
    locale.languageCode == 'en' ? const RaLocalizationsEn() : const RaLocalizationsZh(),
  );

  @override
  bool shouldReload(_RaLocalizationsDelegate old) => false;
}
