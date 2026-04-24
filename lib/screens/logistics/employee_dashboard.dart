import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_spacing.dart';
import '../../config/theme/app_text_styles.dart';
import '../../models/donation_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/logistics_provider.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/app_bottom_nav_bar.dart';

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
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: const [_ActiveTasksTab(), _CompletedTasksTab()],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          AppBottomNavItem(
            icon: Icons.local_shipping_outlined,
            activeIcon: Icons.local_shipping,
            label: 'Active',
          ),
          AppBottomNavItem(
            icon: Icons.history_outlined,
            activeIcon: Icons.history,
            label: 'History',
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = context.watch<AuthProvider>().user;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: (isDark ? AppColors.darkDivider : AppColors.divider)
                .withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Logistics Portal', style: AppTextStyles.titleLarge),
                Text(
                  user?.email ?? 'Field Operative',
                  style: AppTextStyles.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.logout_rounded,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
            onPressed: () => context.read<AuthProvider>().signOut(),
            tooltip: 'Sign Out',
          ),
        ],
      ),
    );
  }
}

class _ActiveTasksTab extends StatelessWidget {
  const _ActiveTasksTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LogisticsProvider>();
    final tasks = provider.employeeTasks.where((d) => d.isActive).toList();

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_turned_in_outlined,
              size: 64,
              color: AppColors.textHint.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No Active Tasks',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'New assignments will appear here',
              style: AppTextStyles.bodySmall,
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

class _CompletedTasksTab extends StatelessWidget {
  const _CompletedTasksTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LogisticsProvider>();
    final completed = provider.employeeTasks.where((d) => !d.isActive).toList();

    if (completed.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_rounded,
              size: 64,
              color: AppColors.textHint.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No History Records',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textHint,
              ),
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
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: AppCard(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 24,
                ),
              ),
              title: Text(
                d.mealType.name.toUpperCase(),
                style: AppTextStyles.titleSmall,
              ),
              subtitle: Text(
                'Delivered • ${d.id.substring(0, 8).toUpperCase()}',
                style: AppTextStyles.caption,
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
          ),
        );
      },
    );
  }
}

class _ActiveTaskCard extends StatelessWidget {
  final DonationModel donation;

  const _ActiveTaskCard({required this.donation});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Icon(_statusIcon, color: _statusColor, size: 24),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          donation.mealType.name.toUpperCase(),
                          style: AppTextStyles.titleMedium,
                        ),
                        Text(
                          donation.status.name.toUpperCase(),
                          style: AppTextStyles.overline.copyWith(
                            color: _statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Divider(height: 1),
              ),
              _buildInfoRow(
                Icons.business_rounded,
                donation.ngoName ?? 'NGO Unknown',
              ),
              const SizedBox(height: AppSpacing.xs),
              _buildInfoRow(Icons.location_on_rounded, donation.pickupAddress),
              const SizedBox(height: AppSpacing.xs),
              _buildInfoRow(
                Icons.flag_rounded,
                donation.deliveryAddress ?? 'Target Location',
              ),
              const SizedBox(height: AppSpacing.lg),
              _StatusStepper(currentStatus: donation.status),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => _advanceStatus(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _statusColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                  child: Text(_nextActionLabel, style: AppTextStyles.button),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textHint),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(text, style: AppTextStyles.bodySmall)),
      ],
    );
  }

  Color get _statusColor {
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

  IconData get _statusIcon {
    switch (donation.status) {
      case DonationStatus.assigned:
        return Icons.assignment_ind_rounded;
      case DonationStatus.picked:
        return Icons.inventory_2_rounded;
      case DonationStatus.inTransit:
        return Icons.local_shipping_rounded;
      case DonationStatus.nearLocation:
        return Icons.near_me_rounded;
      default:
        return Icons.local_shipping_rounded;
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
        return 'Confirm Delivery';
      default:
        return 'Update Status';
    }
  }

  void _advanceStatus(BuildContext context) {
    DonationStatus nextStatus;
    switch (donation.status) {
      case DonationStatus.assigned:
        nextStatus = DonationStatus.picked;
        break;
      case DonationStatus.picked:
        nextStatus = DonationStatus.inTransit;
        break;
      case DonationStatus.inTransit:
        nextStatus = DonationStatus.nearLocation;
        break;
      case DonationStatus.nearLocation:
        nextStatus = DonationStatus.delivered;
        break;
      default:
        nextStatus = donation.status;
    }
    context.read<LogisticsProvider>().updateDeliveryStatus(
      donation.id,
      nextStatus,
    );
  }
}

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
    'Transit',
    'Nearby',
    'Done',
  ];

  @override
  Widget build(BuildContext context) {
    final currentIdx = _steps.indexOf(currentStatus);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: List.generate(_steps.length * 2 - 1, (i) {
        if (i.isEven) {
          final stepIdx = i ~/ 2;
          final isComplete = stepIdx <= currentIdx;
          final isCurrent = stepIdx == currentIdx;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isCurrent
                      ? AppColors.primary
                      : (isComplete ? AppColors.primary : Colors.transparent),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isComplete
                        ? AppColors.primary
                        : (isDark ? AppColors.darkDivider : AppColors.divider),
                    width: 2,
                  ),
                ),
                child: isComplete && !isCurrent
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : (isCurrent
                          ? Container(
                              margin: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            )
                          : null),
              ),
              const SizedBox(height: 6),
              Text(
                _stepLabels[stepIdx],
                style: AppTextStyles.caption.copyWith(
                  fontSize: 10,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  color: isComplete ? AppColors.primary : AppColors.textHint,
                ),
              ),
            ],
          );
        }

        final lineIdx = (i - 1) ~/ 2;
        final isComplete = lineIdx < currentIdx;

        return Expanded(
          child: Container(
            height: 2,
            margin: const EdgeInsets.only(bottom: 18),
            color: isComplete
                ? AppColors.primary
                : (isDark ? AppColors.darkDivider : AppColors.divider),
          ),
        );
      }),
    );
  }
}
