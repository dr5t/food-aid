import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_spacing.dart';
import '../../config/theme/app_text_styles.dart';
import '../../models/donation_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/logistics_provider.dart';
import '../../providers/emergency_provider.dart';
import '../../models/emergency_request_model.dart';
import '../../widgets/admin/create_employee_dialog.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/app_bottom_nav_bar.dart';

class CompanyDashboard extends StatefulWidget {
  const CompanyDashboard({super.key});

  @override
  State<CompanyDashboard> createState() => _CompanyDashboardState();
}

class _CompanyDashboardState extends State<CompanyDashboard> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      context.read<LogisticsProvider>().listenCompanyData(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark 
          ? AppColors.darkBackground 
          : AppColors.background,
      appBar: AppAppBar(
        title: 'Fleet Member',
        actions: [
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
          _UnassignedTab(),
          _EmployeesTab(),
          _CompanyCompletedTab(),
        ],
      ),
      floatingActionButton: _buildEmergencyFAB(),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          AppBottomNavItem(
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard,
            label: 'Dashboard',
          ),
          AppBottomNavItem(
            icon: Icons.assignment_outlined,
            activeIcon: Icons.assignment,
            label: 'Unassigned',
          ),
          AppBottomNavItem(
            icon: Icons.group_outlined,
            activeIcon: Icons.group,
            label: 'Employees',
          ),
          AppBottomNavItem(
            icon: Icons.task_alt_rounded,
            activeIcon: Icons.task_alt_rounded,
            label: 'Completed',
          ),
        ],
      ),
    );
  }

  }

  Widget _buildEmergencyFAB() {
    return FloatingActionButton.extended(
          onPressed: () => _showEmergencyDialog(),
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.emergency_share, size: 24),
          label: Text(
            '🚨 SOS EMERGENCY',
            style: GoogleFonts.orbitron(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              fontSize: 14,
            ),
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 2000.ms, color: Colors.white38)
        .shake(duration: 500.ms, hz: 4);
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
                          'Logistics SOS Signal',
                          style: AppTextStyles.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Broadcast urgent food pickup signal to nearby donors',
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
                            label: 'Non-Veg',
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
                        labelText: 'Quantity Needed',
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
                                  backgroundColor: AppColors.error,
                                  content: Text(
                                    'SOS BROADCASTED TO NEARBY DONORS',
                                    style: GoogleFonts.orbitron(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: const Text('Broadcast SOS'),
                        ),
                      ],
                    ),
                  ],
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
    final provider = context.watch<LogisticsProvider>();

    final active = provider.companyDonations
        .where((d) => d.isActive)
        .length;
    final delivered = provider.companyDonations
        .where((d) => d.status == DonationStatus.delivered)
        .length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 100),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.organizationName ?? 'Logistics Company',
                style: AppTextStyles.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Active Session • All systems operational',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.4,
          children: [
            _StatCard(
              label: 'Unassigned',
              value: '${provider.unassignedDonations.length}',
              icon: Icons.assignment_outlined,
              color: AppColors.statusPending,
            ),
            _StatCard(
              label: 'Active',
              value: '$active',
              icon: Icons.local_shipping_outlined,
              color: AppColors.statusAssigned,
            ),
            _StatCard(
              label: 'Delivered',
              value: '$delivered',
              icon: Icons.check_circle_outline,
              color: AppColors.statusDelivered,
            ),
            _StatCard(
              label: 'Employees',
              value: '${provider.employees.length}',
              icon: Icons.group_outlined,
              color: AppColors.primary,
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.xl),
        Text(
          'Active Deliveries',
          style: AppTextStyles.titleMedium,
        ),
        const SizedBox(height: AppSpacing.md),

        ...provider.companyDonations
            .where((d) => d.isActive)
            .take(5)
            .map((d) => _DeliveryTile(donation: d)),

        if (provider.companyDonations.where((d) => d.isActive).isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Text(
                'No active deliveries',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
              ),
            ),
          ),
      ],
    );
  }
}

class _UnassignedTab extends StatelessWidget {
  const _UnassignedTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LogisticsProvider>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Text(
                'Pending Tasks',
                style: AppTextStyles.titleLarge,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.statusPending.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Text(
                  '${provider.unassignedDonations.length} Pending',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.statusPending,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: provider.unassignedDonations.isEmpty
              ? _buildEmptyState('No pending tasks available')
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  itemCount: provider.unassignedDonations.length,
                  itemBuilder: (context, index) {
                    return _DeliveryTile(
                      donation: provider.unassignedDonations[index],
                      isUnassigned: true,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_turned_in_outlined, size: 48, color: AppColors.textHint.withValues(alpha: 0.3)),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}

class _EmployeesTab extends StatelessWidget {
  const _EmployeesTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LogisticsProvider>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Text(
                'Employees',
                style: AppTextStyles.titleLarge,
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showCreateEmployeeDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Employee'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: provider.employees.isEmpty
              ? _buildEmptyState('No employees added yet')
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  itemCount: provider.employees.length,
                  itemBuilder: (context, index) {
                    final employee = provider.employees[index];
                    return _EmployeeTile(employee: employee);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_outlined, size: 48, color: AppColors.textHint.withValues(alpha: 0.3)),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
          ),
        ],
      ),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTextStyles.titleLarge,
          ),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}

class _DeliveryTile extends StatelessWidget {
  final DonationModel donation;
  final bool isUnassigned;

  const _DeliveryTile({
    required this.donation,
    this.isUnassigned = false,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(donation.status);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Text(
                    donation.status.name.toUpperCase(),
                    style: AppTextStyles.overline.copyWith(color: statusColor),
                  ),
                ),
                const Spacer(),
                Text(
                  '#${donation.id.substring(0, 8).toUpperCase()}',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              donation.mealType.name,
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            _buildInfoRow(Icons.business, donation.ngoName ?? 'Unknown NGO'),
            _buildInfoRow(Icons.location_on_outlined, donation.pickupAddress),
            const SizedBox(height: AppSpacing.md),
            if (isUnassigned)
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => _showAssignDialog(context, donation),
                  child: const Text('Assign Employee'),
                ),
              )
            else if (donation.employeeName != null)
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person_outline, size: 16, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Assigned to: ${donation.employeeName}',
                      style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
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
          Icon(icon, size: 14, color: AppColors.textHint),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(DonationStatus status) {
    switch (status) {
      case DonationStatus.pending:
        return AppColors.statusPending;
      case DonationStatus.assigned:
        return AppColors.statusAssigned;
      case DonationStatus.picked:
        return AppColors.statusPicked;
      case DonationStatus.delivered:
        return AppColors.statusDelivered;
      default:
        return AppColors.textHint;
    }
  }
}

class _EmployeeTile extends StatelessWidget {
  final UserModel employee;

  const _EmployeeTile({required this.employee});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: const Icon(Icons.person, color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employee.name,
                    style: AppTextStyles.titleSmall,
                  ),
                  Text(
                    employee.email,
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
              onPressed: () => _showDeleteConfirm(context, employee),
            ),
          ],
        ),
      ),
    );
  }
}

void _showDeleteConfirm(BuildContext context, UserModel employee) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Remove Employee?'),
      content: Text('Are you sure you want to remove ${employee.name}?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        TextButton(
          onPressed: () async {
            final ok = await context.read<LogisticsProvider>().deleteEmployee(employee.uid);
            if (ok && context.mounted) {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Employee removed')),
              );
            }
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Remove'),
        ),
      ],
    ),
  );
}

void _showAssignDialog(BuildContext context, DonationModel donation) {
  showDialog(
    context: context,
    builder: (context) {
      return Consumer<LogisticsProvider>(
        builder: (context, provider, _) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Assign Employee',
                    style: AppTextStyles.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Select an employee for task #${donation.id.substring(0, 8).toUpperCase()}',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (provider.employees.isEmpty)
                    Center(
                      child: Text(
                        'No employees available',
                        style: AppTextStyles.bodySmall,
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: provider.employees.length,
                        itemBuilder: (context, index) {
                          final employee = provider.employees[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: ListTile(
                              onTap: () {
                                final user = context.read<AuthProvider>().user;
                                if (user != null) {
                                  provider.assignEmployee(
                                    donation.id,
                                    user.uid,
                                    user.organizationName ?? 'Company',
                                    employee.uid,
                                    employee.name,
                                  );
                                }
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Task assigned to ${employee.name}'),
                                  ),
                                );
                              },
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                child: const Icon(Icons.person, size: 18, color: AppColors.primary),
                              ),
                              title: Text(employee.name),
                              subtitle: const Text('Available'),
                              trailing: const Icon(Icons.chevron_right),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                side: BorderSide(color: AppColors.divider.withValues(alpha: 0.1)),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

void _showCreateEmployeeDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      final user = context.read<AuthProvider>().user;
      return CreateEmployeeDialog(
        title: 'Add New Employee',
        targetRole: UserRole.logisticsEmployee,
        onCreateEmployee: ({
          required String name,
          required String email,
          required String password,
          String? phone,
        }) async {
          return await context.read<AuthProvider>().createLogisticsEmployee(
                name: name,
                email: email,
                password: password,
                phone: phone,
                companyId: user?.uid ?? '',
                companyName: user?.organizationName ?? 'Logistics Company',
              );
        },
      );
    },
  );
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

class _CompanyCompletedTab extends StatelessWidget {
  const _CompanyCompletedTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LogisticsProvider>();
    final completed = provider.companyDonations.where((d) => d.status == DonationStatus.delivered).toList();

    if (completed.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_rounded, size: 64, color: AppColors.textHint.withValues(alpha: 0.1)),
            const SizedBox(height: 16),
            Text('No completed deliveries', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, 100),
      itemCount: completed.length,
      itemBuilder: (context, index) {
        return _DeliveryTile(donation: completed[index]);
      },
    );
  }
}
