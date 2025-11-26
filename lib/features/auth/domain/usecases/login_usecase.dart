import 'package:easy_app/core/error/app_error.dart';
import 'package:easy_app/core/error/result.dart';
import 'package:easy_app/features/auth/data/repositories/auth_repository.dart';
import 'package:easy_app/features/auth/domain/entities/token.dart';
import 'package:easy_app/core/di/dependency_injection.dart';

/// Login use case
class LoginUseCase {
  final AuthRepository _authRepository;

  LoginUseCase({
    AuthRepository? authRepository,
  }) : _authRepository = authRepository ?? getIt<AuthRepository>();

  /// Execute login with authorization code
  Future<Result<Token>> execute(String authorizationCode) async {
    if (authorizationCode.isEmpty) {
      return Failure(AppError.validation(
        message: 'Authorization code is required',
      ));
    }

    return await _authRepository.exchangeAuthCode(authorizationCode);
  }
}
