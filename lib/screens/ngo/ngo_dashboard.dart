import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_spacing.dart';
import '../../models/donation_model.dart';
import '../../models/emergency_request_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/donation_provider.dart';
import '../../providers/emergency_provider.dart';
import '../../providers/theme_provider.dart';

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
      appBar: AppBar(
        title: Text(
          'NGO Dashboard',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, size: 22),
            onPressed: () => context.read<ThemeProvider>().toggleTheme(),
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
          _AvailableDonationsTab(),
          _MyEmergenciesTab(),
        ],
      ),
      floatingActionButton: _buildEmergencyFAB(),
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
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Available',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning_amber),
            activeIcon: Icon(Icons.warning),
            label: 'My Emergencies',
          ),
        ],
      ),
    );
  }

  // ─── Emergency FAB ──────────────────────────────────────────────

  Widget _buildEmergencyFAB() {
    return FloatingActionButton.extended(
      onPressed: () => _showEmergencyDialog(),
      backgroundColor: AppColors.emergency,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.warning),
      label: const Text('Emergency'),
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
            return AlertDialog(
              title: Row(
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
                  Text(
                    'Emergency Request',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This will alert all donors within 10km of your location.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  Text(
                    'Meal Type',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: _MealTypeOption(
                          label: 'Vegetarian',
                          icon: Icons.eco,
                          color: AppColors.success,
                          isSelected: selectedMealType == 'veg',
                          onTap: () => setDialogState(
                              () => selectedMealType = 'veg'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _MealTypeOption(
                          label: 'Non-Veg',
                          icon: Icons.restaurant,
                          color: AppColors.accentDark,
                          isSelected: selectedMealType == 'nonVeg',
                          onTap: () => setDialogState(
                              () => selectedMealType = 'nonVeg'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: qtyController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Number of Meals Needed',
                      prefixIcon: Icon(Icons.people, size: 20),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
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
                        const SnackBar(
                          content: Text(
                              '🚨 Emergency request sent to nearby donors'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emergency,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Send Alert'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// OVERVIEW TAB
// ═══════════════════════════════════════════════════════════════════

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

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(
          'Hello, ${user?.organizationName ?? user?.name ?? 'NGO'} 👋',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage donations and emergency requests',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Stats
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Available',
                value: '${pending.length}',
                icon: Icons.inventory_2_outlined,
                color: AppColors.info,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _StatCard(
                label: 'Accepted',
                value: '$accepted',
                icon: Icons.thumb_up_outlined,
                color: AppColors.statusAccepted,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Delivered',
                value: '$delivered',
                icon: Icons.check_circle_outline,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _StatCard(
                label: 'Emergencies',
                value: '${emergencies.length}',
                icon: Icons.warning_amber,
                color: AppColors.emergency,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// AVAILABLE DONATIONS TAB
// ═══════════════════════════════════════════════════════════════════

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
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: pending.length,
      itemBuilder: (_, i) {
        final d = pending[i];
        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        d.title,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (d.isExpired)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusFull),
                        ),
                        child: Text(
                          'Expired',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'by ${d.donorName}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: [
                    _InfoChip(Icons.restaurant, d.foodTypeLabel),
                    _InfoChip(Icons.eco, d.mealTypeLabel),
                    _InfoChip(Icons.scale, d.quantityDisplay),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                _InfoChip(Icons.location_on, d.pickupAddress),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        child: const Text('View Details'),
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
                        child: const Text('Accept'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// MY EMERGENCIES TAB
// ═══════════════════════════════════════════════════════════════════

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
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: requests.length,
      itemBuilder: (_, i) {
        final req = requests[i];
        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          child: ListTile(
            leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: req.isActive
                    ? AppColors.emergency.withValues(alpha: 0.1)
                    : AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Icon(
                req.isActive ? Icons.warning : Icons.check_circle,
                color: req.isActive ? AppColors.emergency : AppColors.success,
                size: 20,
              ),
            ),
            title: Text(
              '${req.quantity} ${req.mealTypeLabel} meals',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              req.statusLabel,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
            trailing: req.isActive
                ? TextButton(
                    onPressed: () =>
                        context.read<EmergencyProvider>().cancelRequest(req.id),
                    child: const Text('Cancel',
                        style: TextStyle(color: AppColors.error)),
                  )
                : null,
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════════

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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
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
          color: isSelected ? color.withValues(alpha: 0.08) : null,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isSelected ? color : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : null),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? color : null,
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
