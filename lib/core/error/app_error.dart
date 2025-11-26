import 'package:equatable/equatable.dart';

/// Error type classification
enum ErrorType {
  network,
  authentication,
  server,
  validation,
  unknown,
}

/// Application error
class AppError extends Equatable {
  final ErrorType type;
  final String message;
  final String? technicalMessage;
  final int? statusCode;
  final bool isRetryable;

  const AppError({
    required this.type,
    required this.message,
    this.technicalMessage,
    this.statusCode,
    required this.isRetryable,
  });

  /// Create network error
  factory AppError.network({
    required String message,
    String? technicalMessage,
    bool isRetryable = true,
  }) {
    return AppError(
      type: ErrorType.network,
      message: message,
      technicalMessage: technicalMessage,
      isRetryable: isRetryable,
    );
  }

  /// Create authentication error
  factory AppError.authentication({
    required String message,
    String? technicalMessage,
    int? statusCode,
  }) {
    return AppError(
      type: ErrorType.authentication,
      message: message,
      technicalMessage: technicalMessage,
      statusCode: statusCode ?? 401,
      isRetryable: false,
    );
  }

  /// Create server error
  factory AppError.server({
    required String message,
    String? technicalMessage,
    int? statusCode,
    bool isRetryable = false,
  }) {
    return AppError(
      type: ErrorType.server,
      message: message,
      technicalMessage: technicalMessage,
      statusCode: statusCode ?? 500,
      isRetryable: isRetryable,
    );
  }

  /// Create validation error
  factory AppError.validation({
    required String message,
    String? technicalMessage,
  }) {
    return AppError(
      type: ErrorType.validation,
      message: message,
      technicalMessage: technicalMessage,
      isRetryable: false,
    );
  }

  /// Create unknown error
  factory AppError.unknown({
    required String message,
    String? technicalMessage,
  }) {
    return AppError(
      type: ErrorType.unknown,
      message: message,
      technicalMessage: technicalMessage,
      isRetryable: false,
    );
  }

  @override
  List<Object?> get props => [
        type,
        message,
        technicalMessage,
        statusCode,
        isRetryable,
      ];
}

