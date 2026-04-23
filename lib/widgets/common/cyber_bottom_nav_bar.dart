import 'dart:ui';
import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';

class CyberBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<CyberBottomNavItem> items;

  const CyberBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Container(
      height: 70 + bottomPadding,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          top: BorderSide(
            color: AppColors.neonCyan.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.black.withOpacity(0.7),
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (index) {
                final isSelected = currentIndex == index;
                final item = items[index];
                
                return InkWell(
                  onTap: () => onTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.neonCyan.withOpacity(0.15),
                                blurRadius: 15,
                                spreadRadius: -2,
                              )
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          color: isSelected ? AppColors.neonCyan : AppColors.darkTextSecondary,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: AppTextStyles.hitechSmall.copyWith(
                            fontSize: 10,
                            color: isSelected ? AppColors.neonCyan : AppColors.darkTextSecondary,
                            shadows: isSelected
                                ? [
                                    Shadow(
                                      color: AppColors.neonCyan.withOpacity(0.5),
                                      blurRadius: 10,
                                    )
                                  ]
                                : [],
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(height: 4),
                          Container(
                            width: 20,
                            height: 2,
                            decoration: BoxDecoration(
                              color: AppColors.neonCyan,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.neonCyan.withOpacity(0.8),
                                  blurRadius: 8,
                                )
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class CyberBottomNavItem {
  final IconData icon;
  final String label;

  const CyberBottomNavItem({
    required this.icon,
    required this.label,
  });
}
