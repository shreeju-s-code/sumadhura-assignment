import 'package:flutter/services.dart';

/// Centralized utility for high-tactile haptic feedback and vibrations.
abstract class HapticHelper {
  /// Delivers an unmistakable, heavy vibration feedback pulse.
  static Future<void> heavyVibrate() async {
    try {
      await HapticFeedback.heavyImpact();
      // Second pulse to create a reinforced tactile feel on Android devices
      await Future.delayed(const Duration(milliseconds: 60));
      await HapticFeedback.heavyImpact();
    } catch (_) {
      // Graceful fallback if device vibration motor is unavailable or restricted
    }
  }

  /// Single heavy impact vibration
  static Future<void> singleHeavy() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (_) {}
  }
}
