import 'package:flutter/material.dart';

import 'router.dart';
import 'services/notification_payload.dart';
import 'services/notification_service.dart';
import 'theme/theme.dart';

class CustomerApp extends StatefulWidget {
  const CustomerApp({super.key});

  @override
  State<CustomerApp> createState() => _CustomerAppState();
}

class _CustomerAppState extends State<CustomerApp> {
  @override
  void initState() {
    super.initState();

    // 监听通知点击。用 ValueNotifier 而非回调的原因见 NotificationService：
    // 冷启动时通知可能比路由更早就绪，所以这里除了订阅后续变化，
    // 还要主动读一次当前值。
    NotificationService.tappedPayload.addListener(_handleTappedPayload);
    _handleTappedPayload();
  }

  @override
  void dispose() {
    NotificationService.tappedPayload.removeListener(_handleTappedPayload);
    super.dispose();
  }

  void _handleTappedPayload() {
    final payload = NotificationService.tappedPayload.value;
    if (payload == null) return;

    // 读完就清空，否则下次 rebuild 会重复跳转。
    NotificationService.tappedPayload.value = null;

    // 路由此刻可能还没挂载，推到下一帧执行。
    WidgetsBinding.instance.addPostFrameCallback((_) => _navigate(payload));
  }

  void _navigate(NotificationPayload payload) {
    // planId 挂在 query 而非路径上：客户详情页的身份是 customerId，
    // planId 只是「从哪条提醒进来的」这个上下文，不该参与路径。
    router.go(
      Uri(
        path: customerDetailLocation(payload.customerId),
        queryParameters: {'planId': '${payload.planId}'},
      ).toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '客户跟进',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // 跟随系统深色模式设置
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
