import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme/app_colors.dart';

class HitechCircularLoader extends StatelessWidget {
  final double size;
  final Color? color;

  const HitechCircularLoader({
    super.key,
    this.size = 50,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = color ?? AppColors.neonCyan;
    
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer spinning ring
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: primaryColor.withOpacity(0.1),
                width: 2,
              ),
            ),
          ),
          
          // Outer pulse ring
          Container(
            width: size * 0.8,
            height: size * 0.8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: primaryColor.withOpacity(0.2),
                width: 1,
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat())
           .scale(duration: 1.seconds, begin: Offset(0.8, 0.8), end: Offset(1.2, 1.2))
           .fadeOut(duration: 1.seconds),

          // Spinning arc
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 2 * math.pi),
            duration: 2.seconds,
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value,
                child: CustomPaint(
                  size: Size(size, size),
                  painter: _ArcPainter(primaryColor),
                ),
              );
            },
          ).animate(onPlay: (controller) => controller.repeat()),

          // Inner pulsing core
          Container(
            width: size * 0.3,
            height: size * 0.3,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor,
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .scale(duration: 600.ms, begin: Offset(0.8, 0.8), end: Offset(1.2, 1.2))
           .shimmer(duration: 1.seconds, color: Colors.white.withOpacity(0.3)),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final Color color;
  _ArcPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawArc(rect, 0, 1.5, false, paint);
    canvas.drawArc(rect, math.pi, 1.5, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
