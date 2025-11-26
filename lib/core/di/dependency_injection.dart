import 'package:easy_app/core/config/app_config.dart';
import 'package:easy_app/core/config/environment.dart';
import 'package:easy_app/core/navigation/app_router.dart';
import 'package:easy_app/core/network/api_service.dart';
import 'package:easy_app/core/storage/secure_token_storage.dart';
import 'package:easy_app/core/storage/storage_service.dart';
import 'package:easy_app/features/auth/data/repositories/auth_repository.dart';
import 'package:easy_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:easy_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:easy_app/features/auth/domain/usecases/refresh_token_usecase.dart';
import 'package:easy_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:easy_app/features/home/data/repositories/home_repository.dart';
import 'package:easy_app/features/home/domain/usecases/load_home_modules_usecase.dart';
import 'package:easy_app/features/home/domain/usecases/load_user_profile_usecase.dart';
import 'package:easy_app/features/home/domain/usecases/register_push_token_usecase.dart';
import 'package:easy_app/features/home/domain/usecases/check_app_version_usecase.dart';
import 'package:easy_app/features/home/domain/usecases/check_maintenance_status_usecase.dart';
import 'package:easy_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:easy_app/features/announcements/data/repositories/announcement_repository.dart';
import 'package:easy_app/features/announcements/domain/usecases/get_announcements_usecase.dart';
import 'package:easy_app/features/announcements/domain/usecases/get_announcements_by_page_usecase.dart';
import 'package:easy_app/features/announcements/domain/usecases/search_announcements_usecase.dart';
import 'package:easy_app/features/announcements/domain/usecases/get_announcement_detail_usecase.dart';
import 'package:easy_app/features/announcements/presentation/cubit/announcement_cubit.dart';
import 'package:easy_app/core/navigation/navigation_service.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

final getIt = GetIt.instance;

/// Setup dependency injection
Future<void> setupDependencyInjection(Environment environment) async {
  // 0. Initialize Logger
  // Colors are auto-detected based on terminal support
  // To force enable colors: AppLogger.enableColors = true (only works in terminals)
  // To force disable colors: AppLogger.enableColors = false (for IDE debug console)
  // Note: Colors don't work in IDE debug consoles, only in actual terminals

  // 1. Core Services (registered first)

  // App Configuration
  final appConfig = AppConfig.getConfig(environment);
  getIt.registerSingleton<AppConfig>(appConfig);

  // Secure Token Storage
  getIt.registerSingleton<SecureTokenStorage>(SecureTokenStorage());

  // Storage Service
  final storageService = StorageService();
  await storageService.initialize();
  getIt.registerSingleton<StorageService>(storageService);

  // API Service
  getIt.registerSingleton<ApiService>(
    ApiService(
      config: appConfig,
      tokenStorage: getIt<SecureTokenStorage>(),
    ),
  );

  // Router
  final router = AppRouter.createRouter();
  getIt.registerSingleton<GoRouter>(router);

  // Navigation Service
  getIt.registerSingleton<NavigationService>(NavigationService(router: router));

  // 2. Repositories (registered second)
  getIt.registerSingleton<AuthRepository>(
    AuthRepository(),
  );
  getIt.registerSingleton<HomeRepository>(
    HomeRepository(),
  );
  getIt.registerSingleton<AnnouncementRepository>(
    AnnouncementRepository(apiService: getIt<ApiService>()),
  );
  // TODO: Register other repositories as they are created

  // 3. Use Cases (registered third)
  getIt.registerFactory<LoginUseCase>(() => LoginUseCase());
  getIt.registerFactory<LogoutUseCase>(() => LogoutUseCase());
  getIt.registerFactory<RefreshTokenUseCase>(() => RefreshTokenUseCase());
  getIt.registerFactory<LoadHomeModulesUseCase>(() => LoadHomeModulesUseCase());
  getIt.registerFactory<LoadUserProfileUseCase>(() => LoadUserProfileUseCase());
  getIt.registerFactory<RegisterPushTokenUseCase>(
      () => RegisterPushTokenUseCase());
  getIt.registerFactory<CheckAppVersionUseCase>(() => CheckAppVersionUseCase());
  getIt.registerFactory<CheckMaintenanceStatusUseCase>(
      () => CheckMaintenanceStatusUseCase());
  getIt.registerFactory<GetAnnouncementsUseCase>(() =>
      GetAnnouncementsUseCase(repository: getIt<AnnouncementRepository>()));
  getIt.registerFactory<GetAnnouncementsByPageUseCase>(() =>
      GetAnnouncementsByPageUseCase(
          repository: getIt<AnnouncementRepository>()));
  getIt.registerFactory<SearchAnnouncementsUseCase>(() =>
      SearchAnnouncementsUseCase(repository: getIt<AnnouncementRepository>()));
  getIt.registerFactory<GetAnnouncementDetailUseCase>(() =>
      GetAnnouncementDetailUseCase(
          repository: getIt<AnnouncementRepository>()));
  // TODO: Register other use cases as they are created

  // 4. BLoCs/Cubits (registered last)
  getIt.registerFactory<AuthCubit>(() => AuthCubit());
  getIt.registerFactory<HomeCubit>(() => HomeCubit());
  getIt.registerFactory<AnnouncementCubit>(() => AnnouncementCubit());
  // TODO: Register other BLoCs/Cubits as they are created
}
