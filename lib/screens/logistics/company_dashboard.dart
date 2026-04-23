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
                color: AppColors.neonCyan.withOpacity(0.05),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'HUB',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'TASKS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined),
            activeIcon: Icon(Icons.group),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (provider.unassignedDonations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 56,
                color: isDark
                    ? AppColors.darkTextHint
                    : AppColors.textHint),
            const SizedBox(height: AppSpacing.md),
            Text(
              'All donations are assigned',
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
      itemCount: provider.unassignedDonations.length,
      itemBuilder: (_, i) {
        final d = provider.unassignedDonations[i];
        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d.title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'From: ${d.donorName} → To: ${d.ngoName ?? "NGO"}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        d.pickupAddress,
                        style: GoogleFonts.inter(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showAssignDialog(context, d),
                    child: const Text('Assign Employee'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAssignDialog(BuildContext context, DonationModel donation) {
    final provider = context.read<LogisticsProvider>();
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
                                  provider.assignEmployee(donation.id, employee);
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
                                  backgroundColor: AppColors.neonCyan.withOpacity(0.1),
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
}


class _EmployeesTab extends StatelessWidget {
  const _EmployeesTab();

  @override
  Widget build(BuildContext context) {
    final employees = context.watch<LogisticsProvider>().employees;

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Text('OPERATIVE NETWORK', style: AppTextStyles.hitechHeading),
                const Spacer(),
                Text('${employees.length} ACTIVE', style: GoogleFonts.orbitron(fontSize: 10, color: AppColors.neonGreen)),
              ],
            ),
          ),
          Expanded(
            child: employees.isEmpty
                ? Center(child: Text('NO OPERATIVES FOUND', style: GoogleFonts.orbitron(color: Colors.white24)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    itemCount: employees.length,
                    itemBuilder: (_, i) => _EmployeeTile(employee: employees[i]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateEmployeeDialog(context),
        backgroundColor: AppColors.neonCyan,
        child: const Icon(Icons.person_add, color: Colors.black),
      ),
    );
  }

  void _showCreateEmployeeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateEmployeeDialog(),
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
              color: color.withOpacity(0.7),
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
}
