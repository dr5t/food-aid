import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme/app_colors.dart';

class NeonIndicator extends StatelessWidget {
  final Color color;
  final double size;
  final bool isAnimated;

  const NeonIndicator({
    super.key,
    this.color = AppColors.neonCyan,
    this.size = 8,
    this.isAnimated = true,
  });

  @override
  Widget build(BuildContext context) {
    final widget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.8),
            blurRadius: size * 1.5,
            spreadRadius: size * 0.2,
          ),
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: size * 3,
            spreadRadius: size * 0.5,
          ),
        ],
      ),
    );

    if (!isAnimated) return widget;

    return widget.animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          duration: 1.seconds,
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.2, 1.2),
          curve: Curves.easeInOut,
        )
        .shimmer(
          duration: 2.seconds,
          color: Colors.white.withOpacity(0.5),
        );
  }
}
