import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_spacing.dart';
import '../../models/donation_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/donation_provider.dart';
import '../../providers/emergency_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/common/connection_status_indicator.dart';
import '../../widgets/common/skeleton_widgets.dart';

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
      appBar: AppBar(
        title: Text(
          'Food Aid',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        actions: [
          const ConnectionStatusIndicator(),
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, size: 22),
            onPressed: () => context.read<ThemeProvider>().toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 22),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout, size: 22),
            onPressed: () => context.read<AuthProvider>().signOut(),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _OverviewTab(),
          _MyDonationsTab(),
          _EmergencyAlertsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
        },
        icon: const Icon(Icons.add),
        label: const Text('Donate Food'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism_outlined),
            activeIcon: Icon(Icons.volunteer_activism),
            label: 'My Donations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning_amber),
            activeIcon: Icon(Icons.warning),
            label: 'Emergencies',
          ),
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
    final donations = context.watch<DonationProvider>().donations;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final active = donations.where((d) => d.isActive).length;
    final delivered =
        donations.where((d) => d.status == DonationStatus.delivered).length;
    final pending =
        donations.where((d) => d.status == DonationStatus.pending).length;

    final provider = context.watch<DonationProvider>();
    final isFetching = provider.isFetching;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(
          'Hello, ${user?.name.split(' ').first ?? 'Donor'} 👋',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2),
        const SizedBox(height: 4),
        Text(
          'Your contributions make a difference',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideX(begin: -0.1),
        const SizedBox(height: AppSpacing.xl),

        if (isFetching)
          Column(
            children: [
              Row(
                children: const [
                  Expanded(child: SkeletonCard()),
                  SizedBox(width: AppSpacing.md),
                  Expanded(child: SkeletonCard()),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: const [
                  Expanded(child: SkeletonCard()),
                  SizedBox(width: AppSpacing.md),
                  Expanded(child: SkeletonCard()),
                ],
              ),
            ],
          ).animate().fadeIn()
        else
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Total',
                      value: '${donations.length}',
                      icon: Icons.inventory_2_outlined,
                      color: AppColors.neonCyan,
                      gradient: AppColors.neonCyanGradient,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _StatCard(
                      label: 'Active',
                      value: '$active',
                      icon: Icons.local_shipping_outlined,
                      color: AppColors.neonPurple,
                      gradient: AppColors.neonPurpleGradient,
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Delivered',
                      value: '$delivered',
                      icon: Icons.check_circle_outline,
                      color: AppColors.neonGreen,
                      gradient: AppColors.neonGreenGradient,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _StatCard(
                      label: 'Pending',
                      value: '$pending',
                      icon: Icons.pending_outlined,
                      color: AppColors.neonAmber,
                      gradient: AppColors.neonAmberGradient,
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
            ],
          ),

        const SizedBox(height: AppSpacing.xl),

        Text(
          'Recent Donations',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ).animate().fadeIn(delay: 400.ms),
        const SizedBox(height: AppSpacing.md),

        if (isFetching)
          Column(
            children: List.generate(3, (index) => const SkeletonTile()),
          ).animate().fadeIn()
        else if (donations.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                children: [
                  Icon(
                    Icons.volunteer_activism_outlined,
                    size: 56,
                    color: isDark
                        ? AppColors.darkTextHint
                        : AppColors.textHint,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No donations yet',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Tap the + button to donate food',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.darkTextHint
                          : AppColors.textHint,
                    ),
                  ),
                ],
              ).animate().fadeIn().scale(),
            ),
          )
        else
          ...donations.take(5).map((d) => _DonationTile(donation: d)
              .animate()
              .fadeIn(delay: 500.ms)
              .slideX(begin: 0.1)),
      ],
    );
  }
}


class _MyDonationsTab extends StatelessWidget {
  const _MyDonationsTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DonationProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: TextField(
            onChanged: provider.setSearchQuery,
            decoration: InputDecoration(
              hintText: 'Search donations...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: provider.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () => provider.setSearchQuery(''),
                    )
                  : null,
            ),
          ),
        ),

        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            children: [
              _FilterChip(
                label: 'All',
                isSelected: provider.statusFilter == null,
                onTap: () => provider.setStatusFilter(null),
              ),
              ...DonationStatus.values
                  .where((s) => s != DonationStatus.expired)
                  .map((s) => _FilterChip(
                        label: s.name[0].toUpperCase() +
                            s.name.substring(1),
                        isSelected: provider.statusFilter == s,
                        onTap: () => provider.setStatusFilter(s),
                      )),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        Expanded(
          child: provider.isFetching
              ? ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  itemCount: 5,
                  itemBuilder: (_, __) => const SkeletonTile(),
                )
              : provider.filteredDonations.isEmpty
                  ? Center(
                      child: Text(
                        'No donations found',
                        style: GoogleFonts.inter(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ).animate().fadeIn(),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md),
                      itemCount: provider.filteredDonations.length,
                      itemBuilder: (_, i) => _DonationTile(
                        donation: provider.filteredDonations[i],
                      ).animate().fadeIn(delay: (i * 50).ms).slideX(begin: 0.1),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 56,
              color: AppColors.success.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No active emergencies',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Emergency requests from nearby NGOs will appear here',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: isDark
                    ? AppColors.darkTextHint
                    : AppColors.textHint,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: requests.length,
      itemBuilder: (_, i) {
        final req = requests[i];
        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.emergency.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: const Icon(Icons.warning,
                          color: AppColors.emergency, size: 20),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🚨 Emergency Request',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.emergency,
                            ),
                          ),
                          Text(
                            req.ngoName,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    _InfoChip(
                        Icons.restaurant, req.mealTypeLabel),
                    const SizedBox(width: AppSpacing.sm),
                    _InfoChip(Icons.people,
                        '${req.quantity} meals needed'),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                _InfoChip(Icons.location_on, req.ngoAddress),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final user =
                          context.read<AuthProvider>().user;
                      if (user != null) {
                        await context
                            .read<EmergencyProvider>()
                            .donorAcceptRequest(
                              req.id,
                              user.uid,
                              user.name,
                            );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emergency,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Accept & Donate'),
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


class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final LinearGradient? gradient;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: isDark ? gradient?.withOpacity(0.05) : null,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Card(
        color: isDark ? Colors.transparent : null,
        elevation: isDark ? 0 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          side: isDark
              ? BorderSide(color: color.withOpacity(0.2), width: 1)
              : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Icon(icon, size: 18, color: color),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: isDark ? color : null,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension on LinearGradient {
  LinearGradient withOpacity(double opacity) {
    return LinearGradient(
      colors: colors.map((c) => c.withOpacity(opacity)).toList(),
      begin: begin,
      end: end,
      stops: stops,
      transform: transform,
    );
  }
}

class _DonationTile extends StatelessWidget {
  final DonationModel donation;

  const _DonationTile({required this.donation});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: _statusColor(donation.status).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Icon(
            _statusIcon(donation.status),
            color: _statusColor(donation.status),
            size: 20,
          ),
        ),
        title: Text(
          donation.title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${donation.foodTypeLabel} · ${donation.quantityDisplay}',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: _statusColor(donation.status).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          child: Text(
            donation.statusLabel,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _statusColor(donation.status),
            ),
          ),
        ),
      ),
    );
  }

  Color _statusColor(DonationStatus s) {
    switch (s) {
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

  IconData _statusIcon(DonationStatus s) {
    switch (s) {
      case DonationStatus.pending:
        return Icons.pending;
      case DonationStatus.accepted:
        return Icons.thumb_up_outlined;
      case DonationStatus.assigned:
        return Icons.assignment_ind;
      case DonationStatus.picked:
        return Icons.inventory;
      case DonationStatus.inTransit:
        return Icons.local_shipping;
      case DonationStatus.nearLocation:
        return Icons.near_me;
      case DonationStatus.delivered:
        return Icons.check_circle;
      case DonationStatus.rejected:
        return Icons.cancel;
      case DonationStatus.expired:
        return Icons.timer_off;
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Chip(
          label: Text(label),
          backgroundColor: isSelected
              ? primary.withValues(alpha: 0.12)
              : null,
          labelStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? primary : null,
          ),
          side: BorderSide(
            color: isSelected ? primary : Colors.transparent,
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
