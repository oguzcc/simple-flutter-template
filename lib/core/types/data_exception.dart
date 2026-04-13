import 'package:dio/dio.dart';

/// Base exception for all domain-level errors.
///
/// Subclass this rather than throwing `Exception('...')` — typed exceptions
/// make error handling in `fold`/`catch` branches explicit.
sealed class AppException implements Exception {
  const AppException(this.message, {this.cause, this.stackTrace});

  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() => message;
}

/// Thrown when the network layer fails (connectivity, timeout, bad response).
class NetworkException extends AppException {
  const NetworkException(
    super.message, {
    this.statusCode,
    super.cause,
    super.stackTrace,
  });

  final int? statusCode;

  factory NetworkException.fromDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.cancel:
        return NetworkException('Request was cancelled', cause: error);
      case DioExceptionType.connectionTimeout:
        return NetworkException('Connection timeout', cause: error);
      case DioExceptionType.receiveTimeout:
        return NetworkException('Receive timeout', cause: error);
      case DioExceptionType.sendTimeout:
        return NetworkException('Send timeout', cause: error);
      case DioExceptionType.badCertificate:
        return NetworkException('Bad certificate', cause: error);
      case DioExceptionType.connectionError:
        final isSocket =
            error.message?.contains('SocketException') ?? false;
        return NetworkException(
          isSocket ? 'No internet connection' : 'Network error',
          cause: error,
        );
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode;
        final data = error.response?.data;
        final serverMsg = data is Map<String, dynamic>
            ? data['message']?.toString()
            : null;
        return NetworkException(
          serverMsg ?? _defaultStatusMessage(status),
          statusCode: status,
          cause: error,
        );
      case DioExceptionType.unknown:
        return NetworkException('Unexpected network error', cause: error);
    }
  }

  static String _defaultStatusMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not found';
      case 409:
        return 'Conflict';
      case 422:
        return 'Unprocessable entity';
      case 429:
        return 'Too many requests';
      case 500:
        return 'Internal server error';
      case 502:
        return 'Bad gateway';
      case 503:
        return 'Service unavailable';
      default:
        return 'Something went wrong';
    }
  }
}

/// Thrown by authentication flows (sign-in, sign-up, social login, token refresh).
class AuthException extends AppException {
  const AuthException(
    super.message, {
    this.code,
    super.cause,
    super.stackTrace,
  });

  final String? code;
}

/// Thrown when data cannot be parsed into the expected shape.
class ParseException extends AppException {
  const ParseException(super.message, {super.cause, super.stackTrace});
}

/// Thrown by platform services (permissions, storage, device info).
class PlatformException extends AppException {
  const PlatformException(super.message, {super.cause, super.stackTrace});
}

/// Legacy error wrapper — kept for backwards compatibility with existing
/// `AsyncRes<T>` typedefs. New code should use [AppException] subtypes.
class Err implements Exception {
  Err(Object error) {
    if (error is DioException) {
      message = NetworkException.fromDio(error).message;
    } else {
      message = error.toString();
    }
  }

  late String message;

  @override
  String toString() => message;
}
