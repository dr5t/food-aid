import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';

class AppLoader extends StatelessWidget {
  final double size;
  final Color? color;
  final String? text;

  const AppLoader({
    super.key,
    this.size = 24,
    this.color,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = color ?? AppColors.primary;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            strokeWidth: 2,
          ),
        ),
        if (text != null) ...[
          const SizedBox(height: 12),
          Text(
            text!,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
