# Deployment Architecture - Unit 1: Easy App Complete Application

## Overview

This document defines the deployment architecture for Unit 1: Easy App Complete Application, including build configuration, environment setup, and deployment processes.

---

## Build Architecture

### Flutter Build System

**Build Flavors**: Three flavors for different environments
- **dev**: Development environment
- **staging**: Staging environment
- **prod**: Production environment

**Build Configuration**:
```
lib/
├── main.dart              # Shared app entry
├── main_dev.dart          # Development entry point
├── main_staging.dart      # Staging entry point
└── main_prod.dart         # Production entry point
```

**Flavor-Specific Configuration**:
- Each flavor has its own entry point
- Environment configuration loaded at runtime
- Build-time constants for optimization

---

## Environment Architecture

### Environment Configuration

**Configuration Structure**:
```dart
class EnvironmentConfig {
  final String apiBaseUrl;
  final String appName;
  final bool enableLogging;
  final bool enableAnalytics;
  final List<String> certificatePins;
  final Map<String, String> featureFlags;
}
```

**Environment-Specific Values**:

| Environment | API Base URL | Logging | Analytics | Certificate Pins |
|-------------|--------------|---------|-----------|------------------|
| dev | TBD | Enabled | Enabled | Dev pins |
| staging | `https://mcafe.azurewebsites.net/api` | Enabled | Enabled | Staging pins |
| prod | `https://mcafebaru.azurewebsites.net/api` | Disabled | Enabled | Prod pins |

---

## Infrastructure Services Architecture

### Service Integration Architecture

```
App
  ├── Firebase Services
  │   ├── Firebase Cloud Messaging (FCM)
  │   ├── Firebase Analytics
  │   └── Firebase Crashlytics
  ├── Huawei Services
  │   └── Huawei Push (HMS)
  ├── Health Services
  │   ├── Google Fit (Android)
  │   └── Apple Health (iOS)
  └── Backend Services
      ├── API Endpoints
      ├── Microsoft OAuth
      └── Azure Graph API
```

### Service Initialization

**Initialization Sequence**:
1. **Core Services** (App Launch):
   - Storage initialization
   - Network initialization
   - Configuration loading

2. **Firebase Services** (App Launch):
   - Firebase initialization
   - FCM token registration
   - Analytics initialization
   - Crashlytics initialization

3. **HMS Services** (Conditional - Huawei devices):
   - HMS initialization
   - HMS push token registration

4. **Health Services** (On Feature Access):
   - Health data service initialization
   - Permission requests
   - Step data monitoring

---

## Deployment Pipeline

### Development Workflow

```
Developer
  ├── Local Development
  │   ├── Run with dev flavor
  │   ├── Test features
  │   └── Debug issues
  ├── Code Commit
  │   ├── Git commit
  │   └── Push to repository
  └── CI/CD Pipeline
      ├── Build staging flavor
      ├── Run tests
      └── Deploy to staging
```

### Staging Deployment

```
Staging Build
  ├── Build staging flavor
  ├── Run automated tests
  ├── Manual QA testing
  ├── Deploy to TestFlight (iOS) / Internal Testing (Android)
  └── Approval for production
```

### Production Deployment

```
Production Build
  ├── Build production flavor
  ├── Run full test suite
  ├── Code signing
  ├── App Store submission
  │   ├── Google Play Console (Android)
  │   └── App Store Connect (iOS)
  ├── App review
  └── Production release
```

---

## Security Architecture

### Certificate Pinning Architecture

**Pinning Strategy**:
- Pin certificates for all API endpoints
- Environment-specific certificate pins
- Support for certificate rotation
- Strict enforcement (block on pin failure)

**Certificate Storage**:
- Certificate hashes stored in code (not secrets)
- Environment-specific pins
- Support multiple pins for rotation

### Token Storage Architecture

**Storage Strategy**:
- Tokens: flutter_secure_storage (platform keychain/keystore)
- Other data: Hive with encryption
- Secure deletion on logout

**Token Flow**:
```
OAuth Flow
  ├── Authorization code received
  ├── Exchange for tokens
  ├── Store tokens in secure storage
  ├── Use tokens for API calls
  └── Refresh tokens automatically
```

---

## Monitoring and Observability

### Analytics Architecture

**Event Tracking**:
- User actions (login, feature usage)
- API calls (success/failure)
- Error events
- Performance metrics

**Analytics Flow**:
```
User Action
  ├── Event logged locally
  ├── Sent to Firebase Analytics
  └── Aggregated in Firebase Console
```

### Crash Reporting Architecture

**Error Reporting**:
- Automatic crash reporting
- Custom error logging
- User context (user ID, app version)
- Breadcrumb logging

**Crash Flow**:
```
Error/Crash
  ├── Error captured
  ├── Context collected
  ├── Sent to Crashlytics
  └── Available in Firebase Console
```

---

## Update Architecture

### Version Management

**Version Check Flow**:
```
App Launch
  ├── Check app version
  ├── Compare with server version
  ├── If critical update: Force update dialog
  ├── If optional update: Show notification
  └── Link to app store
```

**Update Mechanisms**:
- **App Store Updates**: Standard app store updates
- **Force Updates**: Non-dismissible update dialog
- **Optional Updates**: Dismissible update notification

---

## Network Architecture

### API Architecture

**API Layer Structure**:
```
Presentation Layer
  ├── BLoCs/Cubits
  └── Use Cases
      └── Repositories
          └── API Service
              ├── Dio HTTP Client
              ├── Certificate Pinning
              ├── Auth Interceptor
              └── Retry Interceptor
```

**API Request Flow**:
```
API Request
  ├── Certificate pinning check
  ├── Add Bearer token
  ├── Send request
  ├── Handle response
  ├── Retry on network error
  └── Return result
```

---

## Storage Architecture

### Local Storage Architecture

**Storage Layers**:
```
App Storage
  ├── Secure Storage (Tokens)
  │   └── Platform keychain/keystore
  ├── Encrypted Storage (Sensitive Data)
  │   └── Hive with encryption
  └── Regular Storage (Cached Data)
      └── Hive without encryption
```

**Storage Strategy**:
- Tokens: Secure storage only
- User profile: Encrypted Hive
- Cached data: Regular Hive with expiration
- Cache size limits with LRU eviction

---

## Deployment Architecture Summary

### Build Configuration
- Three build flavors (dev, staging, prod)
- Environment-specific configuration
- Build-time optimization

### Infrastructure Services
- Firebase (FCM, Analytics, Crashlytics)
- HMS (Push notifications for Huawei)
- Health services (Google Fit, Apple Health)
- Backend APIs

### Security
- Certificate pinning for all environments
- Secure token storage
- Encrypted data storage

### Monitoring
- Analytics tracking
- Crash reporting
- Error logging

### Deployment
- Standard app store deployment
- OTA update mechanism
- Version management

---

## Notes

- **Environment Isolation**: Each environment has isolated configuration
- **Service Integration**: All services integrated via dependency injection
- **Security First**: Security measures implemented at all layers
- **Monitoring**: Comprehensive monitoring and observability
- **Deployment**: Standard deployment process with automation support

