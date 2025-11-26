# Component Dependencies

This document defines dependency relationships and communication patterns between components in the Easy App Flutter mobile application.

## Dependency Rules

### Clean Architecture Dependency Rule
- **Presentation Layer** → **Domain Layer** → **Data Layer**
- Dependencies flow inward: Outer layers depend on inner layers, not vice versa
- Domain layer has no dependencies on other layers

### Dependency Direction
```
Presentation (BLoCs, UI)
    ↓ depends on
Domain (Use Cases, Entities)
    ↓ depends on
Data (Repositories, API Services)
```

---

## Core Component Dependencies

### CoreNavigation
- **Dependencies**: None (core service, no external dependencies)
- **Used By**: All features (via dependency injection)

### CoreNetwork (ApiService)
- **Dependencies**: 
  - Dio (HTTP client)
  - CoreConfig (for base URLs, certificates)
  - CoreStorage (for token storage for refresh interceptor)
- **Used By**: All repositories

### CoreStorage
- **Dependencies**: 
  - Hive (local storage)
  - Encryption packages
- **Used By**: All repositories, AuthRepository (for token storage)

### CoreDI (Dependency Injection)
- **Dependencies**: get_it package
- **Used By**: Application initialization, all features

---

## Feature Component Dependencies

### Authentication Feature

#### AuthPresentation (AuthBloc/AuthCubit)
- **Depends On**:
  - LoginUseCase
  - LogoutUseCase
  - RefreshTokenUseCase
  - NavigationService (for navigation after login/logout)
- **No Dependencies On**: Other features (authentication is independent)

#### AuthDomain (Use Cases)
- **Depends On**:
  - AuthRepository
  - NavigationService (LoginUseCase, LogoutUseCase)
- **No Dependencies On**: Other features

#### AuthData (AuthRepository)
- **Depends On**:
  - ApiService
  - StorageService (for token storage)
- **No Dependencies On**: Other repositories

---

### Home Feature

#### HomePresentation (HomeBloc/HomeCubit)
- **Depends On**:
  - LoadHomeModulesUseCase
  - LoadUserProfileUseCase
  - RegisterPushTokenUseCase
  - CheckAppVersionUseCase
  - CheckMaintenanceStatusUseCase
  - NavigationService (for navigation to features)
  - **ProfileRepository** (direct dependency for cross-feature communication - as per design decision)
- **Dependencies On Other Features**: Profile (for user summary display)

#### HomeDomain (Use Cases)
- **Depends On**:
  - HomeRepository
  - ProfileRepository (LoadUserProfileUseCase - direct dependency)
- **Dependencies On Other Features**: Profile (direct dependency)

#### HomeData (HomeRepository)
- **Depends On**:
  - ApiService
- **No Dependencies On**: Other repositories

---

### Profile Feature

#### ProfilePresentation (ProfileBloc/ProfileCubit)
- **Depends On**:
  - GetProfileUseCase
  - UpdateProfileUseCase
  - UploadProfilePictureUseCase
  - DeleteProfilePictureUseCase
  - NavigationService
- **No Dependencies On**: Other features (but Home depends on Profile)

#### ProfileDomain (Use Cases)
- **Depends On**:
  - ProfileRepository
  - HomeRepository (UpdateProfileUseCase - to notify Home of profile updates)
- **Dependencies On Other Features**: Home (for notification)

#### ProfileData (ProfileRepository)
- **Depends On**:
  - ApiService
  - StorageService (for caching)
- **No Dependencies On**: Other repositories

---

### Announcements Feature

#### AnnouncementsPresentation (AnnouncementsBloc/AnnouncementsCubit)
- **Depends On**:
  - GetAnnouncementsUseCase
  - GetAnnouncementDetailsUseCase
  - SearchAnnouncementsUseCase
  - FilterAnnouncementsUseCase
  - NavigationService
- **No Dependencies On**: Other features

#### AnnouncementsDomain (Use Cases)
- **Depends On**:
  - AnnouncementRepository
- **No Dependencies On**: Other features

#### AnnouncementsData (AnnouncementRepository)
- **Depends On**:
  - ApiService
  - StorageService (for caching)
- **No Dependencies On**: Other repositories

---

### QR Wallet Feature

#### QRWalletPresentation (QRWalletBloc/QRWalletCubit)
- **Depends On**:
  - ScanQRCodeUseCase
  - ShowQRCodeUseCase
  - ProcessPaymentUseCase
  - GetPaymentHistoryUseCase
  - GetTransactionDetailsUseCase
  - NavigationService
  - CameraService (for QR scanning)
- **No Dependencies On**: Other features

#### QRWalletDomain (Use Cases)
- **Depends On**:
  - QRWalletRepository
  - HomeRepository (ProcessPaymentUseCase - to update wallet balance on Home)
- **Dependencies On Other Features**: Home (for wallet balance update)

#### QRWalletData (QRWalletRepository)
- **Depends On**:
  - ApiService
  - StorageService (for caching)
- **No Dependencies On**: Other repositories

---

### Eclaims Feature

#### EclaimsPresentation (EclaimsBloc/EclaimsCubit)
- **Depends On**:
  - SubmitOutOfOfficeClaimUseCase
  - SubmitHealthScreeningClaimUseCase
  - SubmitNewEntryClaimUseCase
  - GetMyClaimsUseCase
  - GetClaimDetailsUseCase
  - CancelClaimUseCase
  - NavigationService
  - FilePickerService (for file attachments)
- **No Dependencies On**: Other features

#### EclaimsDomain (Use Cases)
- **Depends On**:
  - EclaimsRepository
- **No Dependencies On**: Other features

#### EclaimsData (EclaimsRepository)
- **Depends On**:
  - ApiService
  - StorageService (for caching)
- **No Dependencies On**: Other repositories

---

### AstroDesk Feature

#### AstroDeskPresentation (AstroDeskBloc/AstroDeskCubit)
- **Depends On**:
  - GetSupportTicketsUseCase
  - CreateSupportTicketUseCase
  - GetTicketDetailsUseCase
  - GetTownHallContentUseCase
  - NavigationService
  - FilePickerService (for image attachments)
- **No Dependencies On**: Other features

#### AstroDeskDomain (Use Cases)
- **Depends On**:
  - AstroDeskRepository
- **No Dependencies On**: Other features

#### AstroDeskData (AstroDeskRepository)
- **Depends On**:
  - ApiService
  - StorageService (for caching)
- **No Dependencies On**: Other repositories

---

### Steps Challenge Feature

#### StepsChallengePresentation (StepsChallengeBloc/StepsChallengeCubit)
- **Depends On**:
  - GetStepDataUseCase
  - SyncStepsFromHealthAppUseCase
  - GetRankingsUseCase
  - GetProgressGraphUseCase
  - NavigationService
  - HealthDataService (for Google Fit/Apple Health integration)
- **No Dependencies On**: Other features

#### StepsChallengeDomain (Use Cases)
- **Depends On**:
  - StepsChallengeRepository
  - HealthDataService (SyncStepsFromHealthAppUseCase)
- **No Dependencies On**: Other features

#### StepsChallengeData (StepsChallengeRepository)
- **Depends On**:
  - ApiService
  - StorageService (for caching)
  - HealthDataService (for fetching steps)
- **No Dependencies On**: Other repositories

---

## Cross-Feature Communication

### Direct Dependency Pattern (as per design decision)

#### Home → Profile
- **Purpose**: Home displays user profile summary (name, avatar, wallet balance)
- **Implementation**: HomeBloc depends on ProfileRepository directly
- **Communication**: HomeBloc calls ProfileRepository.getProfile() to get user summary
- **When**: On home page load, after profile update

#### Profile → Home
- **Purpose**: Notify Home when profile is updated
- **Implementation**: UpdateProfileUseCase depends on HomeRepository
- **Communication**: After profile update, trigger Home refresh (via HomeRepository or event)
- **When**: After successful profile update

#### QR Wallet → Home
- **Purpose**: Update wallet balance on Home after payment
- **Implementation**: ProcessPaymentUseCase depends on HomeRepository
- **Communication**: After successful payment, update Home wallet balance
- **When**: After successful payment processing

---

## Dependency Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │ AuthBloc │  │ HomeBloc │  │ProfileBloc│  │  ...     │   │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘   │
│       │             │              │             │          │
│       │             │              │             │          │
│       └─────────────┴──────────────┴─────────────┘          │
│                    │                                          │
│                    ▼                                          │
│              ┌──────────┐                                    │
│              │Navigation │                                    │
│              │  Service │                                    │
│              └──────────┘                                    │
└────────────────────┬─────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                     Domain Layer                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │LoginUse  │  │LoadHome  │  │GetProfile│  │  ...     │   │
│  │  Case    │  │UseCase   │  │UseCase   │  │          │   │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘   │
│       │             │              │             │          │
│       │             │              │             │          │
│       └─────────────┴──────────────┴─────────────┘          │
└────────────────────┬─────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │   Auth   │  │  Home    │  │ Profile  │  │  ...     │   │
│  │Repository│  │Repository│  │Repository│  │          │   │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘   │
│       │             │              │             │          │
│       └─────────────┴──────────────┴─────────────┘          │
│                    │                                          │
│                    ▼                                          │
│              ┌──────────┐                                    │
│              │  Api      │                                    │
│              │ Service   │                                    │
│              └─────┬─────┘                                    │
│                    │                                          │
│                    ▼                                          │
│              ┌──────────┐                                    │
│              │ Storage  │                                     │
│              │ Service  │                                    │
│              └──────────┘                                    │
└─────────────────────────────────────────────────────────────┘
```

---

## Dependency Injection Graph

### Service Locator Setup (get_it)

```
Application
    ├── Core Services
    │   ├── ApiService
    │   ├── NavigationService
    │   ├── StorageService
    │   └── DependencyInjectionService
    │
    ├── Repositories
    │   ├── AuthRepository (depends on: ApiService, StorageService)
    │   ├── HomeRepository (depends on: ApiService)
    │   ├── ProfileRepository (depends on: ApiService, StorageService)
    │   ├── AnnouncementRepository (depends on: ApiService, StorageService)
    │   ├── QRWalletRepository (depends on: ApiService, StorageService)
    │   ├── EclaimsRepository (depends on: ApiService, StorageService)
    │   └── ... (other repositories)
    │
    └── Use Cases
        ├── LoginUseCase (depends on: AuthRepository)
        ├── LoadHomeModulesUseCase (depends on: HomeRepository)
        ├── GetProfileUseCase (depends on: ProfileRepository)
        └── ... (other use cases)
```

---

## Communication Patterns

### Pattern 1: BLoC → Use Case → Repository → API
**Standard flow for most operations**
```
UI Event → BLoC → Use Case → Repository → ApiService → Backend
                ↓
            Result<T> → BLoC → State → UI
```

### Pattern 2: Cross-Feature Direct Dependency
**Used for: Home → Profile, QR Wallet → Home**
```
HomeBloc → ProfileRepository.getProfile() → ApiService
```

### Pattern 3: Use Case Orchestration
**Used for: LoginUseCase (multiple steps)**
```
LoginUseCase
  ├── AuthRepository.exchangeAuthCode()
  ├── AuthRepository.saveTokens()
  ├── HomeRepository.getUserProfile()
  └── NavigationService.navigateToHome()
```

### Pattern 4: Caching Pattern
**Used for: Offline support**
```
Use Case → Repository
  ├── Try API call
  ├── If success: Cache data, return data
  └── If error: Return cached data (if available)
```

---

## Dependency Validation Rules

### Rule 1: No Circular Dependencies
- Feature A cannot depend on Feature B if Feature B depends on Feature A
- Exception: Home ↔ Profile (bidirectional but acceptable for user summary)

### Rule 2: Domain Layer Independence
- Domain layer (Use Cases, Entities) has no dependencies on Presentation or Data layers
- Use Cases depend only on Repositories (abstractions)

### Rule 3: Repository Abstraction
- BLoCs and Use Cases depend on Repository interfaces, not implementations
- Allows for easy testing and swapping implementations

### Rule 4: Core Services Singleton
- Core services (NavigationService, ApiService, StorageService) are singletons
- Registered once in dependency injection setup

---

## Notes

- **Direct Dependencies**: As per design decision, cross-feature communication uses direct dependencies (Home → Profile, QR Wallet → Home)
- **Dependency Injection**: All dependencies are injected via get_it service locator
- **Testability**: Dependencies are abstracted through interfaces, allowing easy mocking in tests
- **Loose Coupling**: Features are mostly independent, with minimal cross-feature dependencies
- **Error Propagation**: Errors flow from Data → Domain → Presentation via Result<T> types

