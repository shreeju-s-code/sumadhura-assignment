
abstract class ApiEndpoints {
  // Default base URL pointing to MockAPI 
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
