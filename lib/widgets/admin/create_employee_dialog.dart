import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_spacing.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';

class CreateEmployeeDialog extends StatefulWidget {
  final String title;
  final UserRole targetRole;
  final Future<UserModel?> Function({
    required String name,
    required String email,
    required String password,
    String phone,
  }) onCreateEmployee;

  const CreateEmployeeDialog({
    super.key,
    required this.title,
    required this.targetRole,
    required this.onCreateEmployee,
  });

  @override
  State<CreateEmployeeDialog> createState() => _CreateEmployeeDialogState();
}

class _CreateEmployeeDialogState extends State<CreateEmployeeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  bool _showSuccess = false;
  String? _error;
  String _generatedEmail = '';
  String _generatedPassword = '';

  @override
  void initState() {
    super.initState();
    _passwordController.text = AuthService.generatePassword();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _createEmployee() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await widget.onCreateEmployee(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phone: _phoneController.text.trim(),
    );

    if (result != null) {
      setState(() {
        _isLoading = false;
        _showSuccess = true;
        _generatedEmail = _emailController.text.trim();
        _generatedPassword = _passwordController.text;
      });
    } else {
      setState(() {
        _isLoading = false;
        _error = 'Failed to create account. Email may already be in use.';
      });
    }
  }

  void _copyCredentials() {
    final text =
        'Email: $_generatedEmail\nPassword: $_generatedPassword';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Credentials copied to clipboard',
          style: GoogleFonts.inter(),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: _showSuccess ? _buildSuccessView(isDark) : _buildFormView(isDark),
        ),
      ),
    );
  }

  Widget _buildFormView(bool isDark) {
    final roleLabel = widget.targetRole == UserRole.admin
        ? 'Admin Employee'
        : 'Delivery Partner';

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person_add_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Create $roleLabel account',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, size: 20),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          _buildField(
            controller: _nameController,
            label: 'Full Name',
            hint: 'e.g. Rahul Sharma',
            icon: Icons.person_outline,
            validator: (v) =>
                v == null || v.isEmpty ? 'Name is required' : null,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildField(
            controller: _emailController,
            label: 'Email Address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Email is required';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          _buildField(
            controller: _phoneController,
            label: 'Phone (optional)',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: AppSpacing.md),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock_outline,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (v.length < 6) return 'Min 6 chars';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _passwordController.text =
                          AuthService.generatePassword();
                    });
                  },
                  tooltip: 'Generate new password',
                  icon: const Icon(Icons.autorenew_rounded, size: 22),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),

          if (_error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              _error!,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.red,
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.lg),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: _isLoading ? null : _createEmployee,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Create Account',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            color: AppColors.primary,
            size: 40,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Account Created!',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Share these credentials securely with the employee.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.lg),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey.shade200,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCredentialRow('Email', _generatedEmail, isDark),
              const SizedBox(height: AppSpacing.sm),
              _buildCredentialRow('Password', _generatedPassword, isDark),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _copyCredentials,
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: Text(
                  'Copy',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'Done',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCredentialRow(String label, String value, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: SelectableText(
            value,
            style: GoogleFonts.robotoMono(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.inter(fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.inter(fontSize: 14),
        prefixIcon: Icon(icon, size: 20),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
