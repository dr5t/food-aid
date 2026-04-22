import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_spacing.dart';
import '../../models/donation_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/logistics_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/admin/create_employee_dialog.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Logistics Hub',
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
          _UnassignedTab(),
          _EmployeesTab(),
        ],
      ),
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
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Unassigned',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined),
            activeIcon: Icon(Icons.group),
            label: 'Employees',
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// OVERVIEW
// ═══════════════════════════════════════════════════════════════════

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
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(
          '${user?.organizationName ?? 'Company'} 🚚',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage deliveries and employees',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Unassigned',
                value: '${provider.unassignedDonations.length}',
                icon: Icons.assignment_outlined,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _StatCard(
                label: 'Active',
                value: '$active',
                icon: Icons.local_shipping_outlined,
                color: AppColors.info,
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
                label: 'Employees',
                value: '${provider.employees.length}',
                icon: Icons.group_outlined,
                color: AppColors.statusAssigned,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.xl),
        Text(
          'Active Deliveries',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        ...provider.companyDonations
            .where((d) => d.isActive)
            .take(5)
            .map((d) => _DeliveryTile(donation: d)),

        if (provider.companyDonations.where((d) => d.isActive).isEmpty)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Center(
              child: Text(
                'No active deliveries',
                style: GoogleFonts.inter(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// UNASSIGNED DONATIONS TAB
// ═══════════════════════════════════════════════════════════════════

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
    final user = context.read<AuthProvider>().user;

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assign Employee',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (provider.employees.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Center(
                    child: Text(
                      'No employees registered yet',
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                )
              else
                ...provider.employees.map((e) => ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: Text(
                          e.initials,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      title: Text(e.name),
                      subtitle: Text(e.phone.isNotEmpty
                          ? e.phone
                          : e.email),
                      onTap: () async {
                        if (user != null) {
                          await provider.assignEmployee(
                            donation.id,
                            user.uid,
                            user.organizationName ?? user.name,
                            e.uid,
                            e.name,
                          );
                        }
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                    )),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// EMPLOYEES TAB
// ═══════════════════════════════════════════════════════════════════

class _EmployeesTab extends StatelessWidget {
  const _EmployeesTab();

  @override
  Widget build(BuildContext context) {
    final employees = context.watch<LogisticsProvider>().employees;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
          // Header info
          Container(
            margin: const EdgeInsets.all(AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Row(
              children: [
                Icon(Icons.people_alt_rounded, size: 20, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Create employee accounts to assign deliveries. '
                    'Credentials are generated automatically.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: employees.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.group_add_outlined, size: 48,
                            color: isDark
                                ? AppColors.darkTextHint
                                : AppColors.textHint),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'No employees yet',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap + to create your first employee account',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.darkTextHint
                                : AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md),
                    itemCount: employees.length,
                    itemBuilder: (_, i) {
                      final e = employees[i];
                      return Card(
                        margin:
                            const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.1),
                            child: Text(
                              e.initials,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          title: Text(
                            e.name,
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            e.email,
                            style: GoogleFonts.inter(fontSize: 12),
                          ),
                          trailing: Icon(Icons.chevron_right,
                              color: isDark
                                  ? AppColors.darkTextHint
                                  : AppColors.textHint),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateEmployeeDialog(context),
        child: const Icon(Icons.person_add),
      ),
    );
  }

  void _showCreateEmployeeDialog(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.user;
    final authService = AuthService();

    showDialog(
      context: context,
      builder: (ctx) => CreateEmployeeDialog(
        title: 'Create Delivery Partner',
        targetRole: UserRole.logisticsEmployee,
        onCreateEmployee: ({
          required String name,
          required String email,
          required String password,
          String phone = '',
        }) =>
            authService.createUserWithCredentials(
          name: name,
          email: email,
          password: password,
          role: UserRole.logisticsEmployee,
          createdByUid: currentUser?.uid ?? '',
          companyId: currentUser?.uid,
          organizationName: currentUser?.organizationName,
          phone: phone,
        ),
      ),
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

class _DeliveryTile extends StatelessWidget {
  final DonationModel donation;

  const _DeliveryTile({required this.donation});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: const Icon(Icons.local_shipping,
              color: AppColors.info, size: 20),
        ),
        title: Text(
          donation.title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          donation.employeeName ?? 'Unassigned',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
        trailing: Text(
          donation.statusLabel,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.statusInTransit,
          ),
        ),
      ),
    );
  }
}
