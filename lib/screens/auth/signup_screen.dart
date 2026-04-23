import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_spacing.dart';
import '../../config/theme/app_text_styles.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_input.dart';
import '../../widgets/common/database_status_indicator.dart';
import '../../widgets/common/cyber_background.dart';
import '../../widgets/common/cyber_card.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _orgNameCtrl = TextEditingController();
  final _orgDescCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  UserRole _selectedRole = UserRole.donor;
  DonorType _selectedDonorType = DonorType.home;
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _phoneCtrl.dispose();
    _orgNameCtrl.dispose();
    _orgDescCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.signUp(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      role: _selectedRole,
      phone: _phoneCtrl.text.trim(),
      donorType: _selectedRole == UserRole.donor ? _selectedDonorType : null,
      organizationName: (_selectedRole == UserRole.ngo || _selectedRole == UserRole.logisticsCompany)
          ? _orgNameCtrl.text.trim()
          : null,
      organizationDescription: _selectedRole == UserRole.ngo ? _orgDescCtrl.text.trim() : null,
      address: _addressCtrl.text.trim().isNotEmpty ? _addressCtrl.text.trim() : null,
    );

    if (success && mounted) {
      // Navigation is now handled by AppRouter via refreshListenable
    } else if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(auth.error ?? 'Access Denied: Enrollment Failed')),
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
            left: -150,
            child: _buildGlow(AppColors.neonPink, 400),
          ).animate(onPlay: (c) => c.repeat()).move(
                begin: const Offset(-30, -30),
                end: const Offset(30, 30),
                duration: 8.seconds,
                curve: Curves.easeInOut,
              ),
          Positioned(
            bottom: -100,
            right: -100,
            child: _buildGlow(AppColors.neonCyan, 350),
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
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    children: [
                      // Logo Section
                      _buildLogoSection().animate().scale(duration: 800.ms, curve: Curves.easeOutBack),
                      AppSpacing.verticalLg,
                      
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
                              
                              _buildRoleSelector().animate().fadeIn(delay: 300.ms).slideX(begin: 0.1, end: 0),
                              AppSpacing.verticalLg,

                              _buildSectionTitle('IDENTITY PROTOCOL'),
                              AppInput(
                                controller: _nameCtrl,
                                label: 'AGENT NAME',
                                hint: 'e.g. Aryan Sharma',
                                prefixIcon: Icons.person_add_alt_1_rounded,
                                validator: (v) => v == null || v.isEmpty ? 'Identity record required' : null,
                              ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1, end: 0),
                              AppSpacing.verticalMd,
                              
                              AppInput(
                                controller: _emailCtrl,
                                label: 'NEURAL LINK ID (EMAIL)',
                                hint: 'aryan@dehradun.aid',
                                prefixIcon: Icons.alternate_email_rounded,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Neural link ID required';
                                  if (!v.contains('@')) return 'Invalid ID format';
                                  return null;
                                },
                              ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.1, end: 0),
                              AppSpacing.verticalMd,
                              
                              AppInput(
                                controller: _passCtrl,
                                label: 'ENCRYPTION KEY (PASSWORD)',
                                hint: '••••••••',
                                prefixIcon: Icons.vpn_key_rounded,
                                obscureText: _obscure,
                                suffix: IconButton(
                                  icon: Icon(
                                    _obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, 
                                    size: 18,
                                    color: isDark ? AppColors.neonCyan.withValues(alpha: 0.7) : null,
                                  ),
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                ),
                                validator: (v) => (v == null || v.length < 6) ? 'Min. 6 characters for security' : null,
                              ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.1, end: 0),
                              
                              AppSpacing.verticalLg,
                              _buildSectionTitle('COMM-LINK & GRID LOC'),
                              AppInput(
                                controller: _phoneCtrl,
                                label: 'COMMS ID (PHONE)',
                                hint: '+91 9876543210',
                                prefixIcon: Icons.phone_iphone_rounded,
                                keyboardType: TextInputType.phone,
                              ).animate().fadeIn(delay: 700.ms).slideX(begin: 0.1, end: 0),
                              AppSpacing.verticalMd,
                              
                              AppInput(
                                controller: _addressCtrl,
                                label: 'GRID ADDRESS (DEHRADUN)',
                                hint: 'e.g. Rajpur Road Node',
                                prefixIcon: Icons.map_rounded,
                                maxLines: 2,
                              ).animate().fadeIn(delay: 800.ms).slideX(begin: 0.1, end: 0),

                              if (_selectedRole == UserRole.donor) ...[
                                AppSpacing.verticalLg,
                                _buildDonorTypeSelector().animate().fadeIn().slideX(begin: 0.1, end: 0),
                              ],

                              if (_selectedRole == UserRole.ngo || _selectedRole == UserRole.logisticsCompany) ...[
                                AppSpacing.verticalLg,
                                _buildSectionTitle('ENTITY PROTOCOL'),
                                AppInput(
                                  controller: _orgNameCtrl,
                                  label: 'ORGANIZATION NAME',
                                  hint: _selectedRole == UserRole.ngo ? 'e.g. Doon Food Bank' : 'e.g. Dehradun Express',
                                  prefixIcon: Icons.business_center_rounded,
                                  validator: (v) => v == null || v.isEmpty ? 'Entity name required' : null,
                                ).animate().fadeIn().slideX(begin: 0.1, end: 0),
                                if (_selectedRole == UserRole.ngo) ...[
                                  AppSpacing.verticalMd,
                                  AppInput(
                                    controller: _orgDescCtrl,
                                    label: 'MISSION PROFILE',
                                    hint: 'Describe your node\'s objectives...',
                                    prefixIcon: Icons.description_rounded,
                                    maxLines: 3,
                                  ).animate().fadeIn().slideX(begin: 0.1, end: 0),
                                ],
                              ],

                              AppSpacing.verticalXl,
                              
                              _buildSubmitButton(auth, isDark),
                              
                              AppSpacing.verticalLg,
                              _buildFooter(context, isDark),
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
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.neonPink.withValues(alpha: 0.2), width: 2),
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
              begin: const Offset(1, 1),
              end: const Offset(1.2, 1.2),
              duration: 2.seconds,
            ),
            
        Container(
          width: 80,
          height: 80,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black,
            boxShadow: [
              BoxShadow(
                color: AppColors.neonPink.withValues(alpha: 0.4),
                blurRadius: 25,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/app_logo.png',
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PROTOCOL: ENROLLMENT',
          style: AppTextStyles.hitech.copyWith(
            fontSize: 12,
            letterSpacing: 2,
            color: AppColors.neonPink,
            fontWeight: FontWeight.bold,
          ),
        ),
        AppSpacing.verticalXs,
        Text(
          'JOIN THE NETWORK',
          style: AppTextStyles.hitech.copyWith(
            fontSize: 28,
            letterSpacing: 1,
            fontWeight: FontWeight.w900,
            foreground: Paint()
              ..shader = AppColors.neonGradient.createShader(
                const Rect.fromLTWH(0, 0, 300, 70),
              ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.hitech.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
          color: AppColors.neonCyan.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('ACCESS LEVEL'),
        Row(
          children: [
            _roleBtn(UserRole.donor, 'DONOR'),
            const SizedBox(width: 8),
            _roleBtn(UserRole.ngo, 'NGO'),
            const SizedBox(width: 8),
            _roleBtn(UserRole.logisticsCompany, 'LOGISTICS'),
          ],
        ),
      ],
    );
  }

  Widget _roleBtn(UserRole role, String label) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: AnimatedContainer(
          duration: 300.ms,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.neonCyan.withValues(alpha: 0.05) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.neonCyan : Colors.white10,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected ? [
              BoxShadow(
                color: AppColors.neonCyan.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: -2,
              )
            ] : null,
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.hitech.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.neonCyan : Colors.white38,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDonorTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('DONOR CATEGORY'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: DonorType.values.map((type) {
            final isSelected = _selectedDonorType == type;
            return ChoiceChip(
              label: Text(_donorTypeLabel(type)),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedDonorType = type),
              selectedColor: AppColors.neonCyan.withValues(alpha: 0.15),
              backgroundColor: Colors.white.withValues(alpha: 0.02),
              side: BorderSide(color: isSelected ? AppColors.neonCyan : Colors.white10),
              labelStyle: AppTextStyles.hitech.copyWith(
                fontSize: 10,
                color: isSelected ? AppColors.neonCyan : Colors.white60,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _donorTypeLabel(DonorType type) {
    switch (type) {
      case DonorType.hotel: return 'HOTEL';
      case DonorType.restaurant: return 'RESTAURANT';
      case DonorType.wedding: return 'EVENT/WEDDING';
      case DonorType.home: return 'HOME';
      case DonorType.resort: return 'RESORT';
      case DonorType.catering: return 'CATERING';
      case DonorType.other: return 'OTHER';
    }
  }

  Widget _buildSubmitButton(AuthProvider auth, bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.neonPink.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: AppButton(
        label: auth.isLoading ? 'AUTHORIZING...' : 'AUTHORIZE REGISTRATION',
        onPressed: _handleSignup,
        isLoading: auth.isLoading,
        textStyle: AppTextStyles.hitech.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "EXISTING CYBER ID? ",
                style: AppTextStyles.hitech.copyWith(fontSize: 10, color: Colors.white38),
              ),
              TextButton(
                onPressed: () => context.go('/login'),
                child: Text(
                  'LOGIN',
                  style: AppTextStyles.hitech.copyWith(
                    color: AppColors.neonCyan,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'ENROLLMENT SUBJECT TO NODE VERIFICATION',
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
