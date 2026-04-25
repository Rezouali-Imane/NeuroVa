import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Riverpod provider for theme mode management
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

/// Provider to load and persist theme preference
final themePreferenceProvider = FutureProvider<ThemeMode>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final themeString = prefs.getString('theme_mode') ?? 'dark';
  
  switch (themeString) {
    case 'light':
      return ThemeMode.light;
    case 'system':
      return ThemeMode.system;
    default:
      return ThemeMode.dark;
  }
});

/// Helper function to save theme preference
Future<void> saveThemePreference(ThemeMode mode) async {
  final prefs = await SharedPreferences.getInstance();
  final themeString = mode == ThemeMode.light
      ? 'light'
      : mode == ThemeMode.system
          ? 'system'
          : 'dark';
  await prefs.setString('theme_mode', themeString);
}

/// Helper to toggle between dark and light
Future<void> toggleTheme(WidgetRef ref) async {
  final current = ref.read(themeModeProvider);
  final newMode =
      current == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  ref.read(themeModeProvider.notifier).state = newMode;
  await saveThemePreference(newMode);
}
