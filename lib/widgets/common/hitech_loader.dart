import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HitechLoader extends StatelessWidget {
  final double size;
  final Color? color;
  final String? text;

  const HitechLoader({
    super.key,
    this.size = 80.0,
    this.color,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    final neonColor = color ?? Theme.of(context).colorScheme.primary;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulsing ring
              Container(
                width: size * 1.5,
                height: size * 1.5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: neonColor.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.5, 1.5),
                    duration: 2000.ms,
                    curve: Curves.easeOutQuad,
                  )
                  .fadeOut(duration: 2000.ms),

              // Glassmorphism ring
              Container(
                width: size * 1.1,
                height: size * 1.1,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 2,
                  ),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.transparent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .rotate(duration: 5000.ms),

              // The Logo with glowing effect
              Container(
                width: size,
                height: size,
                padding: const EdgeInsets.all(12),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .scale(
                    begin: const Offset(0.95, 0.95),
                    end: const Offset(1.05, 1.05),
                    duration: 1500.ms,
                    curve: Curves.easeInOut,
                  ),

              // Scanning line
              Container(
                width: size * 1.5,
                height: 1.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      neonColor.withOpacity(0.2),
                      neonColor,
                      neonColor.withOpacity(0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .moveY(
                    begin: -size * 0.7,
                    end: size * 0.7,
                    duration: 2000.ms,
                    curve: Curves.linear,
                  ),
            ],
          ),

          if (text != null) ...[
            const SizedBox(height: 24),
            Text(
              text!.toUpperCase(),
              style: TextStyle(
                color: neonColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
                shadows: [
                  Shadow(
                    color: neonColor.withOpacity(0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
            )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .fadeIn(duration: 1000.ms),
          ],
        ],
      ),
    );
  }
}
