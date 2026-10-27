import 'package:flutter/material.dart';

/// Centralized MediaQuery-driven scaling utility for:
/// 1. Text sizes (sp)
/// 2. SizedBox spacing (vSpace, hSpace)
/// 3. Container dimensions (w, h)
/// 4. Padding (paddingAll, paddingSymmetric, paddingLTRB)
class Responsive {
  // Baseline design reference dimensions (standard modern mobile)
  static const double _baseWidth = 375.0;
  static const double _baseHeight = 812.0;

  /// Screen width from MediaQuery
  static double screenWidth(BuildContext context) => MediaQuery.sizeOf(context).width;

  /// Screen height from MediaQuery
  static double screenHeight(BuildContext context) => MediaQuery.sizeOf(context).height;

  /// Bottom inset (e.g. keyboard) from MediaQuery
  static double bottomInset(BuildContext context) => MediaQuery.viewInsetsOf(context).bottom;

  /// Device status bar & notch safe padding
  static EdgeInsets safePadding(BuildContext context) => MediaQuery.paddingOf(context);

  /// --------------------------------------------------------------------------
  /// 1. TEXT SIZE (sp): Scaled dynamically using MediaQuery screen width
  /// Clamped between 0.85x and 1.25x to maintain readability on all Android devices
  /// --------------------------------------------------------------------------
  static double sp(BuildContext context, double fontSize) {
    final scale = (screenWidth(context) / _baseWidth).clamp(0.85, 1.25);
    return fontSize * scale;
  }

  /// --------------------------------------------------------------------------
  /// 2. SIZEDBOX: Responsive spacing using MediaQuery
  /// --------------------------------------------------------------------------
  static Widget vSpace(BuildContext context, double height) {
    return SizedBox(height: h(context, height));
  }

  static Widget hSpace(BuildContext context, double width) {
    return SizedBox(width: w(context, width));
  }

  /// --------------------------------------------------------------------------
  /// 3. CONTAINER: Responsive width and height dimensions using MediaQuery
  /// --------------------------------------------------------------------------
  static double w(BuildContext context, double width) {
    final scale = (screenWidth(context) / _baseWidth).clamp(0.85, 1.3);
    return width * scale;
  }

  static double h(BuildContext context, double height) {
    final scale = (screenHeight(context) / _baseHeight).clamp(0.85, 1.3);
    return height * scale;
  }

  /// --------------------------------------------------------------------------
  /// 4. PADDING: Scaled padding using MediaQuery
  /// --------------------------------------------------------------------------
  static EdgeInsets paddingAll(BuildContext context, double value) {
    final scaled = w(context, value);
    return EdgeInsets.all(scaled);
  }

  static EdgeInsets paddingSymmetric(
    BuildContext context, {
    double horizontal = 0.0,
    double vertical = 0.0,
  }) {
    return EdgeInsets.symmetric(
      horizontal: w(context, horizontal),
      vertical: h(context, vertical),
    );
  }

  static EdgeInsets paddingLTRB(
    BuildContext context,
    double left,
    double top,
    double right,
    double bottom,
  ) {
    return EdgeInsets.fromLTRB(
      w(context, left),
      h(context, top),
      w(context, right),
      h(context, bottom),
    );
  }

  /// Responsive QR code dimension based on screen width
  static double qrCodeSize(BuildContext context) {
    final screenW = screenWidth(context);
    return (screenW * 0.52).clamp(160.0, 240.0);
  }

  /// Responsive QR scanner frame cutout box based on screen width
  static double scannerBoxSize(BuildContext context) {
    final screenW = screenWidth(context);
    return (screenW * 0.68).clamp(220.0, 320.0);
  }
}
