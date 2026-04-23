import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme/app_colors.dart';

class CyberAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBottomBorder;

  const CyberAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBottomBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.neonCyan : AppColors.primary;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: leading,
      title: Text(
        title.toUpperCase(),
        style: GoogleFonts.orbitron(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: isDark ? Colors.white : AppColors.textPrimary,
          letterSpacing: 2.0,
        ),
      ),
      actions: [
        if (actions != null) ...actions!,
        const SizedBox(width: 8),
      ],
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: isDark 
                  ? Colors.black.withOpacity(0.7) 
                  : Colors.white.withOpacity(0.7),
              border: showBottomBorder 
                  ? Border(
                      bottom: BorderSide(
                        color: primaryColor.withOpacity(0.5),
                        width: 1,
                      ),
                    )
                  : null,
            ),
            child: Stack(
              children: [
                // Subtle scanline pattern
                if (isDark)
                  Opacity(
                    opacity: 0.05,
                    child: CustomPaint(
                      painter: _GridPainter(color: primaryColor),
                      size: Size.infinite,
                    ),
                  ),
                // Glowing line at the bottom
                if (showBottomBorder)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 1,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _GridPainter extends CustomPainter {
  final Color color;
  _GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;

    const double spacing = 15.0;
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
