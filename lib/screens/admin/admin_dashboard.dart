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
  late AnimationController _refreshController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _refreshController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().startListening();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Ann Seva Style
    const emeraldGreen = Color(0xFF10B981);
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

    final admin = context.watch<AdminProvider>();
    
    if (admin.isLoading) {
      if (!_refreshController.isAnimating) _refreshController.repeat();
    } else {
      if (_refreshController.isAnimating) {
        _refreshController.stop();
        _refreshController.reset();
      }
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppAppBar(
        backgroundColor: bgColor,
        title: authProvider.user?.role == UserRole.superAdmin
            ? 'Super Admin'
            : 'Admin Console',
        actions: [
          IconButton(
            onPressed: () => context.read<AdminProvider>().refreshStats(),
            icon: RotationTransition(
              turns: _refreshController,
              child: const Icon(Icons.refresh_rounded, color: Color(0xFF64748B)),
            ),
            tooltip: 'Refresh',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF64748B)),
            onSelected: (value) {
              if (value == 'logout') authProvider.signOut();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout_rounded, size: 20, color: Colors.redAccent),
                    const SizedBox(width: 8),
                    Text('Sign Out', style: GoogleFonts.inter(color: Colors.redAccent)),
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
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
            ),
            child: TabBar(
              controller: _tabController,
              labelStyle: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              unselectedLabelStyle: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              indicatorColor: emeraldGreen,
              labelColor: emeraldGreen,
              unselectedLabelColor: const Color(0xFF64748B),
              indicatorSize: TabBarIndicatorSize.label,
              indicatorPadding: const EdgeInsets.symmetric(vertical: 8),
              dividerColor: Colors.transparent,
              tabs: [
                const Tab(text: 'Overview'),
                Tab(
                  child: Consumer<AdminProvider>(
                    builder: (_, admin, _) {
                      final count = admin.pendingCount;
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Requests'),
                          if (count > 0) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.redAccent,
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
    const emeraldGreen = Color(0xFF10B981);

    if (admin.isLoading && stats.isEmpty) {
      return const Center(child: AppLoader(text: 'Updating statistics...'));
    }

    return RefreshIndicator(
      onRefresh: () => admin.refreshStats(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.xl),
        children: [
          if (authProvider.user?.role == UserRole.superAdmin)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: emeraldGreen.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(Icons.shield_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Super Admin Session',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Full system access active',
                          style: GoogleFonts.inter(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 13,
                          ),
                        ),
                      ],
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
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _StatCard(
                icon: Icons.people_rounded,
                label: 'Total Users',
                value: '${stats['totalUsers'] ?? 0}',
                color: emeraldGreen,
                isDark: isDark,
              ),
              _StatCard(
                icon: Icons.pending_actions_rounded,
                label: 'New Requests',
                value: '${stats['pendingVerifications'] ?? 0}',
                color: const Color(0xFFF59E0B), // Amber for pending
                isDark: isDark,
              ),
              _StatCard(
                icon: Icons.volunteer_activism_rounded,
                label: 'Donations',
                value: '${stats['totalDonations'] ?? 0}',
                color: const Color(0xFF6366F1), // Indigo
                isDark: isDark,
              ),
              _StatCard(
                icon: Icons.check_circle_rounded,
                label: 'Success Rate',
                value: '${stats['completedDonations'] ?? 0}',
                color: const Color(0xFF06B6D4), // Cyan
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 24),

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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
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
          onApprove: () async {
            final ok = await admin.approveUser(user.uid);
            if (ok && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('User approved. Confirmation email sent to ${user.email}'),
                  backgroundColor: AppColors.primary,
                ),
              );
            } else if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(admin.error ?? 'Approval failed'),
                  backgroundColor: Colors.red,
                ),
              );
              admin.clearError();
            }
          },
          onReject: () => _showRejectDialog(context, admin, user),
        );
      },
    );
  }

  void _showRejectDialog(
    BuildContext context,
    AdminProvider admin,
    UserModel user,
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
            onPressed: () async {
              final ok = await admin.rejectUser(user.uid, controller.text.trim());
              if (ok && context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Registration rejected for ${user.email}')),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(admin.error ?? 'Rejection failed'),
                    backgroundColor: Colors.red,
                  ),
                );
                admin.clearError();
              }
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
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                        onPressed: () => _showDeleteConfirm(context, admin, emp),
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

  void _showDeleteConfirm(BuildContext context, AdminProvider admin, UserModel user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Team Member?'),
        content: Text('Are you sure you want to remove ${user.name} from the team?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final ok = await admin.deleteUser(user.uid);
              if (ok && context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Team member removed')),
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
}
