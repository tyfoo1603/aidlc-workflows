import 'package:dio/dio.dart';
import 'package:easy_app/core/config/app_config.dart';
import 'package:easy_app/core/error/app_error.dart';
import 'package:easy_app/core/error/result.dart';
import 'package:easy_app/core/storage/secure_token_storage.dart';
import 'package:easy_app/core/network/certificate_pinning_interceptor.dart';
import 'package:easy_app/core/network/custom_log_interceptor.dart';
import 'package:easy_app/core/utils/app_logger.dart';
import 'package:dio/io.dart';
import 'package:easy_app/features/auth/domain/entities/token.dart';

/// API Service for all backend API calls
class ApiService {
  late final Dio _dio;
  final AppConfig _config;
  final SecureTokenStorage _tokenStorage;
  bool _isRefreshing = false;

  ApiService({
    required AppConfig config,
    required SecureTokenStorage tokenStorage,
  })  : _config = config,
        _tokenStorage = tokenStorage {
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _config.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(_AuthInterceptor(_tokenStorage, this));
    _dio.interceptors.add(_RetryInterceptor());

    // Add certificate pinning interceptor
    if (_config.certificatePins.isNotEmpty) {
      _dio.interceptors.add(CertificatePinningInterceptor(config: _config));
      // Use custom HTTP client adapter for certificate pinning
      final httpClientFactory = PinnedHttpClientFactory(config: _config);
      _dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () => httpClientFactory.createHttpClient(),
      );
    }

    if (_config.enableLogging) {
      _dio.interceptors.add(CustomLogInterceptor(
        logRequest: true,
        logResponse: true,
        logError: true,
        logRequestHeaders: true,
        logResponseHeaders: false,
        logRequestBody: true,
        logResponseBody: true,
      ));
    }
  }

  // Authentication endpoints

  /// Exchange authorization code for tokens
  Future<Result<Token>> exchangeAuthCode(String code) async {
    try {
      AppLogger.info('Exchanging authorization code for tokens', tag: 'ApiService');
      // Microsoft OAuth token endpoint
      final response = await _dio.post(
        _config.microsoftTokenUrl,
        data: {
          'grant_type': 'authorization_code',
          'code': code,
          'client_id': _config.microsoftClientId,
          'client_secret': _config.microsoftClientSecret,
          'redirect_uri': _config.microsoftRedirectUri,
        },
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
        ),
      );

      // Map response to Token entity
      final data = response.data;
      final expiresIn = data['expires_in'] as int;
      final now = DateTime.now();

      final token = Token(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String,
        expiresAt: now.add(Duration(seconds: expiresIn)),
        issuedAt: now,
        userId: '', // TODO: Extract from token or fetch profile
      );
      AppLogger.success('Successfully exchanged authorization code for tokens', tag: 'ApiService');
      return Success(token);
    } catch (e) {
      AppLogger.error('Failed to exchange authorization code', tag: 'ApiService', error: e);
      return Failure(_handleError(e));
    }
  }

  /// Refresh access token
  Future<Result<Token>> refreshToken(String refreshToken) async {
    try {
      AppLogger.info('Refreshing access token', tag: 'ApiService');
      // Microsoft OAuth token endpoint
      final response = await _dio.post(
        _config.microsoftTokenUrl,
        data: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
          'client_id': _config.microsoftClientId,
          'client_secret': _config.microsoftClientSecret,
        },
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
        ),
      );

      // Map response to Token entity
      final data = response.data as Map<String, dynamic>;
      final expiresIn = data['expires_in'] as int? ?? 3600;
      final now = DateTime.now();

      // Get existing userId from stored tokens
      final existingTokens = await _tokenStorage.getTokens();
      final userId = existingTokens?.userId ?? '';

      final token = Token(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String,
        expiresAt: now.add(Duration(seconds: expiresIn)),
        issuedAt: now,
        userId: userId,
      );
      AppLogger.success('Successfully refreshed access token', tag: 'ApiService');
      return Success(token);
    } catch (e) {
      AppLogger.error('Failed to refresh access token', tag: 'ApiService', error: e);
      return Failure(_handleError(e));
    }
  }

  /// Revoke sign-in sessions
  Future<Result<void>> revokeSignInSessions() async {
    try {
      // Azure Graph API
      // POST to https://graph.microsoft.com/v1.0/me/revokeSignInSessions
      // Note: This requires a valid Microsoft Graph token
      // The interceptor will skip adding the Bearer token for Microsoft Graph
      // So we need to manually add it
      final tokens = await _tokenStorage.getTokens();
      if (tokens == null) {
        return Failure(AppError.authentication(
          message: 'No access token available',
        ));
      }

      await _dio.post(
        'https://graph.microsoft.com/v1.0/me/revokeSignInSessions',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${tokens.accessToken}',
          },
        ),
      );

      return const Success(null);
    } catch (e) {
      return Failure(_handleError(e));
    }
  }

  /// Invalidate all refresh tokens
  Future<Result<void>> invalidateRefreshTokens() async {
    try {
      // Azure Graph API
      // POST to https://graph.microsoft.com/v1.0/me/invalidateAllRefreshTokens
      // Note: This requires a valid Microsoft Graph token
      // The interceptor will skip adding the Bearer token for Microsoft Graph
      // So we need to manually add it
      final tokens = await _tokenStorage.getTokens();
      if (tokens == null) {
        return Failure(AppError.authentication(
          message: 'No access token available',
        ));
      }

      await _dio.post(
        'https://graph.microsoft.com/v1.0/me/invalidateAllRefreshTokens',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${tokens.accessToken}',
          },
        ),
      );

      return const Success(null);
    } catch (e) {
      return Failure(_handleError(e));
    }
  }

  // Landing/Home endpoints

  /// Get landing categories (modules)
  Future<Result<List<dynamic>>> getLandingCategories(String userId) async {
    try {
      // POST {{baseUrl}}/landing/newcategory
      // Body: userID (form data)
      final response = await _dio.post(
        '/landing/newcategory',
        data: {
          'userID': userId,
        },
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
        ),
      );

      return Success(response.data as List<dynamic>);
    } catch (e) {
      return Failure(_handleError(e));
    }
  }

  /// Get user profile
  Future<Result<dynamic>> getUserProfile(String userId) async {
    try {
      // POST {{baseUrl}}/landing/newuserprofile
      // Body: userID
      final response = await _dio.post(
        '/landing/user-profile',
        data: {
          'userID': userId,
        },
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
        ),
      );

      return Success(response.data);
    } catch (e) {
      return Failure(_handleError(e));
    }
  }

  /// Get module notifications
  Future<Result<List<dynamic>>> getModuleNotifications(
    String userId,
    String moduleId,
  ) async {
    try {
      // TODO: Implement API call
      // POST {{baseUrl}}/landing/newmodulesnotification
      // Body: userID, moduleID
      throw UnimplementedError('getModuleNotifications not implemented');
    } catch (e) {
      return Failure(_handleError(e));
    }
  }

  /// Register push token
  Future<Result<void>> registerPushToken(
    String userId,
    String firebaseToken,
    String hmsToken,
    String appVersion,
  ) async {
    try {
      // POST {{baseUrl}}/landing/newgrab token
      // Body: userID, firebaseToken, hms, appVersion
      await _dio.post(
        '/landing/newgrab token',
        data: {
          'userID': userId,
          'firebaseToken': firebaseToken,
          'hms': hmsToken,
          'appVersion': appVersion,
        },
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
        ),
      );

      return const Success(null);
    } catch (e) {
      return Failure(_handleError(e));
    }
  }

  /// Get app version
  Future<Result<dynamic>> getAppVersion(String appType) async {
    try {
      // POST {{baseUrl}}/landing/version
      // Body: appType
      final response = await _dio.post(
        '/landing/version',
        data: {
          'appType': appType,
        },
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
        ),
      );

      return Success(response.data);
    } catch (e) {
      return Failure(_handleError(e));
    }
  }

  /// Get maintenance status
  Future<Result<dynamic>> getMaintenanceStatus() async {
    try {
      // GET {{baseUrl}}/landing/newmaintenance
      final response = await _dio.get('/landing/newmaintenance');
      return Success(response.data);
    } catch (e) {
      return Failure(_handleError(e));
    }
  }

  /// Check user
  Future<Result<dynamic>> checkUser(String userId) async {
    try {
      // POST {{baseUrl}}/landing/newusercheck
      // Body: userID
      final response = await _dio.post(
        '/landing/newusercheck',
        data: {
          'userID': userId,
        },
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
        ),
      );

      return Success(response.data);
    } catch (e) {
      return Failure(_handleError(e));
    }
  }

  // Announcement endpoints

  /// Get all announcements (newretrieve endpoint)
  Future<Result<dynamic>> getAnnouncements() async {
    try {
      // GET {{baseUrl}}/announcement/newretrieve
      final response = await _dio.get('/announcement/newretrieve');
      return Success(response.data);
    } catch (e) {
      return Failure(_handleError(e));
    }
  }

  /// Get announcements by page
  Future<Result<dynamic>> getAnnouncementsByPage(int page) async {
    try {
      // GET {{baseUrl}}/announcement/retrievepage?page={{page}}
      final response = await _dio.get(
        '/announcement/retrievepage',
        queryParameters: {'page': page},
      );
      return Success(response.data);
    } catch (e) {
      return Failure(_handleError(e));
    }
  }

  /// Search announcements
  Future<Result<dynamic>> searchAnnouncements(
      String searchText, int page) async {
    try {
      // POST {{baseUrl}}/announcement/searchpage
      // Body: search_text, query: page
      final response = await _dio.post(
        '/announcement/searchpage',
        data: {
          'search_text': searchText,
        },
        queryParameters: {'page': page},
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
        ),
      );
      return Success(response.data);
    } catch (e) {
      return Failure(_handleError(e));
    }
  }

  /// Get announcement detail by ID
  Future<Result<dynamic>> getAnnouncementDetail(String id) async {
    try {
      // POST {{baseUrl}}/announcement/search
      // Body: anc_id
      final response = await _dio.post(
        '/announcement/search',
        data: {
          'anc_id': id,
        },
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
        ),
      );
      return Success(response.data);
    } catch (e) {
      return Failure(_handleError(e));
    }
  }

  // Error handling

  AppError _handleError(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    }
    return AppError.unknown(
      message: 'An unexpected error occurred',
      technicalMessage: error.toString(),
    );
  }

  AppError _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return AppError.network(
          message:
              'Network connection error. Please check your internet connection.',
          technicalMessage: error.message,
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) {
          return AppError.authentication(
            message: 'Authentication failed. Please login again.',
            statusCode: statusCode,
            technicalMessage: error.response?.data?.toString(),
          );
        } else if (statusCode == 400) {
          return AppError.validation(
            message: 'Invalid request. Please check your input.',
            technicalMessage: error.response?.data?.toString(),
          );
        } else if (statusCode != null && statusCode >= 500) {
          return AppError.server(
            message: 'Server error. Please try again later.',
            statusCode: statusCode,
            technicalMessage: error.response?.data?.toString(),
            isRetryable: statusCode == 503,
          );
        }
        return AppError.server(
          message: 'Request failed. Please try again.',
          statusCode: statusCode,
          technicalMessage: error.response?.data?.toString(),
        );
      default:
        return AppError.unknown(
          message: 'An unexpected error occurred',
          technicalMessage: error.message,
        );
    }
  }

  /// Retry request after token refresh (internal method)
  Future<Result<T>> retryRequest<T>(
    RequestOptions requestOptions,
  ) async {
    try {
      final options = Options(
        method: requestOptions.method,
        headers: requestOptions.headers,
      );
      final response = await _dio.request<T>(
        requestOptions.path,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
        options: options,
      );
      return Success(response.data as T);
    } catch (e) {
      return Failure(_handleError(e));
    }
  }

  /// Retry request after token refresh (private method)
  Future<Result<T>> _retryRequest<T>(
    RequestOptions requestOptions,
  ) async {
    return retryRequest<T>(requestOptions);
  }

  /// Refresh token and retry request
  Future<Result<T>> refreshAndRetry<T>(
    RequestOptions requestOptions,
  ) async {
    if (_isRefreshing) {
      // Wait for ongoing refresh
      await Future.delayed(const Duration(milliseconds: 100));
      return _retryRequest<T>(requestOptions);
    }

    _isRefreshing = true;
    try {
      final tokens = await _tokenStorage.getTokens();
      if (tokens == null) {
        return Failure(AppError.authentication(
          message: 'No refresh token available',
        ));
      }

      final refreshResult = await refreshToken(tokens.refreshToken);
      if (refreshResult.isFailure) {
        _isRefreshing = false;
        return Failure(refreshResult.errorOrNull!);
      }

      final newTokens = refreshResult.valueOrNull!;
      await _tokenStorage.saveTokens(newTokens);
      _isRefreshing = false;

      return retryRequest<T>(requestOptions);
    } catch (e) {
      _isRefreshing = false;
      return Failure(_handleError(e));
    }
  }
}

/// Auth interceptor for adding Bearer token and handling 401
class _AuthInterceptor extends Interceptor {
  final SecureTokenStorage _tokenStorage;
  final ApiService _apiService;

  _AuthInterceptor(this._tokenStorage, this._apiService);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // Skip authentication for OAuth token endpoints and Microsoft Graph API
    final skipAuthPaths = [
      '/oauth2/v2.0/token',
      'login.microsoftonline.com',
      'graph.microsoft.com',
    ];

    final shouldSkipAuth = skipAuthPaths.any(
      (path) => options.uri.toString().contains(path),
    );

    if (!shouldSkipAuth) {
      // Add Bearer token for all other requests
      final tokens = await _tokenStorage.getTokens();
      if (tokens != null) {
        // Add token even if expired or about to expire
        // The onError handler will refresh if we get a 401
        options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
        AppLogger.debug('Added Bearer token to request', tag: 'AuthInterceptor');
      } else {
        AppLogger.warning('No tokens available for request', tag: 'AuthInterceptor');
      }
    } else {
      AppLogger.debug('Skipping authentication for OAuth/Graph API endpoint', tag: 'AuthInterceptor');
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      AppLogger.warning('Received 401 Unauthorized, attempting token refresh', tag: 'AuthInterceptor');
      // Token expired or invalid, attempt to refresh and retry
      final tokens = await _tokenStorage.getTokens();

      // Only retry if we have a refresh token
      if (tokens != null && tokens.refreshToken.isNotEmpty) {
        AppLogger.info('Refreshing token and retrying request', tag: 'AuthInterceptor');
        final retryResult =
            await _apiService.refreshAndRetry(err.requestOptions);
        if (retryResult.isSuccess) {
          AppLogger.success('Token refreshed and request retried successfully', tag: 'AuthInterceptor');
          handler.resolve(Response(
            requestOptions: err.requestOptions,
            data: retryResult.valueOrNull,
          ));
          return;
        } else {
          AppLogger.error('Token refresh failed', tag: 'AuthInterceptor');
        }
      } else {
        AppLogger.warning('No refresh token available, cannot retry', tag: 'AuthInterceptor');
      }

      // If refresh failed or no tokens, clear tokens and require re-login
      AppLogger.info('Clearing tokens and requiring re-login', tag: 'AuthInterceptor');
      await _tokenStorage.clearTokens();
    }
    handler.next(err);
  }
}

/// Retry interceptor for network errors
class _RetryInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_isNetworkError(err)) {
      // Network errors are handled by error handler, not retried automatically
      // User will see error message with manual retry option
    }
    handler.next(err);
  }

  bool _isNetworkError(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError;
  }
}
