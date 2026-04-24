import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_spacing.dart';
import '../../config/theme/app_text_styles.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_input.dart';
import '../../widgets/common/database_status_indicator.dart';
import '../../widgets/common/app_background.dart';
import '../../widgets/common/app_card.dart';

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
              Expanded(child: Text(auth.error ?? 'Registration Failed')),
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
      body: AppBackground(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: AppSpacing.screenPadding,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    children: [
                      // Logo Section
                      _buildLogoSection(),
                      AppSpacing.verticalLg,
                      
                      AppCard(
                        padding: const EdgeInsets.all(32),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader(isDark),
                              AppSpacing.verticalXl,
                              
                              _buildRoleSelector(),
                              AppSpacing.verticalLg,

                              _buildSectionTitle('Personal Information'),
                              AppInput(
                                controller: _nameCtrl,
                                label: 'Full Name',
                                hint: 'e.g. Aryan Sharma',
                                prefixIcon: Icons.person_add_alt_1_rounded,
                                validator: (v) => v == null || v.isEmpty ? 'Name required' : null,
                              ),
                              AppSpacing.verticalMd,
                              
                              AppInput(
                                controller: _emailCtrl,
                                label: 'Email Address',
                                hint: 'aryan@example.com',
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
                                prefixIcon: Icons.vpn_key_rounded,
                                obscureText: _obscure,
                                suffix: IconButton(
                                  icon: Icon(
                                    _obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, 
                                    size: 18,
                                  ),
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                ),
                                validator: (v) => (v == null || v.length < 6) ? 'Min. 6 characters required' : null,
                              ),
                              
                              AppSpacing.verticalLg,
                              _buildSectionTitle('Contact & Location'),
                              AppInput(
                                controller: _phoneCtrl,
                                label: 'Phone Number',
                                hint: '+91 9876543210',
                                prefixIcon: Icons.phone_iphone_rounded,
                                keyboardType: TextInputType.phone,
                              ),
                              AppSpacing.verticalMd,
                              
                              AppInput(
                                controller: _addressCtrl,
                                label: 'Address',
                                hint: 'e.g. Rajpur Road, Dehradun',
                                prefixIcon: Icons.map_rounded,
                                maxLines: 2,
                              ),

                              if (_selectedRole == UserRole.donor) ...[
                                AppSpacing.verticalLg,
                                _buildDonorTypeSelector(),
                              ],

                              if (_selectedRole == UserRole.ngo || _selectedRole == UserRole.logisticsCompany) ...[
                                AppSpacing.verticalLg,
                                _buildSectionTitle('Organization Details'),
                                AppInput(
                                  controller: _orgNameCtrl,
                                  label: 'Organization Name',
                                  hint: _selectedRole == UserRole.ngo ? 'e.g. Doon Food Bank' : 'e.g. Dehradun Express',
                                  prefixIcon: Icons.business_center_rounded,
                                  validator: (v) => v == null || v.isEmpty ? 'Organization name required' : null,
                                ),
                                if (_selectedRole == UserRole.ngo) ...[
                                  AppSpacing.verticalMd,
                                  AppInput(
                                    controller: _orgDescCtrl,
                                    label: 'Mission Description',
                                    hint: 'Describe your organization\'s objectives...',
                                    prefixIcon: Icons.description_rounded,
                                    maxLines: 3,
                                  ),
                                ],
                              ],

                              _buildSubmitButton(auth, isDark),
                              
                              AppSpacing.verticalLg,
                              _buildFooter(context, isDark),
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
    return Container(
      width: 70,
      height: 70,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
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
          'Join Food Aid',
          style: AppTextStyles.headingLarge,
        ),
        AppSpacing.verticalXs,
        Text(
          'Fill in your details to get started',
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Text(
        title,
        style: AppTextStyles.titleSmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Account Type'),
        Row(
          children: [
            _roleBtn(UserRole.donor, 'Donor'),
            const SizedBox(width: 8),
            _roleBtn(UserRole.ngo, 'NGO'),
            const SizedBox(width: 8),
            _roleBtn(UserRole.logisticsCompany, 'Logistics'),
          ],
        ),
      ],
    );
  }

  Widget _roleBtn(UserRole role, String label) {
    final isSelected = _selectedRole == role;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : (isDark ? Colors.white10 : Colors.black12),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.label.copyWith(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : (isDark ? Colors.white38 : Colors.black38),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDonorTypeSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
              selectedColor: AppColors.primary.withValues(alpha: 0.15),
              backgroundColor: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.02),
              side: BorderSide(color: isSelected ? AppColors.primary : (isDark ? Colors.white10 : Colors.black12)),
              labelStyle: AppTextStyles.label.copyWith(
                fontSize: 12,
                color: isSelected ? AppColors.primary : (isDark ? Colors.white60 : Colors.black54),
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
      case DonorType.hotel: return 'Hotel';
      case DonorType.restaurant: return 'Restaurant';
      case DonorType.wedding: return 'Event/Wedding';
      case DonorType.home: return 'Home';
      case DonorType.resort: return 'Resort';
      case DonorType.catering: return 'Catering';
      case DonorType.other: return 'Other';
    }
  }

  Widget _buildSubmitButton(AuthProvider auth, bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: AppButton(
        label: auth.isLoading ? 'Creating Account...' : 'Create Account',
        onPressed: _handleSignup,
        isLoading: auth.isLoading,
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
                "Already have an account? ",
                style: AppTextStyles.bodySmall,
              ),
              TextButton(
                onPressed: () => context.go('/login'),
                child: Text(
                  'Sign In',
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
