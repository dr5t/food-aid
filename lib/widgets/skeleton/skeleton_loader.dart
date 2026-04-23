import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_spacing.dart';

class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final bool showNeonBorder;

  const SkeletonLoader({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = AppSpacing.radiusMd,
    this.showNeonBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.darkSkeleton1 : AppColors.skeleton1;
    final highlightColor = isDark ? AppColors.darkSkeleton2 : AppColors.skeleton2;

    return Stack(
      children: [
        Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          period: const Duration(milliseconds: 1200),
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: isDark ? Border.all(color: Colors.white.withValues(alpha: 0.05)) : null,
            ),
          ),
        ),
        if (showNeonBorder && isDark)
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: AppColors.neonCyan.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
      ],
    );
  }
}

class CyberSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const CyberSkeleton({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0A0A) : Colors.grey[200],
        borderRadius: BorderRadius.circular(borderRadius),
        border: isDark ? Border.all(color: Colors.white10, width: 0.5) : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: [
            // Base Shimmer
            Shimmer.fromColors(
              baseColor: isDark ? const Color(0xFF111111) : Colors.grey[300]!,
              highlightColor: isDark ? const Color(0xFF1A1A1A) : Colors.grey[100]!,
              child: Container(color: Colors.white),
            ),
            
            // Scanning Line Effect
            _ScanningLine(height: height),
            
            // Tech Corners
            if (isDark) ...[
              Positioned(
                top: 0,
                left: 0,
                child: _TechCorner(color: AppColors.neonCyan.withValues(alpha: 0.3)),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: RotatedBox(
                  quarterTurns: 2,
                  child: _TechCorner(color: AppColors.neonPink.withValues(alpha: 0.3)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ScanningLine extends StatefulWidget {
  final double height;
  const _ScanningLine({required this.height});

  @override
  State<_ScanningLine> createState() => _ScanningLineState();
}

class _ScanningLineState extends State<_ScanningLine> with SingleTickerProviderStateMixin {
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
        return Positioned(
          top: _controller.value * widget.height,
          left: 0,
          right: 0,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.neonCyan.withValues(alpha: 0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TechCorner extends StatelessWidget {
  final Color color;
  const _TechCorner({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: color, width: 1.5),
          left: BorderSide(color: color, width: 1.5),
        ),
      ),
    );
  }
}

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CyberSkeleton(width: 140, height: 16),
          AppSpacing.verticalSm,
          const CyberSkeleton(height: 12),
          AppSpacing.verticalXs,
          const CyberSkeleton(width: 200, height: 12),
          AppSpacing.verticalMd,
          Row(
            children: [
              const CyberSkeleton(width: 80, height: 28, borderRadius: 20),
              const Spacer(),
              const CyberSkeleton(width: 60, height: 12),
            ],
          ),
        ],
      ),
    );
  }
}

class SkeletonTile extends StatelessWidget {
  const SkeletonTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          const CyberSkeleton(width: 50, height: 50, borderRadius: 12),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CyberSkeleton(width: 120, height: 14),
                const SizedBox(height: 8),
                const CyberSkeleton(width: 80, height: 12),
              ],
            ),
          ),
          const CyberSkeleton(width: 60, height: 24, borderRadius: 12),
        ],
      ),
    );
  }
}

class SkeletonList extends StatelessWidget {
  final int itemCount;

  const SkeletonList({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => const SkeletonTile(),
      ),
    );
  }
}

class SkeletonSummaryCards extends StatelessWidget {
  const SkeletonSummaryCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        3,
        (index) => Expanded(
          child: Container(
            margin: EdgeInsets.only(
              right: index < 2 ? AppSpacing.sm : 0,
            ),
            child: const CyberSkeleton(height: 100),
          ),
        ),
      ),
    );
  }
}

class SkeletonStats extends StatelessWidget {
  const SkeletonStats({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      childAspectRatio: 1.8,
      children: List.generate(
        4,
        (_) => const CyberSkeleton(height: double.infinity),
      ),
    );
  }
}



