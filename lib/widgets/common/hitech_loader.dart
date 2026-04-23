import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme/app_colors.dart';

class HitechLoader extends StatelessWidget {
  final double size;
  final Color? color;
  final String? text;

  const HitechLoader({
    super.key,
    this.size = 60,
    this.color,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = color ?? AppColors.neonCyan;
    final secondaryColor = AppColors.neonPurple;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background glow
              Container(
                width: size * 0.8,
                height: size * 0.8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),

              // Outer Static Ring
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: primaryColor.withOpacity(0.05),
                    width: 1,
                  ),
                ),
              ),

              // Spinning Outer Dash Ring
              _RotatingRing(
                size: size,
                duration: 3.seconds,
                child: CustomPaint(
                  size: Size(size, size),
                  painter: _DashRingPainter(
                    color: primaryColor.withOpacity(0.3),
                    dashCount: 12,
                    strokeWidth: 1,
                  ),
                ),
              ),

              // Spinning Middle Arc
              _RotatingRing(
                size: size * 0.85,
                duration: 2.seconds,
                reverse: true,
                child: CustomPaint(
                  size: Size(size * 0.85, size * 0.85),
                  painter: _ArcPainter(
                    color: primaryColor,
                    strokeWidth: 2,
                    sweepAngle: 1.2,
                  ),
                ),
              ),

              // Spinning Inner Arc
              _RotatingRing(
                size: size * 0.7,
                duration: 1.5.seconds,
                child: CustomPaint(
                  size: Size(size * 0.7, size * 0.7),
                  painter: _ArcPainter(
                    color: secondaryColor,
                    strokeWidth: 2,
                    sweepAngle: 0.8,
                  ),
                ),
              ),

              // Scanning Line
              _ScanningLine(size: size),

              // Core Pulsing Node
              Container(
                width: size * 0.2,
                height: size * 0.2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white,
                      primaryColor,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.8),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ).animate(onPlay: (controller) => controller.repeat(reverse: true))
               .scale(duration: 600.ms, begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2))
               .shimmer(duration: 1.seconds, color: Colors.white.withOpacity(0.5)),
            ],
          ),
        ),
        if (text != null) ...[
          const SizedBox(height: 16),
          Text(
            text!.toUpperCase(),
            style: TextStyle(
              color: primaryColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              fontFamily: 'Orbitron',
            ),
          ).animate(onPlay: (controller) => controller.repeat())
           .fadeIn(duration: 500.ms)
           .then()
           .fadeOut(duration: 500.ms, delay: 1.seconds),
        ],
      ],
    );
  }
}

class _RotatingRing extends StatelessWidget {
  final double size;
  final Widget child;
  final Duration duration;
  final bool reverse;

  const _RotatingRing({
    required this.size,
    required this.child,
    required this.duration,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: reverse ? -2 * math.pi : 2 * math.pi),
      duration: duration,
      builder: (context, value, child) {
        return Transform.rotate(
          angle: value,
          child: child,
        );
      },
      child: child,
    ).animate(onPlay: (controller) => controller.repeat());
  }
}

class _ScanningLine extends StatelessWidget {
  final double size;

  const _ScanningLine({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size * 0.9,
      height: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppColors.neonCyan.withOpacity(0.5),
            Colors.transparent,
          ],
        ),
      ),
    ).animate(onPlay: (controller) => controller.repeat())
     .moveY(begin: -size/2, end: size/2, duration: 2.seconds)
     .fadeIn(duration: 200.ms)
     .then()
     .fadeOut(duration: 200.ms, delay: 1.6.seconds);
  }
}

class _ArcPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double sweepAngle;

  _ArcPainter({
    required this.color,
    required this.strokeWidth,
    required this.sweepAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawArc(rect, 0, sweepAngle, false, paint);
    canvas.drawArc(rect, math.pi, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DashRingPainter extends CustomPainter {
  final Color color;
  final int dashCount;
  final double strokeWidth;

  _DashRingPainter({
    required this.color,
    required this.dashCount,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);
    const dashWidth = 0.2;
    final space = (2 * math.pi) / dashCount;

    for (var i = 0; i < dashCount; i++) {
      final startAngle = i * space;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        dashWidth,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
