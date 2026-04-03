import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/forgot_password_page.dart';
import '../../features/auth/login_page.dart';
import '../../features/auth/register_page.dart';
import '../../features/onboarding/onboarding_page.dart';
import '../../features/auth/reset_password_page.dart';
import '../../features/auth/reset_password_success_page.dart';
import '../../features/auth/confirm_mail.dart';
import '../../features/settings/settings_page.dart';
import '../../features/home/home_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/onboarding',
  
  routes: <RouteBase>[
    // Redirect root to onboarding
    GoRoute(
      path: '/',
      redirect: (BuildContext context, GoRouterState state) => '/onboarding',
    ),
    GoRoute(
      path: '/onboarding',
      builder: (BuildContext context, GoRouterState state) {
        return const OnboardingPage();
      },
    ),
    GoRoute(
  path: '/confirm-email',
  builder: (BuildContext context, GoRouterState state) {
    final email = state.extra as String? ?? '';
    return ConfirmEmailPage(email: email);
  },
),
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginPage();
      },
    ),

    GoRoute(
      path: '/register',
      builder: (BuildContext context, GoRouterState state) {
        return const RegisterPage();
      },
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (BuildContext context, GoRouterState state) {
        return const ForgotPasswordPage();
      },
    ),
       GoRoute(
      path: '/resetpassword',
      builder: (BuildContext context, GoRouterState state) {
        return const   ResetPasswordPage();
      },
    ),
      GoRoute(
        path: '/resetpassword-success',
        builder: (BuildContext context, GoRouterState state) {
          return const ResetPasswordSuccessPage();
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (BuildContext context, GoRouterState state) {
          final isVerified = state.extra as bool? ?? false;
          return SettingsPage(isVerified: isVerified);
        },
      ),
      GoRoute(
        path: '/home',
        builder: (BuildContext context, GoRouterState state) {
          return const HomePage();
        },
      ),
  ],
);
