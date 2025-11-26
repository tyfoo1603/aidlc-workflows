# Tech Stack Decisions - Unit 1: Easy App Complete Application

## Overview

This document validates and documents tech stack decisions for Unit 1: Easy App Complete Application based on NFR requirements assessment.

---

## Core Framework

### Flutter SDK
- **Version**: 3.38.2 (as specified in requirements)
- **Rationale**: Matches requirements, ensures compatibility
- **Status**: ✅ Validated

---

## State Management

### BLoC/Cubit Pattern
- **Library**: `flutter_bloc` (latest stable)
- **Pattern**: BLoC/Cubit for state management
- **Rationale**: 
  - Matches requirements (NFR6)
  - Provides separation of concerns
  - Testable architecture
  - Supports complex state management
- **Status**: ✅ Validated

**Usage**:
- Use `Cubit` for simpler state management (most features)
- Use `Bloc` for complex event-driven flows (authentication)
- Separate business logic from UI
- Testable with bloc_test package

---

## Dependency Injection

### get_it
- **Library**: `get_it` (latest stable)
- **Pattern**: Service locator pattern
- **Rationale**:
  - Matches application design
  - Simple and lightweight
  - Supports lazy initialization
  - Well-established in Flutter community
- **Status**: ✅ Validated

**Usage**:
- Register dependencies on app initialization
- Resolve dependencies via `getIt.get<T>()`
- Support lazy initialization for performance
- Register in order: Core services → Repositories → Use Cases → BLoCs

---

## Local Storage

### Hive
- **Library**: `hive` + `hive_flutter` (latest stable)
- **Purpose**: Local data storage and caching
- **Rationale**:
  - Fast NoSQL database
  - Supports encryption
  - Good for caching
  - Lightweight
- **Status**: ✅ Validated

**Usage**:
- Cache user data, announcements, transactions, etc.
- Encrypted boxes for sensitive cached data (not tokens)
- Type adapters for entities
- LRU eviction for cache management

### flutter_secure_storage
- **Library**: `flutter_secure_storage` (latest stable)
- **Purpose**: Secure token storage
- **Rationale**:
  - Platform-native secure storage (keychain/keystore)
  - Automatic encryption
  - Better security than Hive for tokens
  - Matches NFR requirement (SEC-001)
- **Status**: ✅ Validated

**Usage**:
- Store access tokens
- Store refresh tokens
- Platform keychain (iOS) / keystore (Android)
- Automatic encryption by platform

---

## Network

### Dio
- **Library**: `dio` (latest stable)
- **Purpose**: HTTP client for API calls
- **Rationale**:
  - Powerful HTTP client
  - Supports interceptors
  - Certificate pinning support
  - Good error handling
- **Status**: ✅ Validated

**Usage**:
- API service implementation
- Interceptors for token refresh, error handling
- Certificate pinning configuration
- Environment-specific Dio instances

### Certificate Pinning
- **Library**: `certificate_pinning` or Dio's built-in pinning
- **Purpose**: SSL certificate pinning
- **Rationale**:
  - Security requirement (SEC-002)
  - Prevents man-in-the-middle attacks
  - Required for all environments
- **Status**: ✅ Validated

**Usage**:
- Pin certificates for all environments
- Environment-specific certificates
- Strict enforcement (block on pin failure)

---

## Image Loading

### Cached Network Image
- **Library**: `cached_network_image` (latest stable)
- **Purpose**: Image loading and caching
- **Rationale**:
  - Lazy loading support
  - Memory + disk cache
  - Matches NFR requirement (PERF-003)
  - Good performance
- **Status**: ✅ Validated

**Usage**:
- Lazy load images as they come into view
- Memory cache for frequently accessed images
- Disk cache for persistent storage
- Preload critical images (avatars, icons)

---

## Push Notifications

### Firebase Cloud Messaging (FCM)
- **Library**: `firebase_messaging` (latest stable)
- **Purpose**: Push notifications for Android/iOS
- **Rationale**:
  - Required by NFR5
  - Industry standard
  - Good cross-platform support
- **Status**: ✅ Validated

**Usage**:
- Register FCM tokens
- Handle notifications
- Deep linking from notifications

### Huawei Mobile Services (HMS)
- **Library**: `huawei_push` (latest stable)
- **Purpose**: Push notifications for Huawei devices
- **Rationale**:
  - Required by NFR5
  - Huawei device support
  - Alternative to FCM for Huawei
- **Status**: ✅ Validated

**Usage**:
- Register HMS tokens
- Handle notifications on Huawei devices
- Fallback to FCM for non-Huawei devices

---

## Health Data Integration

### Google Fit (Android)
- **Library**: `health` or `google_fit` (latest stable)
- **Purpose**: Step data from Google Fit
- **Rationale**:
  - Required by NFR14
  - Android health data integration
  - Real-time step sync
- **Status**: ✅ Validated

**Usage**:
- Request permissions
- Fetch step data
- Real-time sync when steps change
- Handle permission denials

### Apple Health (iOS)
- **Library**: `health` (latest stable)
- **Purpose**: Step data from Apple Health
- **Rationale**:
  - Required by NFR14
  - iOS health data integration
  - Real-time step sync
- **Status**: ✅ Validated

**Usage**:
- Request permissions
- Fetch step data
- Real-time sync when steps change
- Handle permission denials

---

## Error Handling

### Result/Either Types
- **Pattern**: Custom Result type or `dartz` Either
- **Purpose**: Type-safe error handling
- **Rationale**:
  - Matches application design
  - Type-safe error handling
  - No exceptions for expected errors
- **Status**: ✅ Validated

**Usage**:
- Return `Result<T>` from repositories and use cases
- Handle success and error cases explicitly
- No try-catch for expected errors

---

## Analytics & Crash Reporting

### Firebase Analytics
- **Library**: `firebase_analytics` (latest stable)
- **Purpose**: App analytics
- **Rationale**:
  - Required by NFR9
  - Industry standard
  - Good integration with Firebase
- **Status**: ✅ Validated

**Usage**:
- Track user events
- Track feature usage
- Track errors

### Firebase Crashlytics
- **Library**: `firebase_crashlytics` (latest stable)
- **Purpose**: Crash reporting
- **Rationale**:
  - Required by NFR9
  - Industry standard
  - Good integration with Firebase
- **Status**: ✅ Validated

**Usage**:
- Automatic crash reporting
- Custom error logging
- Crash analytics

---

## UI/Design System

### Material Design 3
- **Library**: Flutter's built-in Material 3
- **Purpose**: UI design system
- **Rationale**:
  - Required by NFR3
  - Consistent design across platforms
  - Modern Material Design
- **Status**: ✅ Validated

**Usage**:
- Material 3 components
- Light and dark themes
- Responsive layouts

---

## Testing

### Unit Testing
- **Library**: `test` (Flutter built-in)
- **Purpose**: Unit tests
- **Rationale**:
  - Required by NFR13
  - Flutter standard
- **Status**: ✅ Validated

### Widget Testing
- **Library**: `flutter_test` (Flutter built-in)
- **Purpose**: Widget tests
- **Rationale**:
  - Required by NFR13
  - Flutter standard
- **Status**: ✅ Validated

### Integration Testing
- **Library**: `integration_test` (Flutter built-in)
- **Purpose**: Integration tests
- **Rationale**:
  - Required by NFR13
  - Flutter standard
- **Status**: ✅ Validated

### BLoC Testing
- **Library**: `bloc_test` (latest stable)
- **Purpose**: BLoC/Cubit testing
- **Rationale**:
  - Test state management
  - Required for BLoC pattern
- **Status**: ✅ Validated

---

## Build Configuration

### Build Flavors
- **Tool**: Flutter build flavors
- **Purpose**: Environment-specific builds
- **Rationale**:
  - Required by NFR10
  - Dev, staging, production environments
- **Status**: ✅ Validated

**Environments**:
- Development
- Staging: `https://mcafe.azurewebsites.net/api`
- Production: `https://mcafebaru.azurewebsites.net/api`

---

## Tech Stack Summary

| Category | Technology | Library | Status |
|----------|-----------|---------|--------|
| Framework | Flutter | 3.38.2 | ✅ Validated |
| State Management | BLoC/Cubit | flutter_bloc | ✅ Validated |
| Dependency Injection | Service Locator | get_it | ✅ Validated |
| Local Storage | NoSQL Database | hive | ✅ Validated |
| Secure Storage | Platform Storage | flutter_secure_storage | ✅ Validated |
| Network | HTTP Client | dio | ✅ Validated |
| Certificate Pinning | SSL Pinning | certificate_pinning/dio | ✅ Validated |
| Image Loading | Image Cache | cached_network_image | ✅ Validated |
| Push Notifications | FCM | firebase_messaging | ✅ Validated |
| Push Notifications | HMS | huawei_push | ✅ Validated |
| Health Data (Android) | Google Fit | health/google_fit | ✅ Validated |
| Health Data (iOS) | Apple Health | health | ✅ Validated |
| Analytics | Analytics | firebase_analytics | ✅ Validated |
| Crash Reporting | Crashlytics | firebase_crashlytics | ✅ Validated |
| UI/Design | Material Design 3 | Flutter built-in | ✅ Validated |
| Testing | Unit/Widget/Integration | Flutter built-in | ✅ Validated |
| BLoC Testing | BLoC Tests | bloc_test | ✅ Validated |

---

## Notes

- **All Tech Stack Decisions Validated**: All technologies match requirements and NFR needs
- **No Changes Required**: Tech stack is appropriate for the application
- **Package Versions**: Use latest stable versions at implementation time
- **Compatibility**: Ensure all packages are compatible with Flutter 3.38.2

