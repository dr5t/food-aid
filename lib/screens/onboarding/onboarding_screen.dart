import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_spacing.dart';
import '../../config/theme/app_text_styles.dart';
import '../../widgets/common/app_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final _pages = const [
    _OnboardingPage(
      icon: Icons.auto_awesome_rounded,
      title: 'Hitech Surplus Shield',
      subtitle:
          'Join Dehradun\'s smartest network. Protect surplus food from going to waste using advanced logistics tracking.',
      gradient: AppColors.neonCyanGradient,
    ),
    _OnboardingPage(
      icon: Icons.hub_rounded,
      title: 'The Dehradun Node',
      subtitle:
          'Connect instantly with local NGOs and volunteers. Our decentralized grid ensures food reaches the right families fast.',
      gradient: AppColors.neonPurpleGradient,
    ),
    _OnboardingPage(
      icon: Icons.radar_rounded,
      title: 'Precision Tracking',
      subtitle:
          'Monitor every grain in real-time. Secure, transparent, and efficient delivery across the Doon Valley.',
      gradient: AppColors.neonPinkGradient,
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
    final primaryColor = isDark ? AppColors.neonCyan : AppColors.primary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: Stack(
        children: [
          // Background Glow
          if (isDark)
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonCyan.withOpacity(0.1),
                      blurRadius: 100,
                      spreadRadius: 50,
                    ),
                  ],
                ),
              ),
            ),

          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: AppSpacing.paddingMd,
                    child: TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text(
                        'SKIP PROTOCOL',
                        style: TextStyle(
                          color: primaryColor.withOpacity(0.6),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
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
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
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
                                  ? primaryColor
                                  : (isDark ? Colors.white12 : Colors.black12),
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusFull),
                            ),
                          ),
                        ),
                      ),
                      AppSpacing.verticalXl,
                      SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          label: _currentPage == _pages.length - 1
                              ? 'INITIALIZE'
                              : 'NEXT PHASE',
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
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
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
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: gradient.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: (gradient as LinearGradient).colors.first.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 64,
                color: (gradient as LinearGradient).colors.first,
              ),
            ),
          ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds),
          AppSpacing.verticalXl,
          Text(
            title.toUpperCase(),
            style: AppTextStyles.heading.copyWith(
              letterSpacing: 2,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.verticalMd,
          Text(
            subtitle,
            style: AppTextStyles.body.copyWith(
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

extension on Gradient {
  Gradient withOpacity(double opacity) {
    if (this is LinearGradient) {
      final g = this as LinearGradient;
      return LinearGradient(
        colors: g.colors.map((c) => c.withOpacity(opacity)).toList(),
        begin: g.begin,
        end: g.end,
      );
    }
    return this;
  }
}
