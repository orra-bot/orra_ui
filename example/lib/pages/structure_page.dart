import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:orra_ui/orra_ui.dart';

import '../gallery_layout.dart';
import 'page_scaffold.dart';

/// 工具栏与分组：开关按钮、工具栏、手风琴、复选框组、字段组。
class StructurePage extends StatefulWidget {
  const StructurePage({super.key});

  @override
  State<StructurePage> createState() => _StructurePageState();
}

class _StructurePageState extends State<StructurePage> {
  bool _pinned = false;
  bool _preview = true;
  Set<String> _marks = <String>{'bold'};
  Set<String> _align = <String>{'start'};
  Set<String> _events = <String>{'run.failed', 'run.finished'};
  bool _notify = true;
  String _channel = 'email';

  @override
  Widget build(BuildContext context) {
    final RaThemeData theme = RaTheme.of(context);
    final GalleryLayout layout = GalleryLayout.of(context);
    return GalleryPage(
      title: '工具栏与分组',
      description:
          '对照 Base UI 的 Toggle / Toggle Group / Toolbar / Accordion / Checkbox Group / Fieldset。'
          '工具栏内用方向键在控件之间移动焦点（输入框内不拦截）。',
      sections: <GallerySection>[
        GallerySection(
          title: '开关按钮',
          description: '两态按钮（aria-pressed）：仅图标时为 28 圆形并带提示；有文字时为安静按钮。',
          child: DemoWrap(
            children: <Widget>[
              RaToggle(
                label: '固定到侧栏',
                icon: const RaIcon(LucideIcons.pin),
                pressed: _pinned,
                onChanged: (bool v) => setState(() => _pinned = v),
              ),
              RaToggle(
                label: '预览',
                icon: const RaIcon(LucideIcons.eye),
                pressed: _preview,
                onChanged: (bool v) => setState(() => _preview = v),
                child: const Text('预览'),
              ),
            ],
          ),
        ),
        GallerySection(
          title: '工具栏',
          description: '开关按钮组（多选 / 单选）、分隔线、普通按钮与选择框组合在一行。',
          child: RaToolbar(
            semanticLabel: '格式',
            children: <Widget>[
              RaToggleGroup<String>(
                semanticLabel: '文字样式',
                values: _marks,
                onChanged: (Set<String> v) => setState(() => _marks = v),
                items: const <RaToggleItem<String>>[
                  RaToggleItem<String>(
                    value: 'bold',
                    label: '粗体',
                    icon: RaIcon(LucideIcons.bold),
                    shortcut: '⌘B',
                  ),
                  RaToggleItem<String>(
                    value: 'italic',
                    label: '斜体',
                    icon: RaIcon(LucideIcons.italic),
                    shortcut: '⌘I',
                  ),
                  RaToggleItem<String>(
                    value: 'underline',
                    label: '下划线',
                    icon: RaIcon(LucideIcons.underline),
                    shortcut: '⌘U',
                  ),
                  RaToggleItem<String>(
                    value: 'strike',
                    label: '删除线',
                    icon: RaIcon(LucideIcons.strikethrough),
                  ),
                ],
              ),
              const RaToolbarSeparator(),
              RaToggleGroup<String>(
                semanticLabel: '对齐',
                multiple: false,
                values: _align,
                onChanged: (Set<String> v) => setState(() => _align = v),
                items: const <RaToggleItem<String>>[
                  RaToggleItem<String>(
                    value: 'start',
                    label: '左对齐',
                    icon: RaIcon(LucideIcons.textAlignStart),
                  ),
                  RaToggleItem<String>(
                    value: 'center',
                    label: '居中',
                    icon: RaIcon(LucideIcons.textAlignCenter),
                  ),
                ],
              ),
              const RaToolbarSeparator(),
              RaIconButton(label: '插入链接', icon: const RaIcon(LucideIcons.link), onPressed: () {}),
              RaIconButton(label: '代码', icon: const RaIcon(LucideIcons.code), onPressed: () {}),
            ],
          ),
        ),
        GallerySection(
          title: '手风琴',
          description: '默认一次只展开一项；↑ ↓ 在标题间移动焦点，Enter / Space 展开或收起。',
          child: const RaAccordion(
            initiallyExpanded: <Object>{'what'},
            items: <RaAccordionItem>[
              RaAccordionItem(
                value: 'what',
                title: '它能做什么？',
                child: Text('按你的描述自动处理收件箱里的客户反馈：分类、汇总，并在需要时提醒你。'),
              ),
              RaAccordionItem(
                value: 'access',
                title: '它能访问哪些数据？',
                child: Text('只读访问你授权的邮箱与工单系统；不会代替你发送任何消息。'),
              ),
              RaAccordionItem(
                value: 'billing',
                title: '如何计费？（暂未开放）',
                enabled: false,
                child: SizedBox.shrink(),
              ),
            ],
          ),
        ),
        GallerySection(
          title: '复选框组与字段组',
          description: '父项「全选」在部分选中时显示横线；字段组可整体禁用。',
          child: SizedBox(
            width: layout.fieldColumnWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: theme.spacing.xl3,
              children: <Widget>[
                RaFieldset(
                  legend: '通知',
                  description: const Text('选择哪些事件会通知你。'),
                  children: <Widget>[
                    RaSwitch(
                      value: _notify,
                      onChanged: (bool v) => setState(() => _notify = v),
                      label: const Text('接收通知'),
                    ),
                  ],
                ),
                RaFieldset(
                  legend: '事件',
                  enabled: _notify,
                  children: <Widget>[
                    RaCheckboxGroup<String>(
                      parentLabel: '全部事件',
                      values: _events,
                      onChanged: (Set<String> v) => setState(() => _events = v),
                      options: const <RaCheckboxOption<String>>[
                        RaCheckboxOption<String>(value: 'run.failed', label: '运行失败'),
                        RaCheckboxOption<String>(value: 'run.finished', label: '运行完成'),
                        RaCheckboxOption<String>(
                          value: 'run.waiting',
                          label: '等待你处理',
                          description: '例如需要确认一笔付款。',
                        ),
                      ],
                    ),
                  ],
                ),
                RaFieldset(
                  legend: '通知方式',
                  enabled: _notify,
                  children: <Widget>[
                    RaRadioGroup<String>(
                      value: _channel,
                      onChanged: (String v) => setState(() => _channel = v),
                      options: const <RaRadioOption<String>>[
                        RaRadioOption<String>(value: 'email', label: '邮件'),
                        RaRadioOption<String>(value: 'desktop', label: '桌面通知'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
