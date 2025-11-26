import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_app/core/navigation/navigation_service.dart';
import 'package:easy_app/core/error/result.dart';
import 'package:easy_app/features/auth/domain/entities/auth_state.dart';
import 'package:easy_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:easy_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:easy_app/features/auth/domain/usecases/refresh_token_usecase.dart';
import 'package:easy_app/core/di/dependency_injection.dart';

/// Authentication Cubit
class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final RefreshTokenUseCase _refreshTokenUseCase;
  final NavigationService _navigationService;

  AuthCubit({
    LoginUseCase? loginUseCase,
    LogoutUseCase? logoutUseCase,
    RefreshTokenUseCase? refreshTokenUseCase,
    NavigationService? navigationService,
  })  : _loginUseCase = loginUseCase ?? getIt<LoginUseCase>(),
        _logoutUseCase = logoutUseCase ?? getIt<LogoutUseCase>(),
        _refreshTokenUseCase =
            refreshTokenUseCase ?? getIt<RefreshTokenUseCase>(),
        _navigationService = navigationService ?? getIt<NavigationService>(),
        super(AuthState.initial());

  /// Initialize authentication state on app launch
  Future<void> initialize() async {
    // TODO: Check stored tokens and validate
    // If valid tokens exist, set authenticated state
    // If tokens expired, attempt refresh
    // If refresh fails, stay in initial state
  }

  /// Start login flow
  Future<void> login() async {
    emit(AuthState.authorizing());
    // TODO: Open OAuth webview
    // Intercept authorization code
    // Call login with code
  }

  /// Handle authorization code received
  Future<void> handleAuthorizationCode(String code) async {
    emit(AuthState.codeReceived());
    emit(AuthState.exchanging());

    final result = await _loginUseCase.execute(code);
    if (result.isFailure) {
      emit(AuthState.error(result.errorOrNull!.message));
      return;
    }

    final token = result.valueOrNull!;
    emit(AuthState.authenticated(token.userId));
    await _navigationService.navigateToHome();
  }

  /// Logout
  Future<void> logout() async {
    final result = await _logoutUseCase.execute();
    if (result.isFailure) {
      emit(AuthState.error(result.errorOrNull!.message));
      return;
    }

    emit(AuthState.initial());
    await _navigationService.navigateToLogin();
  }

  /// Refresh token
  Future<void> refreshToken() async {
    final result = await _refreshTokenUseCase.execute();
    if (result.isFailure) {
      // If refresh fails, force logout
      await logout();
    }
  }
}
