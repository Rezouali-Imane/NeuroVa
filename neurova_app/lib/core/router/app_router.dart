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
import '../../features/ai/screens/ai_chat_screen.dart';
import '../../features/auth/state/auth_notifier.dart';
import '../../features/focus/dashboard1.dart';
import '../../features/focus/focus_page.dart';
import '../../features/tasks/tasks_page.dart';
import '../../features/focus/menupage.dart' as menu_module;
import '../../features/notes/notes_page.dart';
import '../../features/study_rooms/study_rooms_page.dart';
import '../../features/discipline/discipline_page.dart';
import '../../features/calendar/calendar_page.dart';
import 'page_transitions.dart';

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
    initialLocation: '/onboarding',
    refreshListenable: notifier,

    redirect: (BuildContext context, GoRouterState state) {
      final authState = ref.read(authNotifierProvider);
      final bool isAuthenticated = authState.isAuthenticated;

      final bool isLoggingIn = state.matchedLocation == '/login';
      final bool isRegistering = state.matchedLocation == '/register';
      final bool isOnboarding =
          state.matchedLocation == '/onboarding' ||
          state.matchedLocation == '/';
      final bool isDashboard = state.matchedLocation == '/dashboard';
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
            isSetupProfile ||
            isDashboard) {
          return null;
        }
        return '/register';
      }

      if (isAuthenticated && (isLoggingIn || isRegistering || isOnboarding)) {
        return '/dashboard';
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
        pageBuilder: (BuildContext context, GoRouterState state) =>
            buildTransitionPage<void>(
          child: const OnboardingPage(),
          name: '/onboarding',
        ),
      ),

      GoRoute(
        path: '/confirm-email',
        pageBuilder: (BuildContext context, GoRouterState state) {
          final email = state.extra as String? ?? '';
          return buildTransitionPage<void>(
            child: ConfirmEmailPage(email: email),
            name: '/confirm-email',
          );
        },
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            buildTransitionPage<void>(
          child: const LoginPage(),
          name: '/login',
        ),
      ),

      GoRoute(
        path: '/register',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            buildTransitionPage<void>(
          child: const RegisterPage(),
          name: '/register',
        ),
      ),
      GoRoute(
        path: '/forgot-password',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            buildTransitionPage<void>(
          child: const ForgotPasswordPage(),
          name: '/forgot-password',
        ),
      ),

      GoRoute(
        path: '/reset-code',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            buildTransitionPage<void>(
          child: ResetCodePage(email: state.extra as String? ?? ''),
          name: '/reset-code',
        ),
      ),

      GoRoute(
        path: '/resetpassword',
        pageBuilder: (BuildContext context, GoRouterState state) {
          final extra = state.extra;
          late Widget child;
          if (extra is Map<String, String>) {
            child = ResetPasswordPage(
              email: extra['email'] ?? '',
              code: extra['code'] ?? '',
            );
          } else {
            child = ResetPasswordPage(email: extra as String? ?? '', code: '');
          }
          return buildTransitionPage<void>(
            child: child,
            name: '/resetpassword',
          );
        },
      ),
      GoRoute(
        path: '/auth-callback',
        pageBuilder: (context, state) {
          final router = GoRouter.of(context);
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

              router.go('/profile');
              return;
            }

            if (token != null && token.isNotEmpty) {
              await ref
                  .read(authNotifierProvider.notifier)
                  .finalizeGithubLogin(token);

              if (isNewUser) {
                router.go('/setup-profile');
              } else {
                router.go('/dashboard');
              }
            } else {
              router.go('/login');
            }
          });

          return buildTransitionPage<void>(
            child: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
            name: '/auth-callback',
          );
        },
      ),
      GoRoute(
        path: '/resetpassword-success',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            buildTransitionPage<void>(
          child: const ResetPasswordSuccessPage(),
          name: '/resetpassword-success',
        ),
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            buildTransitionPage<void>(
          child: const ProfilePage(),
          name: '/profile',
        ),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            buildTransitionPage<void>(
          child: const SettingsPage(),
          name: '/settings',
        ),
      ),
      GoRoute(
        path: '/setup-profile',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            buildTransitionPage<void>(
          child: const SetupProfil(signupEmail: '', signupPassword: ''),
          name: '/setup-profile',
        ),
      ),

      GoRoute(
        path: '/ai',
        pageBuilder: (BuildContext context, GoRouterState state) {
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

          return buildTransitionPage<void>(
            child: AIChatScreen(
              userId: userId,
              aiService: aiService,
            ),
            name: '/ai',
          );
        },
      ),
      GoRoute(
        path: '/dashboard',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            buildTransitionPage<void>(
          child: const Dashboard1(),
          name: '/dashboard',
        ),
      ),
      GoRoute(
        path: '/tasks',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            buildTransitionPage<void>(
          child: const TasksPage(),
          name: '/tasks',
        ),
      ),
      GoRoute(
        path: '/focus',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            buildTransitionPage<void>(
          child: const FocusPage(),
          name: '/focus',
        ),
      ),
      GoRoute(
        path: '/notes',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            buildTransitionPage<void>(
          child: const NotesPage(),
          name: '/notes',
        ),
      ),
      GoRoute(
        path: '/rooms',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            buildTransitionPage<void>(
          child: const StudyRoomsPage(),
          name: '/rooms',
        ),
      ),
      GoRoute(
        path: '/discipline',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            buildTransitionPage<void>(
          child: const DisciplinePage(),
          name: '/discipline',
        ),
      ),
      GoRoute(
        path: '/calendar',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            buildTransitionPage<void>(
          child: const CalendarPage(),
          name: '/calendar',
        ),
      ),
      GoRoute(
        path: '/menu',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            buildTransitionPage<void>(
          child: const menu_module.MenuPage(),
          name: '/menu',
        ),
      ),
    ],
  );
});
