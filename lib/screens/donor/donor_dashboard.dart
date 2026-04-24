import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_spacing.dart';
import '../../config/theme/app_text_styles.dart';
import '../../models/donation_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/donation_provider.dart';
import '../../providers/emergency_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/common/app_bottom_nav_bar.dart';
import '../../widgets/common/app_app_bar.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/app_background.dart';
import '../../widgets/common/connection_status_indicator.dart';
import '../../widgets/common/app_loader.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/status_badge.dart';

class DonorDashboard extends StatefulWidget {
  const DonorDashboard({super.key});

  @override
  State<DonorDashboard> createState() => _DonorDashboardState();
}

class _DonorDashboardState extends State<DonorDashboard> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      context.read<DonationProvider>().listenDonorDonations(user.uid);
      context.read<EmergencyProvider>().listenOpenRequests();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppAppBar(
        title: 'Food Aid',
        actions: [
          const ConnectionStatusIndicator(),
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, size: 20),
            onPressed: () => context.read<ThemeProvider>().toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.logout, size: 20),
            onPressed: () => context.read<AuthProvider>().signOut(),
          ),
        ],
      ),
      body: AppBackground(
        child: Stack(
          children: [
            IndexedStack(
              index: _currentIndex,
              children: const [
                _OverviewTab(),
                _MyDonationsTab(),
                _EmergencyAlertsTab(),
              ],
            ),
            if (context.watch<DonationProvider>().isFetching)
              const Center(child: AppLoader()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Donate'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          AppBottomNavItem(icon: Icons.grid_view_rounded, label: 'Overview'),
          AppBottomNavItem(icon: Icons.history_rounded, label: 'Completed'),
          AppBottomNavItem(icon: Icons.warning_amber_rounded, label: 'Alerts'),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final stats = context.watch<DonationProvider>().donorStats;
    final active = stats['active'] ?? 0;
    final delivered = stats['completed'] ?? 0;
    final total = stats['total'] ?? 0;
    final provider = context.watch<DonationProvider>();
    final isFetching = provider.isFetching;
    final donations = provider.donations;
    // final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // Welcome banner (simplified for Donor)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white24,
                child: Icon(Icons.favorite_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hello, ${user?.name.split(' ').first ?? 'Donor'}',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      'Your contributions are saving lives.',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Quick Stats
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.4,
          children: [
            _StatCard(
              label: 'Total Donations',
              value: '$total',
              icon: Icons.inventory_2_rounded,
              color: AppColors.primary,
            ),
            _StatCard(
              label: 'Active Donations',
              value: '$active',
              icon: Icons.local_shipping_rounded,
              color: Colors.blue,
            ),
            _StatCard(
              label: 'Completed',
              value: '$delivered',
              icon: Icons.check_circle_rounded,
              color: AppColors.success,
            ),
            _StatCard(
              label: 'Impact Score',
              value: 'A+',
              icon: Icons.star_rounded,
              color: Colors.orange,
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.xl),

        Text('Recent Activity', style: AppTextStyles.titleMedium),
        const SizedBox(height: AppSpacing.md),

        if (donations.isEmpty && !isFetching)
          const EmptyState(
            icon: Icons.history_rounded,
            title: 'No activity yet',
            message: 'Your recent donations will appear here.',
          )
        else
          ...donations.take(5).map((d) => _DonationTile(donation: d)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 24, color: color),
            const Spacer(),
            Text(
              value,
              style: AppTextStyles.headingMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white60
                    : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DonationTile extends StatelessWidget {
  final DonationModel donation;

  const _DonationTile({required this.donation});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _statusIcon(donation.status),
            color: AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(donation.title, style: AppTextStyles.titleSmall),
        subtitle: Text(
          '${donation.foodTypeLabel} · ${donation.quantityDisplay}',
          style: AppTextStyles.bodySmall,
        ),
        trailing: StatusBadge(
          status: donation.statusLabel,
          type: _statusType(donation.status),
        ),
      ),
    );
  }

  StatusBadgeType _statusType(DonationStatus s) {
    switch (s) {
      case DonationStatus.pending:
        return StatusBadgeType.warning;
      case DonationStatus.accepted:
        return StatusBadgeType.info;
      case DonationStatus.assigned:
        return StatusBadgeType.info;
      case DonationStatus.picked:
        return StatusBadgeType.info;
      case DonationStatus.inTransit:
        return StatusBadgeType.info;
      case DonationStatus.nearLocation:
        return StatusBadgeType.info;
      case DonationStatus.delivered:
        return StatusBadgeType.success;
      case DonationStatus.rejected:
        return StatusBadgeType.error;
      case DonationStatus.expired:
        return StatusBadgeType.neutral;
    }
  }

  IconData _statusIcon(DonationStatus s) {
    switch (s) {
      case DonationStatus.pending:
        return Icons.access_time_rounded;
      case DonationStatus.accepted:
        return Icons.handshake_rounded;
      case DonationStatus.assigned:
        return Icons.person_rounded;
      case DonationStatus.picked:
        return Icons.inventory_2_rounded;
      case DonationStatus.inTransit:
        return Icons.local_shipping_rounded;
      case DonationStatus.nearLocation:
        return Icons.location_on_rounded;
      case DonationStatus.delivered:
        return Icons.check_circle_rounded;
      case DonationStatus.rejected:
        return Icons.block_rounded;
      case DonationStatus.expired:
        return Icons.timer_off_rounded;
    }
  }
}

class _MyDonationsTab extends StatelessWidget {
  const _MyDonationsTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DonationProvider>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: TextField(
            onChanged: provider.setSearchQuery,
            decoration: InputDecoration(
              hintText: 'Search donations...',
              prefixIcon: const Icon(Icons.search_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
        Expanded(
          child: provider.filteredDonations.isEmpty && !provider.isFetching
              ? const EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'No results found',
                  message: 'Try adjusting your search query.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  itemCount: provider.filteredDonations.length,
                  itemBuilder: (_, i) =>
                      _DonationTile(donation: provider.filteredDonations[i]),
                ),
        ),
      ],
    );
  }
}

class _EmergencyAlertsTab extends StatelessWidget {
  const _EmergencyAlertsTab();

  @override
  Widget build(BuildContext context) {
    final emergencyProvider = context.watch<EmergencyProvider>();
    final requests = emergencyProvider.openRequests;

    if (requests.isEmpty) {
      return const EmptyState(
        icon: Icons.security_rounded,
        title: 'All Secure',
        message: 'No active emergency requests in your area.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: requests.length,
      itemBuilder: (_, i) {
        final req = requests[i];
        return AppCard(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Emergency: ${req.ngoName}',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _EmergencyDetail(Icons.restaurant_rounded, req.mealTypeLabel),
                _EmergencyDetail(
                  Icons.people_rounded,
                  '${req.quantity} meals required',
                ),
                _EmergencyDetail(Icons.location_on_rounded, req.ngoAddress),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Respond Now'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmergencyDetail extends StatelessWidget {
  final IconData icon;
  final String text;
  const _EmergencyDetail(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: AppTextStyles.bodySmall)),
        ],
      ),
    );
  }
}
