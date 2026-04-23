import 'dart:ui';
import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';

class CyberCard extends StatelessWidget {
  final Widget child;
  final Color? borderColor;
  final double borderRadius;
  final bool showGlow;
  final bool showCorners;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Gradient? backgroundGradient;
  final Color? glowColor;

  const CyberCard({
    super.key,
    required this.child,
    this.borderColor,
    this.borderRadius = 16,
    this.showGlow = false,
    this.showCorners = true,
    this.padding,
    this.margin,
    this.backgroundGradient,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundGradient != null ? null : (isDark ? AppColors.darkSurface : theme.cardTheme.color),
        gradient: backgroundGradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05)),
          width: 1,
        ),
        boxShadow: (showGlow || glowColor != null) ? [
          BoxShadow(
            color: (glowColor ?? AppColors.primary).withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          )
        ] : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

