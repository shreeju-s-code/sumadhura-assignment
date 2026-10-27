import 'package:dio/dio.dart';

/// Base custom exception for all API-related failures.
abstract class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Thrown when there is no network connection or a connection timeout.
class NetworkException extends ApiException {
  const NetworkException([super.message = 'Unable to connect to the server. Please check your internet connection.']);
}

/// Thrown when the requested resource (e.g., visitor ID) is not found (404).
class NotFoundException extends ApiException {
  const NotFoundException([super.message = 'The requested visitor could not be found.'])
      : super(statusCode: 404);
}

/// Thrown on bad request / validation failure (400 / 422).
class ValidationApiException extends ApiException {
  const ValidationApiException(super.message, {super.statusCode = 400});
}

/// Thrown when the server returns a 5xx response.
class ServerException extends ApiException {
  const ServerException([super.message = 'A server error occurred. Please try again later.'])
      : super(statusCode: 500);
}

/// Thrown when an unexpected error occurs during request execution or parsing.
class UnexpectedApiException extends ApiException {
  const UnexpectedApiException([super.message = 'An unexpected error occurred. Please try again.']);
}

/// Helper method to transform Dio exceptions into clean domain exceptions.
ApiException handleDioError(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      return const NetworkException('Connection timed out. Please verify your network connection.');

    case DioExceptionType.badResponse:
      final statusCode = error.response?.statusCode;
      if (statusCode == 404) {
        return const NotFoundException('Visitor record not found.');
      } else if (statusCode != null && statusCode >= 500) {
        return const ServerException('Server error. Please try again shortly.');
      } else {
        final data = error.response?.data;
        String msg = 'Request failed with status $statusCode.';
        if (data is Map && data.containsKey('message')) {
          msg = data['message'].toString();
        } else if (data is String && data.isNotEmpty) {
          msg = data;
        }
        return ValidationApiException(msg, statusCode: statusCode);
      }

    case DioExceptionType.cancel:
      return const UnexpectedApiException('The request was cancelled.');

    case DioExceptionType.unknown:
    default:
      if (error.error != null && error.error.toString().contains('SocketException')) {
        return const NetworkException('No internet connection detected.');
      }
      return UnexpectedApiException(error.message ?? 'An unexpected network error occurred.');
  }
}
