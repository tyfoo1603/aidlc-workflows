import 'package:easy_app/core/error/result.dart';
import 'package:easy_app/features/home/data/repositories/home_repository.dart';
import 'package:easy_app/features/home/domain/entities/landing_category.dart';
import 'package:easy_app/core/di/dependency_injection.dart';

/// Load home modules use case
class LoadHomeModulesUseCase {
  final HomeRepository _homeRepository;

  LoadHomeModulesUseCase({
    HomeRepository? homeRepository,
  }) : _homeRepository = homeRepository ?? getIt<HomeRepository>();

  /// Execute loading home modules
  Future<Result<List<LandingCategory>>> execute(String userId) async {
    return await _homeRepository.getLandingCategories(userId);
  }
}
