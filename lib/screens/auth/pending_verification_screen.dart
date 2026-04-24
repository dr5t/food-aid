import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_spacing.dart';
import '../../config/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_background.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/app_button.dart';

class PendingVerificationScreen extends StatelessWidget {
  const PendingVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRejected = user?.isRejected ?? false;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatusIcon(isRejected),
                  
                  AppSpacing.verticalXl,

                  AppCard(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildHeader(isRejected),
                          AppSpacing.verticalLg,
                          
                          _buildUserInfo(user, isRejected, isDark),
                          
                          AppSpacing.verticalXl,
                          
                          _buildActionButtons(authProvider, isDark, isRejected),
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
    );
  }

  Widget _buildStatusIcon(bool isRejected) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isRejected ? AppColors.error.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.1),
      ),
      child: Icon(
        isRejected ? Icons.error_outline_rounded : Icons.pending_actions_rounded,
        size: 50,
        color: isRejected ? AppColors.error : AppColors.primary,
      ),
    );
  }

  Widget _buildHeader(bool isRejected) {
    return Column(
      children: [
        Text(
          isRejected ? 'Account Rejected' : 'Verification Pending',
          textAlign: TextAlign.center,
          style: AppTextStyles.titleLarge,
        ),
        AppSpacing.verticalSm,
        Text(
          isRejected 
              ? 'Your application could not be approved at this time.'
              : 'Our administrators are currently reviewing your account application.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }

  Widget _buildUserInfo(dynamic user, bool isRejected, bool isDark) {
    return Column(
      children: [
        const Divider(),
        AppSpacing.verticalMd,
        _infoRow('Name', user?.name ?? 'Unknown'),
        _infoRow('Role', user?.roleLabel ?? 'Unassigned'),
        AppSpacing.verticalMd,
        const Divider(),
        if (isRejected && user?.rejectionReason != null) ...[
          AppSpacing.verticalLg,
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reason for rejection:',
                  style: AppTextStyles.label.copyWith(color: AppColors.error),
                ),
                AppSpacing.verticalXs,
                Text(
                  user!.rejectionReason!,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          Text(value, style: AppTextStyles.titleSmall),
        ],
      ),
    );
  }

  Widget _buildActionButtons(AuthProvider auth, bool isDark, bool isRejected) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => auth.signOut(),
        child: const Text('Sign Out'),
      ),
    );
  }
}
