/// Base exception class
class AppException implements Exception {
  final String message;
  final int? code;

  const AppException({required this.message, this.code});

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Server/API exceptions
class ServerException extends AppException {
  const ServerException({required super.message, super.code});
}

/// Cache/Local storage exceptions
class CacheException extends AppException {
  const CacheException({required super.message, super.code});
}

/// Network connectivity exceptions
class NetworkException extends AppException {
  const NetworkException({required super.message, super.code});
}

/// Validation exceptions
class ValidationException extends AppException {
  const ValidationException({required super.message, super.code});
}

/// Permission exceptions
class PermissionException extends AppException {
  const PermissionException({required super.message, super.code});
}
