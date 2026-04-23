import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../config/theme/app_spacing.dart';

class AppInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled;
  final TextInputAction? textInputAction;

  const AppInput({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              label!.toUpperCase(),
              style: AppTextStyles.label.copyWith(
                fontSize: 10,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.neonCyan.withValues(alpha: 0.7) : AppColors.primary.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: isDark ? [
              BoxShadow(
                color: AppColors.neonCyan.withValues(alpha: 0.03),
                blurRadius: 15,
                spreadRadius: -5,
              ),
            ] : null,
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: validator,
            onChanged: onChanged,
            enabled: enabled,
            textInputAction: textInputAction,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
            decoration: InputDecoration(
              hintText: hint,
              errorText: errorText,
              prefixIcon: prefixIcon != null
                  ? Icon(
                      prefixIcon, 
                      size: 20, 
                      color: isDark ? AppColors.neonCyan.withValues(alpha: 0.8) : AppColors.primary.withValues(alpha: 0.8),
                    )
                  : null,
              suffixIcon: suffix,
            ),
          ),
        ),
      ],
    );
  }
}
