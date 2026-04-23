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
    final finalBorderColor = borderColor ?? (isDark ? AppColors.neonCyan.withValues(alpha: 0.3) : Colors.black12);
    
    return Container(
      margin: margin,
      child: Stack(
        children: [
          // Glass Effect Background
          ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: padding ?? const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(
                    color: finalBorderColor,
                    width: 1.5,
                  ),
                  gradient: backgroundGradient ?? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark 
                      ? [
                          Colors.white.withValues(alpha: 0.05),
                          Colors.white.withValues(alpha: 0.01),
                        ]
                      : [
                          Colors.black.withValues(alpha: 0.02),
                          Colors.black.withValues(alpha: 0.005),
                        ],
                  ),
                  boxShadow: (showGlow || glowColor != null) ? [
                    BoxShadow(
                      color: glowColor ?? finalBorderColor.withValues(alpha: 0.2),
                      blurRadius: 15,
                      spreadRadius: 2,
                    )
                  ] : null,
                ),
                child: child,
              ),
            ),
          ),

        // Cyber Corners
        if (showCorners)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _CornerPainter(
                  color: finalBorderColor.withValues(alpha: 0.8),
                  borderRadius: borderRadius,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final double borderRadius;

  _CornerPainter({required this.color, required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const double cornerLength = 12.0;

    // Top Left
    canvas.drawLine(
      const Offset(0, cornerLength),
      const Offset(0, 0),
      paint,
    );
    canvas.drawLine(
      const Offset(0, 0),
      const Offset(cornerLength, 0),
      paint,
    );

    // Top Right
    canvas.drawLine(
      Offset(size.width - cornerLength, 0),
      Offset(size.width, 0),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width, cornerLength),
      paint,
    );

    // Bottom Left
    canvas.drawLine(
      Offset(0, size.height - cornerLength),
      Offset(0, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height),
      Offset(cornerLength, size.height),
      paint,
    );

    // Bottom Right
    canvas.drawLine(
      Offset(size.width - cornerLength, size.height),
      Offset(size.width, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width, size.height - cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
