import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class AppLogger {
  static void log(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toString();
      developer.log(
        '[$timestamp] $message',
        name: tag ?? 'AppLogger',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String? tag,
  }) {
    final timestamp = DateTime.now().toString();
    developer.log(
      '[$timestamp] ERROR: $message',
      name: tag ?? 'AppError',
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void api(
    String endpoint, {
    Object? request,
    Object? response,
    Map<String, String>? headers,
    Object? error,
    int? statusCode,
  }) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toString();
      developer.log(
        '[$timestamp] API Call to $endpoint',
        name: 'API',
        error: error,
      );

      if (headers != null) {
        final sanitizedHeaders = Map<String, String>.from(headers)
          ..updateAll(
            (key, value) => key.toLowerCase().contains('key') ? '***' : value,
          );
        developer.log(
          '[$timestamp] Headers: $sanitizedHeaders',
          name: 'API Headers',
        );
      }

      if (request != null) {
        developer.log('[$timestamp] Request: $request', name: 'API Request');
      }
      if (response != null) {
        developer.log('[$timestamp] Response: $response', name: 'API Response');
      }
      if (statusCode != null) {
        final status = statusCode == 200 ? 'SUCCESS' : 'FAILED';
        developer.log(
          '[$timestamp] Status $statusCode ($status)',
          name: 'API Status',
        );
      }
    }
  }

  static void performance(String operation, Duration duration) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toString();
      developer.log(
        '[$timestamp] $operation took ${duration.inMilliseconds}ms',
        name: 'Performance',
      );
    }
  }
}
