import 'package:easy_app/core/error/app_error.dart';
import 'package:easy_app/core/error/result.dart';
import 'package:easy_app/features/auth/data/repositories/auth_repository.dart';
import 'package:easy_app/features/auth/domain/entities/token.dart';
import 'package:easy_app/core/di/dependency_injection.dart';

/// Refresh token use case
class RefreshTokenUseCase {
  final AuthRepository _authRepository;

  RefreshTokenUseCase({
    AuthRepository? authRepository,
  }) : _authRepository = authRepository ?? getIt<AuthRepository>();

  /// Execute token refresh
  Future<Result<Token>> execute() async {
    // Get stored tokens
    final tokensResult = await _authRepository.getStoredTokens();
    if (tokensResult.isFailure || tokensResult.valueOrNull == null) {
      return Failure(AppError.authentication(
        message: 'No refresh token available',
      ));
    }

    final tokens = tokensResult.valueOrNull!;
    return await _authRepository.refreshToken(tokens.refreshToken);
  }
}
