# Application Components

This document defines the high-level components and their responsibilities for the Easy App Flutter mobile application, following Clean Architecture with BLoC pattern.

## Architecture Overview

The application follows **Clean Architecture** with three main layers:
- **Presentation Layer**: UI, BLoCs/Cubits, Widgets
- **Domain Layer**: Use Cases, Entities, Business Logic
- **Data Layer**: Repositories, API Services, Local Storage

**Folder Structure**: Feature-based organization with shared `core` folder for infrastructure components.

---

## Core/Shared Components

### Core Infrastructure Components

#### CoreConfig
- **Purpose**: Application configuration and constants
- **Responsibilities**:
  - Environment configuration (dev, staging, production)
  - API base URLs
  - App version information
  - Feature flags

#### CoreError
- **Purpose**: Error handling infrastructure
- **Responsibilities**:
  - Custom exception classes
  - Result/Either types for error handling
  - Error message formatting
  - Error logging

#### CoreNavigation
- **Purpose**: Centralized navigation service
- **Responsibilities**:
  - Route definitions
  - Navigation coordination
  - Deep linking handling
  - Navigation state management

#### CoreDI
- **Purpose**: Dependency injection setup
- **Responsibilities**:
  - Service locator configuration (get_it)
  - Dependency registration
  - Dependency resolution

#### CoreStorage
- **Purpose**: Local storage infrastructure
- **Responsibilities**:
  - Hive box initialization
  - Encrypted storage setup
  - Storage utilities

#### CoreNetwork
- **Purpose**: Network infrastructure
- **Responsibilities**:
  - HTTP client configuration (Dio)
  - Certificate pinning setup
  - Interceptor configuration (token refresh, error handling)
  - Network connectivity checking

---

## Feature Components

### Authentication Feature

#### AuthPresentation
- **Purpose**: Authentication UI and state management
- **Responsibilities**:
  - Login screen UI
  - Logout UI
  - Password reset UI
  - Authentication state management (AuthBloc/AuthCubit)
  - OAuth webview handling

#### AuthDomain
- **Purpose**: Authentication business logic
- **Responsibilities**:
  - Use cases: LoginUseCase, LogoutUseCase, RefreshTokenUseCase
  - Authentication entities
  - Token management logic

#### AuthData
- **Purpose**: Authentication data layer
- **Responsibilities**:
  - AuthRepository (hybrid: feature-based for complex auth flow)
  - Token storage (Hive with encryption)
  - Microsoft OAuth API integration
  - Azure Graph API integration

---

### Home Feature

#### HomePresentation
- **Purpose**: Home page UI and state management
- **Responsibilities**:
  - Home screen UI
  - Module grid/list display
  - User summary display
  - Home state management (HomeBloc/HomeCubit)
  - Navigation to features

#### HomeDomain
- **Purpose**: Home business logic
- **Responsibilities**:
  - Use cases: LoadHomeModulesUseCase, LoadUserProfileUseCase, RegisterPushTokenUseCase
  - Home entities (LandingCategory, UserSummary)
  - Module filtering logic

#### HomeData
- **Purpose**: Home data layer
- **Responsibilities**:
  - HomeRepository (feature-based)
  - Landing categories API integration
  - Profile API integration
  - Push token registration

---

### Profile Feature

#### ProfilePresentation
- **Purpose**: Profile UI and state management
- **Responsibilities**:
  - Profile screen UI
  - Profile edit UI
  - Profile picture upload UI
  - Profile state management (ProfileBloc/ProfileCubit)

#### ProfileDomain
- **Purpose**: Profile business logic
- **Responsibilities**:
  - Use cases: GetProfileUseCase, UpdateProfileUseCase, UploadProfilePictureUseCase, DeleteProfilePictureUseCase
  - Profile entities
  - Profile validation logic

#### ProfileData
- **Purpose**: Profile data layer
- **Responsibilities**:
  - ProfileRepository (feature-based)
  - Profile API integration
  - Profile picture upload API integration
  - Local profile caching

---

### Announcements Feature

#### AnnouncementsPresentation
- **Purpose**: Announcements UI and state management
- **Responsibilities**:
  - Announcements list UI
  - Announcement details UI
  - Search and filter UI
  - Announcements state management (AnnouncementsBloc/AnnouncementsCubit)

#### AnnouncementsDomain
- **Purpose**: Announcements business logic
- **Responsibilities**:
  - Use cases: GetAnnouncementsUseCase, GetAnnouncementDetailsUseCase, SearchAnnouncementsUseCase, FilterAnnouncementsUseCase
  - Announcement entities
  - Search and filter logic

#### AnnouncementsData
- **Purpose**: Announcements data layer
- **Responsibilities**:
  - AnnouncementsRepository (entity-based: AnnouncementRepository)
  - Announcements API integration
  - Local announcements caching

---

### QR Wallet Feature

#### QRWalletPresentation
- **Purpose**: QR Wallet UI and state management
- **Responsibilities**:
  - QR Wallet screen UI
  - QR scanner UI
  - QR code display UI
  - Payment confirmation UI
  - Payment history UI
  - QR Wallet state management (QRWalletBloc/QRWalletCubit)

#### QRWalletDomain
- **Purpose**: QR Wallet business logic
- **Responsibilities**:
  - Use cases: ScanQRCodeUseCase, ShowQRCodeUseCase, ProcessPaymentUseCase, GetPaymentHistoryUseCase, GetTransactionDetailsUseCase
  - QR Wallet entities (Payment, Transaction, QRCode)
  - Payment validation logic
  - QR code generation logic

#### QRWalletData
- **Purpose**: QR Wallet data layer
- **Responsibilities**:
  - QRWalletRepository (feature-based for complex payment flow)
  - Payment API integration
  - Transaction history API integration
  - Local payment caching

---

### Eclaims Feature

#### EclaimsPresentation
- **Purpose**: Eclaims UI and state management
- **Responsibilities**:
  - Eclaims screen UI
  - Claim submission forms UI (Out of Office, Health Screening, New Entry)
  - My Claims list UI
  - Claim details UI
  - Eclaims state management (EclaimsBloc/EclaimsCubit)

#### EclaimsDomain
- **Purpose**: Eclaims business logic
- **Responsibilities**:
  - Use cases: SubmitOutOfOfficeClaimUseCase, SubmitHealthScreeningClaimUseCase, SubmitNewEntryClaimUseCase, GetMyClaimsUseCase, GetClaimDetailsUseCase, CancelClaimUseCase
  - Claim entities (Claim, ClaimType, ClaimStatus)
  - Claim validation logic

#### EclaimsData
- **Purpose**: Eclaims data layer
- **Responsibilities**:
  - EclaimsRepository (feature-based for complex claim flow)
  - Claims API integration
  - File upload handling
  - Local claims caching

---

### AstroDesk Feature

#### AstroDeskPresentation
- **Purpose**: AstroDesk UI and state management
- **Responsibilities**:
  - AstroDesk screen UI
  - Support tickets list UI
  - Create ticket UI
  - Ticket details UI
  - Town Hall content UI
  - AstroDesk state management (AstroDeskBloc/AstroDeskCubit)

#### AstroDeskDomain
- **Purpose**: AstroDesk business logic
- **Responsibilities**:
  - Use cases: GetSupportTicketsUseCase, CreateSupportTicketUseCase, GetTicketDetailsUseCase, GetTownHallContentUseCase
  - Ticket entities
  - Ticket filtering logic

#### AstroDeskData
- **Purpose**: AstroDesk data layer
- **Responsibilities**:
  - AstroDeskRepository (feature-based)
  - AstroDesk API integration
  - Local tickets caching

---

### Report Piracy Feature

#### ReportPiracyPresentation
- **Purpose**: Report Piracy UI and state management
- **Responsibilities**:
  - Report Piracy screen UI
  - Commercial outlet report form UI
  - Website report form UI
  - Report history UI
  - Report Piracy state management (ReportPiracyBloc/ReportPiracyCubit)

#### ReportPiracyDomain
- **Purpose**: Report Piracy business logic
- **Responsibilities**:
  - Use cases: SubmitCommercialOutletReportUseCase, SubmitWebsiteReportUseCase, GetReportHistoryUseCase
  - Report entities
  - Report validation logic

#### ReportPiracyData
- **Purpose**: Report Piracy data layer
- **Responsibilities**:
  - ReportPiracyRepository (feature-based)
  - Report Piracy API integration
  - Local reports caching

---

### Settings Feature

#### SettingsPresentation
- **Purpose**: Settings UI and state management
- **Responsibilities**:
  - Settings screen UI
  - App version display
  - Update management UI
  - Notification preferences UI
  - Settings state management (SettingsBloc/SettingsCubit)

#### SettingsDomain
- **Purpose**: Settings business logic
- **Responsibilities**:
  - Use cases: GetAppVersionUseCase, CheckForUpdatesUseCase, UpdateNotificationPreferencesUseCase
  - Settings entities
  - Update logic

#### SettingsData
- **Purpose**: Settings data layer
- **Responsibilities**:
  - SettingsRepository (feature-based)
  - Settings API integration
  - Local settings storage

---

### AstroNet Feature

#### AstroNetPresentation
- **Purpose**: AstroNet UI and state management
- **Responsibilities**:
  - AstroNet login UI
  - AstroNet content webview UI
  - AstroNet state management (AstroNetBloc/AstroNetCubit)

#### AstroNetDomain
- **Purpose**: AstroNet business logic
- **Responsibilities**:
  - Use cases: LoginToAstroNetUseCase, GetAstroNetContentUseCase
  - AstroNet entities

#### AstroNetData
- **Purpose**: AstroNet data layer
- **Responsibilities**:
  - AstroNetRepository (feature-based)
  - AstroNet API integration

---

### Steps Challenge Feature

#### StepsChallengePresentation
- **Purpose**: Steps Challenge UI and state management
- **Responsibilities**:
  - Steps Challenge screen UI
  - Step data display UI
  - Rankings display UI
  - Progress graph UI
  - Steps Challenge state management (StepsChallengeBloc/StepsChallengeCubit)

#### StepsChallengeDomain
- **Purpose**: Steps Challenge business logic
- **Responsibilities**:
  - Use cases: GetStepDataUseCase, SyncStepsFromHealthAppUseCase, GetRankingsUseCase, GetProgressGraphUseCase
  - Steps entities
  - Steps calculation logic

#### StepsChallengeData
- **Purpose**: Steps Challenge data layer
- **Responsibilities**:
  - StepsChallengeRepository (feature-based)
  - Steps API integration
  - Health data integration (Google Fit, Apple Health)
  - Local steps caching

---

### Content Highlights Feature

#### ContentHighlightsPresentation
- **Purpose**: Content Highlights UI and state management
- **Responsibilities**:
  - Content Highlights webview UI
  - Content Highlights state management (ContentHighlightsBloc/ContentHighlightsCubit)

#### ContentHighlightsDomain
- **Purpose**: Content Highlights business logic
- **Responsibilities**:
  - Use cases: GetContentHighlightsUseCase
  - Content entities

#### ContentHighlightsData
- **Purpose**: Content Highlights data layer
- **Responsibilities**:
  - ContentHighlightsRepository (feature-based)
  - Content Highlights API integration

---

### Friends & Family Feature

#### FriendsFamilyPresentation
- **Purpose**: Friends & Family UI and state management
- **Responsibilities**:
  - Friends & Family webview UI
  - Friends & Family state management (FriendsFamilyBloc/FriendsFamilyCubit)

#### FriendsFamilyDomain
- **Purpose**: Friends & Family business logic
- **Responsibilities**:
  - Use cases: GetFriendsFamilyContentUseCase
  - Friends & Family entities

#### FriendsFamilyData
- **Purpose**: Friends & Family data layer
- **Responsibilities**:
  - FriendsFamilyRepository (feature-based)
  - Friends & Family API integration

---

### Sooka Share Feature

#### SookaSharePresentation
- **Purpose**: Sooka Share UI and state management
- **Responsibilities**:
  - Sooka Share webview UI
  - Refer lead submission form UI
  - Sooka Share state management (SookaShareBloc/SookaShareCubit)

#### SookaShareDomain
- **Purpose**: Sooka Share business logic
- **Responsibilities**:
  - Use cases: GetSookaShareContentUseCase, SubmitReferLeadUseCase
  - Sooka Share entities

#### SookaShareData
- **Purpose**: Sooka Share data layer
- **Responsibilities**:
  - SookaShareRepository (feature-based)
  - Sooka Share API integration

---

## Shared Domain Entities

### Core Entities (in shared domain)
- **User**: Core user information
- **Token**: Authentication tokens
- **AppConfig**: Application configuration
- **Error**: Error information

### Feature-Specific Entities (in feature folders)
- **Profile**: Profile-specific user data (extends User)
- **Announcement**: Announcement data
- **Payment**: Payment transaction data
- **Claim**: Claim data
- **Ticket**: Support ticket data
- **Report**: Piracy report data
- **Steps**: Step data
- And other feature-specific entities

---

## Component Organization Summary

```
lib/
├── core/                          # Shared infrastructure
│   ├── config/                    # Configuration
│   ├── error/                     # Error handling
│   ├── navigation/                # Navigation service
│   ├── di/                        # Dependency injection
│   ├── storage/                   # Storage infrastructure
│   └── network/                   # Network infrastructure
├── features/                      # Feature-based organization
│   ├── auth/
│   │   ├── presentation/          # UI, BLoCs
│   │   ├── domain/                # Use cases, entities
│   │   └── data/                 # Repositories, API
│   ├── home/
│   ├── profile/
│   ├── announcements/
│   ├── qr_wallet/
│   ├── eclaims/
│   ├── astrodesk/
│   ├── report_piracy/
│   ├── settings/
│   ├── astronet/
│   ├── steps_challenge/
│   ├── content_highlights/
│   ├── friends_family/
│   └── sooka_share/
└── shared/                        # Shared domain entities (if needed)
    └── domain/
```

---

## Notes

- **Component Boundaries**: Each feature is self-contained with presentation, domain, and data layers
- **Shared Components**: Core infrastructure components are in `core/` folder
- **Domain Organization**: Core entities in shared domain, feature-specific entities in feature folders
- **Dependencies**: Presentation → Domain → Data (dependency rule enforced)
- **Communication**: Direct dependencies for cross-feature communication (e.g., Home depends on Profile)

