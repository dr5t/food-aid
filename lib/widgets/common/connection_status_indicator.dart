import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/connection_provider.dart';
import '../../config/theme/app_colors.dart';

class ConnectionStatusIndicator extends StatelessWidget {
  const ConnectionStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final isOnline = context.watch<ConnectionProvider>().isOnline;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isOnline ? AppColors.success : AppColors.error,
        boxShadow: [
          BoxShadow(
            color: (isOnline ? AppColors.success : AppColors.error).withOpacity(0.5),
            blurRadius: 4,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}
