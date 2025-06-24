import 'package:dio/dio.dart';

class NetworkExceptions {
  final String message;
  final int? statusCode;
  final String? errorCode;

  const NetworkExceptions({required this.message, this.statusCode, this.errorCode});

  static NetworkExceptions fromDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
        return const NetworkExceptions(
          message: 'Connection timeout. Please check your internet connection.',
          errorCode: 'CONNECTION_TIMEOUT',
        );
      case DioExceptionType.sendTimeout:
        return const NetworkExceptions(message: 'Send timeout. Please try again.', errorCode: 'SEND_TIMEOUT');
      case DioExceptionType.receiveTimeout:
        return const NetworkExceptions(message: 'Receive timeout. Please try again.', errorCode: 'RECEIVE_TIMEOUT');
      case DioExceptionType.badResponse:
        return _handleBadResponse(dioException);
      case DioExceptionType.cancel:
        return const NetworkExceptions(message: 'Request was cancelled.', errorCode: 'REQUEST_CANCELLED');
      case DioExceptionType.connectionError:
        return const NetworkExceptions(
          message: 'No internet connection. Please check your network.',
          errorCode: 'NO_INTERNET',
        );
      case DioExceptionType.badCertificate:
        return const NetworkExceptions(message: 'Bad certificate. Please try again.', errorCode: 'BAD_CERTIFICATE');
      case DioExceptionType.unknown:
        return NetworkExceptions(message: 'Unexpected error: ${dioException.message}', errorCode: 'UNKNOWN_ERROR');
    }
  }

  static NetworkExceptions _handleBadResponse(DioException dioException) {
    final statusCode = dioException.response?.statusCode;
    final data = dioException.response?.data;

    String message = 'An error occurred';
    String? errorCode;

    // Try to extract error message from response
    if (data is Map<String, dynamic>) {
      message = data['message'] ?? data['error'] ?? data['detail'] ?? message;
      errorCode = data['code'] ?? data['error_code'];
    }

    switch (statusCode) {
      case 400:
        return NetworkExceptions(
          message: message.isNotEmpty ? message : 'Bad request',
          statusCode: statusCode,
          errorCode: errorCode ?? 'BAD_REQUEST',
        );
      case 401:
        return NetworkExceptions(
          message: message.isNotEmpty ? message : 'Unauthorized access',
          statusCode: statusCode,
          errorCode: errorCode ?? 'UNAUTHORIZED',
        );
      case 403:
        return NetworkExceptions(
          message: message.isNotEmpty ? message : 'Access forbidden',
          statusCode: statusCode,
          errorCode: errorCode ?? 'FORBIDDEN',
        );
      case 404:
        return NetworkExceptions(
          message: message.isNotEmpty ? message : 'Resource not found',
          statusCode: statusCode,
          errorCode: errorCode ?? 'NOT_FOUND',
        );
      case 422:
        return NetworkExceptions(
          message: message.isNotEmpty ? message : 'Validation error',
          statusCode: statusCode,
          errorCode: errorCode ?? 'VALIDATION_ERROR',
        );
      case 429:
        return NetworkExceptions(
          message: message.isNotEmpty ? message : 'Too many requests',
          statusCode: statusCode,
          errorCode: errorCode ?? 'RATE_LIMITED',
        );
      case 500:
        return NetworkExceptions(
          message: message.isNotEmpty ? message : 'Internal server error',
          statusCode: statusCode,
          errorCode: errorCode ?? 'SERVER_ERROR',
        );
      case 502:
        return NetworkExceptions(
          message: message.isNotEmpty ? message : 'Bad gateway',
          statusCode: statusCode,
          errorCode: errorCode ?? 'BAD_GATEWAY',
        );
      case 503:
        return NetworkExceptions(
          message: message.isNotEmpty ? message : 'Service unavailable',
          statusCode: statusCode,
          errorCode: errorCode ?? 'SERVICE_UNAVAILABLE',
        );
      default:
        return NetworkExceptions(
          message: message.isNotEmpty ? message : 'Something went wrong',
          statusCode: statusCode,
          errorCode: errorCode ?? 'UNKNOWN_ERROR',
        );
    }
  }

  static NetworkExceptions unexpectedError(String message) {
    return NetworkExceptions(message: 'Unexpected error: $message', errorCode: 'UNEXPECTED_ERROR');
  }

  @override
  String toString() {
    return 'NetworkException: $message (Code: $errorCode, Status: $statusCode)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NetworkExceptions &&
        other.message == message &&
        other.statusCode == statusCode &&
        other.errorCode == errorCode;
  }

  @override
  int get hashCode => message.hashCode ^ statusCode.hashCode ^ errorCode.hashCode;
}
