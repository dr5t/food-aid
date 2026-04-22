import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_spacing.dart';
import '../../config/theme/app_text_styles.dart';
import '../../models/donation_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/dashboard/status_tracker.dart';
import '../../widgets/skeleton/skeleton_loader.dart';
import '../../widgets/animations/fade_slide_transition.dart';
import 'package:intl/intl.dart';

class DonationTrackingScreen extends StatelessWidget {
  final String donationId;
  const DonationTrackingScreen({super.key, required this.donationId});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Donation Tracking')),
      body: StreamBuilder<DonationModel>(
        stream: service.getDonationStream(donationId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Padding(
              padding: AppSpacing.screenPadding,
              child: const SkeletonList(itemCount: 3),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Donation not found'));
          }
          final d = snapshot.data!;
          return SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: FadeSlideTransition(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: AppSpacing.cardPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d.title, style: AppTextStyles.subheading),
                          AppSpacing.verticalSm,
                          Text(d.description, style: AppTextStyles.bodySmall),
                          AppSpacing.verticalMd,
                          _infoRow(Icons.restaurant_rounded, d.foodTypeLabel),
                          AppSpacing.verticalSm,
                          _infoRow(Icons.inventory_2_outlined, '${d.quantity} ${d.unit}'),
                          AppSpacing.verticalSm,
                          _infoRow(Icons.location_on_outlined, d.pickupAddress),
                          AppSpacing.verticalSm,
                          _infoRow(Icons.calendar_today_outlined, DateFormat('MMM d, yyyy · h:mm a').format(d.createdAt)),
                          if (d.employeeName != null) ...[
                            AppSpacing.verticalSm,
                            _infoRow(Icons.person_outlined, 'Delivery: ${d.employeeName}'),
                          ],
                        ],
                      ),
                    ),
                  ),
                  AppSpacing.verticalMd,
                  StatusTracker(currentStatus: d.status),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        AppSpacing.horizontalSm,
        Expanded(child: Text(text, style: AppTextStyles.bodySmall)),
      ],
    );
  }
}
