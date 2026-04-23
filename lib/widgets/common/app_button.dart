import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_spacing.dart';

import '../animations/scale_tap.dart';
import 'hitech_loader.dart';

enum AppButtonVariant { primary, secondary, outlined, text }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double? height;
  final TextStyle? textStyle;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final child = _buildButton();

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        height: height ?? 52,
        child: child,
      );
    }

    return SizedBox(height: height ?? 52, child: child);
  }

  Widget _buildButton() {
    final buttonChild = isLoading
        ? const HitechLoader(size: 24, color: Colors.white)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                AppSpacing.horizontalSm,
              ],
              Text(
                label,
                style: const TextStyle(letterSpacing: 0.5).merge(textStyle),
              ),
            ],
          );

    switch (variant) {
      case AppButtonVariant.primary:
        return ScaleTap(
          onTap: isLoading ? null : onPressed,
          child: Container(
            decoration: BoxDecoration(
              gradient: AppColors.neonGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonCyan.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.black,
                elevation: 0,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  fontSize: 13,
                ),
              ),
              child: buttonChild,
            ),
          ),
        );
      case AppButtonVariant.secondary:
        return ScaleTap(
          onTap: isLoading ? null : onPressed,
          child: Container(
            decoration: BoxDecoration(
              gradient: AppColors.cyberGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonPurple.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  fontSize: 13,
                ),
              ),
              child: buttonChild,
            ),
          ),
        );
      case AppButtonVariant.outlined:
        return ScaleTap(
          onTap: isLoading ? null : onPressed,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.5), width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: buttonChild,
          ),
        );
      case AppButtonVariant.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          child: buttonChild,
        );
    }
  }
}
