/// Central API configuration and endpoint registry.
/// The base URL is configurable and can be customized via environment variables,
/// build configs, or runtime settings.
abstract class ApiEndpoints {
  /// Default base URL pointing to MockAPI or configurable endpoint.
  /// Replace with your MockAPI project endpoint (e.g., https://6600xxxx.mockapi.io/api/v1).
  static String baseUrl = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://6ae0f627be3bc8fead981e6d.mockapi.io/api/v1/',
  );

  /// Endpoint path for visitors collection
  static const String visitors = '/visitors';

  /// Individual visitor by ID
  static String visitorById(String id) => '$visitors/$id';

  /// Check-in action endpoint
  static String checkIn(String id) => '$visitors/$id';

  /// Check-out action endpoint
  static String checkOut(String id) => '$visitors/$id';
}
