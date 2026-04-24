import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/signup_screen.dart';
import '../../screens/auth/pending_verification_screen.dart';
import '../../screens/donor/donor_dashboard.dart';
import '../../screens/donor/create_donation_screen.dart';
import '../../screens/donor/donation_tracking_screen.dart';
import '../../screens/donor/donation_history_screen.dart';
import '../../screens/ngo/ngo_dashboard.dart';
import '../../screens/logistics/company_dashboard.dart';
import '../../screens/logistics/employee_dashboard.dart';
import '../../screens/admin/admin_dashboard.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/notifications/notifications_screen.dart';

class AppRouter {
  static GoRouter router(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isAuthenticated = authProvider.isAuthenticated;
        final isInitialized = authProvider.isInitialized;
        final currentPath = state.uri.path;

        debugPrint('--- Router Redirect Check ---');
        debugPrint('Path: $currentPath');
        debugPrint('Authenticated: $isAuthenticated');
        debugPrint('Initialized: $isInitialized');
        debugPrint('Role: ${authProvider.role}');

        if (!isInitialized) {
          debugPrint('Not initialized, staying at $currentPath');
          return null;
        }

        final publicRoutes = ['/onboarding', '/login', '/signup'];
        final isOnPublicRoute = publicRoutes.contains(currentPath);

        if (!isAuthenticated && !isOnPublicRoute) {
          debugPrint('AppRouter: Protected route and not authenticated, redirecting to /login');
          return '/login';
        }

        if (isAuthenticated && isOnPublicRoute) {
          if (!authProvider.isEmailVerified && authProvider.role != UserRole.superAdmin) {
            debugPrint('AppRouter: Email not verified, redirecting to /pending-verification');
            return '/pending-verification';
          }
          if (authProvider.isPendingVerification ||
              authProvider.isRejected) {
            debugPrint('AppRouter: Authenticated but pending/rejected, redirecting to /pending-verification');
            return '/pending-verification';
          }

          final target = _dashboardForRole(authProvider.role);
          debugPrint('AppRouter: Authenticated on public route, redirecting to $target');
          return target;
        }

        if (isAuthenticated && !isOnPublicRoute) {
           if (!authProvider.isEmailVerified && currentPath != '/pending-verification' && authProvider.role != UserRole.superAdmin) {
             debugPrint('AppRouter: Email not verified on private route, redirecting to /pending-verification');
             return '/pending-verification';
           }
           if ((authProvider.isPendingVerification || authProvider.isRejected) && currentPath != '/pending-verification') {
             debugPrint('AppRouter: Authenticated but pending/rejected on private route, redirecting to /pending-verification');
             return '/pending-verification';
           }
        }

        debugPrint('AppRouter: No redirection needed for $currentPath');
        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => _buildPage(
            state,
            const SplashScreen(),
          ),
        ),
        GoRoute(
          path: '/onboarding',
          pageBuilder: (context, state) => _buildPage(
            state,
            const OnboardingScreen(),
          ),
        ),
        GoRoute(
          path: '/login',
          pageBuilder: (context, state) => _buildPage(
            state,
            const LoginScreen(),
          ),
        ),
        GoRoute(
          path: '/signup',
          pageBuilder: (context, state) => _buildPage(
            state,
            const SignupScreen(),
          ),
        ),
        GoRoute(
          path: '/pending-verification',
          pageBuilder: (context, state) => _buildPage(
            state,
            const PendingVerificationScreen(),
          ),
        ),

        GoRoute(
          path: '/admin',
          pageBuilder: (context, state) => _buildPage(
            state,
            const AdminDashboard(),
          ),
        ),

        GoRoute(
          path: '/donor',
          pageBuilder: (context, state) => _buildPage(
            state,
            const DonorDashboard(),
          ),
          routes: [
            GoRoute(
              path: 'create',
              pageBuilder: (context, state) => _buildPage(
                state,
                const CreateDonationScreen(),
              ),
            ),
            GoRoute(
              path: 'tracking/:donationId',
              pageBuilder: (context, state) => _buildPage(
                state,
                DonationTrackingScreen(
                  donationId: state.pathParameters['donationId']!,
                ),
              ),
            ),
            GoRoute(
              path: 'history',
              pageBuilder: (context, state) => _buildPage(
                state,
                const DonationHistoryScreen(),
              ),
            ),
          ],
        ),

        GoRoute(
          path: '/ngo',
          pageBuilder: (context, state) => _buildPage(
            state,
            const NgoDashboard(),
          ),
        ),

        GoRoute(
          path: '/company',
          pageBuilder: (context, state) => _buildPage(
            state,
            const CompanyDashboard(),
          ),
        ),

        GoRoute(
          path: '/employee',
          pageBuilder: (context, state) => _buildPage(
            state,
            const EmployeeDashboard(),
          ),
        ),

        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) => _buildPage(
            state,
            const ProfileScreen(),
          ),
        ),
        GoRoute(
          path: '/notifications',
          pageBuilder: (context, state) => _buildPage(
            state,
            const NotificationsScreen(),
          ),
        ),
      ],
    );
  }

  static String _dashboardForRole(UserRole? role) {
    switch (role) {
      case UserRole.donor:
        return '/donor';
      case UserRole.ngo:
        return '/ngo';
      case UserRole.logisticsCompany:
        return '/company';
      case UserRole.logisticsEmployee:
        return '/employee';
      case UserRole.admin:
      case UserRole.superAdmin:
        return '/admin';
      case null:
        return '/donor';
    }
  }

  static CustomTransitionPage _buildPage(GoRouterState state, Widget child) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 600),
      reverseTransitionDuration: const Duration(milliseconds: 500),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curveAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutExpo,
          reverseCurve: Curves.easeInOutExpo,
        );

        return FadeTransition(
          opacity: curveAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(curveAnimation),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.96, end: 1.0).animate(curveAnimation),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
