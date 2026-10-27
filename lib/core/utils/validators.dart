/// Form validation utilities enforcing visitor management business rules.
abstract class Validators {
  /// Name is required and must have at least 2 characters.
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Visitor name is required.';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters.';
    }
    return null;
  }

  /// Purpose is required.
  static String? validatePurpose(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Purpose of visit is required.';
    }
    return null;
  }

  /// Mobile number must contain exactly 10 digits.
  static String? validateMobile(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile number is required.';
    }
    final cleaned = value.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length != 10) {
      return 'Mobile number must contain exactly 10 digits.';
    }
    return null;
  }

  /// Email is optional, but if provided, it must be a valid email format.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address.';
    }
    return null;
  }
}
