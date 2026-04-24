import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF1B5E20); // Deep Forest Green
  static const Color primaryLight = Color(0xFF4C8C4A);
  static const Color primaryDark = Color(0xFF003308);

  static const Color accent = Color(0xFF2E7D32); // Emerald Accent
  static const Color secondary = accent;
  static const Color accentLight = Color(0xFF60AD5E);
  static const Color accentDark = Color(0xFF005005);

  static const Color background = Color(0xFFF8F9FA); // Light Grey/White
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F3F4);

  static const Color textPrimary = Color(0xFF1A1C1E);
  static const Color textSecondary = Color(0xFF44474E);
  static const Color textHint = Color(0xFF74777F);

  static const Color darkBackground = Color(0xFF111315); // Deep Slate
  static const Color darkBg = Color(0xFF111315);
  static const Color darkSurface = Color(0xFF1A1C1E);
  static const Color darkSurfaceVariant = Color(0xFF2D3033);
  static const Color darkTextPrimary = Color(0xFFE2E2E6);
  static const Color darkTextSecondary = Color(0xFFC4C6D0);
  static const Color darkTextHint = Color(0xFF8E9199);
  static const Color darkDivider = Color(0xFF44474E);
  static const Color darkPrimary = Color(
    0xFF81C784,
  ); // Muted Green for Dark Mode
  static const Color darkAccent = Color(0xFFA5D6A7);

  static const Color error = Color(0xFFBA1A1A);
  static const Color errorLight = Color(0xFFFFDAD6);
  static const Color success = Color(0xFF388E3C);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFF9A825);
  static const Color warningLight = Color(0xFFFFF9C4);
  static const Color neonAmber = Color(0xFFFFC107);
  static const Color info = Color(0xFF0288D1);
  static const Color infoLight = Color(0xFFE1F5FE);

  static const Color divider = Color(0xFFC4C6D0);
  static const Color disabled = Color(0xFFE2E2E6);

  static const Color skeleton1 = Color(0xFFE1E2E8);
  static const Color skeleton2 = Color(0xFFF1F3F4);
  static const Color darkSkeleton1 = Color(0xFF2D3033);
  static const Color darkSkeleton2 = Color(0xFF3E4246);

  static const Color statusPending = Color(0xFFF9A825);
  static const Color statusAccepted = Color(0xFF0288D1);
  static const Color statusAssigned = Color(0xFF6750A4);
  static const Color statusPicked = Color(0xFF006A6A);
  static const Color statusInTransit = Color(0xFF006874);
  static const Color statusNearLocation = Color(0xFF4E6602);
  static const Color statusDelivered = Color(0xFF388E3C);
  static const Color statusRejected = Color(0xFFBA1A1A);
  static const Color statusExpired = Color(0xFF74777F);

  static const Color emergency = Color(0xFFB3261E);
  static const Color emergencyLight = Color(0xFFF9DEDC);
  static const Color emergencyBg = Color(0xFFFFF1F0);

  // Simple Gradients for status or highlights (optional, kept subtle)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
