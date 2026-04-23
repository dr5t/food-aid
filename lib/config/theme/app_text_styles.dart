import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get heading => GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  static TextStyle get headingLarge => GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        height: 1.2,
        letterSpacing: -0.5,
      );

  static TextStyle get neonGlow => GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w900,
        color: AppColors.neonCyan,
        shadows: [
          Shadow(
            color: AppColors.neonCyan.withOpacity(0.5),
            blurRadius: 10,
          ),
          Shadow(
            color: AppColors.neonPurple.withOpacity(0.3),
            blurRadius: 20,
          ),
        ],
      );

  static TextStyle get hitech => GoogleFonts.orbitron(
        fontSize: 28,
        fontWeight: FontWeight.w900,
        color: AppColors.neonCyan,
        letterSpacing: 4,
        shadows: [
          Shadow(
            color: AppColors.neonCyan.withOpacity(0.8),
            blurRadius: 10,
          ),
          Shadow(
            color: AppColors.neonPurple.withOpacity(0.5),
            blurRadius: 20,
          ),
        ],
      );
  
  static TextStyle get hitechSmall => GoogleFonts.orbitron(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.neonCyan,
        letterSpacing: 2,
      );

  static TextStyle get subheading => GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  static TextStyle get body => GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  static TextStyle get caption => GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  static TextStyle get button => GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.0,
      );

  static TextStyle get buttonSmall => GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.0,
      );

  static TextStyle get label => GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  static TextStyle get overline => GoogleFonts.outfit(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 1.2,
        height: 1.4,
      );
}

