import 'package:easy_app/core/error/result.dart';
import 'package:easy_app/features/home/data/repositories/home_repository.dart';
import 'package:easy_app/core/di/dependency_injection.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Register push token use case
class RegisterPushTokenUseCase {
  final HomeRepository _homeRepository;

  RegisterPushTokenUseCase({
    HomeRepository? homeRepository,
  }) : _homeRepository = homeRepository ?? getIt<HomeRepository>();

  /// Execute push token registration
  Future<Result<void>> execute(
    String userId,
    String firebaseToken,
    String hmsToken,
  ) async {
    // Get app version
    final packageInfo = await PackageInfo.fromPlatform();
    final appVersion = packageInfo.version;

    return await _homeRepository.registerPushToken(
      userId,
      firebaseToken,
      hmsToken,
      appVersion,
    );
  }
}
