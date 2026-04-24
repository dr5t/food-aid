import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_spacing.dart';
import '../../config/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_input.dart';
import '../../widgets/animations/fade_slide_transition.dart';
import '../../widgets/common/app_app_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _phoneCtrl = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final auth = context.read<AuthProvider>();
    await auth.updateProfile(name: _nameCtrl.text.trim(), phone: _phoneCtrl.text.trim());
    if (mounted) {
      setState(() => _editing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated'), backgroundColor: AppColors.success),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppAppBar(
        title: 'Profile',
        actions: [
          if (!_editing)
            TextButton(onPressed: () => setState(() => _editing = true), child: const Text('Edit')),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: FadeSlideTransition(
          child: Column(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(user?.initials ?? '?', style: AppTextStyles.heading.copyWith(color: AppColors.primary)),
              ),
              AppSpacing.verticalMd,
              Text(user?.email ?? '', style: AppTextStyles.bodySmall),
              AppSpacing.verticalXs,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text(
                  user?.role.name.toUpperCase() ?? '',
                  style: AppTextStyles.overline.copyWith(color: AppColors.primary),
                ),
              ),
              AppSpacing.verticalXl,
              AppInput(controller: _nameCtrl, label: 'Name', prefixIcon: Icons.person_outline, enabled: _editing),
              AppSpacing.verticalMd,
              AppInput(controller: _phoneCtrl, label: 'Phone', prefixIcon: Icons.phone_outlined, keyboardType: TextInputType.phone, enabled: _editing),
              if (_editing) ...[
                AppSpacing.verticalXl,
                AppButton(label: 'Save Changes', onPressed: _save, isLoading: auth.isLoading),
                AppSpacing.verticalSm,
                AppButton(label: 'Cancel', variant: AppButtonVariant.outlined, onPressed: () => setState(() => _editing = false)),
              ],
              AppSpacing.verticalXl,
              AppButton(
                label: 'Sign Out',
                variant: AppButtonVariant.outlined,
                icon: Icons.logout_rounded,
                onPressed: () => auth.signOut(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
