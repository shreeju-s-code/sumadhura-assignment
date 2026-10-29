import 'package:flutter/material.dart';

/// Centralized SnackBar helper providing modern curved, floating notifications
/// in two clear states: Green (Success) and Red (Failed).
abstract class AppSnackBar {
  // Vibrant, high-visibility Green for successful actions
  static const Color successGreen = Color(0xFF15803D);

  // Vivid Red for errors, failures, and validations
  static const Color failedRed = Color(0xFFDC2626);

  /// Displays a floating curved green notification for successful actions.
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context: context,
      message: message,
      backgroundColor: successGreen,
      icon: Icons.check_circle_rounded,
      duration: duration,
    );
  }

  /// Displays a floating curved red notification for failed actions/errors.
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    _show(
      context: context,
      message: message,
      backgroundColor: failedRed,
      icon: Icons.error_outline_rounded,
      duration: duration,
    );
  }

  /// Convenience alias routing to showSuccess (Green)
  static void showInfo(
    BuildContext context,
    String message, {
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    showSuccess(context, message, duration: duration);
  }

  static void _show({
    required BuildContext context,
    required String message,
    required Color backgroundColor,
    required IconData icon,
    required Duration duration,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: duration,
        elevation: 5,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        backgroundColor: backgroundColor,
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
