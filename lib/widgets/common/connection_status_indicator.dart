import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/connection_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme/app_colors.dart';

class ConnectionStatusIndicator extends StatelessWidget {
  const ConnectionStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final isOnline = context.watch<ConnectionProvider>().isOnline;
    final dbOnline = context.watch<AuthProvider>().dbOnline;

    Color color;
    String message;

    if (!isOnline) {
      color = AppColors.error;
      message = 'Network Offline';
    } else if (!dbOnline) {
      color = AppColors.warning;
      message = 'Database Syncing...';
    } else {
      color = AppColors.success;
      message = 'System Live';
    }

    return Tooltip(
      message: message,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.6),
              blurRadius: 6,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}

