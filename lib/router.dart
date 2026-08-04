import 'package:go_router/go_router.dart';

import 'features/customers/customers_page.dart';
import 'features/funnel/funnel_page.dart';
import 'features/home/home_page.dart';
import 'features/settings/settings_page.dart';
import 'widgets/app_shell.dart';

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
            ),
          ],
        ),
      ],
    ),
  ],
);
