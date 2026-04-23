import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_spacing.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/hitech_loader.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Wait for splash duration AND database health check
    await Future.wait([
      Future.delayed(AppConstants.splashDuration),
      authProvider.checkDatabaseHealth(),
    ]);

    if (mounted) {
      if (authProvider.isAuthenticated) {
        // Redirection logic should be handled by the router, 
        // but for now we follow the existing flow or trigger a refresh
        context.go('/');
      } else {
        context.go('/onboarding');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0B) : Colors.white,
      body: Stack(
        children: [
          // Background ambient glow
          if (isDark)
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.neonCyan.withOpacity(0.05),
                ),
              ).animate().fadeIn(duration: 2.seconds),
            ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const HitechLoader(
                  size: 100,
                  text: "System Initializing",
                ),
                const SizedBox(height: 60),
                Text(
                  AppConstants.appName.toUpperCase(),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.black,
                    letterSpacing: 8,
                    color: isDark ? Colors.white : AppColors.primary,
                  ),
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
                const SizedBox(height: 8),
                Text(
                  "DEHRADUN • INDIA",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                    color: isDark ? AppColors.neonCyan : AppColors.primary,
                  ),
                ).animate().fadeIn(delay: 800.ms),
              ],
            ),
          ),

          // Bottom Status Bar
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: authProvider.dbOnline ? AppColors.neonGreen : AppColors.error,
                        boxShadow: [
                          if (authProvider.dbOnline)
                            BoxShadow(
                              color: AppColors.neonGreen.withOpacity(0.5),
                              blurRadius: 8,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      authProvider.dbOnline ? "DATABASE SECURE" : "DATABASE OFFLINE",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ],
                ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeIn(duration: 1.seconds),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
