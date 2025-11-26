import 'package:easy_app/core/error/result.dart';
import 'package:easy_app/core/network/api_service.dart';
import 'package:easy_app/core/storage/storage_service.dart';
import 'package:easy_app/features/home/domain/entities/landing_category.dart';
import 'package:easy_app/features/home/domain/entities/user_summary.dart';
import 'package:easy_app/features/home/domain/entities/app_version.dart';
import 'package:easy_app/features/home/domain/entities/maintenance_status.dart';
import 'package:easy_app/features/home/data/models/user_summary_model.dart';
import 'package:easy_app/features/home/data/models/app_version_model.dart';
import 'package:easy_app/features/home/data/models/maintenance_status_model.dart';
import 'package:easy_app/core/di/dependency_injection.dart';
import 'package:easy_app/core/error/app_error.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Home repository
class HomeRepository {
  final ApiService _apiService;

  HomeRepository({
    ApiService? apiService,
    StorageService? storageService,
  })  : _apiService = apiService ?? getIt<ApiService>();

  /// Get landing categories (modules)
  Future<Result<List<LandingCategory>>> getLandingCategories(
      String userId) async {
    final result = await _apiService.getLandingCategories(userId);
    if (result.isFailure) {
      return Failure(result.errorOrNull!);
    }

    // TODO: Map API response to LandingCategory entities
    // For now, return empty list
    return const Success([]);
  }

  /// Get user profile (for user summary)
  Future<Result<UserSummary>> getUserProfile(String userId) async {
    final result = await _apiService.getUserProfile(userId);
    if (result.isFailure) {
      return Failure(result.errorOrNull!);
    }

    // Map API response to UserSummary entity
    final data = result.valueOrNull as Map<String, dynamic>?;
    if (data == null) {
      return Failure(AppError.validation(
        message: 'User profile data is null',
      ));
    }

    try {
      final model = UserSummaryModel.fromJson(data);
      return Success(model.toEntity());
    } catch (e) {
      return Failure(AppError.unknown(
        message: 'Failed to parse user profile',
        technicalMessage: e.toString(),
      ));
    }
  }

  /// Register push token
  Future<Result<void>> registerPushToken(
    String userId,
    String firebaseToken,
    String hmsToken,
    String appVersion,
  ) async {
    return await _apiService.registerPushToken(
      userId,
      firebaseToken,
      hmsToken,
      appVersion,
    );
  }

  /// Get app version
  Future<Result<AppVersion>> getAppVersion(String appType) async {
    final result = await _apiService.getAppVersion(appType);
    if (result.isFailure) {
      return Failure(result.errorOrNull!);
    }

    // Map API response to AppVersion entity
    final data = result.valueOrNull as Map<String, dynamic>?;
    if (data == null) {
      return Failure(AppError.validation(
        message: 'App version data is null',
      ));
    }

    try {
      // Get current version from package_info
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final model = AppVersionModel.fromJson({
        ...data,
        'currentVersion': currentVersion,
      });
      return Success(model.toEntity());
    } catch (e) {
      return Failure(AppError.unknown(
        message: 'Failed to parse app version',
        technicalMessage: e.toString(),
      ));
    }
  }

  /// Get maintenance status
  Future<Result<MaintenanceStatus>> getMaintenanceStatus() async {
    final result = await _apiService.getMaintenanceStatus();
    if (result.isFailure) {
      return Failure(result.errorOrNull!);
    }

    // Map API response to MaintenanceStatus entity
    final data = result.valueOrNull as Map<String, dynamic>?;
    if (data == null) {
      return Failure(AppError.validation(
        message: 'Maintenance status data is null',
      ));
    }

    try {
      final model = MaintenanceStatusModel.fromJson(data);
      return Success(model.toEntity());
    } catch (e) {
      return Failure(AppError.unknown(
        message: 'Failed to parse maintenance status',
        technicalMessage: e.toString(),
      ));
    }
  }
}
