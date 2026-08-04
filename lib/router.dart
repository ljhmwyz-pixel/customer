import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/customers/customers_page.dart';
import 'features/funnel/funnel_page.dart';
import 'features/home/home_page.dart';
import 'features/reminders/permission_page.dart';
import 'features/reminders/reminder_log_page.dart';
import 'features/reminders/reminder_test_page.dart';
import 'features/settings/settings_page.dart';
import 'theme/tokens.dart';
import 'widgets/app_shell.dart';

/// 客户详情页的路由路径。
///
/// 单独提出来是因为通知点击的深链要用它，而阶段 3 才有真实页面。
/// 常量放一处，阶段 3 换实现时不需要在两边找字符串。
const String customerDetailPath = '/customers/:id';

String customerDetailLocation(int customerId) => '/customers/$customerId';

/// 路由配置。
///
/// 用 StatefulShellRoute 让四个 Tab 各自保留导航栈与滚动位置。
/// 通知点击的深链跳转在阶段 2 接入。
final router = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/', builder: (context, state) => const HomePage()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/customers',
              builder: (context, state) => const CustomersPage(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) => _CustomerDetailPlaceholder(
                    customerId: state.pathParameters['id'],
                    planId: state.uri.queryParameters['planId'],
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/funnel',
              builder: (context, state) => const FunnelPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsPage(),
              routes: [
                GoRoute(
                  path: 'reminder-permissions',
                  builder: (context, state) => const PermissionPage(),
                ),
                GoRoute(
                  path: 'reminder-log',
                  builder: (context, state) => const ReminderLogPage(),
                ),
                GoRoute(
                  path: 'reminder-test',
                  builder: (context, state) => const ReminderTestPage(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

/// 客户详情页占位。
///
/// 阶段 2A 只需要验证「点通知能带着正确的 planId 与 customerId 跳进来」，
/// 所以这里把参数显示出来即可，真实内容在阶段 3 替换。
/// 参数直接展示而不是静默忽略：跳转参数错了要能一眼看出来。
class _CustomerDetailPlaceholder extends StatelessWidget {
  const _CustomerDetailPlaceholder({this.customerId, this.planId});

  final String? customerId;
  final String? planId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('客户详情')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('阶段 3 实现'),
            const SizedBox(height: AppTokens.s12),
            Text('customerId = ${customerId ?? '缺失'}'),
            Text('planId = ${planId ?? '缺失'}'),
          ],
        ),
      ),
    );
  }
}
