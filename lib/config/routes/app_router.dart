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

        if (!isInitialized) return null;

        final publicRoutes = ['/', '/onboarding', '/login', '/signup'];
        final isOnPublicRoute = publicRoutes.contains(currentPath);

        if (!isAuthenticated && !isOnPublicRoute) {
          return '/login';
        }

        if (isAuthenticated && isOnPublicRoute) {
          // Check if user needs verification first
          if (authProvider.isPendingVerification ||
              authProvider.isRejected) {
            return '/pending-verification';
          }
          return _dashboardForRole(authProvider.role);
        }

        // If authenticated and on pending-verification, but now approved → redirect to dashboard
        if (isAuthenticated &&
            currentPath == '/pending-verification' &&
            authProvider.isApproved) {
          return _dashboardForRole(authProvider.role);
        }

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

        // ─── Admin ────────────────────────────────────────────
        GoRoute(
          path: '/admin',
          pageBuilder: (context, state) => _buildPage(
            state,
            const AdminDashboard(),
          ),
        ),

        // ─── Donor ────────────────────────────────────────────
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

        // ─── NGO ──────────────────────────────────────────────
        GoRoute(
          path: '/ngo',
          pageBuilder: (context, state) => _buildPage(
            state,
            const NgoDashboard(),
          ),
        ),

        // ─── Logistics Company ────────────────────────────────
        GoRoute(
          path: '/company',
          pageBuilder: (context, state) => _buildPage(
            state,
            const CompanyDashboard(),
          ),
        ),

        // ─── Logistics Employee ───────────────────────────────
        GoRoute(
          path: '/employee',
          pageBuilder: (context, state) => _buildPage(
            state,
            const EmployeeDashboard(),
          ),
        ),

        // ─── Shared ───────────────────────────────────────────
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
        return '/admin';
      case null:
        return '/donor';
    }
  }

  static CustomTransitionPage _buildPage(GoRouterState state, Widget child) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.02),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            )),
            child: child,
          ),
        );
      },
    );
  }
}
