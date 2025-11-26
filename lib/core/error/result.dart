import 'package:easy_app/core/error/app_error.dart';

/// Result type for error handling
/// Represents either a success value or a failure error
sealed class Result<T> {
  const Result();
}

/// Success result containing a value
final class Success<T> extends Result<T> {
  final T value;

  const Success(this.value);
}

/// Failure result containing an error
final class Failure<T> extends Result<T> {
  final AppError error;

  const Failure(this.error);
}

/// Extension methods for Result
extension ResultExtension<T> on Result<T> {
  /// Check if result is success
  bool get isSuccess => this is Success<T>;

  /// Check if result is failure
  bool get isFailure => this is Failure<T>;

  /// Get value if success, null otherwise
  T? get valueOrNull => switch (this) {
        Success(value: final v) => v,
        Failure() => null,
      };

  /// Get error if failure, null otherwise
  AppError? get errorOrNull => switch (this) {
        Success() => null,
        Failure(error: final e) => e,
      };

  /// Fold result to a single value
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(AppError error) onFailure,
  }) {
    return switch (this) {
      Success(value: final v) => onSuccess(v),
      Failure(error: final e) => onFailure(e),
    };
  }
}
