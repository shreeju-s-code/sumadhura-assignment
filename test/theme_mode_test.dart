import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sumadhura_visitor/core/theme/theme_provider.dart';

void main() {
  group('ThemeModeNotifier Tests', () {
    test('Default mode starts in light mode', () {
      final notifier = ThemeModeNotifier();
      expect(notifier.state, ThemeMode.light);
      expect(notifier.isDarkMode, isFalse);
    });

    test('Toggling theme switches between light and dark modes', () {
      final notifier = ThemeModeNotifier();

      notifier.toggleTheme();
      expect(notifier.state, ThemeMode.dark);
      expect(notifier.isDarkMode, isTrue);

      notifier.toggleTheme();
      expect(notifier.state, ThemeMode.light);
      expect(notifier.isDarkMode, isFalse);
    });

    test('Explicitly setting theme mode updates state correctly', () {
      final notifier = ThemeModeNotifier();

      notifier.setTheme(ThemeMode.dark);
      expect(notifier.state, ThemeMode.dark);

      notifier.setTheme(ThemeMode.light);
      expect(notifier.state, ThemeMode.light);
    });
  });
}

