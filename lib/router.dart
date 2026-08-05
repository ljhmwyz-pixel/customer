import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/customers/customer_detail_page.dart';
import 'features/business/quote_form_page.dart';
import 'features/business/sample_form_page.dart';
import 'features/customers/customer_form_page.dart';
import 'features/customers/customers_page.dart';
import 'features/customers/followup_form_page.dart';
import 'features/funnel/funnel_page.dart';
import 'features/home/home_page.dart';
import 'features/orders/order_form_page.dart';
import 'features/opportunities/opportunity_form_page.dart';
import 'features/reminders/permission_page.dart';
import 'features/reminders/reminder_log_page.dart';
import 'features/reminders/reminder_test_page.dart';
import 'features/settings/settings_page.dart';
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
                  path: 'new',
                  builder: (context, state) => const CustomerFormPage(),
                ),
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    final customerId = int.tryParse(
                      state.pathParameters['id'] ?? '',
                    );
                    final rawPlanId = state.uri.queryParameters['planId'];
                    final planId = rawPlanId == null
                        ? null
                        : int.tryParse(rawPlanId);
                    return CustomerDetailPage(
                      customerId: customerId,
                      highlightedPlanId: planId,
                      invalidPlanId: rawPlanId != null && planId == null,
                    );
                  },
                  routes: [
                    GoRoute(
                      path: 'edit',
                      builder: (context, state) {
                        final customerId = int.tryParse(
                          state.pathParameters['id'] ?? '',
                        );
                        if (customerId == null) {
                          return const CustomerDetailPage(customerId: null);
                        }
                        return CustomerFormPage(customerId: customerId);
                      },
                    ),
                    GoRoute(
                      path: 'followups/new',
                      builder: (context, state) {
                        final customerId = int.tryParse(
                          state.pathParameters['id'] ?? '',
                        );
                        if (customerId == null) {
                          return const CustomerDetailPage(customerId: null);
                        }
                        return FollowupFormPage(customerId: customerId);
                      },
                    ),
                    GoRoute(
                      path: 'opportunities/new',
                      builder: (context, state) {
                        final customerId = int.tryParse(
                          state.pathParameters['id'] ?? '',
                        );
                        if (customerId == null) {
                          return const _RouteErrorPage(message: '客户编号无效');
                        }
                        return OpportunityFormPage(customerId: customerId);
                      },
                    ),
                    GoRoute(
                      path: 'opportunities/:opportunityId/edit',
                      builder: (context, state) {
                        final customerId = int.tryParse(
                          state.pathParameters['id'] ?? '',
                        );
                        final opportunityId = int.tryParse(
                          state.pathParameters['opportunityId'] ?? '',
                        );
                        if (customerId == null || opportunityId == null) {
                          return const _RouteErrorPage(message: '项目编号无效');
                        }
                        return OpportunityFormPage(
                          customerId: customerId,
                          opportunityId: opportunityId,
                        );
                      },
                    ),
                    GoRoute(
                      path: 'orders/new',
                      builder: (context, state) {
                        final customerId = int.tryParse(
                          state.pathParameters['id'] ?? '',
                        );
                        if (customerId == null) {
                          return const _RouteErrorPage(message: '客户编号无效');
                        }
                        return OrderFormPage(customerId: customerId);
                      },
                    ),
                    GoRoute(
                      path: 'opportunities/:opportunityId/quotes/new',
                      builder: (context, state) => QuoteFormPage(
                        customerId: int.parse(state.pathParameters['id']!),
                        opportunityId: int.parse(
                          state.pathParameters['opportunityId']!,
                        ),
                      ),
                    ),
                    GoRoute(
                      path: 'opportunities/:opportunityId/samples/new',
                      builder: (context, state) => SampleFormPage(
                        customerId: int.parse(state.pathParameters['id']!),
                        opportunityId: int.parse(
                          state.pathParameters['opportunityId']!,
                        ),
                      ),
                    ),
                    GoRoute(
                      path: 'orders/:orderId/edit',
                      builder: (context, state) {
                        final customerId = int.tryParse(
                          state.pathParameters['id'] ?? '',
                        );
                        if (customerId == null) {
                          return const _RouteErrorPage(message: '客户编号无效');
                        }
                        final orderId = int.tryParse(
                          state.pathParameters['orderId'] ?? '',
                        );
                        if (orderId == null) {
                          return const _RouteErrorPage(message: '订单编号无效');
                        }
                        return OrderFormPage(
                          customerId: customerId,
                          orderId: orderId,
                        );
                      },
                    ),
                  ],
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

class _RouteErrorPage extends StatelessWidget {
  const _RouteErrorPage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('无法打开页面')),
    body: Center(child: Text(message)),
  );
}
