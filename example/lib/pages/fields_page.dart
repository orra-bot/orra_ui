import 'package:flutter/widgets.dart';
import 'package:orra_ui/orra_ui.dart';

import '../gallery_layout.dart';
import 'page_scaffold.dart';

/// 输入框与表单校验。
class FieldsPage extends StatefulWidget {
  const FieldsPage({super.key});

  @override
  State<FieldsPage> createState() => _FieldsPageState();
}

class _FieldsPageState extends State<FieldsPage> {
  final GlobalKey<RaFormState> _form = GlobalKey<RaFormState>();

  void _submit() {
    if (_form.currentState!.validate()) {
      RaToast.of(context).success('已保存');
    } else {
      RaToast.of(context).error('有字段未通过校验', description: '请按提示修改后再保存。');
    }
  }

  @override
  Widget build(BuildContext context) {
    final GalleryLayout layout = GalleryLayout.of(context);
    return GalleryPage(
      title: '输入框',
      description: '聚焦以边框变为强调色表示（无焦点环）；悬停边框加深；错误时为危险色。右键可剪切 / 拷贝 / 粘贴。',
      sections: <GallerySection>[
        GallerySection(
          title: '表单校验',
          description: '失焦后开始校验，之后随输入实时更新；点「保存」一次校验全部字段。',
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: layout.fieldColumnWidth,
              child: RaForm(
                key: _form,
                children: <Widget>[
                  RaTextField(
                    label: '名称',
                    placeholder: '例如：客户反馈助手',
                    validator: (String v) => v.trim().isEmpty ? '请填写名称' : null,
                  ),
                  RaTextField(
                    label: '邮箱',
                    placeholder: 'name@example.com',
                    description: '用于接收通知。',
                    validator: (String v) =>
                        v.isEmpty || RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)
                        ? null
                        : '邮箱格式不正确',
                  ),
                  const RaTextField(label: '说明', multiline: true, placeholder: '它做什么、能访问什么'),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: RaButton(
                      variant: RaButtonVariant.primary,
                      onPressed: _submit,
                      child: const Text('保存'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        GallerySection(
          title: '其他形态',
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: layout.fieldColumnWidth,
              child: const RaForm(
                children: <Widget>[
                  RaTextField(label: '搜索', hideLabel: true, search: true, placeholder: '搜索…'),
                  RaTextField(label: '密码', obscureText: true, placeholder: '至少 8 位'),
                  RaTextField(label: '已禁用', enabled: false, initialValue: '不可编辑'),
                  RaTextField(label: '服务端错误', initialValue: 'taken-name', error: '名称已被占用'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
