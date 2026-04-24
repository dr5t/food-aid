import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_spacing.dart';
import '../../config/theme/app_text_styles.dart';
import '../../models/user_model.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/admin/create_employee_dialog.dart';
import '../../widgets/common/app_app_bar.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/app_loader.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().startListening();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppAppBar(
        title: authProvider.user?.role == UserRole.superAdmin
            ? 'Super Admin Dashboard'
            : 'Admin Dashboard',
        actions: [
          IconButton(
            onPressed: () => context.read<AdminProvider>().refreshStats(),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') authProvider.signOut();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text('Sign Out', style: AppTextStyles.label),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: isDark ? Colors.black : Colors.white,
            child: TabBar(
              controller: _tabController,
              labelStyle: AppTextStyles.label.copyWith(
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: AppTextStyles.label,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: [
                const Tab(text: 'Overview'),
                Tab(
                  child: Consumer<AdminProvider>(
                    builder: (_, admin, _) {
                      final count = admin.pendingCount;
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Verifications'),
                          if (count > 0) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                '$count',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ),
                const Tab(text: 'Team'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _OverviewTab(isDark: isDark),
                _VerificationsTab(isDark: isDark),
                _TeamTab(
                  isDark: isDark,
                  adminUid: authProvider.user?.uid ?? '',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final bool isDark;
  const _OverviewTab({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final authProvider = context.watch<AuthProvider>();
    final stats = admin.platformStats;

    if (admin.isLoading && stats.isEmpty) {
      return const Center(child: AppLoader(text: 'Updating statistics...'));
    }

    return RefreshIndicator(
      onRefresh: () => admin.refreshStats(),
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text(
            authProvider.user?.role == UserRole.superAdmin
                ? 'Administrator Console'
                : 'System Overview',
            style: AppTextStyles.heading,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Platform Management & Monitoring',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          if (authProvider.user?.role == UserRole.superAdmin)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.security_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SUPER ADMIN SESSION',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Root access active for ${authProvider.user?.name}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'ROOT',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.md),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
            childAspectRatio: 1.55,
            children: [
              _StatCard(
                icon: Icons.people_rounded,
                label: 'Total Users',
                value: '${stats['totalUsers'] ?? 0}',
                color: Colors.blue,
                isDark: isDark,
              ),
              _StatCard(
                icon: Icons.pending_actions_rounded,
                label: 'Pending',
                value: '${stats['pendingVerifications'] ?? 0}',
                color: Colors.orange,
                isDark: isDark,
              ),
              _StatCard(
                icon: Icons.volunteer_activism_rounded,
                label: 'Donations',
                value: '${stats['totalDonations'] ?? 0}',
                color: AppColors.primary,
                isDark: isDark,
              ),
              _StatCard(
                icon: Icons.check_circle_rounded,
                label: 'Delivered',
                value: '${stats['completedDonations'] ?? 0}',
                color: Colors.teal,
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          Text(
            'User Breakdown',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _RoleRow(
            label: 'Donors',
            count: stats['donors'] ?? 0,
            icon: Icons.favorite_rounded,
            color: Colors.red,
            isDark: isDark,
          ),
          _RoleRow(
            label: 'NGOs',
            count: stats['ngos'] ?? 0,
            icon: Icons.business_rounded,
            color: Colors.blue,
            isDark: isDark,
          ),
          _RoleRow(
            label: 'Logistics Companies',
            count: stats['companies'] ?? 0,
            icon: Icons.local_shipping_rounded,
            color: Colors.orange,
            isDark: isDark,
          ),
          _RoleRow(
            label: 'Delivery Partners',
            count: stats['employees'] ?? 0,
            icon: Icons.delivery_dining_rounded,
            color: Colors.purple,
            isDark: isDark,
          ),
          _RoleRow(
            label: 'Team Members',
            count: stats['admins'] ?? 0,
            icon: Icons.admin_panel_settings_rounded,
            color: Colors.indigo,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      color: color.withValues(alpha: 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const Spacer(),
          Text(value, style: AppTextStyles.heading),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _RoleRow extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _RoleRow({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(label, style: AppTextStyles.titleSmall)),
          Text(
            '$count',
            style: AppTextStyles.titleMedium.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _VerificationsTab extends StatelessWidget {
  final bool isDark;
  const _VerificationsTab({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final pending = admin.pendingVerifications;

    if (admin.isLoading && pending.isEmpty) {
      return const Center(child: AppLoader(text: 'Loading verifications...'));
    }

    if (pending.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.verified_rounded,
              size: 64,
              color: AppColors.primary.withValues(alpha: 0.2),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('All Caught Up', style: AppTextStyles.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text('No pending verifications', style: AppTextStyles.bodySmall),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: pending.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final user = pending[index];
        return _VerificationCard(
          user: user,
          isDark: isDark,
          onApprove: () => admin.approveUser(user.uid),
          onReject: () => _showRejectDialog(context, admin, user.uid),
        );
      },
    );
  }

  void _showRejectDialog(
    BuildContext context,
    AdminProvider admin,
    String uid,
  ) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          'Reject Registration',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Reason for rejection...',
            hintStyle: GoogleFonts.inter(fontSize: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter()),
          ),
          FilledButton(
            onPressed: () {
              admin.rejectUser(uid, controller.text.trim());
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              'Reject',
              style: GoogleFonts.inter(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerificationCard extends StatelessWidget {
  final UserModel user;
  final bool isDark;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _VerificationCard({
    required this.user,
    required this.isDark,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final isNgo = user.role == UserRole.ngo;
    final accentColor = isNgo ? AppColors.primary : Colors.orange;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: accentColor.withValues(alpha: 0.1),
                child: Icon(
                  isNgo ? Icons.business_rounded : Icons.local_shipping_rounded,
                  color: accentColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.organizationName ?? user.name,
                      style: AppTextStyles.titleSmall,
                    ),
                    Text(user.roleLabel, style: AppTextStyles.caption),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'PENDING',
                  style: AppTextStyles.overline.copyWith(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          _detailRow(Icons.person_outline, user.name),
          _detailRow(Icons.email_outlined, user.email),
          if (user.phone.isNotEmpty)
            _detailRow(Icons.phone_outlined, user.phone),

          const SizedBox(height: AppSpacing.md),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Reject'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ElevatedButton(
                  onPressed: onApprove,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Approve'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamTab extends StatelessWidget {
  final bool isDark;
  final String adminUid;
  const _TeamTab({required this.isDark, required this.adminUid});

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final employees = admin.adminEmployees;

    return Scaffold(
      body: employees.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.group_add_rounded,
                    size: 64,
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No Team Members',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Tap + to create admin employee accounts',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: employees.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final emp = employees[index];
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.1,
                        ),
                        child: Text(
                          emp.initials,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              emp.name,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              emp.email,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Admin',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: Text(
          'Add Employee',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final admin = context.read<AdminProvider>();
    showDialog(
      context: context,
      builder: (ctx) => CreateEmployeeDialog(
        title: 'Create Admin Employee',
        targetRole: UserRole.admin,
        onCreateEmployee:
            ({
              required String name,
              required String email,
              required String password,
              String? phone = '',
            }) => admin.createAdminEmployee(
              name: name,
              email: email,
              password: password,
              createdByUid: adminUid,
              phone: phone ?? '',
            ),
      ),
    );
  }
}
