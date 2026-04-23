import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_spacing.dart';
import '../../models/donation_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/donation_provider.dart';
import '../../providers/emergency_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/common/cyber_app_bar.dart';
import '../../widgets/common/cyber_bottom_nav_bar.dart';
import '../../widgets/common/cyber_card.dart';
import '../../widgets/common/cyber_background.dart';
import '../../widgets/common/connection_status_indicator.dart';
import '../../widgets/common/skeleton_widgets.dart';
import '../../widgets/common/hitech_loader.dart';
import '../../widgets/common/scanning_overlay.dart';

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
      extendBodyBehindAppBar: true,
      appBar: CyberAppBar(
        title: 'FOOD AID',
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
      body: CyberBackground(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + kToolbarHeight),
              child: IndexedStack(
                index: _currentIndex,
                children: const [
                  _OverviewTab(),
                  _MyDonationsTab(),
                  _EmergencyAlertsTab(),
                ],
              ),
            ).animate(target: _currentIndex.toDouble()).fadeIn(duration: 400.ms),
            if (context.watch<DonationProvider>().isFetching)
              const ScanningOverlay(label: 'SYNCING TELEMETRY...'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add, color: Colors.black),
        label: Text('DONATE', style: GoogleFonts.orbitron(fontWeight: FontWeight.w700, color: Colors.black)),
        backgroundColor: AppColors.neonCyan,
      ).animate().scale(delay: 400.ms, duration: 400.ms, curve: Curves.easeOutBack),
      bottomNavigationBar: CyberBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          CyberBottomNavItem(
            icon: Icons.grid_view_outlined,
            label: 'STATUS',
          ),
          CyberBottomNavItem(
            icon: Icons.history_outlined,
            label: 'HISTORY',
          ),
          CyberBottomNavItem(
            icon: Icons.bolt_outlined,
            label: 'ALERTS',
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
    final stats = context.watch<DonationProvider>().donorStats;
    final active = stats['active'] ?? 0;
    final delivered = stats['completed'] ?? 0;
    final total = stats['total'] ?? 0;
    final provider = context.watch<DonationProvider>();
    final isFetching = provider.isFetching;
    final donations = provider.donations;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HELLO, ${user?.name.toUpperCase().split(' ').first ?? 'DONOR'}',
                  style: GoogleFonts.orbitron(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.neonCyan : null,
                  ),
                ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2),
                Text(
                  'DEHRADUN OPERATIONAL NODE',
                  style: GoogleFonts.orbitron(
                    fontSize: 10,
                    color: isDark ? AppColors.neonCyan.withValues(alpha: 0.5) : Colors.black54,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600,
                  ),
                ).animate().fadeIn(delay: 100.ms),
              ],
            ),
            if (isFetching) 
              const HitechLoader(size: 24)
            else
              const Icon(Icons.verified_user_outlined, color: AppColors.success, size: 24)
                  .animate().scale(duration: 400.ms),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),

        if (isFetching && donations.isEmpty)
          const SkeletonStats().animate().fadeIn()
        else
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.5,
            children: [
              _StatCard(
                label: 'TOTAL UNITS',
                value: '$total',
                icon: Icons.inventory_2_outlined,
                color: AppColors.neonCyan,
                gradient: AppColors.neonCyanGradient,
              ),
              _StatCard(
                label: 'ACTIVE LINKS',
                value: '$active',
                icon: Icons.sensors_rounded,
                color: AppColors.neonPurple,
                gradient: AppColors.neonPurpleGradient,
              ),
              _StatCard(
                label: 'DELIVERED',
                value: '$delivered',
                icon: Icons.check_circle_outline,
                color: AppColors.neonGreen,
                gradient: AppColors.neonGreenGradient,
              ),
              _StatCard(
                label: 'STATION: DDN',
                value: 'ONLINE',
                icon: Icons.radar_rounded,
                color: AppColors.neonAmber,
                gradient: AppColors.neonAmberGradient,
              ),
            ],
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

        const SizedBox(height: AppSpacing.xl),

        Row(
          children: [
            Text(
              'RECENT TELEMETRY',
              style: GoogleFonts.orbitron(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            const Spacer(),
            Container(
              width: 40,
              height: 2,
              decoration: BoxDecoration(
                gradient: AppColors.neonGradient,
              ),
            ),
          ],
        ).animate().fadeIn(delay: 400.ms),
        const SizedBox(height: AppSpacing.md),

        if (isFetching && donations.isEmpty)
          const SkeletonList(itemCount: 3).animate().fadeIn()
        else if (donations.isEmpty)
          _EmptyHitechState(isDark: isDark)
        else
          ...donations.take(5).map((d) => _DonationTile(donation: d)
              .animate()
              .fadeIn(delay: 500.ms)
              .slideX(begin: 0.1)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final LinearGradient gradient;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CyberCard(
      borderColor: color.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: color),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.orbitron(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? color : null,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.orbitron(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white38 : Colors.black38,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _DonationTile extends StatelessWidget {
  final DonationModel donation;

  const _DonationTile({required this.donation});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _statusColor(donation.status);

    return CyberCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      borderColor: statusColor.withValues(alpha: 0.2),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 0),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _statusIcon(donation.status),
            color: statusColor,
            size: 20,
          ),
        ),
        title: Text(
          donation.title.toUpperCase(),
          style: GoogleFonts.orbitron(
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          '${donation.foodTypeLabel} · ${donation.quantityDisplay}'.toUpperCase(),
          style: GoogleFonts.orbitron(
            fontSize: 9,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                donation.statusLabel.toUpperCase(),
                style: GoogleFonts.orbitron(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(DonationStatus s) {
    switch (s) {
      case DonationStatus.pending: return AppColors.neonAmber;
      case DonationStatus.accepted: return AppColors.neonBlue;
      case DonationStatus.assigned: return AppColors.neonPurple;
      case DonationStatus.picked: return AppColors.neonCyan;
      case DonationStatus.inTransit: return AppColors.neonCyan;
      case DonationStatus.nearLocation: return AppColors.neonGreen;
      case DonationStatus.delivered: return AppColors.success;
      case DonationStatus.rejected: return AppColors.error;
      case DonationStatus.expired: return AppColors.disabled;
    }
  }

  IconData _statusIcon(DonationStatus s) {
    switch (s) {
      case DonationStatus.pending: return Icons.radar_rounded;
      case DonationStatus.accepted: return Icons.handshake_outlined;
      case DonationStatus.assigned: return Icons.assignment_ind_outlined;
      case DonationStatus.picked: return Icons.inventory_2_outlined;
      case DonationStatus.inTransit: return Icons.local_shipping_outlined;
      case DonationStatus.nearLocation: return Icons.location_on_outlined;
      case DonationStatus.delivered: return Icons.verified_outlined;
      case DonationStatus.rejected: return Icons.block_flipped;
      case DonationStatus.expired: return Icons.timer_off_outlined;
    }
  }
}

class _EmptyHitechState extends StatelessWidget {
  final bool isDark;
  const _EmptyHitechState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          children: [
            Icon(
              Icons.sensors_off_rounded,
              size: 48,
              color: isDark ? Colors.white10 : Colors.black12,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'NO DATA STREAMS FOUND',
              style: GoogleFonts.orbitron(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white24 : Colors.black24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'INITIATE DONATION PROTOCOL TO START',
              style: GoogleFonts.orbitron(
                fontSize: 8,
                color: isDark ? Colors.white10 : Colors.black12,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn();
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
            style: GoogleFonts.orbitron(fontSize: 12),
            decoration: InputDecoration(
              hintText: 'SEARCH DATABASES...',
              hintStyle: GoogleFonts.orbitron(fontSize: 10, color: isDark ? Colors.white24 : Colors.black24),
              prefixIcon: Icon(Icons.search_rounded, size: 18, color: isDark ? AppColors.neonCyan : null),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
        Expanded(
          child: provider.isFetching && provider.filteredDonations.isEmpty
              ? ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  itemCount: 5,
                  itemBuilder: (_, _) => const SkeletonTile(),
                )
              : provider.filteredDonations.isEmpty
                  ? Center(child: Text('NO RESULTS', style: GoogleFonts.orbitron(fontSize: 12, color: Colors.white24)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
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
            Icon(Icons.security_rounded, size: 48, color: AppColors.success.withValues(alpha: 0.2)),
            const SizedBox(height: AppSpacing.md),
            Text(
              'PERIMETER SECURE',
              style: GoogleFonts.orbitron(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.success.withValues(alpha: 0.5),
              ),
            ),
            Text(
              'No active emergency pings in Dehradun sector',
              style: GoogleFonts.orbitron(fontSize: 8, color: isDark ? Colors.white24 : Colors.black24),
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
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.emergency.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            gradient: LinearGradient(
              colors: [AppColors.emergency.withValues(alpha: 0.1), Colors.transparent],
              begin: Alignment.topLeft,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.emergency, size: 20)
                        .animate(onPlay: (c) => c.repeat())
                        .shimmer(duration: 1.seconds),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'EMERGENCY LINK: ${req.ngoName.toUpperCase()}',
                      style: GoogleFonts.orbitron(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.emergency,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _EmergencyDetail(Icons.restaurant_rounded, req.mealTypeLabel.toUpperCase()),
                _EmergencyDetail(Icons.people_rounded, '${req.quantity} MEALS REQUIRED'),
                _EmergencyDetail(Icons.location_on_rounded, req.ngoAddress.toUpperCase()),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emergency,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('RESPOND NOW', style: GoogleFonts.orbitron(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ),
        ).animate().shake(delay: (i * 100).ms);
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
          Icon(icon, size: 14, color: Colors.white38),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.orbitron(fontSize: 9, color: Colors.white70, letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
