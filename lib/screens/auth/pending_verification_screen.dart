import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_spacing.dart';
import '../../providers/auth_provider.dart';
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
    final isEmailVerified = authProvider.isEmailVerified;

    const emeraldGreen = Color(0xFF10B981);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatusIcon(isRejected, isEmailVerified, emeraldGreen),

                  AppSpacing.verticalXl,

                  AppCard(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildHeader(isRejected, isEmailVerified, emeraldGreen),
                          AppSpacing.verticalLg,

                          _buildUserInfo(user, isRejected, isDark),

                          AppSpacing.verticalXl,

                          _buildActionButtons(authProvider, isEmailVerified, emeraldGreen),
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

  Widget _buildStatusIcon(bool isRejected, bool isEmailVerified, Color emeraldGreen) {
    IconData icon;
    Color color;

    if (!isEmailVerified) {
      icon = Icons.mark_email_unread_rounded;
      color = emeraldGreen;
    } else if (isRejected) {
      icon = Icons.error_outline_rounded;
      color = AppColors.error;
    } else {
      icon = Icons.pending_actions_rounded;
      color = emeraldGreen;
    }

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.1),
      ),
      child: Icon(
        icon,
        size: 50,
        color: color,
      ),
    );
  }

  Widget _buildHeader(bool isRejected, bool isEmailVerified, Color emeraldGreen) {
    String title;
    String subtitle;

    if (!isEmailVerified) {
      title = 'Verify Your Email';
      subtitle = 'We\'ve sent a verification link to your email address. Please check your inbox and click the link to continue.';
    } else if (isRejected) {
      title = 'Account Rejected';
      subtitle = 'Your application could not be approved at this time.';
    } else {
      title = 'Verification Pending';
      subtitle = 'Our administrators are currently reviewing your account application. You\'ll be notified once approved.';
    }

    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
        AppSpacing.verticalSm,
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF64748B),
            height: 1.5,
          ),
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
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B))),
          Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B))),
        ],
      ),
    );
  }

  Widget _buildActionButtons(AuthProvider auth, bool isEmailVerified, Color emeraldGreen) {
    return Column(
      children: [
        if (!isEmailVerified) ...[
          AppButton(
            label: 'I have verified my email',
            onPressed: () => auth.reloadUser(),
            backgroundColor: emeraldGreen,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () async {
                await auth.resendVerificationEmail();
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: emeraldGreen.withOpacity(0.5)),
                foregroundColor: emeraldGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('Resend Verification Email', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
          ),
          AppSpacing.verticalMd,
        ],
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => auth.signOut(),
            child: Text(
              'Sign Out',
              style: GoogleFonts.inter(color: Colors.redAccent, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
