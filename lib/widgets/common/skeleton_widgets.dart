import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_spacing.dart';

class SkeletonTile extends StatelessWidget {
  const SkeletonTile({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.darkSkeleton1 : AppColors.skeleton1;
    final highlightColor = isDark ? AppColors.darkSkeleton2 : AppColors.skeleton2;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black12,
          width: 1,
        ),
      ),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        period: const Duration(milliseconds: 1500),
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
    ).animate().fadeIn(duration: 400.ms);
  }
}

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.darkSkeleton1 : AppColors.skeleton1;
    final highlightColor = isDark ? AppColors.darkSkeleton2 : AppColors.skeleton2;

    return Container(
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
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        period: const Duration(milliseconds: 2000),
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
    ).animate().fadeIn(duration: 400.ms);
  }
}

class SkeletonStats extends StatelessWidget {
  const SkeletonStats({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.darkSkeleton1 : AppColors.skeleton1;
    final highlightColor = isDark ? AppColors.darkSkeleton2 : AppColors.skeleton2;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.5,
        children: List.generate(4, (index) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        )),
      ),
    );
  }
}

