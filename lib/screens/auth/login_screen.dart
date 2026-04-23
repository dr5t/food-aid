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
import '../../widgets/common/cyber_background.dart';
import '../../widgets/common/cyber_card.dart';

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
      body: CyberBackground(
        children: [
          // Ambient Glows
          Positioned(
            top: -150,
            right: -150,
            child: _buildGlow(AppColors.neonCyan, 400),
          ).animate(onPlay: (c) => c.repeat()).move(
                begin: const Offset(-30, -30),
                end: const Offset(30, 30),
                duration: 8.seconds,
                curve: Curves.easeInOut,
              ),
          Positioned(
            bottom: -100,
            left: -100,
            child: _buildGlow(AppColors.neonPurple, 350),
          ).animate(onPlay: (c) => c.repeat()).move(
                begin: const Offset(30, 30),
                end: const Offset(-30, -30),
                duration: 7.seconds,
                curve: Curves.easeInOut,
              ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: AppSpacing.screenPadding,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Section with Scanning Effect
                      _buildLogoSection().animate().scale(duration: 800.ms, curve: Curves.easeOutBack),
                      
                      AppSpacing.verticalLg,
                      
                      // Auth Card
                      CyberCard(
                        borderRadius: 28,
                        showGlow: true,
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
                                label: 'NEURAL LINK ID (EMAIL)',
                                hint: 'name@dehradun.aid',
                                prefixIcon: Icons.alternate_email_rounded,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Neural Link ID required';
                                  if (!v.contains('@')) return 'Invalid ID format';
                                  return null;
                                },
                              ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1, end: 0),
                              
                              AppSpacing.verticalMd,
                              
                              AppInput(
                                controller: _passCtrl,
                                label: 'ENCRYPTION KEY (PASSWORD)',
                                hint: '••••••••',
                                prefixIcon: Icons.security_rounded,
                                obscureText: _obscure,
                                suffix: IconButton(
                                  icon: Icon(
                                    _obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                    size: 18,
                                    color: isDark ? AppColors.neonCyan.withValues(alpha: 0.7) : null,
                                  ),
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                ),
                                validator: (v) => (v == null || v.isEmpty) ? 'Encryption Key required' : null,
                              ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.1, end: 0),
                              
                              AppSpacing.verticalLg,
                              
                              _buildSubmitButton(auth, isDark),
                              
                              AppSpacing.verticalLg,
                              
                              _buildFooter(context),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(duration: 800.ms).moveY(begin: 30, end: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Database Status
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: const Align(
                alignment: Alignment.topRight,
                child: DatabaseStatusIndicator(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoSection() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulsing Ring
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.2), width: 2),
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
              begin: const Offset(1, 1),
              end: const Offset(1.2, 1.2),
              duration: 2.seconds,
            ),
            
        Container(
          width: 100,
          height: 100,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black,
            boxShadow: [
              BoxShadow(
                color: AppColors.neonCyan.withValues(alpha: 0.4),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/app_logo.png',
            fit: BoxFit.contain,
          ),
        ),
        
        if (_isAuthenticating)
          const Positioned.fill(
            child: _ScanningEffect(),
          ),
      ],
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PROTOCOL: INITIALIZE',
          style: AppTextStyles.hitech.copyWith(
            fontSize: 12,
            letterSpacing: 2,
            color: AppColors.neonCyan,
            fontWeight: FontWeight.bold,
          ),
        ),
        AppSpacing.verticalXs,
        Text(
          'DEHRADUN NODE',
          style: AppTextStyles.hitech.copyWith(
            fontSize: 28,
            letterSpacing: 1,
            fontWeight: FontWeight.w900,
            foreground: Paint()
              ..shader = AppColors.cyberGradient.createShader(
                const Rect.fromLTWH(0, 0, 200, 70),
              ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(AuthProvider auth, bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.neonCyan.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: AppButton(
        label: _isAuthenticating ? 'VERIFYING...' : 'AUTHORIZE SESSION',
        onPressed: _login,
        isLoading: auth.isLoading,
        textStyle: AppTextStyles.hitech.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
          fontSize: 14,
        ),
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
                "UNREGISTERED AGENT? ",
                style: AppTextStyles.hitech.copyWith(fontSize: 10, color: Colors.white38),
              ),
              TextButton(
                onPressed: () => context.go('/signup'),
                child: Text(
                  'ENROLL NOW',
                  style: AppTextStyles.hitech.copyWith(
                    color: AppColors.neonCyan,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'SECURE LINE: 256-BIT ENCRYPTION ACTIVE',
            style: AppTextStyles.hitech.copyWith(
              fontSize: 8,
              color: Colors.white12,
              letterSpacing: 1,
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
            color: color.withValues(alpha: 0.12),
            blurRadius: 100,
            spreadRadius: 40,
          ),
        ],
      ),
    );
  }
}

class _ScanningEffect extends StatefulWidget {
  const _ScanningEffect();

  @override
  State<_ScanningEffect> createState() => _ScanningEffectState();
}

class _ScanningEffectState extends State<_ScanningEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: _controller.value * 100,
              left: 0,
              right: 0,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonCyan,
                      blurRadius: 10,
                      spreadRadius: 1,
                    )
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
