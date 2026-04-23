import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_spacing.dart';

class SkeletonTile extends StatelessWidget {
  const SkeletonTile({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF0F0F12) : AppColors.skeleton1;
    final highlightColor = isDark ? AppColors.neonCyan.withOpacity(0.1) : AppColors.skeleton2;

    return Stack(
      children: [
        Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          period: const Duration(milliseconds: 1500),
          child: Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            decoration: BoxDecoration(
              color: isDark ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.black12,
                width: 1,
              ),
            ),
            child: ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              title: Container(
                width: double.infinity,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              subtitle: Container(
                width: 150,
                height: 12,
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        if (isDark)
          Positioned.fill(
            child: IgnorePointer(
              child: _ScanlineOverlay(color: AppColors.neonCyan.withOpacity(0.05)),
            ),
          ),
      ],
    );
  }
}

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF0F0F12) : AppColors.skeleton1;
    final highlightColor = isDark ? AppColors.neonPurple.withOpacity(0.1) : AppColors.skeleton2;

    return Stack(
      children: [
        Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          period: const Duration(milliseconds: 2000),
          child: Container(
            width: 160,
            decoration: BoxDecoration(
              color: isDark ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.black12,
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: 80,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 120,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isDark)
          Positioned.fill(
            child: IgnorePointer(
              child: _ScanlineOverlay(color: AppColors.neonPurple.withOpacity(0.05)),
            ),
          ),
      ],
    );
  }
}

class _ScanlineOverlay extends StatefulWidget {
  final Color color;
  const _ScanlineOverlay({required this.color});

  @override
  State<_ScanlineOverlay> createState() => _ScanlineOverlayState();
}

class _ScanlineOverlayState extends State<_ScanlineOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
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
        return CustomPaint(
          painter: _ScanlinePainter(_controller.value, widget.color),
        );
      },
    );
  }
}

class _ScanlinePainter extends CustomPainter {
  final double progress;
  final Color color;

  _ScanlinePainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          color.withOpacity(0.02),
          color,
          color.withOpacity(0.02),
          Colors.transparent,
        ],
        stops: const [0.0, 0.48, 0.5, 0.52, 1.0],
      ).createShader(Rect.fromLTWH(
        0, 
        (progress * size.height * 2) - size.height, 
        size.width, 
        size.height
      ));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    
    // Draw subtle horizontal grid lines
    final gridPaint = Paint()
      ..color = color.withOpacity(0.05)
      ..strokeWidth = 0.5;
      
    for (double y = 0; y < size.height; y += 10) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(_ScanlinePainter oldDelegate) => oldDelegate.progress != progress;
}

