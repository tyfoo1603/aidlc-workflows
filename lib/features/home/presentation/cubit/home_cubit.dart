import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:easy_app/core/navigation/navigation_service.dart';
import 'package:easy_app/core/error/result.dart';
import 'package:easy_app/core/config/app_config.dart';
import 'package:easy_app/core/storage/secure_token_storage.dart';
import 'package:easy_app/features/auth/domain/entities/token.dart';
import 'package:easy_app/features/home/domain/entities/landing_category.dart';
import 'package:easy_app/features/home/domain/entities/user_summary.dart';
import 'package:easy_app/features/home/domain/entities/app_version.dart';
import 'package:easy_app/features/home/domain/entities/maintenance_status.dart';
import 'package:easy_app/features/home/domain/usecases/load_home_modules_usecase.dart';
import 'package:easy_app/features/home/domain/usecases/load_user_profile_usecase.dart';
import 'package:easy_app/features/home/domain/usecases/register_push_token_usecase.dart';
import 'package:easy_app/features/home/domain/usecases/check_app_version_usecase.dart';
import 'package:easy_app/features/home/domain/usecases/check_maintenance_status_usecase.dart';
import 'package:easy_app/core/di/dependency_injection.dart';
import 'dart:convert';

/// Home state
class HomeState {
  final bool isLoading;
  final List<LandingCategory>? modules;
  final UserSummary? userSummary;
  final AppVersion? appVersion;
  final MaintenanceStatus? maintenanceStatus;
  final String? errorMessage;
  final String? successMessage;

  const HomeState({
    this.isLoading = false,
    this.modules,
    this.userSummary,
    this.appVersion,
    this.maintenanceStatus,
    this.errorMessage,
    this.successMessage,
  });

  HomeState copyWith({
    bool? isLoading,
    List<LandingCategory>? modules,
    UserSummary? userSummary,
    AppVersion? appVersion,
    MaintenanceStatus? maintenanceStatus,
    String? errorMessage,
    String? successMessage,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      modules: modules ?? this.modules,
      userSummary: userSummary ?? this.userSummary,
      appVersion: appVersion ?? this.appVersion,
      maintenanceStatus: maintenanceStatus ?? this.maintenanceStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }
}

/// Home Cubit
class HomeCubit extends Cubit<HomeState> {
  final LoadHomeModulesUseCase _loadHomeModulesUseCase;
  final LoadUserProfileUseCase _loadUserProfileUseCase;
  final CheckAppVersionUseCase _checkAppVersionUseCase;
  final CheckMaintenanceStatusUseCase _checkMaintenanceStatusUseCase;
  final NavigationService _navigationService;
  final AppConfig _appConfig;
  final FlutterAppAuth _appAuth;
  final SecureTokenStorage _tokenStorage;

  HomeCubit({
    LoadHomeModulesUseCase? loadHomeModulesUseCase,
    LoadUserProfileUseCase? loadUserProfileUseCase,
    RegisterPushTokenUseCase? registerPushTokenUseCase,
    CheckAppVersionUseCase? checkAppVersionUseCase,
    CheckMaintenanceStatusUseCase? checkMaintenanceStatusUseCase,
    NavigationService? navigationService,
    AppConfig? appConfig,
    FlutterAppAuth? appAuth,
    SecureTokenStorage? tokenStorage,
  })  : _loadHomeModulesUseCase =
            loadHomeModulesUseCase ?? getIt<LoadHomeModulesUseCase>(),
        _loadUserProfileUseCase =
            loadUserProfileUseCase ?? getIt<LoadUserProfileUseCase>(),
        _checkAppVersionUseCase =
            checkAppVersionUseCase ?? getIt<CheckAppVersionUseCase>(),
        _checkMaintenanceStatusUseCase = checkMaintenanceStatusUseCase ??
            getIt<CheckMaintenanceStatusUseCase>(),
        _navigationService = navigationService ?? getIt<NavigationService>(),
        _appConfig = appConfig ?? getIt<AppConfig>(),
        _appAuth = appAuth ?? FlutterAppAuth(),
        _tokenStorage = tokenStorage ?? getIt<SecureTokenStorage>(),
        super(const HomeState());

  /// Load home page data (all in parallel)
  Future<void> loadHomeData(String userId) async {
    emit(state.copyWith(
      isLoading: true,
      errorMessage: null,
      successMessage: null,
    ));

    try {
      // Load all data in parallel
      final results = await Future.wait([
        _loadHomeModulesUseCase.execute(userId),
        _loadUserProfileUseCase.execute(userId),
        _checkAppVersionUseCase.execute(),
        _checkMaintenanceStatusUseCase.execute(),
      ]);

      final modulesResult = results[0] as Result<List<LandingCategory>>;
      final profileResult = results[1] as Result<UserSummary>;
      final versionResult = results[2] as Result<AppVersion>;
      final maintenanceResult = results[3] as Result<MaintenanceStatus>;

      // Update state with results
      emit(state.copyWith(
        isLoading: false,
        modules: modulesResult.valueOrNull,
        userSummary: profileResult.valueOrNull,
        appVersion: versionResult.valueOrNull,
        maintenanceStatus: maintenanceResult.valueOrNull,
        errorMessage: _getFirstError([
          modulesResult,
          profileResult,
          versionResult,
          maintenanceResult,
        ]),
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load home data: ${e.toString()}',
      ));
    }
  }

  /// Navigate to module
  Future<void> navigateToModule(LandingCategory category) async {
    if (category.isInternal) {
      // Navigate to internal route based on category URL/ID
      // Map category ID to route
      final route = _mapCategoryToRoute(category.id);
      if (route != null) {
        _navigationService.router.push(route);
      } else {
        // Fallback: use URL as route
        _navigationService.router.push(category.url);
      }
    } else if (category.isWeb) {
      // Open webview
      await _navigationService.openWebView(category.url);
    }
  }

  /// Navigate to login using flutter_appauth
  Future<void> navigateToLogin() async {
    try {
      // Construct the authorization service configuration
      final serviceConfiguration = AuthorizationServiceConfiguration(
        authorizationEndpoint:
            'https://login.microsoftonline.com/${_appConfig.microsoftTenantId}/oauth2/v2.0/authorize',
        tokenEndpoint: _appConfig.microsoftTokenUrl,
      );

      // Perform authorization and token exchange
      final result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          _appConfig.microsoftClientId,
          _appConfig.microsoftRedirectUri,
          serviceConfiguration: serviceConfiguration,
          scopes: _appConfig.microsoftScope.split(' '),
          promptValues: ['login'], // Force login prompt
        ),
      );

      // Successfully authenticated, store the tokens
      try {
        // Extract user ID from ID token (JWT)
        final userId = _extractUserIdFromIdToken(result.idToken);

        // Create Token entity
        final token = Token(
          accessToken: result.accessToken!,
          refreshToken: result.refreshToken ?? '',
          expiresAt: result.accessTokenExpirationDateTime ??
              DateTime.now().add(const Duration(hours: 1)),
          issuedAt: DateTime.now(),
          userId: userId,
        );

        // Save tokens to secure storage
        await _tokenStorage.saveTokens(token);

        // Emit success message
        // emit(state.copyWith(
        //   successMessage: 'Login successful! Welcome back.',
        // ));

        // Navigate to home
        _navigationService.navigateToHome();
      } catch (e) {
        emit(state.copyWith(
          errorMessage: 'Failed to store authentication data: ${e.toString()}',
        ));
      }
    } on FlutterAppAuthUserCancelledException {
      // User cancelled the authentication flow
      // Handle gracefully - no error needed
    } on FlutterAppAuthPlatformException catch (e) {
      // Handle authentication errors
      emit(state.copyWith(
        errorMessage: 'Authentication failed: ${e.message}',
      ));
    } catch (e) {
      // Handle other errors
      emit(state.copyWith(
        errorMessage: 'Login failed: ${e.toString()}',
      ));
    }
  }

  /// Extract user ID from ID token (JWT)
  String _extractUserIdFromIdToken(String? idToken) {
    if (idToken == null || idToken.isEmpty) {
      return 'unknown';
    }

    try {
      // Decode JWT (split by '.' and decode the payload)
      final parts = idToken.split('.');
      if (parts.length != 3) {
        return 'unknown';
      }

      // Decode the payload (second part)
      final payload = parts[1];
      // Add padding if needed
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> payloadMap = json.decode(decoded);

      // Extract user ID (could be 'sub', 'oid', or 'preferred_username')
      return payloadMap['sub'] as String? ??
          payloadMap['oid'] as String? ??
          payloadMap['preferred_username'] as String? ??
          'unknown';
    } catch (e) {
      return 'unknown';
    }
  }

  String? _mapCategoryToRoute(String categoryId) {
    // Map category IDs to routes
    final routeMap = {
      'profile': '/profile',
      'announcements': '/announcements',
      'qr-wallet': '/qr-wallet',
      'eclaims': '/eclaims',
      'astrodesk': '/astrodesk',
      'report-piracy': '/report-piracy',
      'settings': '/settings',
      'astronet': '/astronet',
      'steps-challenge': '/steps-challenge',
      'content-highlights': '/content-highlights',
      'friends-family': '/friends-family',
      'sooka-share': '/sooka-share',
    };
    return routeMap[categoryId.toLowerCase()];
  }

  /// Clear success and error messages
  void clearMessages() {
    emit(state.copyWith(
      errorMessage: null,
      successMessage: null,
    ));
  }

  String? _getFirstError(List<Result<dynamic>> results) {
    for (final result in results) {
      if (result.isFailure) {
        return result.errorOrNull?.message;
      }
    }
    return null;
  }
}
