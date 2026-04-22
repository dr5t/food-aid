import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme/app_theme.dart';
import 'config/routes/app_router.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';

class FoodAidApp extends StatelessWidget {
  const FoodAidApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final router = AppRouter.router(authProvider);

    return MaterialApp.router(
      title: 'Food Aid',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeProvider.themeMode,
      routerConfig: router,
    );
  }
}
