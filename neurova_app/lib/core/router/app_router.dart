import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/forgot_password_page.dart';
import '../../features/auth/login_page.dart';
import '../../features/auth/register_page.dart';
import '../../features/onboarding/onboarding1.dart';
import '../../features/auth/reset_password_page.dart';

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
        return const Onboarding1();
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
  ],
);
