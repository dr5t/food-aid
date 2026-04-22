import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_spacing.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _orgNameController = TextEditingController();
  final _orgDescController = TextEditingController();
  final _companyIdController = TextEditingController();
  final _addressController = TextEditingController();

  UserRole _selectedRole = UserRole.donor;
  DonorType _selectedDonorType = DonorType.home;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _orgNameController.dispose();
    _orgDescController.dispose();
    _companyIdController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.md),

                // ─── Header ───────────────────────────────────────
                Text(
                  'Create Account',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Join Food Aid and help reduce food waste',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // ─── Role Selection ───────────────────────────────
                Text(
                  'I am a...',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildRoleSelector(),
                const SizedBox(height: AppSpacing.lg),

                // ─── Common Fields ────────────────────────────────
                _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  icon: Icons.person_outline,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email is required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock_outline,
                  obscure: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 6) return 'At least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: AppSpacing.md),
                _buildTextField(
                  controller: _addressController,
                  label: 'Address',
                  icon: Icons.location_on_outlined,
                  maxLines: 2,
                ),

                // ─── Role-specific Fields ─────────────────────────
                if (_selectedRole == UserRole.donor) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _buildDonorTypeSelector(),
                ],

                if (_selectedRole == UserRole.ngo) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _buildTextField(
                    controller: _orgNameController,
                    label: 'Organization Name',
                    icon: Icons.business_outlined,
                    validator: (v) => v == null || v.isEmpty
                        ? 'Organization name is required'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildTextField(
                    controller: _orgDescController,
                    label: 'Organization Description',
                    icon: Icons.description_outlined,
                    maxLines: 3,
                  ),
                ],

                if (_selectedRole == UserRole.logisticsCompany) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _buildTextField(
                    controller: _orgNameController,
                    label: 'Company Name',
                    icon: Icons.local_shipping_outlined,
                    validator: (v) => v == null || v.isEmpty
                        ? 'Company name is required'
                        : null,
                  ),
                ],

                // ─── Review Notice ────────────────────────────────
                if (_selectedRole == UserRole.ngo ||
                    _selectedRole == UserRole.logisticsCompany) ...[
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.amber.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: Colors.amber.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Your registration will be reviewed by our team before activation.',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.amber.shade800,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.xl),

                // ─── Error ────────────────────────────────────────
                if (authProvider.error != null)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.error, size: 20),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            authProvider.error!,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // ─── Submit ───────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _handleSignup,
                    child: authProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Create Account',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // ─── Login Link ───────────────────────────────────
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: RichText(
                      text: TextSpan(
                        text: 'Already have an account? ',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                        children: [
                          TextSpan(
                            text: 'Log In',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color:
                                  Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // ROLE SELECTOR
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildRoleSelector() {
    // Note: logisticsEmployee and admin roles are not available for self-signup.
    // Employees are created by their logistics company; admin employees by an admin.
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _roleCard(UserRole.donor, Icons.volunteer_activism, 'Donor'),
        _roleCard(UserRole.ngo, Icons.account_balance, 'NGO'),
        _roleCard(
            UserRole.logisticsCompany, Icons.local_shipping, 'Logistics Co.'),
      ],
    );
  }

  Widget _roleCard(UserRole role, IconData icon, String label) {
    final isSelected = _selectedRole == role;
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: (MediaQuery.of(context).size.width - 56) / 2,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? primary.withValues(alpha: 0.08)
              : isDark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isSelected
                ? primary
                : isDark
                    ? AppColors.darkDivider
                    : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: isSelected ? primary : null),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, size: 18, color: primary),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // DONOR TYPE SELECTOR
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildDonorTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Donor Type',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: DonorType.values.map((type) {
            final isSelected = _selectedDonorType == type;
            return ChoiceChip(
              label: Text(_donorTypeLabel(type)),
              selected: isSelected,
              onSelected: (_) =>
                  setState(() => _selectedDonorType = type),
              selectedColor:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
              labelStyle: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _donorTypeLabel(DonorType type) {
    switch (type) {
      case DonorType.hotel:
        return 'Hotel';
      case DonorType.restaurant:
        return 'Restaurant';
      case DonorType.wedding:
        return 'Wedding / Event';
      case DonorType.home:
        return 'Home';
      case DonorType.resort:
        return 'Resort';
      case DonorType.catering:
        return 'Catering';
      case DonorType.other:
        return 'Other';
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // SHARED TEXT FIELD
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: suffixIcon,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // SUBMIT
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signUp(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: _selectedRole,
      phone: _phoneController.text.trim(),
      donorType:
          _selectedRole == UserRole.donor ? _selectedDonorType : null,
      organizationName:
          (_selectedRole == UserRole.ngo ||
                  _selectedRole == UserRole.logisticsCompany)
              ? _orgNameController.text.trim()
              : null,
      organizationDescription:
          _selectedRole == UserRole.ngo
              ? _orgDescController.text.trim()
              : null,
      companyId:
          _selectedRole == UserRole.logisticsEmployee
              ? _companyIdController.text.trim()
              : null,
      address: _addressController.text.trim().isNotEmpty
          ? _addressController.text.trim()
          : null,
    );

    if (success && mounted) {
      // Router handles redirect automatically
    }
  }
}
