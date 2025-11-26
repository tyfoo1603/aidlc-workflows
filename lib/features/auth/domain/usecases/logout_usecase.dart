import 'package:easy_app/core/error/app_error.dart';
import 'package:easy_app/core/error/result.dart';
import 'package:easy_app/core/storage/storage_service.dart';
import 'package:easy_app/features/auth/data/repositories/auth_repository.dart';
import 'package:easy_app/core/di/dependency_injection.dart';

/// Logout use case
class LogoutUseCase {
  final AuthRepository _authRepository;
  final StorageService _storageService;

  LogoutUseCase({
    AuthRepository? authRepository,
    StorageService? storageService,
  })  : _authRepository = authRepository ?? getIt<AuthRepository>(),
        _storageService = storageService ?? getIt<StorageService>();

  /// Execute logout
  Future<Result<void>> execute() async {
    try {
      // Clear tokens
      final clearTokensResult = await _authRepository.clearTokens();
      if (clearTokensResult.isFailure) {
        // Continue with logout even if token clearing fails
      }

      // Clear all cached data
      await _storageService.clearAllCache();

      // Attempt to revoke server sessions (non-blocking)
      _authRepository.revokeSignInSessions().ignore();
      _authRepository.invalidateRefreshTokens().ignore();

      return const Success(null);
    } catch (e) {
      return Failure(AppError.unknown(
        message: 'Failed to logout',
        technicalMessage: e.toString(),
      ));
    }
  }
}
