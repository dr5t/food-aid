import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_spacing.dart';
import '../../config/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_input.dart';
import '../../widgets/common/app_background.dart';
import '../../widgets/common/app_card.dart';

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
  bool _isAuthenticating = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isAuthenticating = true);
    
    final auth = context.read<AuthProvider>();
    final ok = await auth.signIn(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );
    
    if (mounted) setState(() => _isAuthenticating = false);

    if (ok && mounted) {
      // Navigation handled by AppRouter
    } else if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(auth.error ?? 'Access Denied: Invalid Credentials')),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF050505) : Colors.white,
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: AppSpacing.screenPadding,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLogoSection(),
                    
                    AppSpacing.verticalLg,
                    
                    AppCard(
                      borderRadius: 16,
                      padding: const EdgeInsets.all(32),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(isDark),
                            AppSpacing.verticalXl,
                            
                            AppInput(
                              controller: _emailCtrl,
                              label: 'Email Address',
                              hint: 'yourname@example.com',
                              prefixIcon: Icons.alternate_email_rounded,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Email address required';
                                if (!v.contains('@')) return 'Invalid email format';
                                return null;
                              },
                            ),
                            
                            AppSpacing.verticalMd,
                            
                            AppInput(
                              controller: _passCtrl,
                              label: 'Password',
                              hint: '••••••••',
                              prefixIcon: Icons.security_rounded,
                              obscureText: _obscure,
                              suffix: IconButton(
                                icon: Icon(
                                  _obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                  size: 18,
                                ),
                                onPressed: () => setState(() => _obscure = !_obscure),
                              ),
                              validator: (v) => (v == null || v.isEmpty) ? 'Password required' : null,
                            ),
                            
                            AppSpacing.verticalLg,
                            
                            _buildSubmitButton(auth, isDark),
                            
                            AppSpacing.verticalLg,
                            
                            _buildFooter(context),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 80,
      height: 80,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? Colors.black : Colors.white,
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.1)),
      ),
      child: Image.asset(
        'assets/images/app_logo.png',
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Back',
          style: AppTextStyles.headingLarge,
        ),
        AppSpacing.verticalXs,
        Text(
          'Sign in to your account',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(AuthProvider auth, bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: AppButton(
        label: _isAuthenticating ? 'Signing In...' : 'Sign In',
        onPressed: _login,
        isLoading: auth.isLoading,
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account? ",
                style: AppTextStyles.bodySmall,
              ),
              TextButton(
                onPressed: () => context.go('/signup'),
                child: Text(
                  'Sign Up',
                  style: AppTextStyles.buttonSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

