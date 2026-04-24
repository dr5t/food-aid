import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/emergency_request_model.dart';
import '../../providers/emergency_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/app_app_bar.dart';
import '../../widgets/common/app_background.dart';

class SOSRequestsScreen extends StatefulWidget {
  const SOSRequestsScreen({super.key});

  @override
  State<SOSRequestsScreen> createState() => _SOSRequestsScreenState();
}

class _SOSRequestsScreenState extends State<SOSRequestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmergencyProvider>().listenOpenRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmergencyProvider>();
    final requests = provider.openRequests;

    return Scaffold(
      appBar: const AppAppBar(title: 'Active SOS Alerts'),
      body: AppBackground(
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : requests.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          size: 64,
                          color: AppColors.primary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Active Emergencies',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Everything seems to be under control.',
                          style: GoogleFonts.inter(
                            color: AppColors.textSecondary.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final request = requests[index];
                      return _SOSRequestCard(request: request);
                    },
                  ),
      ),
    );
  }
}

class _SOSRequestCard extends StatelessWidget {
  final EmergencyRequestModel request;

  const _SOSRequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    request.ngoName,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'CRITICAL',
                    style: GoogleFonts.orbitron(
                      color: AppColors.error,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.location_on_rounded,
              text: request.ngoAddress,
              color: AppColors.primary,
            ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.restaurant_rounded,
              text: 'Needs ${request.quantity} ${request.mealTypeLabel} meals',
              color: AppColors.neonAmber,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  try {
                    await context.read<EmergencyProvider>().donorAcceptRequest(
                          request.id,
                          user.uid,
                          user.name,
                        );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Thank you! Your help is on the way.'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.volunteer_activism_rounded),
                label: const Text('I CAN HELP'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
