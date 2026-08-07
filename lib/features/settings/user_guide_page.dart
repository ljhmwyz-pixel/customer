import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/tokens.dart';

/// 面向首次使用者的应用内试用说明。
class UserGuidePage extends StatelessWidget {
  const UserGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('使用说明')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppTokens.s16,
          AppTokens.s8,
          AppTokens.s16,
          AppTokens.s32,
        ),
        children: [
          Text('三分钟开始试用', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppTokens.s8),
          Text(
            '先导入示例数据熟悉流程，再录入自己的客户。数据保存在本机，无需登录。',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppTokens.s16),
          FilledButton.icon(
            onPressed: () => context.go('/settings/sample-data'),
            icon: const Icon(Icons.science_outlined),
            label: const Text('去导入示例数据'),
          ),
          const SizedBox(height: AppTokens.s16),
          _GuideSection(
            icon: Icons.today_outlined,
            title: '1. 今日：处理跟进任务',
            children: const [
              '打开应用默认进入“今日”，这里集中显示逾期和今天到期的任务。',
              '首页上方固定提供“新建客户、客户列表、导入客户”三个高频入口；没有待办时也能直接使用。',
              '点击任务可进入客户详情；完成或取消后，任务会保留在历史记录中。',
            ],
          ),
          _GuideSection(
            icon: Icons.people_outline,
            title: '2. 客户：建立客户档案',
            children: const [
              '新建客户后，可使用“联系人、项目、业务、订单”快捷操作添加资料。',
              '客户详情分为“概览、项目、业务、动态”：资料和联系人看概览，报价、样品、注册、招标和订单在业务中维护，计划和跟进历史集中在动态。',
              '建议一个产品机会建立一个项目，避免不同报价和阶段互相覆盖；联系人可维护邮箱、WhatsApp、沟通偏好、决策人和备注。',
            ],
          ),
          _GuideSection(
            icon: Icons.forum_outlined,
            title: '3. 跟进：记录每次沟通',
            children: const [
              '在客户详情点击“记录跟进”，填写客户反馈、项目阶段、下一步行动和下次跟进日期。',
              '可选择联系人和客户态度；历史会保留当时负责人快照。每次沟通新增一条记录，不覆盖历史；保存后系统会同步项目状态并生成提醒。',
              '项目、跟进和订单填写后返回会询问是否放弃；选择“继续编辑”会保留当前输入。',
            ],
          ),
          _GuideSection(
            icon: Icons.track_changes_outlined,
            title: '4. 业务：追踪关键节点',
            children: const [
              '点击客户资料下方“业务”快捷操作，选择项目后新增报价、样品、注册或招标；没有项目时会引导先创建项目。',
              '点击已有业务记录可维护结果或推进节点：报价价格变化请新增版本，样品可推进寄出、签收、测试和结果，注册与招标支持编辑。',
              '已有样品的型号和数量在节点维护页锁定；如有变化请新增样品记录。',
              '维护页顶部直接显示当前状态、附件数量和删除入口，保存按钮固定在底部；删除记录会同时删除关联附件且无法撤销。',
              '注册和招标表单先显示基本信息，资料、资格、授权与风险按区块展开；收起不会清除已填写内容。招标触发高风险或底价支持后会自动打开风险区。',
              '项目、跟进、订单、报价结果、样品、注册和招标页面修改后返回会询问是否放弃；选择“继续编辑”会保留输入，保存成功、确认删除或附件往返不会重复提示。',
              '这些节点会参与今日任务、漏斗统计和异常提醒。',
            ],
          ),
          _GuideSection(
            icon: Icons.filter_alt_outlined,
            title: '5. 漏斗：查看整体进度',
            children: const [
              '客户列表搜索框下可直接使用逾期、A 级、报价停滞、样品停滞和长期沉默五个快捷筛选。',
              '查看客户等级、项目阶段、预计金额和本周跟进数量；点击异常入口会带入对应客户筛选。',
              '点击异常入口可定位长期沉默、注册到期、招标临近截止等记录。',
            ],
          ),
          _GuideSection(
            icon: Icons.notifications_active_outlined,
            title: '6. 提醒：确保任务按时到达',
            children: const [
              '首次使用请在“提醒权限”开启通知、精确闹钟和后台运行权限。',
              '不确定是否正常时，进入“提醒自检”安排一条测试提醒。',
            ],
          ),
          _GuideSection(
            icon: Icons.backup_outlined,
            title: '7. 数据：导出和备份',
            children: const [
              '“Excel 导出”用于查阅和分析；Excel 中的修改不会自动回写应用。',
              '“客户/联系人导入”按“下载模板、选择文件”两步完成；导入前先预览错误并建议先备份，完成后可直接查看客户列表。客户编号优先匹配，联系人按客户和姓名匹配。',
              '“备份与恢复”包含业务数据和附件，换机或升级前请先备份。',
            ],
          ),
          const SizedBox(height: AppTokens.s8),
          Text(
            '推荐习惯：每天打开“今日”，每次沟通后立即记录跟进，每周导出或备份一次。',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideSection extends StatelessWidget {
  const _GuideSection({
    required this.icon,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final String title;
  final List<String> children;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: AppTokens.s8),
    child: ExpansionTile(
      leading: Icon(icon),
      title: Text(title),
      childrenPadding: const EdgeInsets.fromLTRB(
        AppTokens.s16,
        0,
        AppTokens.s16,
        AppTokens.s12,
      ),
      children: [
        for (final child in children)
          Padding(
            padding: const EdgeInsets.only(top: AppTokens.s8),
            child: Align(alignment: Alignment.centerLeft, child: Text(child)),
          ),
      ],
    ),
  );
}
