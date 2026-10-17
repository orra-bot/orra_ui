import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:orra_ui/orra_ui.dart';

import '../gallery_layout.dart';
import 'page_scaffold.dart';

/// 数值与进度：滑杆、数字输入框、进度条、计量条。
class ValuesPage extends StatefulWidget {
  const ValuesPage({super.key});

  @override
  State<ValuesPage> createState() => _ValuesPageState();
}

class _ValuesPageState extends State<ValuesPage> {
  double _volume = 0.6;
  double _temperature = 0.7;
  num? _retries = 3;
  num? _budget = 12.5;
  double _upload = 0.35;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startUpload() {
    _timer?.cancel();
    setState(() => _upload = 0);
    _timer = Timer.periodic(const Duration(milliseconds: 200), (Timer t) {
      setState(() => _upload = (_upload + 0.08).clamp(0, 1));
      if (_upload >= 1) t.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    final RaThemeData theme = RaTheme.of(context);
    final GalleryLayout layout = GalleryLayout.of(context);
    return GalleryPage(
      title: '数值与进度',
      description:
          '对照 Base UI 的 Slider / Number Field / Progress / Meter。'
          '滑杆与数字输入框都支持键盘：方向键一步，Shift 一大步，Home / End 到首尾。',
      sections: <GallerySection>[
        GallerySection(
          title: '滑杆',
          description: '点击轨道跳到该位置并可继续拖动。',
          child: SizedBox(
            width: layout.fieldColumnWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: layout.demoGap,
              children: <Widget>[
                _LabeledValue(
                  label: '音量',
                  value: '${(_volume * 100).round()}%',
                  child: RaSlider(
                    semanticLabel: '音量',
                    value: _volume,
                    onChanged: (double v) => setState(() => _volume = v),
                  ),
                ),
                _LabeledValue(
                  label: '随机性（步长 0.1）',
                  value: _temperature.toStringAsFixed(1),
                  child: RaSlider(
                    semanticLabel: '随机性',
                    value: _temperature,
                    max: 2,
                    step: 0.1,
                    onChanged: (double v) => setState(() => _temperature = v),
                  ),
                ),
                const RaSlider(semanticLabel: '已禁用', value: 0.3, onChanged: null, enabled: false),
              ],
            ),
          ),
        ),
        GallerySection(
          title: '数字输入框',
          description: '失焦或回车时夹到上下限并格式化；无法解析时恢复上一个有效值。',
          child: SizedBox(
            width: layout.fieldColumnWidth,
            child: RaForm(
              children: <Widget>[
                RaNumberField(
                  label: '失败重试次数',
                  description: '0 – 10 次。',
                  value: _retries,
                  min: 0,
                  max: 10,
                  onChanged: (num? v) => setState(() => _retries = v),
                ),
                RaNumberField(
                  label: '每日预算（美元）',
                  value: _budget,
                  min: 0,
                  step: 0.5,
                  decimals: 2,
                  onChanged: (num? v) => setState(() => _budget = v),
                ),
              ],
            ),
          ),
        ),
        GallerySection(
          title: '进度条',
          description: '数值变化有过渡；不确定进度时一段条循环滑动（减弱动效时静止）。',
          child: SizedBox(
            width: layout.fieldColumnWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: layout.demoGap,
              children: <Widget>[
                RaProgress(value: _upload, label: '上传 report.pdf', showValue: true),
                const RaProgress(value: null, label: '正在准备…'),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: RaButton(
                    size: RaButtonSize.sm,
                    onPressed: _startUpload,
                    child: const Text('重新上传'),
                  ),
                ),
              ],
            ),
          ),
        ),
        GallerySection(
          title: '计量条',
          description: '表示用量而非进度：达到提醒阈值变橙，达到上限阈值变红。',
          child: SizedBox(
            width: layout.fieldColumnWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: theme.spacing.xl,
              children: const <Widget>[
                RaMeter(value: 0.32, label: '存储', valueLabel: '3.2 / 10 GB', low: 0.75, high: 0.9),
                RaMeter(
                  value: 0.82,
                  label: '本月运行次数',
                  valueLabel: '820 / 1000',
                  low: 0.75,
                  high: 0.9,
                ),
                RaMeter(value: 0.97, label: '成员席位', valueLabel: '29 / 30', low: 0.75, high: 0.9),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 标签行（左标签、右数值）+ 控件。
class _LabeledValue extends StatelessWidget {
  const _LabeledValue({required this.label, required this.value, required this.child});

  final String label;
  final String value;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final RaThemeData theme = RaTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: theme.spacing.xs,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: Text(label, style: theme.field.labelStyle)),
            Text(value, style: theme.progress.valueStyle),
          ],
        ),
        child,
      ],
    );
  }
}
