import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'router.dart';

class TavrixMenuApp extends StatelessWidget {
  const TavrixMenuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tavrix Menu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.login,
      routes: AppRouter.routes,
    );
  }
}
