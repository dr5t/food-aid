import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_spacing.dart';
import '../../config/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/cyber_background.dart';
import '../../widgets/common/cyber_card.dart';
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
      backgroundColor: isDark ? const Color(0xFF050505) : Colors.white,
      body: CyberBackground(
        children: [
          // Ambient Glow
          Positioned(
            top: -100,
            left: -100,
            child: _buildGlow(isRejected ? AppColors.error : AppColors.neonCyan, 400),
          ).animate(onPlay: (c) => c.repeat()).move(
                begin: const Offset(-20, -20),
                end: const Offset(20, 20),
                duration: 6.seconds,
                curve: Curves.easeInOut,
              ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: AppSpacing.screenPadding,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Column(
                    children: [
                      // Status Icon with Glitchy Animation
                      _buildStatusIcon(isRejected).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                      
                      AppSpacing.verticalXl,

                      CyberCard(
                        borderRadius: 24,
                        showGlow: true,
                        borderColor: isRejected ? AppColors.error.withValues(alpha: 0.5) : AppColors.neonCyan.withValues(alpha: 0.3),
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(isRejected),
                            AppSpacing.verticalLg,
                            
                            _buildTerminalInfo(user, isRejected, isDark),
                            
                            AppSpacing.verticalXl,
                            
                            _buildActionButtons(authProvider, isDark, isRejected),
                          ],
                        ),
                      ).animate().fadeIn(duration: 800.ms).moveY(begin: 30, end: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(bool isRejected) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black,
        border: Border.all(
          color: isRejected ? AppColors.error : AppColors.neonCyan,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isRejected ? AppColors.error : AppColors.neonCyan).withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        isRejected ? Icons.gpp_bad_rounded : Icons.radar_rounded,
        size: 50,
        color: isRejected ? AppColors.error : AppColors.neonCyan,
      ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds, color: Colors.white24),
    );
  }

  Widget _buildHeader(bool isRejected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DIAGNOSTIC: VERIFICATION',
          style: AppTextStyles.hitech.copyWith(
            fontSize: 10,
            letterSpacing: 2,
            color: isRejected ? AppColors.error : AppColors.neonCyan,
            fontWeight: FontWeight.bold,
          ),
        ),
        AppSpacing.verticalXs,
        Text(
          isRejected ? 'ACCESS DENIED' : 'IDENTITY PENDING',
          style: AppTextStyles.hitech.copyWith(
            fontSize: 24,
            letterSpacing: 1,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildTerminalInfo(dynamic user, bool isRejected, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _terminalRow('ENTITY', user?.name?.toUpperCase() ?? 'UNKNOWN'),
        _terminalRow('ROLE', user?.roleLabel?.toUpperCase() ?? 'UNASSIGNED'),
        _terminalRow('NODE', 'DEHRADUN_CENTRAL'),
        const Divider(color: Colors.white10, height: 32),
        Text(
          isRejected
              ? 'PROTOCOL TERMINATED: MANUAL REVIEW REQUIRED'
              : 'ENCRYPTION ACTIVE: AWAITING CLEARANCE FROM SYSTEM ADMINS',
          style: AppTextStyles.hitech.copyWith(
            fontSize: 11,
            color: isRejected ? AppColors.error.withValues(alpha: 0.8) : AppColors.neonCyan.withValues(alpha: 0.7),
            height: 1.6,
          ),
        ),
        if (isRejected && user?.rejectionReason != null) ...[
          AppSpacing.verticalMd,
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
            ),
            child: Text(
              'REASON: ${user!.rejectionReason!.toUpperCase()}',
              style: AppTextStyles.hitech.copyWith(
                fontSize: 10,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _terminalRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: AppTextStyles.hitech.copyWith(fontSize: 10, color: Colors.white38),
          ),
          Text(
            value,
            style: AppTextStyles.hitech.copyWith(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(AuthProvider auth, bool isDark, bool isRejected) {
    return Column(
      children: [
        AppSpacing.verticalMd,
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: () => auth.signOut(),
            icon: const Icon(Icons.power_settings_new_rounded, size: 18, color: Colors.white38),
            label: Text(
              'TERMINATE SESSION',
              style: AppTextStyles.hitech.copyWith(
                color: Colors.white38,
                fontSize: 10,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ],
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
            color: color.withValues(alpha: 0.1),
            blurRadius: 100,
            spreadRadius: 40,
          ),
        ],
      ),
    );
  }
}
