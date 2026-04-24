import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';

class NeonIndicator extends StatelessWidget {
  final Color color;
  final double size;
  final bool isAnimated;

  const NeonIndicator({
    super.key,
    this.color = AppColors.primary,
    this.size = 8,
    this.isAnimated = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
