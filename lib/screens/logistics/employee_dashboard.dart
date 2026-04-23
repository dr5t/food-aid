import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_spacing.dart';
import '../../config/theme/app_text_styles.dart';
import '../../models/donation_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/logistics_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/common/cyber_card.dart';
import '../../widgets/common/cyber_bottom_nav_bar.dart';

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
      backgroundColor: AppColors.darkBg,
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.neonCyan.withOpacity(0.05),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: const [
                      _ActiveTasksTab(),
                      _CompletedTasksTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CyberBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          CyberBottomNavItem(
            icon: Icons.local_shipping_outlined,
            label: 'ACTIVE',
          ),
          CyberBottomNavItem(
            icon: Icons.history_outlined,
            label: 'HISTORY',
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'UNIT DASHBOARD',
                style: AppTextStyles.hitechHeading,
              ),
              Text(
                'FIELD OPERATIVE TERMINAL',
                style: AppTextStyles.hitechSubtitle.copyWith(fontSize: 10, color: AppColors.neonCyan),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70),
            onPressed: () => context.read<AuthProvider>().signOut(),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tasks = provider.employeeTasks.where((d) => d.isActive).toList();

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment_turned_in_outlined, size: 56,
                color: Colors.white10),
            const SizedBox(height: AppSpacing.md),
            Text(
              'NO ACTIVE TASKS',
              style: AppTextStyles.hitechSubtitle.copyWith(color: Colors.white24),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final completed =
        provider.employeeTasks.where((d) => !d.isActive).toList();

    if (completed.isEmpty) {
      return Center(
        child: Text(
          'NO HISTORY RECORDS',
          style: AppTextStyles.hitechSubtitle.copyWith(color: Colors.white24),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: completed.length,
      itemBuilder: (_, i) {
        final d = completed[i];
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          child: CyberCard(
            child: ListTile(
              leading: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.neonGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: const Icon(Icons.check_circle,
                    color: AppColors.neonGreen, size: 20),
              ),
              title: Text(
                d.mealType.name.toUpperCase(),
                style: AppTextStyles.hitechHeading.copyWith(fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                'COMPLETED #${d.id.substring(0, 8).toUpperCase()}',
                style: GoogleFonts.orbitron(
                  fontSize: 10,
                  color: Colors.white38,
                ),
              ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: CyberCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _currentColor.withOpacity(0.1),
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
                        donation.mealType.name.toUpperCase(),
                        style: AppTextStyles.hitechHeading.copyWith(fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        donation.status.name.toUpperCase(),
                        style: GoogleFonts.orbitron(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _currentColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            _buildInfoRow(Icons.business, donation.ngoName ?? 'NGO Unknown'),
            _buildInfoRow(Icons.location_on_outlined, donation.pickupAddress),
            _buildInfoRow(Icons.flag_outlined, donation.deliveryAddress ?? 'Target Location'),

            const SizedBox(height: AppSpacing.md),

            _StatusStepper(currentStatus: donation.status),

            const SizedBox(height: AppSpacing.md),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _advanceStatus(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _currentColor.withOpacity(0.1),
                  foregroundColor: _currentColor,
                  side: BorderSide(color: _currentColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: Text(
                  _nextActionLabel.toUpperCase(),
                  style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.white38),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text.toUpperCase(),
              style: GoogleFonts.orbitron(
                fontSize: 10,
                color: Colors.white70,
                letterSpacing: 0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color get _currentColor {
    switch (donation.status) {
      case DonationStatus.assigned:
        return AppColors.neonAmber;
      case DonationStatus.picked:
        return AppColors.neonPurple;
      case DonationStatus.inTransit:
        return AppColors.neonCyan;
      case DonationStatus.nearLocation:
        return AppColors.neonGreen;
      default:
        return AppColors.neonCyan;
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
    final currentIdx = _steps.indexOf(currentStatus);

    return Row(
      children: List.generate(_steps.length * 2 - 1, (i) {
        if (i.isEven) {
          final stepIdx = i ~/ 2;
          final isComplete = stepIdx <= currentIdx;
          final isCurrent = stepIdx == currentIdx;
          final stepColor = isComplete ? AppColors.neonCyan : Colors.white10;

          return Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isCurrent ? Colors.transparent : stepColor,
                  shape: BoxShape.circle,
                  border: isCurrent
                      ? Border.all(color: AppColors.neonCyan, width: 2)
                      : null,
                  boxShadow: isComplete ? [
                    BoxShadow(color: AppColors.neonCyan.withOpacity(0.3), blurRadius: 4)
                  ] : null,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _stepLabels[stepIdx].toUpperCase(),
                style: GoogleFonts.orbitron(
                  fontSize: 7,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  color: isComplete ? AppColors.neonCyan : Colors.white24,
                ),
              ),
            ],
          );
        }

        final lineIdx = (i - 1) ~/ 2;
        final isComplete = lineIdx < currentIdx;

        return Expanded(
          child: Container(
            height: 1,
            margin: const EdgeInsets.only(bottom: 12),
            color: isComplete ? AppColors.neonCyan.withOpacity(0.5) : Colors.white10,
          ),
        );
      }),
    );
  }
}
