import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';

import '../../features/auth/forgot_password_page.dart';
import '../../features/profil/setup_profil1.dart';
import '../../features/auth/login_page.dart';
import '../../features/auth/register_page.dart';
import '../../features/onboarding/onboarding_page.dart';
import '../../features/auth/reset_password_page.dart';
import '../../features/auth/reset_code_page.dart';
import '../../features/auth/reset_password_success_page.dart';
import '../../features/auth/confirm_mail.dart';
import '../../features/profile/profile_page.dart';
import '../../features/settings/settings_page.dart';
import '../../features/home/home_page.dart';
import '../../features/ai/screens/ai_chat_screen.dart';
import '../../features/auth/state/auth_notifier.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  RouterNotifier(this._ref) {
    _ref.listen(authNotifierProvider, (previous, next) {
      if (previous?.isAuthenticated != next.isAuthenticated) {
        notifyListeners();
      }
    });
  }
}

final routerNotifierProvider = Provider((ref) => RouterNotifier(ref));

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,

    redirect: (BuildContext context, GoRouterState state) {
      final authState = ref.read(authNotifierProvider);
      final bool isAuthenticated = authState.isAuthenticated;

      final bool isLoggingIn = state.matchedLocation == '/login';
      final bool isRegistering = state.matchedLocation == '/register';
      final bool isOnboarding =
          state.matchedLocation == '/onboarding' ||
          state.matchedLocation == '/';
      final bool isConfirmingEmail = state.matchedLocation == '/confirm-email';
      final bool isResetting =
          state.matchedLocation.startsWith('/resetpassword') ||
          state.matchedLocation == '/forgot-password' ||
          state.matchedLocation == '/reset-code';
      final bool isCallback = state.matchedLocation == '/auth-callback';
      final bool isSetupProfile = state.matchedLocation == '/setup-profile';

      if (!isAuthenticated) {
        if (isLoggingIn ||
            isRegistering ||
            isOnboarding ||
            isConfirmingEmail ||
            isResetting ||
            isCallback ||
            isSetupProfile) {
          return null;
        }
        return '/register';
      }

      if (isAuthenticated && (isLoggingIn || isRegistering || isOnboarding)) {
        return '/home';
      }
      return null;
    },

    routes: <RouteBase>[
      GoRoute(
        path: '/',
        redirect: (BuildContext context, GoRouterState state) => '/onboarding',
      ),

      GoRoute(
        path: '/onboarding',
        builder: (BuildContext context, GoRouterState state) =>
            const OnboardingPage(),
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
        builder: (BuildContext context, GoRouterState state) =>
            const LoginPage(),
      ),

      GoRoute(
        path: '/register',
        builder: (BuildContext context, GoRouterState state) =>
            const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (BuildContext context, GoRouterState state) =>
            const ForgotPasswordPage(),
      ),

      GoRoute(
        path: '/reset-code',
        builder: (BuildContext context, GoRouterState state) =>
            ResetCodePage(email: state.extra as String? ?? ''),
      ),

      GoRoute(
        path: '/resetpassword',
        builder: (BuildContext context, GoRouterState state) {
          final extra = state.extra;
          if (extra is Map<String, String>) {
            return ResetPasswordPage(
              email: extra['email'] ?? '',
              code: extra['code'] ?? '',
            );
          }

          return ResetPasswordPage(email: extra as String? ?? '', code: '');
        },
      ),
      GoRoute(
        path: '/auth-callback',
        builder: (context, state) {
          final token = state.uri.queryParameters['accessToken'];
          final isNewUser = state.uri.queryParameters['isNewUser'] == 'true';
          final emailVerified =
              state.uri.queryParameters['emailVerified'] == 'true';

          Future.microtask(() async {
            if (emailVerified) {
              if (token != null && token.isNotEmpty) {
                await ref
                    .read(authNotifierProvider.notifier)
                    .applyAccessToken(token);
              } else {
                ref.read(authNotifierProvider.notifier).markEmailVerified();
              }

              context.go('/profile');
              return;
            }

            if (token != null && token.isNotEmpty) {
              await ref
                  .read(authNotifierProvider.notifier)
                  .finalizeGithubLogin(token);

              if (isNewUser) {
                context.go('/setup-profile');
              } else {
                context.go('/home');
              }
            } else {
              context.go('/login');
            }
          });

          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
      GoRoute(
        path: '/resetpassword-success',
        builder: (BuildContext context, GoRouterState state) =>
            const ResetPasswordSuccessPage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (BuildContext context, GoRouterState state) =>
            const ProfilePage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (BuildContext context, GoRouterState state) =>
            const SettingsPage(),
      ),
      GoRoute(
        path: '/setup-profile',
        builder: (BuildContext context, GoRouterState state) {
          return const SetupProfil(signupEmail: '', signupPassword: '');
        },
      ),
      GoRoute(
        path: '/home',
        builder: (BuildContext context, GoRouterState state) =>
            const HomePage(),
      ),
      GoRoute(
        path: '/ai',
        builder: (BuildContext context, GoRouterState state) {
          final authState = ref.read(authNotifierProvider);
          final aiService = ref.read(aiServiceProvider);

          String userId = 'user';
          final token = authState.token;
          if (token != null) {
            try {
              final parts = token.split('.');
              if (parts.length == 3) {
                final decoded = utf8.decode(
                  base64Url.decode(base64Url.normalize(parts[1])),
                );
                final payload = jsonDecode(decoded) as Map<String, dynamic>;
                userId = (payload['userid'] ?? payload['sub'] ?? 'user').toString();
              }
            } catch (_) {
              userId = 'user';
            }
          }

          return AIChatScreen(
            userId: userId,
            aiService: aiService,
          );
        },
      ),
    ],
  );
});
