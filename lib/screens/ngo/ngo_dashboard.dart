import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_spacing.dart';
import '../../config/theme/app_text_styles.dart';
import '../../models/donation_model.dart';
import '../../models/emergency_request_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/donation_provider.dart';
import '../../providers/emergency_provider.dart';
import '../../widgets/common/app_app_bar.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/app_loader.dart';
import '../../widgets/common/app_bottom_nav_bar.dart';
import '../../widgets/common/empty_state.dart';

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
      backgroundColor: Theme.of(context).brightness == Brightness.dark 
          ? AppColors.darkBackground 
          : AppColors.background,
      appBar: AppAppBar(
        title: 'NGO Dashboard',
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
          _AvailableDonationsTab(),
          _MyEmergenciesTab(),
          _CompletedTab(),
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
            label: 'Overview',
          ),
          AppBottomNavItem(
            icon: Icons.inventory_2_outlined,
            activeIcon: Icons.inventory_2,
            label: 'Available',
          ),
          AppBottomNavItem(
            icon: Icons.warning_amber_outlined,
            activeIcon: Icons.warning,
            label: 'Emergencies',
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

  Widget _buildEmergencyFAB() {
    return FloatingActionButton.extended(
      onPressed: () => _showEmergencyDialog(),
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.emergency),
      label: const Text('New SOS'),
    );
  }

  void _showEmergencyDialog() {
    String selectedMealType = 'veg';
    final qtyController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Create Emergency Request'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Radio<String>(
                    value: 'veg',
                    groupValue: selectedMealType,
                    onChanged: (v) => setDialogState(() => selectedMealType = v!),
                  ),
                  const Text('Veg'),
                  Radio<String>(
                    value: 'nonVeg',
                    groupValue: selectedMealType,
                    onChanged: (v) => setDialogState(() => selectedMealType = v!),
                  ),
                  const Text('Non-Veg'),
                ],
              ),
              TextField(
                controller: qtyController,
                decoration: const InputDecoration(labelText: 'Estimated Persons'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                final qty = int.tryParse(qtyController.text) ?? 0;
                if (qty > 0) {
                  final user = context.read<AuthProvider>().user;
                  if (user != null) {
                    final request = EmergencyRequestModel(
                      id: '',
                      ngoId: user.uid,
                      ngoName: user.organizationName ?? user.name,
                      mealType: selectedMealType,
                      quantity: qty,
                      ngoLocation: user.location ?? const GeoPoint(28.6139, 77.2090),
                      ngoAddress: user.address ?? 'Not specified',
                      status: EmergencyStatus.open,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    );
                    await context.read<EmergencyProvider>().createEmergencyRequest(request);
                    if (ctx.mounted) Navigator.pop(ctx);
                  }
                }
              },
              child: const Text('Broadcast SOS', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final stats = context.watch<DonationProvider>().ngoStats;
    
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome Back,',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
              ),
              Text(
                user?.organizationName ?? 'NGO',
                style: AppTextStyles.titleLarge.copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.5,
          children: [
            _StatCard(
              label: 'Received',
              value: '${stats['total'] ?? 0}',
              icon: Icons.inventory_2_rounded,
              color: AppColors.primary,
            ),
            _StatCard(
              label: 'Active',
              value: '${stats['active'] ?? 0}',
              icon: Icons.local_shipping_rounded,
              color: Colors.blue,
            ),
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
    final provider = context.watch<DonationProvider>();
    final pending = provider.pendingDonations;

    if (provider.isFetching && pending.isEmpty) return const Center(child: AppLoader());
    if (pending.isEmpty) {
      return const EmptyState(
        title: 'No Donations Available',
        message: 'Check back later for new food donations.',
        icon: Icons.no_food_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: pending.length,
      itemBuilder: (context, index) => _DonationCard(donation: pending[index]),
    );
  }
}

class _MyEmergenciesTab extends StatelessWidget {
  const _MyEmergenciesTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmergencyProvider>();
    final requests = provider.ngoRequests;

    if (provider.isLoading && requests.isEmpty) return const Center(child: AppLoader());
    if (requests.isEmpty) {
      return const EmptyState(
        title: 'No Active SOS',
        message: 'Your emergency requests will appear here.',
        icon: Icons.emergency_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: requests.length,
      itemBuilder: (context, index) => _EmergencyRequestCard(request: requests[index]),
    );
  }
}

class _CompletedTab extends StatelessWidget {
  const _CompletedTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DonationProvider>();
    final completed = provider.donations.where((d) => d.status == DonationStatus.delivered).toList();

    if (completed.isEmpty) {
      return const EmptyState(
        title: 'No Completed Tasks',
        message: 'Delivered food donations will appear here.',
        icon: Icons.history,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: completed.length,
      itemBuilder: (context, index) => _DonationCard(donation: completed[index]),
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
          Text(value, style: AppTextStyles.titleLarge),
          Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textHint)),
        ],
      ),
    );
  }
}

class _DonationCard extends StatelessWidget {
  final DonationModel donation;
  const _DonationCard({required this.donation});

  @override
  Widget build(BuildContext context) {
    final canAccept = donation.status == DonationStatus.pending;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(donation.mealTypeLabel.toUpperCase(), style: AppTextStyles.overline.copyWith(color: AppColors.primary)),
                Text('#${donation.id.substring(0, 5).toUpperCase()}', style: AppTextStyles.caption),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(donation.title, style: AppTextStyles.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: AppColors.textHint),
                const SizedBox(width: 4),
                Expanded(child: Text(donation.pickupAddress, style: AppTextStyles.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (canAccept)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final user = context.read<AuthProvider>().user;
                    if (user != null) {
                      context.read<DonationProvider>().acceptDonation(
                        donation.id, 
                        user.uid, 
                        user.organizationName ?? user.name,
                      );
                    }
                  },
                  child: const Text('Request Delivery'),
                ),
              )
            else
              Text('Status: ${donation.status.name}', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _EmergencyRequestCard extends StatelessWidget {
  final EmergencyRequestModel request;
  const _EmergencyRequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('SOS ACTIVE', style: AppTextStyles.overline.copyWith(color: Colors.red, fontWeight: FontWeight.bold)),
                Text(request.createdAt.toString().split(' ')[0], style: AppTextStyles.caption),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text('${request.quantity} Persons • ${request.mealTypeLabel}', style: AppTextStyles.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text('Status: ${request.statusLabel.toUpperCase()}', style: AppTextStyles.bodySmall.copyWith(color: Colors.orange)),
            const SizedBox(height: AppSpacing.md),
            if (request.isOpen)
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => context.read<EmergencyProvider>().cancelRequest(request.id),
                  child: const Text('Cancel Request', style: TextStyle(color: Colors.red)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
