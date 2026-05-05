import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_spacing.dart';
import '../../config/theme/app_text_styles.dart';
import '../../models/donation_model.dart';
import '../common/status_badge.dart';
import '../common/app_card.dart';

class DonationListTile extends StatelessWidget {
  final DonationModel donation;
  final VoidCallback? onTap;

  const DonationListTile({
    super.key,
    required this.donation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(
              _foodTypeIcon,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          AppSpacing.horizontalMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  donation.title,
                  style: AppTextStyles.label.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.verticalXs,
                Text(
                  '${donation.quantity} ${donation.unit} · ${donation.foodTypeLabel}',
                  style: AppTextStyles.caption,
                ),
                AppSpacing.verticalXs,
                Text(
                  DateFormat('MMM d, yyyy · h:mm a').format(donation.createdAt),
                  style: AppTextStyles.caption.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          AppSpacing.horizontalSm,
          StatusBadge(status: donation.status),
        ],
      ),
    );
  }

  IconData get _foodTypeIcon {
    switch (donation.foodType) {
      case FoodType.cookedMeal:
        return Icons.restaurant_rounded;
      case FoodType.rawGroceries:
        return Icons.shopping_basket_rounded;
      case FoodType.packedFood:
        return Icons.inventory_2_rounded;
      case FoodType.bakeryItems:
        return Icons.bakery_dining_rounded;
      case FoodType.beverages:
        return Icons.local_cafe_rounded;
      case FoodType.fruits:
        return Icons.apple_rounded;
      case FoodType.vegetables:
        return Icons.eco_rounded;
      case FoodType.other:
        return Icons.fastfood_rounded;
    }
  }
}
