# Services

This document defines the service layer components and their orchestration patterns for the Easy App Flutter mobile application.

## Service Layer Architecture

The application uses **Use Cases/Interactors pattern** (one use case per user story or feature action) as the service layer. Use cases orchestrate between repositories and BLoCs, encapsulating business logic.

---

## Core Services

### ApiService
- **Purpose**: Single API service class with methods for all endpoints
- **Responsibilities**:
  - HTTP request handling (using Dio)
  - Request/response serialization
  - Certificate pinning
  - Token refresh interceptor
  - Error handling and retry logic
- **Location**: `core/network/api_service.dart`
- **Dependencies**: Dio, CoreNetwork (interceptors)

### NavigationService
- **Purpose**: Centralized navigation coordination
- **Responsibilities**:
  - Route definitions and management
  - Navigation coordination across features
  - Deep linking handling
  - Navigation state management
- **Location**: `core/navigation/navigation_service.dart`
- **Dependencies**: None (core service)

### StorageService
- **Purpose**: Local storage management
- **Responsibilities**:
  - Hive box initialization and management
  - Encrypted storage operations
  - Token storage
  - User data caching
- **Location**: `core/storage/storage_service.dart`
- **Dependencies**: Hive, encryption packages

### DependencyInjectionService
- **Purpose**: Dependency injection setup and management
- **Responsibilities**:
  - Service locator configuration (get_it)
  - Dependency registration
  - Dependency resolution
- **Location**: `core/di/dependency_injection.dart`
- **Dependencies**: get_it package

---

## Feature Services (Use Cases)

### Authentication Services

#### LoginUseCase
- **Purpose**: Orchestrate Microsoft OAuth login flow
- **Responsibilities**:
  - Coordinate OAuth authorization code exchange
  - Token storage via AuthRepository
  - User profile fetching after login
  - Navigation to home after successful login
- **Dependencies**: AuthRepository, HomeRepository, NavigationService
- **Orchestration Flow**:
  1. Receive authorization code
  2. Call AuthRepository.exchangeAuthCode()
  3. Save tokens via AuthRepository.saveTokens()
  4. Call HomeRepository.getUserProfile()
  5. Navigate to home via NavigationService

#### LogoutUseCase
- **Purpose**: Orchestrate logout flow
- **Responsibilities**:
  - Clear local tokens and data
  - Revoke server sessions (if network available)
  - Clear cached data
  - Navigate to login
- **Dependencies**: AuthRepository, StorageService, NavigationService
- **Orchestration Flow**:
  1. Call AuthRepository.revokeSignInSessions() (if network available)
  2. Call AuthRepository.clearTokens()
  3. Clear cached data via StorageService
  4. Navigate to login via NavigationService

#### RefreshTokenUseCase
- **Purpose**: Orchestrate token refresh flow
- **Responsibilities**:
  - Refresh expired access token
  - Update stored tokens
  - Handle refresh failures
- **Dependencies**: AuthRepository
- **Orchestration Flow**:
  1. Get stored refresh token via AuthRepository
  2. Call AuthRepository.refreshToken()
  3. Save new tokens via AuthRepository.saveTokens()
  4. Return Result with new tokens or error

---

### Home Services

#### LoadHomeModulesUseCase
- **Purpose**: Load home page modules and data
- **Responsibilities**:
  - Fetch landing categories
  - Fetch user profile
  - Register push token
  - Check app version and maintenance
- **Dependencies**: HomeRepository, ProfileRepository
- **Orchestration Flow**:
  1. Call HomeRepository.getLandingCategories()
  2. Call ProfileRepository.getProfile() (or use cached if available)
  3. Call HomeRepository.registerPushToken() (if not already registered)
  4. Call HomeRepository.getAppVersion() and getMaintenanceStatus()
  5. Return combined home data

#### RegisterPushTokenUseCase
- **Purpose**: Register device push notification token
- **Responsibilities**:
  - Get device tokens (FCM/HMS)
  - Register with backend
  - Handle registration failures gracefully
- **Dependencies**: HomeRepository, PushNotificationService
- **Orchestration Flow**:
  1. Get FCM token and HMS token (if applicable)
  2. Call HomeRepository.registerPushToken()
  3. Handle success/failure

---

### Profile Services

#### GetProfileUseCase
- **Purpose**: Get user profile data
- **Responsibilities**:
  - Fetch profile from API
  - Cache profile locally
  - Return cached profile if offline
- **Dependencies**: ProfileRepository
- **Orchestration Flow**:
  1. Try to fetch from API via ProfileRepository.getProfile()
  2. If successful, cache via ProfileRepository.cacheProfile()
  3. If offline/error, return cached profile if available
  4. Return Result with profile or error

#### UpdateProfileUseCase
- **Purpose**: Update user profile
- **Responsibilities**:
  - Validate profile data
  - Update via API
  - Update local cache
  - Notify dependent features (Home)
- **Dependencies**: ProfileRepository, HomeRepository (for notification)
- **Orchestration Flow**:
  1. Validate profile data (business rules in Functional Design)
  2. Call ProfileRepository.updateProfile()
  3. Update cache via ProfileRepository.cacheProfile()
  4. Return updated profile

#### UploadProfilePictureUseCase
- **Purpose**: Upload profile picture
- **Responsibilities**:
  - Compress image
  - Upload via API
  - Update local cache
- **Dependencies**: ProfileRepository, ImageService
- **Orchestration Flow**:
  1. Compress image via ImageService
  2. Call ProfileRepository.uploadProfilePicture()
  3. Update cached profile with new image URL
  4. Return image URL

---

### Announcements Services

#### GetAnnouncementsUseCase
- **Purpose**: Get announcements list
- **Responsibilities**:
  - Fetch announcements with pagination
  - Cache announcements locally
  - Return cached data if offline
- **Dependencies**: AnnouncementRepository
- **Orchestration Flow**:
  1. Try to fetch from API via AnnouncementRepository.getAnnouncements()
  2. If successful, cache via AnnouncementRepository.cacheAnnouncements()
  3. If offline/error, return cached announcements if available
  4. Return Result with announcements or error

#### SearchAnnouncementsUseCase
- **Purpose**: Search announcements
- **Responsibilities**:
  - Perform search with debouncing
  - Cache search results
- **Dependencies**: AnnouncementRepository
- **Orchestration Flow**:
  1. Call AnnouncementRepository.searchAnnouncements()
  2. Return search results

---

### QR Wallet Services

#### ProcessPaymentUseCase
- **Purpose**: Process QR code payment
- **Responsibilities**:
  - Validate payment data
  - Process payment via API
  - Update payment history cache
  - Update wallet balance
- **Dependencies**: QRWalletRepository, HomeRepository (for wallet balance update)
- **Orchestration Flow**:
  1. Validate QR code data (business rules in Functional Design)
  2. Call QRWalletRepository.processPayment()
  3. Refresh payment history cache
  4. Update home wallet balance (via HomeRepository)
  5. Return payment response

#### GetPaymentHistoryUseCase
- **Purpose**: Get payment history
- **Responsibilities**:
  - Fetch payment history
  - Cache locally
  - Return cached data if offline
- **Dependencies**: QRWalletRepository
- **Orchestration Flow**:
  1. Try to fetch from API via QRWalletRepository.getPaymentHistory()
  2. If successful, cache via QRWalletRepository.cachePaymentHistory()
  3. If offline/error, return cached history if available
  4. Return Result with transactions or error

---

### Eclaims Services

#### SubmitClaimUseCase (Base for all claim types)
- **Purpose**: Submit claim (Out of Office, Health Screening, or New Entry)
- **Responsibilities**:
  - Validate claim data
  - Compress attachments if needed
  - Submit via API
  - Cache claim locally
- **Dependencies**: EclaimsRepository, FileService
- **Orchestration Flow**:
  1. Validate claim data (business rules in Functional Design)
  2. Compress attachments via FileService if needed
  3. Call EclaimsRepository.submitClaim()
  4. Cache claim via EclaimsRepository.cacheClaims()
  5. Return submitted claim

#### GetMyClaimsUseCase
- **Purpose**: Get user's submitted claims
- **Responsibilities**:
  - Fetch claims list
  - Cache locally
  - Return cached data if offline
- **Dependencies**: EclaimsRepository
- **Orchestration Flow**:
  1. Try to fetch from API via EclaimsRepository.getMyClaims()
  2. If successful, cache via EclaimsRepository.cacheClaims()
  3. If offline/error, return cached claims if available
  4. Return Result with claims or error

---

### Steps Challenge Services

#### SyncStepsFromHealthAppUseCase
- **Purpose**: Sync steps from health app (Google Fit/Apple Health)
- **Responsibilities**:
  - Request health data permissions
  - Fetch steps from health app
  - Post steps to backend
  - Cache steps locally
- **Dependencies**: StepsChallengeRepository, HealthDataService
- **Orchestration Flow**:
  1. Check/request health data permissions via HealthDataService
  2. Fetch steps from health app via HealthDataService.getSteps()
  3. For each day's steps, call StepsChallengeRepository.updateSteps()
  4. Cache steps locally
  5. Return Result with sync status

#### GetRankingsUseCase
- **Purpose**: Get step challenge rankings
- **Responsibilities**:
  - Fetch rankings from API
  - Cache rankings
- **Dependencies**: StepsChallengeRepository
- **Orchestration Flow**:
  1. Call StepsChallengeRepository.getRankings()
  2. Return rankings

---

## Service Orchestration Patterns

### Pattern 1: Fetch with Caching
**Used by**: GetProfileUseCase, GetAnnouncementsUseCase, GetPaymentHistoryUseCase, etc.
1. Try API call
2. If successful: cache data, return data
3. If error/offline: return cached data if available, else return error

### Pattern 2: Submit with Cache Update
**Used by**: UpdateProfileUseCase, ProcessPaymentUseCase, SubmitClaimUseCase
1. Validate input
2. Submit via API
3. Update local cache
4. Notify dependent features (if needed)
5. Return result

### Pattern 3: Sync with External Service
**Used by**: SyncStepsFromHealthAppUseCase, RegisterPushTokenUseCase
1. Check permissions/availability
2. Fetch from external service
3. Transform data
4. Post to backend
5. Cache locally
6. Return result

### Pattern 4: Navigation Orchestration
**Used by**: LoginUseCase, LogoutUseCase
1. Perform business operation
2. Update state
3. Navigate to appropriate screen
4. Handle errors with appropriate navigation

---

## Service Dependencies

### Dependency Injection Setup
All services are registered via get_it service locator:

```dart
// Core services
getIt.registerSingleton<ApiService>(ApiService());
getIt.registerSingleton<NavigationService>(NavigationService());
getIt.registerSingleton<StorageService>(StorageService());

// Repositories
getIt.registerLazySingleton<AuthRepository>(() => AuthRepository(getIt<ApiService>()));
getIt.registerLazySingleton<ProfileRepository>(() => ProfileRepository(getIt<ApiService>()));

// Use cases
getIt.registerFactory<LoginUseCase>(() => LoginUseCase(getIt<AuthRepository>()));
getIt.registerFactory<GetProfileUseCase>(() => GetProfileUseCase(getIt<ProfileRepository>()));
```

### Service Resolution
Services are resolved in BLoCs/Cubits:

```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  
  AuthBloc() : _loginUseCase = getIt<LoginUseCase>();
}
```

---

## Notes

- **Use Case Pattern**: One use case per user story action (as per design decision)
- **Orchestration**: Use cases coordinate between repositories and handle business logic flow
- **Error Handling**: All use cases return Result<T> type for consistent error handling
- **Caching**: Use cases handle caching logic, repositories provide cache methods
- **Dependencies**: Use cases depend on repositories, not directly on API services
- **State Management**: Use cases are called from BLoCs/Cubits, not directly from UI

