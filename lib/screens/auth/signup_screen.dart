import 'dart:ui';
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
      if (auth.isPendingVerification) {
        context.go('/pending-verification');
      } else {
        final role = auth.role;
        if (role != null) {
          String location = '/donor';
          switch (role) {
            case UserRole.admin: location = '/admin'; break;
            case UserRole.ngo: location = '/ngo'; break;
            case UserRole.logisticsCompany: location = '/company'; break;
            case UserRole.logisticsEmployee: location = '/employee'; break;
            default: location = '/donor';
          }
          context.go(location);
        }
      }
    } else if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Signup failed'),
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
            left: -100,
            child: _buildGlow(AppColors.neonPink, 300),
          ).animate(onPlay: (c) => c.repeat()).move(
                begin: const Offset(-20, -20),
                end: const Offset(20, 20),
                duration: 6.seconds,
                curve: Curves.easeInOut,
              ),
          Positioned(
            bottom: -50,
            right: -50,
            child: _buildGlow(AppColors.neonBlue, 250),
          ).animate(onPlay: (c) => c.repeat()).move(
                begin: const Offset(20, 20),
                end: const Offset(-20, -20),
                duration: 5.seconds,
                curve: Curves.easeInOut,
              ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: AppSpacing.screenPadding,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(28),
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
                                child: Text(
                                  'JOIN THE NETWORK',
                                  style: AppTextStyles.heading.copyWith(
                                    letterSpacing: 2,
                                    fontWeight: FontWeight.w900,
                                    foreground: Paint()
                                      ..shader = AppColors.neonGradient.createShader(
                                        const Rect.fromLTWH(0, 0, 300, 70),
                                      ),
                                  ),
                                ),
                              ).animate().fadeIn().moveY(begin: 10, end: 0),
                              AppSpacing.verticalXs,
                              Center(
                                child: Text(
                                  'Initiating registration for Dehradun Node',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: isDark ? AppColors.neonCyan : AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ).animate().fadeIn(delay: 200.ms),
                              AppSpacing.verticalLg,
                              
                              _buildRoleSelector().animate().fadeIn(delay: 300.ms),
                              AppSpacing.verticalMd,

                              _buildSectionTitle('Identity Details'),
                              AppInput(
                                controller: _nameCtrl,
                                label: 'Full Name',
                                hint: 'e.g. Aryan Sharma',
                                prefixIcon: Icons.person_add_alt_1_rounded,
                                validator: (v) => v == null || v.isEmpty ? 'Name is required' : null,
                              ).animate().fadeIn(delay: 400.ms),
                              AppSpacing.verticalMd,
                              AppInput(
                                controller: _emailCtrl,
                                label: 'Cyber Mail',
                                hint: 'aryan@dehradun.aid',
                                prefixIcon: Icons.alternate_email_rounded,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Email is required';
                                  if (!v.contains('@')) return 'Enter a valid email';
                                  return null;
                                },
                              ).animate().fadeIn(delay: 500.ms),
                              AppSpacing.verticalMd,
                              AppInput(
                                controller: _passCtrl,
                                label: 'Access Key',
                                hint: '••••••••',
                                prefixIcon: Icons.vpn_key_rounded,
                                obscureText: _obscure,
                                suffix: IconButton(
                                  icon: Icon(_obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 20),
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                ),
                                validator: (v) => (v == null || v.length < 6) ? 'At least 6 characters' : null,
                              ).animate().fadeIn(delay: 600.ms),
                              
                              AppSpacing.verticalLg,
                              _buildSectionTitle('Location & Contact'),
                              AppInput(
                                controller: _phoneCtrl,
                                label: 'Comm-Link (Phone)',
                                hint: '+91 9876543210',
                                prefixIcon: Icons.phone_iphone_rounded,
                                keyboardType: TextInputType.phone,
                              ).animate().fadeIn(delay: 700.ms),
                              AppSpacing.verticalMd,
                              AppInput(
                                controller: _addressCtrl,
                                label: 'Grid Address (Dehradun)',
                                hint: 'e.g. 42, Rajpur Road, Near Clock Tower',
                                prefixIcon: Icons.map_rounded,
                                maxLines: 2,
                              ).animate().fadeIn(delay: 800.ms),

                              if (_selectedRole == UserRole.donor) ...[
                                AppSpacing.verticalLg,
                                _buildDonorTypeSelector().animate().fadeIn(),
                              ],

                              if (_selectedRole == UserRole.ngo || _selectedRole == UserRole.logisticsCompany) ...[
                                AppSpacing.verticalLg,
                                _buildSectionTitle('Organization Protocol'),
                                AppInput(
                                  controller: _orgNameCtrl,
                                  label: 'Entity Name',
                                  hint: _selectedRole == UserRole.ngo ? 'e.g. Doon Food Bank' : 'e.g. Dehradun Express',
                                  prefixIcon: Icons.business_center_rounded,
                                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                                ).animate().fadeIn(),
                                if (_selectedRole == UserRole.ngo) ...[
                                  AppSpacing.verticalMd,
                                  AppInput(
                                    controller: _orgDescCtrl,
                                    label: 'Mission Profile',
                                    hint: 'Briefly describe your NGO\'s work in Dehradun...',
                                    prefixIcon: Icons.description_rounded,
                                    maxLines: 3,
                                  ).animate().fadeIn(),
                                ],
                              ],

                              AppSpacing.verticalXl,
                              ShaderMask(
                                shaderCallback: (bounds) => AppColors.cyberGradient.createShader(bounds),
                                child: AppButton(
                                  label: 'AUTHORIZE REGISTRATION',
                                  onPressed: _handleSignup,
                                  isLoading: auth.isLoading,
                                ),
                              ).animate().fadeIn(delay: 900.ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
                              
                              AppSpacing.verticalMd,
                              Center(
                                child: TextButton(
                                  onPressed: () => context.go('/login'),
                                  child: RichText(
                                    text: TextSpan(
                                      text: 'Existing Cyber ID? ',
                                      style: AppTextStyles.bodySmall,
                                      children: [
                                        TextSpan(
                                          text: 'LOGIN',
                                          style: TextStyle(
                                            color: AppColors.neonCyan,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ).animate().fadeIn(delay: 1.seconds),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
          color: AppColors.neonCyan.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Access Level'),
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
            color: isSelected ? AppColors.neonCyan.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.neonCyan : Colors.white24,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.neonCyan : Colors.white60,
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
        _buildSectionTitle('Donor Category'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: DonorType.values.map((type) {
            final isSelected = _selectedDonorType == type;
            return ChoiceChip(
              label: Text(_donorTypeLabel(type)),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedDonorType = type),
              selectedColor: AppColors.neonCyan.withOpacity(0.2),
              backgroundColor: Colors.transparent,
              side: BorderSide(color: isSelected ? AppColors.neonCyan : Colors.white24),
              labelStyle: TextStyle(
                fontSize: 11,
                color: isSelected ? AppColors.neonCyan : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _donorTypeLabel(DonorType type) {
    switch (type) {
      case DonorType.hotel: return 'Hotel';
      case DonorType.restaurant: return 'Restaurant';
      case DonorType.wedding: return 'Event/Wedding';
      case DonorType.home: return 'Home';
      case DonorType.resort: return 'Resort';
      case DonorType.catering: return 'Catering';
      case DonorType.other: return 'Other';
    }
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
