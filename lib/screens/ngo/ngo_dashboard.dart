import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_spacing.dart';
import '../../models/emergency_request_model.dart';
import '../../models/donation_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/donation_provider.dart';
import '../../providers/emergency_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/common/skeleton_widgets.dart';
import '../../widgets/common/app_app_bar.dart';
import '../../widgets/common/app_card.dart';
import '../../config/theme/app_text_styles.dart';
import '../../widgets/common/connection_status_indicator.dart';

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
    return Scaffold(
      appBar: AppAppBar(
        title: 'Food Aid',
        actions: [
          const ConnectionStatusIndicator(),
          IconButton(
            icon: const Icon(Icons.logout, size: 20),
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
          _CompletedTab(),
        ],
      ),
      floatingActionButton: _buildEmergencyFAB(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
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
            label: 'Emergencies',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt_rounded),
            activeIcon: Icon(Icons.task_alt_rounded),
            label: 'Completed',
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyFAB() {
    return FloatingActionButton.extended(
      onPressed: () => _showEmergencyDialog(),
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.sos_rounded, size: 24),
      label: const Text(
        'EMERGENCY SOS',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
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
                dialogTheme: Theme.of(context).dialogTheme.copyWith(
                  backgroundColor: AppColors.darkBg.withValues(alpha: 0.9),
                ),
              ),
              child: AlertDialog(
                backgroundColor: Colors.transparent,
                contentPadding: EdgeInsets.zero,
                insetPadding: const EdgeInsets.symmetric(horizontal: 20),
                content: AppCard(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.warning_amber,
                            color: Colors.orange,
                            size: 24,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'New Emergency Request',
                            style: AppTextStyles.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Alerting nearby donors within 10km radius',
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'Meal Type',
                        style: AppTextStyles.label.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: _MealTypeOption(
                              label: 'Vegetarian',
                              icon: Icons.eco,
                              color: Colors.green,
                              isSelected: selectedMealType == 'veg',
                              onTap: () => setDialogState(
                                () => selectedMealType = 'veg',
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: _MealTypeOption(
                              label: 'Non-Vegetarian',
                              icon: Icons.restaurant,
                              color: Colors.red,
                              isSelected: selectedMealType == 'nonVeg',
                              onTap: () => setDialogState(
                                () => selectedMealType = 'nonVeg',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      TextFormField(
                        controller: qtyController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Quantity Required',
                          prefixIcon: Icon(Icons.people, size: 20),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
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
                                ngoLocation:
                                    user.location ??
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
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text('Send Alert'),
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
    final stats = context.watch<DonationProvider>().ngoStats;
    final accepted = stats['active'] ?? 0;
    final delivered = stats['completed'] ?? 0;
    final available = stats['available'] ?? 0;
    final inTransit = stats['inTransit'] ?? 0;

    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final donationProvider = context.watch<DonationProvider>();
    final isFetching = donationProvider.isLoading;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal, Colors.teal.shade300],
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
                child: Icon(Icons.diversity_3_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome, ${user?.organizationName ?? user?.name ?? 'NGO'}',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      'NGO Portal — Smart Distribution',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

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
                      value: '$available',
                      icon: Icons.inventory_2_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _StatCard(
                      label: 'Accepted',
                      value: '$accepted',
                      icon: Icons.thumb_up_outlined,
                      color: Colors.purple,
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
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _StatCard(
                      label: 'In Transit',
                      value: '$inTransit',
                      icon: Icons.local_shipping_outlined,
                      color: Colors.orange,
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
            Icon(
              Icons.inbox_outlined,
              size: 56,
              color: isDark ? AppColors.darkTextHint : AppColors.textHint,
            ),
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
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        100,
      ),
      itemCount: pending.length,
      itemBuilder: (_, i) {
        final d = pending[i];
        return AppCard(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(d.title, style: AppTextStyles.titleMedium),
                  ),
                  if (d.isExpired)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        border: Border.all(color: AppColors.error),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusXs,
                        ),
                      ),
                      child: Text(
                        'EXPIRED',
                        style: AppTextStyles.overline.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text('From: ${d.donorName}', style: AppTextStyles.caption),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _InfoChip(Icons.restaurant, d.foodTypeLabel, Colors.purple),
                  _InfoChip(Icons.eco, d.mealTypeLabel, Colors.green),
                  _InfoChip(Icons.scale, d.quantityDisplay, Colors.orange),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              _InfoChip(Icons.location_on, d.pickupAddress, AppColors.primary),
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
                      child: const Text('View Details'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: d.isExpired
                          ? null
                          : () async {
                              final user = context.read<AuthProvider>().user;
                              if (user != null) {
                                await context
                                    .read<DonationProvider>()
                                    .acceptDonation(
                                      d.id,
                                      user.uid,
                                      user.organizationName ?? user.name,
                                      deliveryAddress: user.address,
                                    );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Donation Accepted Successfully!'),
                                      backgroundColor: AppColors.primary,
                                    ),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Accept'),
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
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        100,
      ),
      itemCount: requests.length,
      itemBuilder: (_, i) {
        final req = requests[i];
        final color = req.isActive ? Colors.orange : Colors.green;
        return AppCard(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
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
              '${req.quantity} ${req.mealTypeLabel} Meals',
              style: AppTextStyles.titleSmall,
            ),
            subtitle: Text(
              'Status: ${req.statusLabel}',
              style: AppTextStyles.caption.copyWith(color: color),
            ),
            trailing: req.isActive
                ? TextButton(
                    onPressed: () =>
                        context.read<EmergencyProvider>().cancelRequest(req.id),
                    child: const Text('Cancel'),
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

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      color: color.withValues(alpha: 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTextStyles.label.copyWith(color: color)),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(value, style: AppTextStyles.heading),
        ],
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
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(
            color: isSelected ? color : Colors.white12,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : Colors.white38),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.grey,
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

class _CompletedTab extends StatelessWidget {
  const _CompletedTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DonationProvider>();
    final completed = provider.donations.where((d) => d.status == DonationStatus.delivered).toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (completed.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              size: 64,
              color: isDark ? Colors.white12 : Colors.grey.shade200,
            ),
            const SizedBox(height: 16),
            Text(
              'No completed deliveries yet',
              style: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: completed.length,
      itemBuilder: (_, i) {
        final d = completed[i];
        return AppCard(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          child: ListTile(
            leading: const Icon(Icons.check_circle_rounded, color: Colors.green),
            title: Text(d.title, style: AppTextStyles.titleSmall),
            subtitle: Text('Delivered on ${d.updatedAt.toString().split(' ')[0]}'),
            trailing: const Text('COMPLETED', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        );
      },
    );
  }
}
