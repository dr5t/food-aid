import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_spacing.dart';
import '../../config/theme/app_text_styles.dart';
import '../../models/donation_model.dart';

class StatusTracker extends StatelessWidget {
  final DonationStatus currentStatus;

  const StatusTracker({super.key, required this.currentStatus});

  static const _steps = [
    DonationStatus.pending,
    DonationStatus.accepted,
    DonationStatus.assigned,
    DonationStatus.picked,
    DonationStatus.inTransit,
    DonationStatus.nearLocation,
    DonationStatus.delivered,
  ];

  @override
  Widget build(BuildContext context) {
    if (currentStatus == DonationStatus.rejected) {
      return _buildTerminal(
        icon: Icons.close,
        color: AppColors.error,
        bgColor: AppColors.errorLight,
        title: 'Donation Rejected',
        subtitle: 'This donation was not approved.',
      );
    }
    if (currentStatus == DonationStatus.expired) {
      return _buildTerminal(
        icon: Icons.timer_off,
        color: AppColors.statusExpired,
        bgColor: const Color(0xFFF5F5F5),
        title: 'Donation Expired',
        subtitle: 'This donation has passed its expiry time.',
      );
    }

    final currentIndex = _steps.indexOf(currentStatus).clamp(0, _steps.length - 1);

    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Donation Progress', style: AppTextStyles.label),
            AppSpacing.verticalMd,
            ...List.generate(_steps.length, (index) {
              final isCompleted = index <= currentIndex;
              final isActive = index == currentIndex;
              final isLast = index == _steps.length - 1;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted
                              ? AppColors.primary
                              : AppColors.surfaceVariant,
                          border: isActive
                              ? Border.all(
                                  color: AppColors.primary,
                                  width: 2,
                                )
                              : null,
                        ),
                        child: isCompleted
                            ? const Icon(Icons.check,
                                size: 16, color: Colors.white)
                            : Center(
                                child: Text(
                                  '${index + 1}',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 32,
                          color: isCompleted && index < currentIndex
                              ? AppColors.primary
                              : AppColors.divider,
                        ),
                    ],
                  ),
                  AppSpacing.horizontalMd,
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _stepLabel(index),
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight:
                                  isActive ? FontWeight.w600 : FontWeight.w400,
                              color: isCompleted
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                            ),
                          ),
                          if (!isLast) AppSpacing.verticalMd,
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTerminal({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required String title,
    required String subtitle,
  }) {
    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            AppSpacing.horizontalMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.label.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AppSpacing.verticalXs,
                  Text(subtitle, style: AppTextStyles.caption),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _stepLabel(int index) {
    switch (index) {
      case 0:
        return 'Request Submitted';
      case 1:
        return 'NGO Accepted';
      case 2:
        return 'Driver Assigned';
      case 3:
        return 'Food Picked Up';
      case 4:
        return 'In Transit';
      case 5:
        return 'Near Location';
      case 6:
        return 'Delivered';
      default:
        return '';
    }
  }
}
