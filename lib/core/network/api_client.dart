import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_endpoints.dart';
import 'api_exceptions.dart';

/// Configured Dio HTTP client with timeouts, logging, and error transformation.
class ApiClient {
  late final Dio _dio;

  ApiClient({String? baseUrl, Dio? customDio}) {
    if (customDio != null) {
      _dio = customDio;
    } else {
      String resolvedBaseUrl = (baseUrl ?? ApiEndpoints.baseUrl).trim();
      if (!resolvedBaseUrl.endsWith('/')) {
        resolvedBaseUrl = '$resolvedBaseUrl/';
      }

      _dio = Dio(
        BaseOptions(
          baseUrl: resolvedBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            // Yellow ANSI code for transparent request tracing
            debugPrint('\x1B[33m⚡ [API REQUEST] ${options.method} ${options.uri}\x1B[0m');
            return handler.next(options);
          },
          onResponse: (response, handler) {
            // Bright green ANSI code for successful API calls
            final status = response.statusCode ?? 200;
            final method = response.requestOptions.method;
            final uri = response.requestOptions.uri;
            debugPrint('\x1B[1;32m✔ [API SUCCESS $status] $method $uri\x1B[0m');
            return handler.next(response);
          },
          onError: (DioException e, handler) {
            // Bright red ANSI code for failed API calls
            final status = e.response?.statusCode ?? 'FAIL';
            final method = e.requestOptions.method;
            final uri = e.requestOptions.uri;
            final message = e.message;
            debugPrint('\x1B[1;31m✖ [API FAIL $status] $method $uri -> $message\x1B[0m');
            return handler.reject(e);
          },
        ),
      );
    }
  }

  Dio get dio => _dio;

  String _cleanPath(String path) {
    if (path.startsWith('/')) {
      return path.substring(1);
    }
    return path;
  }

  /// Update the base URL dynamically at runtime if the user reconfigures it.
  void updateBaseUrl(String newUrl) {
    String cleanUrl = newUrl.trim();
    if (!cleanUrl.endsWith('/')) {
      cleanUrl = '$cleanUrl/';
    }
    _dio.options.baseUrl = cleanUrl;
  }

  /// Perform a GET request.
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(_cleanPath(path), queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnexpectedApiException(e.toString());
    }
  }

  /// Perform a POST request.
  Future<dynamic> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(_cleanPath(path), data: data);
      return response.data;
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnexpectedApiException(e.toString());
    }
  }

  /// Perform a PUT request.
  Future<dynamic> put(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(_cleanPath(path), data: data);
      return response.data;
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnexpectedApiException(e.toString());
    }
  }

  /// Perform a DELETE request.
  Future<dynamic> delete(String path) async {
    try {
      final response = await _dio.delete(_cleanPath(path));
      return response.data;
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnexpectedApiException(e.toString());
    }
  }
}
