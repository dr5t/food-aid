import 'package:flutter/material.dart';

class AppColors {
  AppColors._();


  static const Color primary = Color(0xFF4CAF50);
  static const Color primaryLight = Color(0xFF81C784);
  static const Color primaryDark = Color(0xFF388E3C);

  static const Color accent = Color(0xFFFF9800);
  static const Color accentLight = Color(0xFFFFB74D);
  static const Color accentDark = Color(0xFFF57C00);

  static const Color background = Color(0xFFF7F7F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F0F0);

  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);


  static const Color darkBackground = Color(0xFF000000); // True Black
  static const Color darkSurface = Color(0xFF050505);
  static const Color darkSurfaceVariant = Color(0xFF0A0A0A);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF888888);
  static const Color darkTextHint = Color(0xFF444444);
  static const Color darkDivider = Color(0xFF111111);
  static const Color darkPrimary = Color(0xFF00E5FF); // Neon Cyan
  static const Color darkAccent = Color(0xFFD500F9); // Neon Purple


  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color success = Color(0xFF43A047);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFFFA726);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color info = Color(0xFF29B6F6);
  static const Color infoLight = Color(0xFFE1F5FE);

  static const Color divider = Color(0xFFE0E0E0);
  static const Color disabled = Color(0xFFBDBDBD);

  static const Color skeleton1 = Color(0xFFE0E0E0);
  static const Color skeleton2 = Color(0xFFF0F0F0);
  static const Color darkSkeleton1 = Color(0xFF111111);
  static const Color darkSkeleton2 = Color(0xFF1A1A1A);


  static const Color statusPending = Color(0xFFFFA726);
  static const Color statusAccepted = Color(0xFF42A5F5);
  static const Color statusAssigned = Color(0xFF7E57C2);
  static const Color statusPicked = Color(0xFF26C6DA);
  static const Color statusInTransit = Color(0xFF26A69A);
  static const Color statusNearLocation = Color(0xFF8BC34A);
  static const Color statusDelivered = Color(0xFF66BB6A);
  static const Color statusRejected = Color(0xFFEF5350);
  static const Color statusExpired = Color(0xFF9E9E9E);

  static const Color emergency = Color(0xFFFF1744);
  static const Color emergencyLight = Color(0xFFFF8A80);
  static const Color emergencyBg = Color(0xFFFFEBEE);

  // Neon Colors
  static const Color neonCyan = Color(0xFF00E5FF);
  static const Color neonPurple = Color(0xFFD500F9);
  static const Color neonPink = Color(0xFFFF00E5);
  static const Color neonGreen = Color(0xFF00FF41);
  static const Color neonBlue = Color(0xFF2979FF);
  static const Color neonOrange = Color(0xFFFF9100);
  static const Color neonAmber = Color(0xFFFFC400);

  // Glassmorphism Colors
  static Color glassBackground(Brightness brightness) => brightness == Brightness.dark
      ? Colors.white.withOpacity(0.03)
      : Colors.black.withOpacity(0.05);
  
  static Color glassBorder(Brightness brightness) => brightness == Brightness.dark
      ? Colors.white.withOpacity(0.08)
      : Colors.black.withOpacity(0.1);

  // Neon Gradients
  static const LinearGradient neonGradient = LinearGradient(
    colors: [neonCyan, neonPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyberGradient = LinearGradient(
    colors: [neonPurple, neonPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dehradunMist = LinearGradient(
    colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyberSaffron = LinearGradient(
    colors: [Color(0xFFFF9933), Color(0xFFFF00E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [neonOrange, neonPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient fireGradient = LinearGradient(
    colors: [Color(0xFFFF512F), Color(0xFFDD2476)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient oceanGradient = LinearGradient(
    colors: [Color(0xFF2193B0), Color(0xFF6DD5ED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient neonCyanGradient = LinearGradient(
    colors: [Color(0xFF00E5FF), Color(0xFF00B8D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient neonPurpleGradient = LinearGradient(
    colors: [Color(0xFFD500F9), Color(0xFFAA00FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient neonGreenGradient = LinearGradient(
    colors: [Color(0xFF00FF41), Color(0xFF00C853)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient neonPinkGradient = LinearGradient(
    colors: [Color(0xFFFF00E5), Color(0xFFC51162)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient neonBlueGradient = LinearGradient(
    colors: [Color(0xFF2979FF), Color(0xFF1565C0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient neonAmberGradient = LinearGradient(
    colors: [Color(0xFFFFC400), Color(0xFFFFAB00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const List<BoxShadow> neonGlow = [
    BoxShadow(
      color: neonCyan,
      blurRadius: 10,
      spreadRadius: 1,
    ),
  ];

  static List<BoxShadow> customGlow(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.3),
      blurRadius: 12,
      spreadRadius: 2,
    ),
  ];
}
