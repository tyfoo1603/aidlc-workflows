import 'package:easy_app/core/error/result.dart';
import 'package:easy_app/features/home/data/repositories/home_repository.dart';
import 'package:easy_app/features/home/domain/entities/user_summary.dart';
import 'package:easy_app/core/di/dependency_injection.dart';

/// Load user profile use case
class LoadUserProfileUseCase {
  final HomeRepository _homeRepository;

  LoadUserProfileUseCase({
    HomeRepository? homeRepository,
  }) : _homeRepository = homeRepository ?? getIt<HomeRepository>();

  /// Execute loading user profile
  Future<Result<UserSummary>> execute(String userId) async {
    return await _homeRepository.getUserProfile(userId);
  }
}
