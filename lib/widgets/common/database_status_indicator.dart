import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';

class DatabaseStatusIndicator extends StatelessWidget {
  const DatabaseStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final dbOnline = context.watch<AuthProvider>().dbOnline;
    final color = dbOnline ? AppColors.success : AppColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            dbOnline ? 'Online' : 'Offline',
            style: AppTextStyles.caption.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
