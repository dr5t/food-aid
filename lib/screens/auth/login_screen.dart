import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_spacing.dart';
import '../../config/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_input.dart';
import '../../widgets/common/database_status_indicator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.signIn(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );
    if (ok && mounted) {
      // Navigation is now handled by AppRouter via refreshListenable
    } else if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Login failed'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Animated Background Glows
          Positioned(
            top: -100,
            right: -100,
            child: _buildGlow(AppColors.neonCyan, 300),
          ).animate(onPlay: (c) => c.repeat()).move(
                begin: const Offset(-20, -20),
                end: const Offset(20, 20),
                duration: 5.seconds,
                curve: Curves.easeInOut,
              ),
          Positioned(
            bottom: -50,
            left: -50,
            child: _buildGlow(AppColors.neonPurple, 250),
          ).animate(onPlay: (c) => c.repeat()).move(
                begin: const Offset(20, 20),
                end: const Offset(-20, -20),
                duration: 4.seconds,
                curve: Curves.easeInOut,
              ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Align(
                alignment: Alignment.topRight,
                child: const DatabaseStatusIndicator(),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: AppSpacing.screenPadding,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: isDark 
                              ? Colors.white.withOpacity(0.05) 
                              : Colors.black.withOpacity(0.02),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark 
                                ? Colors.white.withOpacity(0.1) 
                                : Colors.black.withOpacity(0.05),
                          ),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.neonCyan.withOpacity(0.3),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Image.asset('assets/icons/app_icon.png'),
                                ),
                              ).animate().scale(duration: 600.ms, curve: Curves.backOut),
                              AppSpacing.verticalLg,
                              Center(
                                child: Text(
                                  'FOOD AID',
                                  style: AppTextStyles.heading.copyWith(
                                    letterSpacing: 4,
                                    fontWeight: FontWeight.w900,
                                    foreground: Paint()
                                      ..shader = AppColors.neonGradient.createShader(
                                        const Rect.fromLTWH(0, 0, 200, 70),
                                      ),
                                  ),
                                ),
                              ).animate().fadeIn(delay: 200.ms).moveY(begin: 10, end: 0),
                              AppSpacing.verticalXs,
                              Center(
                                child: Text(
                                  'Dehradun\'s High-Tech Food Sharing Network',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: isDark ? AppColors.neonCyan : AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ).animate().fadeIn(delay: 400.ms),
                              AppSpacing.verticalXl,
                              AppInput(
                                controller: _emailCtrl,
                                label: 'Cyber ID / Email',
                                hint: 'name@dehradun.aid',
                                prefixIcon: Icons.alternate_email_rounded,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Email is required';
                                  if (!v.contains('@')) return 'Enter a valid email';
                                  return null;
                                },
                              ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.1, end: 0),
                              AppSpacing.verticalMd,
                              AppInput(
                                controller: _passCtrl,
                                label: 'Security Key',
                                hint: '••••••••',
                                prefixIcon: Icons.lock_open_rounded,
                                obscureText: _obscure,
                                suffix: IconButton(
                                  icon: Icon(
                                    _obscure 
                                        ? Icons.visibility_off_rounded 
                                        : Icons.visibility_rounded,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Password is required';
                                  return null;
                                },
                              ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.1, end: 0),
                              AppSpacing.verticalXl,
                              ShaderMask(
                                shaderCallback: (bounds) => AppColors.neonGradient.createShader(bounds),
                                child: AppButton(
                                  label: 'INITIALIZE SESSION',
                                  onPressed: _login,
                                  isLoading: auth.isLoading,
                                ),
                              ).animate().fadeIn(delay: 700.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
                              AppSpacing.verticalMd,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("New to the network? ", style: AppTextStyles.bodySmall),
                                  TextButton(
                                    onPressed: () => context.go('/signup'),
                                    child: Text(
                                      'JOIN NOW',
                                      style: TextStyle(
                                        color: AppColors.neonCyan,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ).animate().fadeIn(delay: 800.ms),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlow(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 100,
            spreadRadius: 50,
          ),
        ],
      ),
    );
  }
}
