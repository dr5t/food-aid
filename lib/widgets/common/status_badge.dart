import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_spacing.dart';
import '../../config/theme/app_text_styles.dart';
import '../../models/donation_model.dart';

class StatusBadge extends StatelessWidget {
  final DonationStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 4,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        _label,
        style: AppTextStyles.caption.copyWith(
          color: _textColor,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  String get _label {
    switch (status) {
      case DonationStatus.pending:
        return 'Pending';
      case DonationStatus.accepted:
        return 'Accepted';
      case DonationStatus.assigned:
        return 'Assigned';
      case DonationStatus.picked:
        return 'Picked Up';
      case DonationStatus.inTransit:
        return 'In Transit';
      case DonationStatus.nearLocation:
        return 'Near Location';
      case DonationStatus.delivered:
        return 'Delivered';
      case DonationStatus.rejected:
        return 'Rejected';
      case DonationStatus.expired:
        return 'Expired';
    }
  }

  Color get _textColor {
    switch (status) {
      case DonationStatus.pending:
        return AppColors.statusPending;
      case DonationStatus.accepted:
        return AppColors.statusAccepted;
      case DonationStatus.assigned:
        return AppColors.statusAssigned;
      case DonationStatus.picked:
        return AppColors.statusPicked;
      case DonationStatus.inTransit:
        return AppColors.statusInTransit;
      case DonationStatus.nearLocation:
        return AppColors.statusNearLocation;
      case DonationStatus.delivered:
        return AppColors.statusDelivered;
      case DonationStatus.rejected:
        return AppColors.statusRejected;
      case DonationStatus.expired:
        return AppColors.statusExpired;
    }
  }

  Color get _backgroundColor {
    switch (status) {
      case DonationStatus.pending:
        return AppColors.warningLight;
      case DonationStatus.accepted:
        return AppColors.infoLight;
      case DonationStatus.assigned:
        return const Color(0xFFEDE7F6);
      case DonationStatus.picked:
        return const Color(0xFFE0F7FA);
      case DonationStatus.inTransit:
        return const Color(0xFFE0F2F1);
      case DonationStatus.nearLocation:
        return const Color(0xFFF1F8E9);
      case DonationStatus.delivered:
        return AppColors.successLight;
      case DonationStatus.rejected:
        return AppColors.errorLight;
      case DonationStatus.expired:
        return const Color(0xFFF5F5F5);
    }
  }
}
