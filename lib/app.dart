import 'package:flutter/material.dart';

import 'router.dart';
import 'theme/theme.dart';

class CustomerApp extends StatelessWidget {
  const CustomerApp({super.key});

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
