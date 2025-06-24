/// Base exception class for all custom exceptions
abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException({required this.message, this.code});

  @override
  String toString() => 'AppException: $message';
}

/// Generic base exception that's used by resources and usecases
class BaseException extends AppException {
  const BaseException({required super.message, super.code});

  const BaseException.unknownError() : super(message: 'An unknown error occurred');

  @override
  String toString() => 'BaseException: $message';
}

/// Exception thrown when user session is invalid
class SessionException extends AppException {
  const SessionException({required super.message, super.code});

  @override
  String toString() => 'SessionException: $message';
}

/// Exception thrown when there's a connection error
class ConnectionException extends AppException {
  const ConnectionException() : super(message: 'Connection error occurred');

  @override
  String toString() => 'ConnectionException: $message';
}

/// Exception thrown when there's a network-related error
class NetworkException extends AppException {
  const NetworkException({required super.message, super.code});

  @override
  String toString() => 'NetworkException: $message';
}

/// Exception thrown when there's a server error (5xx)
class ServerException extends AppException {
  final int statusCode;

  const ServerException({required super.message, required this.statusCode, super.code});

  @override
  String toString() => 'ServerException ($statusCode): $message';
}

/// Exception thrown when there's a client error (4xx)
class ClientException extends AppException {
  final int statusCode;

  const ClientException({required super.message, required this.statusCode, super.code});

  @override
  String toString() => 'ClientException ($statusCode): $message';
}

/// Exception thrown when authentication fails (401)
class AuthenticationException extends AppException {
  const AuthenticationException({required super.message, super.code});

  @override
  String toString() => 'AuthenticationException: $message';
}

/// Exception thrown when authorization fails (403)
class AuthorizationException extends AppException {
  const AuthorizationException({required super.message, super.code});

  @override
  String toString() => 'AuthorizationException: $message';
}

/// Exception thrown when a resource is not found (404)
class NotFoundException extends AppException {
  const NotFoundException({required super.message, super.code});

  @override
  String toString() => 'NotFoundException: $message';
}

/// Exception thrown when there's a validation error
class ValidationException extends AppException {
  final Map<String, List<String>>? errors;

  const ValidationException({required super.message, this.errors, super.code});

  @override
  String toString() => 'ValidationException: $message';
}

/// Exception thrown when there's a cache-related error
class CacheException extends AppException {
  const CacheException({required super.message, super.code});

  @override
  String toString() => 'CacheException: $message';
}

/// Exception thrown when there's a local storage error
class LocalStorageException extends AppException {
  const LocalStorageException({required super.message, super.code});

  @override
  String toString() => 'LocalStorageException: $message';
}

/// Exception thrown when there's a parsing error
class ParsingException extends AppException {
  const ParsingException({required super.message, super.code});

  @override
  String toString() => 'ParsingException: $message';
}

/// Exception thrown when there's a timeout error
class TimeoutException extends AppException {
  const TimeoutException({required super.message, super.code});

  @override
  String toString() => 'TimeoutException: $message';
}
