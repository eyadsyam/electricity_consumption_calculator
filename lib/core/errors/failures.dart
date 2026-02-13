import 'package:equatable/equatable.dart';

/// Base class for all failures in the app
abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Server/API related failures
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code});
}

/// Cache/Local storage failures
class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.code});
}

/// Network connectivity failures
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code});
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.code});
}

/// Permission failures (mic, camera, etc.)
class PermissionFailure extends Failure {
  const PermissionFailure({required super.message, super.code});
}

/// General/Unknown failures
class UnknownFailure extends Failure {
  const UnknownFailure({required super.message, super.code});
}
