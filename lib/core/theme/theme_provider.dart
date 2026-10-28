import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// StateNotifier to manage application theme mode (light / dark).
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier([super.state = ThemeMode.light]);

  /// Toggle between Light and Dark mode.
  void toggleTheme() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }

  /// Explicitly set the theme mode.
  void setTheme(ThemeMode mode) {
    state = mode;
  }

  /// Whether dark mode is currently active.
  bool get isDarkMode => state == ThemeMode.dark;
}

/// Global provider for application ThemeMode.
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});
