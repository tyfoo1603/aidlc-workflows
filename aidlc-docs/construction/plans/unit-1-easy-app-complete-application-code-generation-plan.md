# Code Generation Plan - Unit 1: Easy App Complete Application

## Purpose
Create detailed code generation plan for Unit 1: Easy App Complete Application. This plan will guide the implementation of the complete Flutter mobile application with all features.

## Unit Context

### Unit Definition
- **Unit Name**: Easy App Complete Application
- **Stories**: 46+ stories (all user stories)
- **Story Points**: 185+ points
- **Complexity**: High
- **Priority**: High

### Features Included
- Core Infrastructure (Auth, Home, Core components)
- Profile Management
- Announcements
- QR Wallet
- Eclaims
- AstroDesk
- Report Piracy
- Settings
- AstroNet
- Steps Challenge
- Content Highlights
- Friends & Family
- Sooka Share

### Architecture
- **Pattern**: Clean Architecture + BLoC/Cubit
- **State Management**: flutter_bloc
- **Dependency Injection**: get_it
- **Local Storage**: Hive + flutter_secure_storage
- **Network**: Dio with certificate pinning

---

## Code Generation Steps

### Phase 1: Project Setup and Configuration

- [x] **Step 1.1**: Create Flutter project structure
  - Initialize Flutter project with Flutter SDK 3.38.2
  - Set up folder structure (lib/core, lib/features)
  - Configure pubspec.yaml with all dependencies

- [x] **Step 1.2**: Configure build flavors
  - Create main_dev.dart, main_staging.dart, main_prod.dart
  - Configure Android build flavors (build.gradle)
  - Configure iOS build flavors (schemes)
  - Set up environment configuration class

- [x] **Step 1.3**: Set up dependency injection
  - Create dependency_injection.dart
  - Configure get_it service locator
  - Set up dependency registration order

- [ ] **Step 1.4**: Configure Firebase services
  - Add google-services.json (Android)
  - Add GoogleService-Info.plist (iOS)
  - Initialize Firebase in main.dart
  - Configure Firebase Analytics
  - Configure Firebase Crashlytics

- [ ] **Step 1.5**: Configure HMS (Huawei) services
  - Add agconnect-services.json (Android)
  - Initialize HMS services
  - Configure HMS Push

---

### Phase 2: Core Infrastructure

- [x] **Step 2.1**: Create core configuration
  - Implement AppConfig class
  - Environment-specific configuration
  - API base URLs per environment
  - Certificate pinning configuration
  - Microsoft OAuth configuration (tenant, client ID, secret, redirect URI)

- [x] **Step 2.2**: Create core error handling
  - Implement Result<T> type
  - Create custom exception classes
  - Error classification (Network, Auth, Server, Validation, Unknown)
  - Error message formatting

- [x] **Step 2.3**: Create core storage
  - Implement StorageService
  - Initialize Hive boxes
  - Set up encrypted Hive boxes
  - Implement cache management with LRU eviction

- [x] **Step 2.4**: Create secure token storage
  - Implement SecureTokenStorage using flutter_secure_storage
  - Token save/retrieve/clear methods
  - Platform-specific configuration

- [x] **Step 2.5**: Create core network
  - Implement ApiService with Dio
  - Configure certificate pinning per environment
  - Set up Dio interceptors (Auth, Retry, Logging, Certificate Pinning)
  - Implement network connectivity checking (TODO: implement connectivity service)

- [x] **Step 2.6**: Create navigation service
  - Implement NavigationService
  - Define all routes
  - Implement navigation methods
  - Deep link handling

- [ ] **Step 2.7**: Create core utilities
  - Connectivity service
  - Image cache manager
  - Memory monitor
  - Update service

---

### Phase 3: Authentication Feature

- [x] **Step 3.1**: Create authentication domain entities
  - Token entity
  - AuthState entity
  - Error entities

- [x] **Step 3.2**: Create authentication data layer
  - AuthRepository implementation
  - Microsoft OAuth API integration
  - Azure Graph API integration
  - Token storage integration

- [x] **Step 3.3**: Create authentication use cases
  - LoginUseCase
  - LogoutUseCase
  - RefreshTokenUseCase
  - ForgotPasswordUseCase (TODO: implement when needed)

- [x] **Step 3.4**: Create authentication presentation layer
  - AuthBloc/AuthCubit with state machine
  - Login screen UI
  - Logout functionality
  - Forgot password screen (TODO: create UI when needed)

- [ ] **Step 3.5**: Implement OAuth flow
  - OAuth webview implementation
  - Authorization code interception
  - Token exchange
  - Token refresh mechanism

- [ ] **Step 3.6**: Create authentication tests
  - Unit tests for use cases
  - Unit tests for repository
  - Widget tests for login screen
  - Integration tests for OAuth flow

---

### Phase 4: Home Feature

- [x] **Step 4.1**: Create home domain entities
  - LandingCategory entity
  - UserSummary entity
  - AppVersion entity
  - MaintenanceStatus entity

- [x] **Step 4.2**: Create home data layer
  - HomeRepository implementation
  - Landing categories API integration (with response mapping)
  - User profile API integration (with response mapping)
  - Push token registration API
  - App version API integration (with response mapping)
  - Maintenance status API integration (with response mapping)

- [x] **Step 4.3**: Create home use cases
  - LoadHomeModulesUseCase
  - LoadUserProfileUseCase
  - RegisterPushTokenUseCase
  - CheckAppVersionUseCase
  - CheckMaintenanceStatusUseCase

- [x] **Step 4.4**: Create home presentation layer
  - HomeBloc/HomeCubit
  - Home screen UI
  - Module grid/list display
  - User summary display
  - Maintenance banner
  - Update dialog

- [ ] **Step 4.5**: Implement push notification registration
  - FCM token registration
  - HMS token registration
  - Token registration on app launch
  - Token registration on login

- [ ] **Step 4.6**: Create home tests
  - Unit tests for use cases
  - Unit tests for repository
  - Widget tests for home screen
  - Integration tests for home flow

---

### Phase 5: Profile Feature

- [ ] **Step 5.1**: Create profile domain entities
  - UserProfile entity
  - ProfileUpdateRequest entity

- [ ] **Step 5.2**: Create profile data layer
  - ProfileRepository implementation
  - Profile API integration
  - Profile picture upload API
  - Profile picture delete API
  - Profile caching

- [ ] **Step 5.3**: Create profile use cases
  - GetProfileUseCase
  - UpdateProfileUseCase
  - UploadProfilePictureUseCase
  - DeleteProfilePictureUseCase

- [ ] **Step 5.4**: Create profile presentation layer
  - ProfileBloc/ProfileCubit
  - Profile screen UI
  - Profile edit screen
  - Profile picture upload UI
  - Home care information screen
  - Updates screen

- [ ] **Step 5.5**: Create profile tests
  - Unit tests for use cases
  - Unit tests for repository
  - Widget tests for profile screens
  - Integration tests for profile flow

---

### Phase 6: Announcements Feature

- [ ] **Step 6.1**: Create announcements domain entities
  - Announcement entity
  - AnnouncementFilter entity

- [ ] **Step 6.2**: Create announcements data layer
  - AnnouncementRepository implementation
  - Announcements API integration
  - Announcement search API
  - Announcement caching

- [ ] **Step 6.3**: Create announcements use cases
  - GetAnnouncementsUseCase
  - GetAnnouncementDetailsUseCase
  - SearchAnnouncementsUseCase
  - FilterAnnouncementsUseCase

- [ ] **Step 6.4**: Create announcements presentation layer
  - AnnouncementsBloc/AnnouncementsCubit
  - Announcements list screen with infinite scroll
  - Announcement details screen
  - Search screen
  - Filter screen

- [ ] **Step 6.5**: Create announcements tests
  - Unit tests for use cases
  - Unit tests for repository
  - Widget tests for announcement screens
  - Integration tests for announcements flow

---

### Phase 7: QR Wallet Feature

- [ ] **Step 7.1**: Create QR wallet domain entities
  - Payment entity
  - Transaction entity
  - QRCodeData entity

- [ ] **Step 7.2**: Create QR wallet data layer
  - QRWalletRepository implementation
  - Payment API integration
  - Transaction history API
  - QR code generation
  - Transaction caching

- [ ] **Step 7.3**: Create QR wallet use cases
  - ScanQRCodeUseCase
  - ShowQRCodeUseCase
  - ProcessPaymentUseCase
  - GetPaymentHistoryUseCase
  - GetTransactionDetailsUseCase

- [ ] **Step 7.4**: Create QR wallet presentation layer
  - QRWalletBloc/QRWalletCubit
  - QR scanner screen
  - QR code display screen
  - Payment confirmation screen
  - Payment history screen with infinite scroll
  - Transaction details screen

- [ ] **Step 7.5**: Implement QR code scanning
  - QR code scanner integration
  - QR code validation
  - QR code generation

- [ ] **Step 7.6**: Create QR wallet tests
  - Unit tests for use cases
  - Unit tests for repository
  - Widget tests for QR wallet screens
  - Integration tests for QR wallet flow

---

### Phase 8: Eclaims Feature

- [ ] **Step 8.1**: Create eclaims domain entities
  - Claim entity
  - ClaimType entity
  - ClaimStatus entity

- [ ] **Step 8.2**: Create eclaims data layer
  - EclaimsRepository implementation
  - Claim submission API
  - Claim update API
  - My claims API
  - Claim details API
  - Claim cancellation API
  - File upload handling
  - Claims caching

- [ ] **Step 8.3**: Create eclaims use cases
  - SubmitOutOfOfficeClaimUseCase
  - SubmitHealthScreeningClaimUseCase
  - SubmitNewEntryClaimUseCase
  - GetMyClaimsUseCase
  - GetClaimDetailsUseCase
  - CancelClaimUseCase

- [ ] **Step 8.4**: Create eclaims presentation layer
  - EclaimsBloc/EclaimsCubit
  - Eclaims guide screen (webview)
  - Eclaims options screen
  - Out of office claim form
  - Health screening claim form
  - New entry claim form
  - My claims list screen with infinite scroll
  - Claim details screen

- [ ] **Step 8.5**: Implement file upload
  - File picker integration
  - Image compression
  - Multipart form data handling

- [ ] **Step 8.6**: Create eclaims tests
  - Unit tests for use cases
  - Unit tests for repository
  - Widget tests for eclaims screens
  - Integration tests for eclaims flow

---

### Phase 9: AstroDesk Feature

- [ ] **Step 9.1**: Create astrodesk domain entities
  - Ticket entity
  - TownHallContent entity

- [ ] **Step 9.2**: Create astrodesk data layer
  - AstroDeskRepository implementation
  - Support tickets API
  - Create ticket API
  - Ticket details API
  - Town hall content API
  - Tickets caching

- [ ] **Step 9.3**: Create astrodesk use cases
  - GetSupportTicketsUseCase
  - FilterSupportTicketsUseCase
  - CreateSupportTicketUseCase
  - GetTicketDetailsUseCase
  - GetTownHallContentUseCase

- [ ] **Step 9.4**: Create astrodesk presentation layer
  - AstroDeskBloc/AstroDeskCubit
  - Support tickets list screen
  - Ticket filter screen
  - Create ticket screen
  - Ticket details screen
  - Town hall content screen

- [ ] **Step 9.5**: Create astrodesk tests
  - Unit tests for use cases
  - Unit tests for repository
  - Widget tests for astrodesk screens
  - Integration tests for astrodesk flow

---

### Phase 10: Report Piracy Feature

- [ ] **Step 10.1**: Create report piracy domain entities
  - Report entity
  - ReportType entity

- [ ] **Step 10.2**: Create report piracy data layer
  - ReportPiracyRepository implementation
  - Submit report API
  - Report history API
  - File upload handling
  - Reports caching

- [ ] **Step 10.3**: Create report piracy use cases
  - SubmitCommercialOutletReportUseCase
  - SubmitWebsiteReportUseCase
  - GetReportHistoryUseCase

- [ ] **Step 10.4**: Create report piracy presentation layer
  - ReportPiracyBloc/ReportPiracyCubit
  - Report type selection screen
  - Commercial outlet report form
  - Website report form
  - Report history screen

- [ ] **Step 10.5**: Create report piracy tests
  - Unit tests for use cases
  - Unit tests for repository
  - Widget tests for report piracy screens
  - Integration tests for report piracy flow

---

### Phase 11: Settings Feature

- [ ] **Step 11.1**: Create settings domain entities
  - NotificationPreferences entity
  - UpdateInfo entity

- [ ] **Step 11.2**: Create settings data layer
  - SettingsRepository implementation
  - App version API
  - Update check API
  - Notification preferences API

- [ ] **Step 11.3**: Create settings use cases
  - GetAppVersionUseCase
  - CheckForUpdatesUseCase
  - UpdateNotificationPreferencesUseCase

- [ ] **Step 11.4**: Create settings presentation layer
  - SettingsBloc/SettingsCubit
  - Settings screen
  - App version display
  - Update management UI
  - Notification preferences screen

- [ ] **Step 11.5**: Implement update mechanism
  - Version check on launch
  - Force update dialog
  - Optional update notification
  - App store links

- [ ] **Step 11.6**: Create settings tests
  - Unit tests for use cases
  - Unit tests for repository
  - Widget tests for settings screens
  - Integration tests for settings flow

---

### Phase 12: AstroNet Feature

- [ ] **Step 12.1**: Create astronet domain entities
  - AstroNetCredentials entity

- [ ] **Step 12.2**: Create astronet data layer
  - AstroNetRepository implementation
  - AstroNet login API
  - AstroNet content API

- [ ] **Step 12.3**: Create astronet use cases
  - LoginToAstroNetUseCase
  - GetAstroNetContentUseCase

- [ ] **Step 12.4**: Create astronet presentation layer
  - AstroNetBloc/AstroNetCubit
  - AstroNet login screen
  - AstroNet content webview

- [ ] **Step 12.5**: Create astronet tests
  - Unit tests for use cases
  - Unit tests for repository
  - Widget tests for astronet screens
  - Integration tests for astronet flow

---

### Phase 13: Steps Challenge Feature

- [ ] **Step 13.1**: Create steps challenge domain entities
  - StepData entity
  - Ranking entity
  - StepDataPoint entity

- [ ] **Step 13.2**: Create steps challenge data layer
  - StepsChallengeRepository implementation
  - Steps API integration
  - Rankings API
  - Google Fit integration (Android)
  - Apple Health integration (iOS)
  - Steps caching

- [ ] **Step 13.3**: Create steps challenge use cases
  - GetStepDataUseCase
  - SyncStepsFromHealthAppUseCase
  - GetRankingsUseCase
  - GetProgressGraphUseCase

- [ ] **Step 13.4**: Create steps challenge presentation layer
  - StepsChallengeBloc/StepsChallengeCubit
  - Steps challenge screen
  - Step data display
  - Rankings display
  - Progress graph screen
  - Historical data navigation

- [ ] **Step 13.5**: Implement health data integration
  - Google Fit integration (Android)
  - Apple Health integration (iOS)
  - Permission requests
  - Real-time step sync
  - Background sync

- [ ] **Step 13.6**: Create steps challenge tests
  - Unit tests for use cases
  - Unit tests for repository
  - Widget tests for steps challenge screens
  - Integration tests for steps challenge flow

---

### Phase 14: Webview Features (Content Highlights, Friends & Family, Sooka Share)

- [ ] **Step 14.1**: Create webview features domain entities
  - WebviewContent entity

- [ ] **Step 14.2**: Create webview features data layer
  - ContentHighlightsRepository
  - FriendsFamilyRepository
  - SookaShareRepository
  - Webview content API integration

- [ ] **Step 14.3**: Create webview features use cases
  - GetContentHighlightsUseCase
  - GetFriendsFamilyContentUseCase
  - GetSookaShareContentUseCase
  - SubmitReferLeadUseCase

- [ ] **Step 14.4**: Create webview features presentation layer
  - ContentHighlightsBloc/ContentHighlightsCubit
  - FriendsFamilyBloc/FriendsFamilyCubit
  - SookaShareBloc/SookaShareCubit
  - Webview screens for each feature
  - Refer lead submission form (Sooka Share)

- [ ] **Step 14.5**: Implement webview handling
  - In-app webview widget
  - Navigation handling
  - Deep link handling from webview

- [ ] **Step 14.6**: Create webview features tests
  - Unit tests for use cases
  - Unit tests for repositories
  - Widget tests for webview screens
  - Integration tests for webview flows

---

### Phase 15: Push Notifications and Deep Linking

- [ ] **Step 15.1**: Implement push notification handling
  - FCM notification handler
  - HMS notification handler
  - Notification routing
  - Deep link extraction from notifications

- [ ] **Step 15.2**: Implement deep link handling
  - Deep link parser
  - Route resolution
  - Access validation
  - Navigation to features

- [ ] **Step 15.3**: Create push notification tests
  - Unit tests for notification handlers
  - Integration tests for notification flow
  - Deep link tests

---

### Phase 16: Testing

- [ ] **Step 16.1**: Create unit tests
  - Test all use cases
  - Test all repositories
  - Test core services
  - Target 70%+ code coverage

- [ ] **Step 16.2**: Create widget tests
  - Test all UI screens
  - Test BLoC/Cubit integration
  - Test navigation

- [ ] **Step 16.3**: Create integration tests
  - Test authentication flow
  - Test home flow
  - Test feature flows
  - Test error handling

- [ ] **Step 16.4**: Create end-to-end tests
  - Test critical user journeys
  - Test complete workflows
  - Test offline scenarios

---

### Phase 17: Build Configuration and Finalization

- [ ] **Step 17.1**: Configure Android build
  - Signing configuration
  - ProGuard rules
  - App bundle configuration
  - Permissions configuration

- [ ] **Step 17.2**: Configure iOS build
  - Signing configuration
  - Info.plist configuration
  - Capabilities configuration
  - App Store configuration

- [ ] **Step 17.3**: Configure web build
  - Web-specific configuration
  - PWA configuration (if needed)

- [ ] **Step 17.4**: Final code review and cleanup
  - Code formatting
  - Linting fixes
  - Documentation
  - Remove debug code

---

## Implementation Order

### Recommended Sequence
1. **Phase 1-2**: Project setup and core infrastructure (foundation)
2. **Phase 3**: Authentication (required for all features)
3. **Phase 4**: Home (navigation hub)
4. **Phase 5**: Profile (needed by home)
5. **Phase 6-14**: Feature implementations (can be parallel)
6. **Phase 15**: Push notifications and deep linking
7. **Phase 16**: Testing
8. **Phase 17**: Build configuration

### Parallel Development Opportunities
- Features (Phase 6-14) can be developed in parallel
- Some tests can be written in parallel with feature development
- Webview features (Phase 14) are simpler and can be done in parallel

---

## Notes

- **Clean Architecture**: Follow Clean Architecture principles (Presentation → Domain → Data)
- **BLoC Pattern**: Use Cubit for simpler state, BLoC for complex flows
- **Dependency Injection**: All dependencies via get_it
- **Error Handling**: Use Result<T> type for error handling
- **Testing**: Comprehensive test coverage (unit, widget, integration, e2e)
- **Code Quality**: Follow Flutter best practices and linting rules

---

## Instructions
This plan will be executed step by step. Each checkbox will be marked as completed as code is generated. The plan covers the complete application implementation.

