import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF10B981); // Emerald Green
  static const Color primaryLight = Color(0xFF34D399);
  static const Color primaryDark = Color(0xFF059669);

  static const Color accent = Color(0xFF3498DB);
  static const Color secondary = accent;

  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F3F4);

  static const Color textPrimary = Color(0xFF1A1C1E);
  static const Color textSecondary = Color(0xFF5F6368);
  static const Color textHint = Color(0xFF70757A);

  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = Color(0xFFE8EAED);
  static const Color darkTextSecondary = Color(0xFFBDC1C6);
  static const Color darkDivider = Color(0xFF3C4043);

  static const Color error = Color(0xFFD93025);
  static const Color success = Color(0xFF1E8E3E);
  static const Color warning = Color(0xFFF9AB00);
  static const Color info = Color(0xFF1A73E8);

  static const Color successLight = Color(0xFFE6F4EA);
  static const Color warningLight = Color(0xFFFEF7E0);
  static const Color infoLight = Color(0xFFE8F0FE);
  static const Color errorLight = Color(0xFFFCE8E6);

  static const Color divider = Color(0xFFDADCE0);

  // Skeleton Colors
  static const Color skeleton1 = Color(0xFFEEEEEE);
  static const Color skeleton2 = Color(0xFFF5F5F5);
  static const Color darkSkeleton1 = Color(0xFF2C2C2C);
  static const Color darkSkeleton2 = Color(0xFF383838);

  // Status Colors
  static const Color statusPending = warning;
  static const Color statusAccepted = info;
  static const Color statusAssigned = Color(0xFF673AB7);
  static const Color statusPicked = Color(0xFF00BCD4);
  static const Color statusInTransit = Color(0xFF009688);
  static const Color statusNearLocation = Color(0xFF8BC34A);
  static const Color statusDelivered = success;
  static const Color statusRejected = error;
  static const Color statusExpired = textHint;

  // Additional Brand Colors
  static const Color accentDark = Color(0xFF2980B9);
  static const Color neonAmber = Color(0xFFFFB300);
  static const Color darkTextHint = Color(0xFF80868B);
  static const Color darkBg = darkBackground;
}
