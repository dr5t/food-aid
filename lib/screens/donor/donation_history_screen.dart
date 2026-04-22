import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_spacing.dart';

import '../../providers/donation_provider.dart';
import '../../widgets/dashboard/donation_list_tile.dart';
import '../../widgets/common/empty_state.dart';

class DonationHistoryScreen extends StatelessWidget {
  const DonationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dp = context.watch<DonationProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Donation History')),
      body: dp.donations.isEmpty
          ? const EmptyState(icon: Icons.history, title: 'No donations yet', subtitle: 'Your donation history will appear here')
          : ListView.separated(
              padding: AppSpacing.screenPadding,
              itemCount: dp.donations.length,
              separatorBuilder: (_, _) => AppSpacing.verticalSm,
              itemBuilder: (context, i) {
                final d = dp.donations[i];
                return DonationListTile(
                  donation: d,
                  onTap: () => context.push('/donor/tracking/${d.id}'),
                );
              },
            ),
    );
  }
}
