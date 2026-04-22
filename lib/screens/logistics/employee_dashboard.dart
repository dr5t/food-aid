import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_spacing.dart';
import '../../models/donation_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/logistics_provider.dart';
import '../../providers/theme_provider.dart';

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      context.read<LogisticsProvider>().listenEmployeeTasks(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Deliveries',
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
          _ActiveTasksTab(),
          _CompletedTasksTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping_outlined),
            activeIcon: Icon(Icons.local_shipping),
            label: 'Active',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// ACTIVE TASKS TAB
// ═══════════════════════════════════════════════════════════════════

class _ActiveTasksTab extends StatelessWidget {
  const _ActiveTasksTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LogisticsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tasks = provider.employeeTasks.where((d) => d.isActive).toList();

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_turned_in_outlined, size: 56,
                color: isDark
                    ? AppColors.darkTextHint
                    : AppColors.textHint),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No active deliveries',
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
              'Assigned deliveries will appear here',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: isDark
                    ? AppColors.darkTextHint
                    : AppColors.textHint,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: tasks.length,
      itemBuilder: (_, i) => _ActiveTaskCard(donation: tasks[i]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// COMPLETED TASKS TAB
// ═══════════════════════════════════════════════════════════════════

class _CompletedTasksTab extends StatelessWidget {
  const _CompletedTasksTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LogisticsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final completed =
        provider.employeeTasks.where((d) => !d.isActive).toList();

    if (completed.isEmpty) {
      return Center(
        child: Text(
          'No completed deliveries',
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
      itemCount: completed.length,
      itemBuilder: (_, i) {
        final d = completed[i];
        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: ListTile(
            leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: const Icon(Icons.check_circle,
                  color: AppColors.success, size: 20),
            ),
            title: Text(
              d.title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              d.statusLabel,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// ACTIVE TASK CARD WITH STATUS PROGRESSION
// ═══════════════════════════════════════════════════════════════════

class _ActiveTaskCard extends StatelessWidget {
  final DonationModel donation;

  const _ActiveTaskCard({required this.donation});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _currentColor.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child:
                      Icon(_currentIcon, color: _currentColor, size: 20),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        donation.title,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        donation.statusLabel,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _currentColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // Route info
            Row(
              children: [
                const Icon(Icons.circle, size: 8,
                    color: AppColors.success),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    donation.pickupAddress,
                    style: GoogleFonts.inter(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 3),
              child: Container(
                width: 2,
                height: 16,
                color: isDark
                    ? AppColors.darkDivider
                    : AppColors.divider,
              ),
            ),
            Row(
              children: [
                const Icon(Icons.circle, size: 8,
                    color: AppColors.emergency),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    donation.deliveryAddress ?? 'Delivery address',
                    style: GoogleFonts.inter(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // Progress Steps
            _StatusStepper(currentStatus: donation.status),

            const SizedBox(height: AppSpacing.md),

            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _advanceStatus(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _currentColor,
                  foregroundColor: Colors.white,
                ),
                child: Text(_nextActionLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color get _currentColor {
    switch (donation.status) {
      case DonationStatus.assigned:
        return AppColors.statusAssigned;
      case DonationStatus.picked:
        return AppColors.statusPicked;
      case DonationStatus.inTransit:
        return AppColors.statusInTransit;
      case DonationStatus.nearLocation:
        return AppColors.statusNearLocation;
      default:
        return AppColors.primary;
    }
  }

  IconData get _currentIcon {
    switch (donation.status) {
      case DonationStatus.assigned:
        return Icons.assignment_ind;
      case DonationStatus.picked:
        return Icons.inventory;
      case DonationStatus.inTransit:
        return Icons.local_shipping;
      case DonationStatus.nearLocation:
        return Icons.near_me;
      default:
        return Icons.local_shipping;
    }
  }

  String get _nextActionLabel {
    switch (donation.status) {
      case DonationStatus.assigned:
        return 'Mark as Picked Up';
      case DonationStatus.picked:
        return 'Start Delivery';
      case DonationStatus.inTransit:
        return 'Arrived Nearby';
      case DonationStatus.nearLocation:
        return 'Mark as Delivered';
      default:
        return 'Update Status';
    }
  }

  DonationStatus get _nextStatus {
    switch (donation.status) {
      case DonationStatus.assigned:
        return DonationStatus.picked;
      case DonationStatus.picked:
        return DonationStatus.inTransit;
      case DonationStatus.inTransit:
        return DonationStatus.nearLocation;
      case DonationStatus.nearLocation:
        return DonationStatus.delivered;
      default:
        return donation.status;
    }
  }

  void _advanceStatus(BuildContext context) {
    context
        .read<LogisticsProvider>()
        .updateDeliveryStatus(donation.id, _nextStatus);
  }
}

// ═══════════════════════════════════════════════════════════════════
// STATUS STEPPER
// ═══════════════════════════════════════════════════════════════════

class _StatusStepper extends StatelessWidget {
  final DonationStatus currentStatus;

  const _StatusStepper({required this.currentStatus});

  static const _steps = [
    DonationStatus.assigned,
    DonationStatus.picked,
    DonationStatus.inTransit,
    DonationStatus.nearLocation,
    DonationStatus.delivered,
  ];

  static const _stepLabels = [
    'Assigned',
    'Picked',
    'In Transit',
    'Nearby',
    'Delivered',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentIdx = _steps.indexOf(currentStatus);

    return Row(
      children: List.generate(_steps.length * 2 - 1, (i) {
        if (i.isEven) {
          final stepIdx = i ~/ 2;
          final isComplete = stepIdx <= currentIdx;
          final isCurrent = stepIdx == currentIdx;

          return Column(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isComplete
                      ? AppColors.primary
                      : isDark
                          ? AppColors.darkSurfaceVariant
                          : AppColors.surfaceVariant,
                  shape: BoxShape.circle,
                  border: isCurrent
                      ? Border.all(
                          color: AppColors.primary, width: 2)
                      : null,
                ),
                child: isComplete
                    ? const Icon(Icons.check, size: 12,
                        color: Colors.white)
                    : null,
              ),
              const SizedBox(height: 4),
              Text(
                _stepLabels[stepIdx],
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight:
                      isCurrent ? FontWeight.w600 : FontWeight.w400,
                  color: isComplete
                      ? AppColors.primary
                      : isDark
                          ? AppColors.darkTextHint
                          : AppColors.textHint,
                ),
              ),
            ],
          );
        }

        // Connector line
        final lineIdx = (i - 1) ~/ 2;
        final isComplete = lineIdx < currentIdx;

        return Expanded(
          child: Container(
            height: 2,
            margin: const EdgeInsets.only(bottom: 16),
            color: isComplete
                ? AppColors.primary
                : isDark
                    ? AppColors.darkDivider
                    : AppColors.divider,
          ),
        );
      }),
    );
  }
}
