import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_spacing.dart';
import '../../widgets/common/app_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final _pages = [
    const _OnboardingPage(
      icon: Icons.volunteer_activism,
      title: 'Reduce Food Waste',
      subtitle:
          'Join our network to protect surplus food from going to waste. Connect with donors and help feed families in need.',
      color: AppColors.primary,
    ),
    const _OnboardingPage(
      icon: Icons.people_outline,
      title: 'Community Connection',
      subtitle:
          'Easily connect with local NGOs, donors, and volunteers. Our platform ensures food reaches the right hands quickly.',
      color: AppColors.statusAssigned,
    ),
    const _OnboardingPage(
      icon: Icons.track_changes,
      title: 'Efficient Tracking',
      subtitle:
          'Monitor donations in real-time. Transparent and efficient logistics across the region.',
      color: AppColors.info,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: AppSpacing.paddingMd,
                child: TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(
                    'SKIP',
                    style: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) => _pages[index],
              ),
            ),

            Padding(
              padding: AppSpacing.screenPadding,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 4,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primary
                              : (isDark ? Colors.white12 : Colors.black12),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusFull,
                          ),
                        ),
                      ),
                    ),
                  ),
                  AppSpacing.verticalXl,
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      label: _currentPage == _pages.length - 1
                          ? 'GET STARTED'
                          : 'NEXT',
                      onPressed: () {
                        if (_currentPage < _pages.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          context.go('/login');
                        }
                      },
                    ),
                  ),
                  AppSpacing.verticalMd,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(child: Icon(icon, size: 80, color: color)),
              )
              .animate()
              .fadeIn(duration: 600.ms)
              .scale(begin: const Offset(0.8, 0.8)),
          AppSpacing.verticalXl,
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.verticalMd,
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
