import 'package:easy_app/core/error/result.dart';
import 'package:easy_app/features/home/data/repositories/home_repository.dart';
import 'package:easy_app/features/home/domain/entities/app_version.dart';
import 'package:easy_app/core/di/dependency_injection.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Check app version use case
class CheckAppVersionUseCase {
  final HomeRepository _homeRepository;

  CheckAppVersionUseCase({
    HomeRepository? homeRepository,
  }) : _homeRepository = homeRepository ?? getIt<HomeRepository>();

  /// Execute app version check
  Future<Result<AppVersion>> execute() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final appType =
        packageInfo.packageName; // or determine app type (android/ios)

    return await _homeRepository.getAppVersion(appType);
  }
}
