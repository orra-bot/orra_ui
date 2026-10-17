import 'package:flutter/widgets.dart';
import 'package:orra_ui/orra_ui.dart';

import 'page_scaffold.dart';

/// 对话框、确认框、Toast。
class OverlaysPage extends StatefulWidget {
  const OverlaysPage({super.key});

  @override
  State<OverlaysPage> createState() => _OverlaysPageState();
}

class _OverlaysPageState extends State<OverlaysPage> {
  bool _failNext = true;

  Future<void> _openFormDialog() async {
    final GlobalKey<RaFormState> form = GlobalKey<RaFormState>();
    await showRaDialog<void>(
      context: context,
      builder: (BuildContext context) => RaDialog(
        title: '新建 Workspace',
        description: const Text('Workspace 是成员与资源的边界，之后可以在设置里改名。'),
        actions: <Widget>[
          RaButton(onPressed: () => Navigator.of(context).pop(), child: const Text('取消')),
          RaButton(
            variant: RaButtonVariant.primary,
            onPressed: () {
              if (form.currentState!.validate()) {
                Navigator.of(context).pop();
                RaToast.of(context).success('已创建');
              }
            },
            child: const Text('创建'),
          ),
        ],
        child: RaForm(
          key: form,
          children: <Widget>[
            RaTextField(
              label: '名称',
              autofocus: true,
              validator: (String v) => v.trim().isEmpty ? '请填写名称' : null,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openConfirm() async {
    final bool deleted = await showRaConfirmDialog(
      context: context,
      title: '删除「客户反馈助手」？',
      description: const Text('删除后无法恢复，相关的运行记录也会一并删除。'),
      confirmLabel: '删除',
      pendingLabel: '删除中…',
      tone: RaConfirmTone.danger,
      onConfirm: () async {
        await Future<void>.delayed(const Duration(seconds: 1));
        if (_failNext) {
          _failNext = false;
          throw Exception('网络连接中断');
        }
        _failNext = true;
      },
      errorText: (Object error) => '删除失败：网络连接中断。请检查网络后重试。',
    );
    if (deleted && mounted) RaToast.of(context).success('已删除');
  }

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: '对话框与提示',
      description: '对话框宽 min(460, 窗口宽 − 32)，遮罩淡入；确认类操作一律用确认框（取代 confirm()）。',
      sections: <GallerySection>[
        GallerySection(
          title: '对话框',
          description: 'Esc 或点击遮罩关闭；Tab 焦点不会离开对话框。',
          child: DemoWrap(
            children: <Widget>[
              RaButton(onPressed: _openFormDialog, child: const Text('打开表单对话框')),
              RaButton(
                variant: RaButtonVariant.danger,
                onPressed: _openConfirm,
                child: const Text('删除（第一次会失败，第二次成功）'),
              ),
            ],
          ),
        ),
        GallerySection(
          title: '弹出面板',
          description: '点击打开，焦点移入面板；Esc 或点外部关闭，焦点回到触发按钮。',
          child: DemoWrap(
            children: <Widget>[
              RaPopover(
                title: '分享「客户反馈助手」',
                description: const Text('拿到链接的 Workspace 成员都可以查看运行记录。'),
                content: Builder(
                  builder: (BuildContext context) => Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: RaButton(
                      variant: RaButtonVariant.primary,
                      size: RaButtonSize.sm,
                      onPressed: () {
                        RaPopover.of(context).close();
                        RaToast.of(context).success('链接已拷贝');
                      },
                      child: const Text('拷贝链接'),
                    ),
                  ),
                ),
                child: Builder(
                  builder: (BuildContext context) => RaButton(
                    selected: RaPopover.of(context).isOpen,
                    onPressed: RaPopover.of(context).toggle,
                    child: const Text('分享'),
                  ),
                ),
              ),
            ],
          ),
        ),
        GallerySection(
          title: '悬停预览卡',
          description: '悬停 600ms 后打开，指针可以移进卡片；离开 300ms 后关闭。键盘聚焦也会打开。',
          child: DemoWrap(
            children: <Widget>[
              RaPreviewCard(
                content: const RaPopoverPanel(
                  title: 'Ive Tian',
                  description: Text('产品负责人 · 上海'),
                  child: Text('负责 3 个对象，最近一次运行在 3 分钟前。'),
                ),
                child: RaButton(
                  variant: RaButtonVariant.ghost,
                  onPressed: () {},
                  child: const Text('@Ive Tian'),
                ),
              ),
            ],
          ),
        ),
        GallerySection(
          title: 'Toast',
          description: '右下角；5 秒后消失，悬停时暂停；成功 / 失败只靠图标颜色区分，最多同时 3 条。',
          child: DemoWrap(
            children: <Widget>[
              RaButton(
                onPressed: () => RaToast.of(context).success('已保存'),
                child: const Text('成功提示'),
              ),
              RaButton(
                onPressed: () =>
                    RaToast.of(context).error('保存失败', description: '服务暂时不可用。稍后会自动重试，你也可以现在重试。'),
                child: const Text('错误提示'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
