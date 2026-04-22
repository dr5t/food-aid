import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_spacing.dart';

class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = AppSpacing.radiusMd,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.skeleton1,
      highlightColor: AppColors.skeleton2,
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.skeleton1,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Shimmer.fromColors(
          baseColor: AppColors.skeleton1,
          highlightColor: AppColors.skeleton2,
          period: const Duration(milliseconds: 1500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 140,
                height: 14,
                decoration: BoxDecoration(
                  color: AppColors.skeleton1,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              AppSpacing.verticalSm,
              Container(
                width: double.infinity,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.skeleton1,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              AppSpacing.verticalXs,
              Container(
                width: 200,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.skeleton1,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              AppSpacing.verticalMd,
              Row(
                children: [
                  Container(
                    width: 80,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.skeleton1,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 60,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.skeleton1,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: const SkeletonCard(),
        ),
      ),
    );
  }
}

class SkeletonSummaryCards extends StatelessWidget {
  const SkeletonSummaryCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.skeleton1,
      highlightColor: AppColors.skeleton2,
      period: const Duration(milliseconds: 1500),
      child: Row(
        children: List.generate(
          3,
          (index) => Expanded(
            child: Container(
              margin: EdgeInsets.only(
                right: index < 2 ? AppSpacing.sm : 0,
              ),
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.skeleton1,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
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
    return Shimmer.fromColors(
      baseColor: AppColors.skeleton1,
      highlightColor: AppColors.skeleton2,
      period: const Duration(milliseconds: 1500),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1.8,
        children: List.generate(
          4,
          (_) => Container(
            decoration: BoxDecoration(
              color: AppColors.skeleton1,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        ),
      ),
    );
  }
}

