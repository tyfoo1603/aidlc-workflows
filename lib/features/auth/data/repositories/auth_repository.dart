import 'package:easy_app/core/error/app_error.dart';
import 'package:easy_app/core/error/result.dart';
import 'package:easy_app/core/network/api_service.dart';
import 'package:easy_app/core/storage/secure_token_storage.dart';
import 'package:easy_app/core/di/dependency_injection.dart';
import 'package:easy_app/features/auth/domain/entities/token.dart';

/// Authentication repository
class AuthRepository {
  final ApiService _apiService;
  final SecureTokenStorage _tokenStorage;

  AuthRepository({
    ApiService? apiService,
    SecureTokenStorage? tokenStorage,
  })  : _apiService = apiService ?? getIt<ApiService>(),
        _tokenStorage = tokenStorage ?? getIt<SecureTokenStorage>();

  /// Exchange authorization code for tokens
  Future<Result<Token>> exchangeAuthCode(String code) async {
    final result = await _apiService.exchangeAuthCode(code);
    if (result.isFailure) {
      return Failure(result.errorOrNull!);
    }

    final token = result.valueOrNull!;
    await _tokenStorage.saveTokens(token);
    return Success(token);
  }

  /// Refresh access token
  Future<Result<Token>> refreshToken(String refreshToken) async {
    final result = await _apiService.refreshToken(refreshToken);
    if (result.isFailure) {
      return Failure(result.errorOrNull!);
    }

    final token = result.valueOrNull!;
    await _tokenStorage.saveTokens(token);
    return Success(token);
  }

  /// Get stored tokens
  Future<Result<Token?>> getStoredTokens() async {
    try {
      final tokens = await _tokenStorage.getTokens();
      return Success(tokens);
    } catch (e) {
      return Failure(AppError.unknown(
        message: 'Failed to retrieve stored tokens',
        technicalMessage: e.toString(),
      ));
    }
  }

  /// Clear tokens
  Future<Result<void>> clearTokens() async {
    try {
      await _tokenStorage.clearTokens();
      return const Success(null);
    } catch (e) {
      return Failure(AppError.unknown(
        message: 'Failed to clear tokens',
        technicalMessage: e.toString(),
      ));
    }
  }

  /// Revoke sign-in sessions
  Future<Result<void>> revokeSignInSessions() async {
    return await _apiService.revokeSignInSessions();
  }

  /// Invalidate all refresh tokens
  Future<Result<void>> invalidateRefreshTokens() async {
    return await _apiService.invalidateRefreshTokens();
  }
}
