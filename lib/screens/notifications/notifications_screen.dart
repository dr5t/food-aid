import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../widgets/common/app_app_bar.dart';
import '../../widgets/common/empty_state.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppAppBar(title: 'Notifications'),
      body: const EmptyState(
        icon: Icons.notifications_none_rounded,
        title: 'No notifications',
        subtitle: 'You\'re all caught up! Notifications will appear here.',
      ),
    );
  }
}
