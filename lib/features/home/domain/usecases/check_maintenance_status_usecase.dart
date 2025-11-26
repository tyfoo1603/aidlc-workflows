import 'package:easy_app/core/error/result.dart';
import 'package:easy_app/features/home/data/repositories/home_repository.dart';
import 'package:easy_app/features/home/domain/entities/maintenance_status.dart';
import 'package:easy_app/core/di/dependency_injection.dart';

/// Check maintenance status use case
class CheckMaintenanceStatusUseCase {
  final HomeRepository _homeRepository;

  CheckMaintenanceStatusUseCase({
    HomeRepository? homeRepository,
  }) : _homeRepository = homeRepository ?? getIt<HomeRepository>();

  /// Execute maintenance status check
  Future<Result<MaintenanceStatus>> execute() async {
    return await _homeRepository.getMaintenanceStatus();
  }
}
