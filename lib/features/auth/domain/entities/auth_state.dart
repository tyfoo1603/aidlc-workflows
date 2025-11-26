import 'package:equatable/equatable.dart';

/// Authentication state for state machine
enum AuthStateType {
  initial,
  authorizing,
  codeReceived,
  exchanging,
  authenticated,
  error,
}

/// Authentication state entity
class AuthState extends Equatable {
  final AuthStateType type;
  final String? errorMessage;
  final String? userId;

  const AuthState({
    required this.type,
    this.errorMessage,
    this.userId,
  });

  /// Initial state
  factory AuthState.initial() {
    return const AuthState(type: AuthStateType.initial);
  }

  /// Authorizing state
  factory AuthState.authorizing() {
    return const AuthState(type: AuthStateType.authorizing);
  }

  /// Code received state
  factory AuthState.codeReceived() {
    return const AuthState(type: AuthStateType.codeReceived);
  }

  /// Exchanging state
  factory AuthState.exchanging() {
    return const AuthState(type: AuthStateType.exchanging);
  }

  /// Authenticated state
  factory AuthState.authenticated(String userId) {
    return AuthState(
      type: AuthStateType.authenticated,
      userId: userId,
    );
  }

  /// Error state
  factory AuthState.error(String errorMessage) {
    return AuthState(
      type: AuthStateType.error,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [type, errorMessage, userId];
}
