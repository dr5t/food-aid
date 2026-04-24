import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'config/theme/app_theme.dart';
import 'config/routes/app_router.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'config/navigation/navigator_key.dart';

class FoodAidApp extends StatefulWidget {
  const FoodAidApp({super.key});

  @override
  State<FoodAidApp> createState() => _FoodAidAppState();
}

class _FoodAidAppState extends State<FoodAidApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    _router = AppRouter.router(authProvider);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp.router(
      title: 'Food Aid',
      debugShowCheckedModeBanner: false,
      key: navigatorKey,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeProvider.themeMode,
      routerConfig: _router,
    );
  }
}
