import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/auth/state/auth_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    final container = ProviderContainer();
    await container.read(authNotifierProvider.notifier).restoreSession();
    
    // Load saved theme preference
    final savedTheme = await container.read(themePreferenceProvider.future);
    container.read(themeModeProvider.notifier).state = savedTheme;

    runApp(
      UncontrolledProviderScope(container: container, child: const NeurovaApp()),
    );
  } catch (e) {
    // If session restoration fails, still run the app
    final container = ProviderContainer();
    runApp(
      UncontrolledProviderScope(container: container, child: const NeurovaApp()),
    );
  }
}

class NeurovaApp extends ConsumerWidget {
  const NeurovaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Neurova',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      scrollBehavior: const _FixedScrollBehavior(),
      routerConfig: router,
    );
  }
}

class _FixedScrollBehavior extends MaterialScrollBehavior {
  const _FixedScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }

  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
