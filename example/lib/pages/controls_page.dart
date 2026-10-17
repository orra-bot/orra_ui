import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:orra_ui/orra_ui.dart';

import '../gallery_layout.dart';
import 'page_scaffold.dart';

/// 选择类控件：复选框、单选组、开关、选择框、分段切换、标签页。
class ControlsPage extends StatefulWidget {
  const ControlsPage({super.key});

  @override
  State<ControlsPage> createState() => _ControlsPageState();
}

class _ControlsPageState extends State<ControlsPage> {
  bool _archive = true;
  bool _digest = false;
  bool _notify = true;
  bool _sounds = false;
  String _appearance = 'system';
  String _role = 'member';
  String? _owner;
  String _mode = 'chat';
  String _tab = 'overview';
  String _module = 'general';

  bool? get _all => _archive && _digest ? true : (!_archive && !_digest ? false : null);

  @override
  Widget build(BuildContext context) {
    final RaThemeData theme = RaTheme.of(context);
    final GalleryLayout layout = GalleryLayout.of(context);
    return GalleryPage(
      title: '选择控件',
      description:
          '对照 Base UI 的 Checkbox / RadioGroup / Switch / Select / ToggleGroup / Tabs。'
          '整行可点击；方向键在同组选项间移动并选中，Home / End 跳到首尾。',
      sections: <GallerySection>[
        GallerySection(
          title: '复选框',
          description: '父项在子项部分选中时显示横线。',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: theme.control.groupGap,
            children: <Widget>[
              RaCheckbox(
                value: _all,
                onChanged: (bool v) => setState(() => _archive = _digest = v),
                label: const Text('全部通知'),
              ),
              Padding(
                padding: EdgeInsetsDirectional.only(start: theme.spacing.xl3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: theme.control.groupGap,
                  children: <Widget>[
                    RaCheckbox(
                      value: _archive,
                      onChanged: (bool v) => setState(() => _archive = v),
                      label: const Text('自动归档已完成的会话'),
                      description: const Text('完成 7 天后移入「已归档」。'),
                    ),
                    RaCheckbox(
                      value: _digest,
                      onChanged: (bool v) => setState(() => _digest = v),
                      label: const Text('每周摘要邮件'),
                    ),
                  ],
                ),
              ),
              const RaCheckbox(value: true, onChanged: null, label: Text('已禁用')),
            ],
          ),
        ),
        GallerySection(
          title: '开关',
          description: '立即生效的设置用开关；需要「保存」的表单用复选框。',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: theme.control.groupGap,
            children: <Widget>[
              RaSwitch(
                value: _notify,
                onChanged: (bool v) => setState(() => _notify = v),
                label: const Text('桌面通知'),
                description: const Text('运行结束或需要处理时提醒你。'),
              ),
              RaSwitch(
                value: _sounds,
                onChanged: (bool v) => setState(() => _sounds = v),
                label: const Text('提示音'),
              ),
              const RaSwitch(value: false, onChanged: null, label: Text('已禁用')),
            ],
          ),
        ),
        GallerySection(
          title: '单选组',
          child: RaRadioGroup<String>(
            semanticLabel: '成员角色',
            value: _role,
            onChanged: (String v) => setState(() => _role = v),
            options: const <RaRadioOption<String>>[
              RaRadioOption<String>(
                value: 'admin',
                label: '管理员',
                description: '可以管理成员、账单与 Workspace 设置。',
              ),
              RaRadioOption<String>(value: 'member', label: '成员', description: '可以创建和使用对象。'),
              RaRadioOption<String>(
                value: 'guest',
                label: '访客',
                description: '暂未开放。',
                enabled: false,
              ),
            ],
          ),
        ),
        GallerySection(
          title: '选择框',
          description: '设置页的选择框：30 高、圆角 8，选中后关闭；选项可带预览。',
          child: DemoWrap(
            children: <Widget>[
              RaSelect<String>(
                semanticLabel: '界面主题',
                value: _appearance,
                onChanged: (String v) => setState(() => _appearance = v),
                options: const <RaSelectOption<String>>[
                  RaSelectOption<String>(
                    value: 'system',
                    label: '跟随系统',
                    leading: RaIcon(LucideIcons.monitor),
                  ),
                  RaSelectOption<String>(
                    value: 'light',
                    label: '浅色',
                    leading: RaIcon(LucideIcons.sun),
                  ),
                  RaSelectOption<String>(
                    value: 'dark',
                    label: '深色',
                    leading: RaIcon(LucideIcons.moon),
                  ),
                ],
              ),
              RaSelect<String>(
                semanticLabel: '负责人',
                width: layout.fieldColumnWidth / 2,
                value: _owner,
                placeholder: '选择负责人',
                onChanged: (String v) => setState(() => _owner = v),
                options: const <RaSelectOption<String>>[
                  RaSelectOption<String>(value: 'ive', label: 'Ive Tian'),
                  RaSelectOption<String>(value: 'ada', label: 'Ada Lovelace'),
                ],
              ),
              const RaSelect<int>(
                value: 1,
                onChanged: null,
                options: <RaSelectOption<int>>[RaSelectOption<int>(value: 1, label: '已禁用')],
              ),
            ],
          ),
        ),
        GallerySection(
          title: '分段切换',
          description: '面板顶栏的模式切换；再次点击当前段不会取消。',
          child: RaSegmentedControl<String>(
            semanticLabel: '模式',
            value: _mode,
            onChanged: (String v) => setState(() => _mode = v),
            segments: const <RaSegment<String>>[
              RaSegment<String>(value: 'chat', label: '对话'),
              RaSegment<String>(value: 'tune', label: '调整'),
              RaSegment<String>(value: 'runs', label: '运行记录'),
            ],
          ),
        ),
        GallerySection(
          title: '标签页',
          description: '横排用于页面内分区；竖排用于 Workspace 模块导航。按下即切换。',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: theme.spacing.xl3,
            children: <Widget>[
              RaTabs.withPanels<String>(
                value: _tab,
                onChanged: (String v) => setState(() => _tab = v),
                tabs: const <RaTab<String>>[
                  RaTab<String>(value: 'overview', label: '概览'),
                  RaTab<String>(value: 'runs', label: '运行记录'),
                  RaTab<String>(value: 'access', label: '权限'),
                  RaTab<String>(value: 'billing', label: '账单', enabled: false),
                ],
                panelBuilder: (BuildContext context, String v) => DemoCaption('当前：$v'),
              ),
              RaTabs.withPanels<String>(
                axis: Axis.vertical,
                value: _module,
                onChanged: (String v) => setState(() => _module = v),
                tabs: const <RaTab<String>>[
                  RaTab<String>(value: 'general', label: '通用', icon: RaIcon(LucideIcons.settings)),
                  RaTab<String>(value: 'members', label: '成员', icon: RaIcon(LucideIcons.users)),
                  RaTab<String>(value: 'usage', label: '用量', icon: RaIcon(LucideIcons.chartColumn)),
                ],
                panelBuilder: (BuildContext context, String v) => DemoCaption('当前模块：$v'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
