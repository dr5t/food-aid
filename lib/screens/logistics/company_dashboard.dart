import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_spacing.dart';
import '../../config/theme/app_text_styles.dart';
import '../../models/donation_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/logistics_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/admin/create_employee_dialog.dart';
import '../../widgets/common/cyber_card.dart';
import '../../widgets/common/cyber_bottom_nav_bar.dart';

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
                color: AppColors.neonCyan.withValues(alpha: 0.05),
              ),
            ).animate().fadeIn(duration: 1000.ms),
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: const [
                      _OverviewTab(),
                      _UnassignedTab(),
                      _EmployeesTab(),
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
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard,
            label: 'HUB',
          ),
          CyberBottomNavItem(
            icon: Icons.assignment_outlined,
            activeIcon: Icons.assignment,
            label: 'TASKS',
          ),
          CyberBottomNavItem(
            icon: Icons.group_outlined,
            activeIcon: Icons.group,
            label: 'UNIT',
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LOGISTICS HUB',
                style: AppTextStyles.hitechHeading.copyWith(fontSize: 20),
              ),
              Text(
                'FLEET CONTROL CENTER',
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


class _OverviewTab extends StatelessWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final provider = context.watch<LogisticsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final active = provider.companyDonations
        .where((d) => d.isActive)
        .length;
    final delivered = provider.companyDonations
        .where((d) => d.status == DonationStatus.delivered)
        .length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 100),
      children: [
        CyberCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SYSTEM USER: ${user?.organizationName?.toUpperCase() ?? 'COMPANY'}',
                style: GoogleFonts.orbitron(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neonCyan,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'LOGISTICS AUTHENTICATED // STATUS: ONLINE',
                style: GoogleFonts.orbitron(
                  fontSize: 10,
                  color: Colors.white54,
                  letterSpacing: 0.5,
                ),
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
              label: 'UNASSIGNED',
              value: '${provider.unassignedDonations.length}',
              icon: Icons.assignment_outlined,
              color: AppColors.neonAmber,
            ),
            _StatCard(
              label: 'ACTIVE',
              value: '$active',
              icon: Icons.local_shipping_outlined,
              color: AppColors.neonCyan,
            ),
            _StatCard(
              label: 'DELIVERED',
              value: '$delivered',
              icon: Icons.check_circle_outline,
              color: AppColors.neonGreen,
            ),
            _StatCard(
              label: 'EMPLOYEES',
              value: '${provider.employees.length}',
              icon: Icons.group_outlined,
              color: AppColors.neonPurple,
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.xl),
        Text(
          'ACTIVE DELIVERIES',
          style: AppTextStyles.hitechSubtitle.copyWith(color: Colors.white),
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
                'NO ACTIVE OPERATIONS',
                style: GoogleFonts.orbitron(
                  fontSize: 12,
                  color: Colors.white24,
                  letterSpacing: 1,
                ),
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
                'PENDING TASKS',
                style: AppTextStyles.hitechHeading.copyWith(fontSize: 18),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.neonAmber.withValues(alpha: 0.1),
                  border: Border.all(color: AppColors.neonAmber.withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${provider.unassignedDonations.length} DETECTED',
                  style: GoogleFonts.orbitron(
                    fontSize: 10,
                    color: AppColors.neonAmber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: provider.unassignedDonations.isEmpty
              ? _buildEmptyState('NO PENDING LOGISTICS DETECTED')
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
          const Icon(Icons.radar, size: 48, color: Colors.white10),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: GoogleFonts.orbitron(
              fontSize: 12,
              color: Colors.white24,
              letterSpacing: 1,
            ),
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
                'UNIT ROSTER',
                style: AppTextStyles.hitechHeading.copyWith(fontSize: 18),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showCreateEmployeeDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: Text(
                  'RECRUIT',
                  style: GoogleFonts.orbitron(fontSize: 10, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonCyan.withValues(alpha: 0.1),
                  foregroundColor: AppColors.neonCyan,
                  side: const BorderSide(color: AppColors.neonCyan),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: provider.employees.isEmpty
              ? _buildEmptyState('NO OPERATIVES ASSIGNED')
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
          const Icon(Icons.group_off_outlined, size: 48, color: Colors.white10),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: GoogleFonts.orbitron(
              fontSize: 12,
              color: Colors.white24,
              letterSpacing: 1,
            ),
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
    return CyberCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: GoogleFonts.orbitron(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.orbitron(
              fontSize: 8,
              color: color.withValues(alpha: 0.7),
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms).scale(begin: const Offset(0.95, 0.95));
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
      child: CyberCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    donation.status.name.toUpperCase(),
                    style: GoogleFonts.orbitron(
                      fontSize: 8,
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '#${donation.id.substring(0, 8).toUpperCase()}',
                  style: GoogleFonts.orbitron(
                    fontSize: 8,
                    color: Colors.white24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              donation.mealType.name.toUpperCase(),
              style: AppTextStyles.hitechHeading.copyWith(fontSize: 14),
            ),
            const SizedBox(height: AppSpacing.xs),
            _buildInfoRow(Icons.business, donation.ngoName ?? 'NGO Unknown'),
            _buildInfoRow(Icons.location_on_outlined, donation.pickupAddress),
            const SizedBox(height: AppSpacing.md),
            if (isUnassigned)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showAssignDialog(context, donation),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonCyan.withValues(alpha: 0.1),
                    foregroundColor: AppColors.neonCyan,
                    side: const BorderSide(color: AppColors.neonCyan),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  child: Text(
                    'ASSIGN OPERATIVE',
                    style: GoogleFonts.orbitron(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            else if (donation.employeeName != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person_outline, size: 14, color: AppColors.neonCyan),
                    const SizedBox(width: 8),
                    Text(
                      'ASSIGNED TO: ${donation.employeeName?.toUpperCase()}',
                      style: GoogleFonts.orbitron(
                        fontSize: 9,
                        color: AppColors.neonCyan,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Icon(icon, size: 12, color: Colors.white38),
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

  Color _getStatusColor(DonationStatus status) {
    switch (status) {
      case DonationStatus.pending:
        return AppColors.neonAmber;
      case DonationStatus.assigned:
        return AppColors.neonCyan;
      case DonationStatus.pickedUp:
        return AppColors.neonPurple;
      case DonationStatus.delivered:
        return AppColors.neonGreen;
      default:
        return Colors.white54;
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
      child: CyberCard(
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.neonCyan.withValues(alpha: 0.1),
                border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.3)),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: AppColors.neonCyan),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employee.name.toUpperCase(),
                    style: GoogleFonts.orbitron(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    employee.email.toUpperCase(),
                    style: GoogleFonts.orbitron(
                      fontSize: 10,
                      color: Colors.white38,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.neonGreen.withValues(alpha: 0.1),
                border: Border.all(color: AppColors.neonGreen.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'ACTIVE',
                style: GoogleFonts.orbitron(
                  fontSize: 8,
                  color: AppColors.neonGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.1, end: 0);
  }
}

void _showAssignDialog(BuildContext context, DonationModel donation) {
  showDialog(
    context: context,
    builder: (context) {
      return Consumer<LogisticsProvider>(
        builder: (context, provider, _) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: CyberCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ASSIGN OPERATIVE',
                    style: AppTextStyles.hitechHeading.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'SELECT UNIT FOR TASK #${donation.id.substring(0, 8).toUpperCase()}',
                    style: GoogleFonts.orbitron(
                      fontSize: 10,
                      color: AppColors.neonCyan,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (provider.employees.isEmpty)
                    Center(
                      child: Text(
                        'NO OPERATIVES AVAILABLE',
                        style: GoogleFonts.orbitron(fontSize: 12, color: Colors.white24),
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: provider.employees.length,
                        itemBuilder: (context, index) {
                          final employee = provider.employees[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
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
                                    backgroundColor: AppColors.neonCyan,
                                    content: Text(
                                      'TASK ASSIGNED TO ${employee.name.toUpperCase()}',
                                      style: GoogleFonts.orbitron(
                                        color: Colors.black,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              leading: CircleAvatar(
                                backgroundColor: AppColors.neonCyan.withValues(alpha: 0.1),
                                child: const Icon(Icons.person, size: 16, color: AppColors.neonCyan),
                              ),
                              title: Text(
                                employee.name.toUpperCase(),
                                style: GoogleFonts.orbitron(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'READY',
                                style: GoogleFonts.orbitron(
                                  fontSize: 8,
                                  color: AppColors.neonGreen,
                                ),
                              ),
                              trailing: const Icon(Icons.chevron_right, color: Colors.white24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                                side: const BorderSide(color: Colors.white10),
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
                      child: Text(
                        'ABORT',
                        style: GoogleFonts.orbitron(
                          color: Colors.white54,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
        title: 'RECRUIT OPERATIVE',
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
