import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_spacing.dart';
import '../../models/donation_model.dart';
import '../../models/emergency_request_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/donation_provider.dart';
import '../../providers/emergency_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/common/connection_status_indicator.dart';
import '../../widgets/common/skeleton_widgets.dart';
import '../../widgets/common/cyber_app_bar.dart';
import '../../widgets/common/cyber_bottom_nav_bar.dart';
import '../../widgets/common/cyber_card.dart';
import '../../widgets/common/cyber_background.dart';
import '../../config/theme/app_text_styles.dart';

class NgoDashboard extends StatefulWidget {
  const NgoDashboard({super.key});

  @override
  State<NgoDashboard> createState() => _NgoDashboardState();
}

class _NgoDashboardState extends State<NgoDashboard> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      context.read<DonationProvider>().listenPendingDonations();
      context.read<DonationProvider>().listenNgoDonations(user.uid);
      context.read<EmergencyProvider>().listenNgoRequests(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true, // For glassmorphism effect
      appBar: CyberAppBar(
        title: 'NGO TERMINAL',
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
        child: IndexedStack(
          index: _currentIndex,
          children: const [
            _OverviewTab(),
            _AvailableDonationsTab(),
            _MyEmergenciesTab(),
          ],
        ),
      ),
      floatingActionButton: _buildEmergencyFAB(),
      bottomNavigationBar: CyberBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          CyberNavItem(
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard,
            label: 'OVERVIEW',
          ),
          CyberNavItem(
            icon: Icons.inventory_2_outlined,
            activeIcon: Icons.inventory_2,
            label: 'AVAILABLE',
          ),
          CyberNavItem(
            icon: Icons.warning_amber,
            activeIcon: Icons.warning,
            label: 'EMERGENCIES',
          ),
        ],
      ),
    );
  }


  Widget _buildEmergencyFAB() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 80), // Avoid overlap with bottom nav
      child: FloatingActionButton.extended(
        onPressed: () => _showEmergencyDialog(),
        backgroundColor: AppColors.neonAmber.withValues(alpha: 0.2),
        foregroundColor: AppColors.neonAmber,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          side: const BorderSide(color: AppColors.neonAmber, width: 2),
        ),
        icon: const Icon(Icons.warning_amber, size: 20),
        label: Text(
          'EMERGENCY',
          style: GoogleFonts.orbitron(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ).animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 2000.ms, color: AppColors.neonAmber.withValues(alpha: 0.3)),
    );
  }

  void _showEmergencyDialog() {
    String selectedMealType = 'veg';
    final qtyController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Theme(
              data: Theme.of(context).copyWith(
                dialogBackgroundColor: AppColors.darkBg.withOpacity(0.9),
              ),
              child: AlertDialog(
                backgroundColor: Colors.transparent,
                contentPadding: EdgeInsets.zero,
                insetPadding: const EdgeInsets.symmetric(horizontal: 20),
                content: CyberCard(
                  borderColor: AppColors.neonAmber,
                  glowColor: AppColors.neonAmber.withValues(alpha: 0.2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.warning_amber,
                              color: AppColors.neonAmber, size: 24),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'EMERGENCY REQUEST',
                            style: AppTextStyles.hitechHeading.copyWith(
                              fontSize: 18,
                              color: AppColors.neonAmber,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'BROADCASTING TO ALL UNITS WITHIN 10KM RADIUS',
                        style: AppTextStyles.hitechSubtitle.copyWith(
                          fontSize: 10,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'MEAL TYPE',
                        style: GoogleFonts.orbitron(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: _MealTypeOption(
                              label: 'VEG',
                              icon: Icons.eco,
                              color: AppColors.neonGreen,
                              isSelected: selectedMealType == 'veg',
                              onTap: () => setDialogState(
                                  () => selectedMealType = 'veg'),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: _MealTypeOption(
                              label: 'NON-VEG',
                              icon: Icons.restaurant,
                              color: AppColors.neonPurple,
                              isSelected: selectedMealType == 'nonVeg',
                              onTap: () => setDialogState(
                                  () => selectedMealType = 'nonVeg'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      TextFormField(
                        controller: qtyController,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.orbitron(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'QUANTITY REQUIRED',
                          labelStyle: GoogleFonts.orbitron(fontSize: 10),
                          prefixIcon: const Icon(Icons.people, size: 20, color: AppColors.neonAmber),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white24),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.neonAmber),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text(
                              'CANCEL',
                              style: GoogleFonts.orbitron(color: Colors.white54, fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          ElevatedButton(
                            onPressed: () async {
                              final qty =
                                  int.tryParse(qtyController.text.trim()) ?? 0;
                              if (qty <= 0) return;

                              final user = context.read<AuthProvider>().user;
                              if (user == null) return;

                              final request = EmergencyRequestModel(
                                id: '',
                                ngoId: user.uid,
                                ngoName: user.organizationName ?? user.name,
                                mealType: selectedMealType,
                                quantity: qty,
                                ngoLocation: user.location ??
                                    const GeoPoint(28.6139, 77.2090),
                                ngoAddress: user.address ?? 'Not specified',
                                status: EmergencyStatus.open,
                                createdAt: DateTime.now(),
                                updatedAt: DateTime.now(),
                              );

                              await context
                                  .read<EmergencyProvider>()
                                  .createEmergencyRequest(request);

                              if (ctx.mounted) Navigator.pop(ctx);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: AppColors.neonAmber,
                                    content: Text(
                                      'SIGNAL BROADCASTED TO NEARBY DONORS',
                                      style: GoogleFonts.orbitron(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.neonAmber,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            child: Text(
                              'SEND ALERT',
                              style: GoogleFonts.orbitron(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}


class _OverviewTab extends StatelessWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final donations = context.watch<DonationProvider>().donations;
    final pending = context.watch<DonationProvider>().pendingDonations;
    final emergencies = context.watch<EmergencyProvider>().activeNgoRequests;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final accepted =
        donations.where((d) => d.status == DonationStatus.accepted).length;
    final delivered =
        donations.where((d) => d.status == DonationStatus.delivered).length;

    final donationProvider = context.watch<DonationProvider>();
    final emergencyProvider = context.watch<EmergencyProvider>();
    final isFetching = donationProvider.isLoading;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(
          'HELLO, ${user?.organizationName?.toUpperCase() ?? user?.name?.toUpperCase() ?? 'NGO'}',
          style: AppTextStyles.hitechHeading.copyWith(
            fontSize: 24,
            color: AppColors.neonCyan,
          ),
        ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2),
        const SizedBox(height: 4),
        Text(
          'ACCESSING MISSION CONTROL // SYSTEM NOMINAL',
          style: AppTextStyles.hitechSubtitle.copyWith(
            fontSize: 12,
            letterSpacing: 1.5,
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
                      label: 'Available',
                      value: '${pending.length}',
                      icon: Icons.inventory_2_outlined,
                      color: AppColors.neonCyan,
                      gradient: AppColors.neonCyanGradient,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _StatCard(
                      label: 'Accepted',
                      value: '$accepted',
                      icon: Icons.thumb_up_outlined,
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
                      label: 'Emergencies',
                      value: '${emergencies.length}',
                      icon: Icons.warning_amber,
                      color: AppColors.neonAmber,
                      gradient: AppColors.neonAmberGradient,
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
            ],
          ),
      ],
    );
  }
}


class _AvailableDonationsTab extends StatelessWidget {
  const _AvailableDonationsTab();

  @override
  Widget build(BuildContext context) {
    final pending = context.watch<DonationProvider>().pendingDonations;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (pending.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 56,
                color: isDark
                    ? AppColors.darkTextHint
                    : AppColors.textHint),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No donations available',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 100),
      itemCount: pending.length,
      itemBuilder: (_, i) {
        final d = pending[i];
        return CyberCard(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      d.title.toUpperCase(),
                      style: AppTextStyles.hitechSubtitle.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.neonCyan,
                      ),
                    ),
                  ),
                  if (d.isExpired)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        border: Border.all(color: AppColors.error),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusXs),
                      ),
                      child: Text(
                        'EXPIRED',
                        style: GoogleFonts.orbitron(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'SOURCE: ${d.donorName.toUpperCase()}',
                style: GoogleFonts.orbitron(
                  fontSize: 10,
                  color: Colors.white70,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _InfoChip(Icons.restaurant, d.foodTypeLabel.toUpperCase(), AppColors.neonPurple),
                  _InfoChip(Icons.eco, d.mealTypeLabel.toUpperCase(), AppColors.neonGreen),
                  _InfoChip(Icons.scale, d.quantityDisplay.toUpperCase(), AppColors.neonAmber),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              _InfoChip(Icons.location_on, d.pickupAddress.toUpperCase(), AppColors.neonCyan),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'DETAILS',
                        style: GoogleFonts.orbitron(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: d.isExpired
                          ? null
                          : () async {
                              final user =
                                  context.read<AuthProvider>().user;
                              if (user != null) {
                                await context
                                    .read<DonationProvider>()
                                    .acceptDonation(
                                      d.id,
                                      user.uid,
                                      user.organizationName ??
                                          user.name,
                                      deliveryAddress: user.address,
                                    );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.neonCyan.withValues(alpha: 0.2),
                        foregroundColor: AppColors.neonCyan,
                        side: const BorderSide(color: AppColors.neonCyan),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'ACCEPT',
                        style: GoogleFonts.orbitron(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}


class _MyEmergenciesTab extends StatelessWidget {
  const _MyEmergenciesTab();

  @override
  Widget build(BuildContext context) {
    final requests = context.watch<EmergencyProvider>().ngoRequests;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (requests.isEmpty) {
      return Center(
        child: Text(
          'No emergency requests yet',
          style: GoogleFonts.inter(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 100),
      itemCount: requests.length,
      itemBuilder: (_, i) {
        final req = requests[i];
        final color = req.isActive ? AppColors.neonAmber : AppColors.neonGreen;
        return CyberCard(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          borderColor: color.withValues(alpha: 0.5),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Icon(
                req.isActive ? Icons.warning_amber : Icons.check_circle_outline,
                color: color,
                size: 20,
              ),
            ),
            title: Text(
              '${req.quantity} ${req.mealTypeLabel.toUpperCase()} MEALS',
              style: GoogleFonts.orbitron(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            subtitle: Text(
              'STATUS: ${req.statusLabel.toUpperCase()}',
              style: GoogleFonts.orbitron(
                fontSize: 10,
                color: color,
                letterSpacing: 1,
              ),
            ),
            trailing: req.isActive
                ? TextButton(
                    onPressed: () =>
                        context.read<EmergencyProvider>().cancelRequest(req.id),
                    child: Text(
                      'ABORT',
                      style: GoogleFonts.orbitron(
                        fontSize: 11,
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
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
    return CyberCard(
      borderColor: color.withValues(alpha: 0.5),
      glowColor: color.withValues(alpha: 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label.toUpperCase(),
                style: AppTextStyles.hitechSubtitle.copyWith(
                  fontSize: 10,
                  color: color,
                  letterSpacing: 1,
                ),
              ),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: GoogleFonts.orbitron(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 2,
            width: 40,
            decoration: BoxDecoration(
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ],
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

class _MealTypeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _MealTypeOption({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(
            color: isSelected ? color : Colors.white12,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 8,
              spreadRadius: 1,
            )
          ] : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : Colors.white38),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.orbitron(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.white38,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _InfoChip(this.icon, this.label, [this.color]);

  @override
  Widget build(BuildContext context) {
    final displayColor = color ?? Colors.white70;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: displayColor),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: GoogleFonts.orbitron(
              fontSize: 10,
              color: displayColor,
              letterSpacing: 0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
