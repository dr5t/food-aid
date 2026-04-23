import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';

class CyberBackground extends StatelessWidget {
  final List<Widget>? children;
  final Widget? child;

  const CyberBackground({super.key, this.children, this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        if (isDark) const Positioned.fill(child: _CyberGrid()),
        if (child != null) child!,
        if (children != null) ...children!,
      ],
    );
  }
}

class _CyberGrid extends StatelessWidget {
  const _CyberGrid();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPainter(),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.neonCyan.withValues(alpha: 0.05)
      ..strokeWidth = 0.5;

    const spacing = 30.0;
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
