import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme/app_colors.dart';

class ScanningOverlay extends StatelessWidget {
  final String label;
  const ScanningOverlay({super.key, this.label = 'SCANNING NETWORK...'});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: Container(
        color: Colors.black.withValues(alpha: 0.4),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CyberScanner(label: label),
              const SizedBox(height: 20),
              Text(
                label,
                style: GoogleFonts.orbitron(
                  fontSize: 12,
                  color: AppColors.neonCyan,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(
                      color: AppColors.neonCyan.withValues(alpha: 0.8),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeIn(duration: 500.ms).then().fadeOut(duration: 500.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _CyberScanner extends StatefulWidget {
  final String label;
  const _CyberScanner({required this.label});

  @override
  State<_CyberScanner> createState() => _CyberScannerState();
}

class _CyberScannerState extends State<_CyberScanner> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 200,
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              // Scan Line
              Positioned(
                top: 100 * _controller.value,
                left: 0,
                right: 0,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: AppColors.neonCyan,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonCyan,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
              // Grid Pattern
              CustomPaint(
                size: const Size(200, 100),
                painter: _GridPainter(AppColors.neonCyan.withValues(alpha: 0.1)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;
  _GridPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;

    for (double i = 0; i <= size.width; i += 20) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i <= size.height; i += 20) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
