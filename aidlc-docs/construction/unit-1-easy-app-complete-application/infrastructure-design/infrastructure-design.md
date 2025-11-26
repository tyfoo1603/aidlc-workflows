# Infrastructure Design - Unit 1: Easy App Complete Application

## Overview

This document defines infrastructure design for Unit 1: Easy App Complete Application, focusing on deployment architecture, build configuration, and infrastructure services.

---

## Deployment Architecture

### Build Flavors

**Requirement**: Support Development, Staging, and Production environments with build flavors

**Flavor Configuration**:
- **Development**: Development environment for local testing
- **Staging**: Staging environment for QA and testing
- **Production**: Production environment for end users

**Flavor Implementation**:
```dart
// lib/main_dev.dart
void main() {
  runApp(MyApp(environment: Environment.dev));
}

// lib/main_staging.dart
void main() {
  runApp(MyApp(environment: Environment.staging));
}

// lib/main_prod.dart
void main() {
  runApp(MyApp(environment: Environment.prod));
}
```

**Build Commands**:
```bash
# Development
flutter run --flavor dev -t lib/main_dev.dart

# Staging
flutter build apk --flavor staging -t lib/main_staging.dart
flutter build ios --flavor staging -t lib/main_staging.dart

# Production
flutter build apk --flavor prod -t lib/main_prod.dart
flutter build ios --flavor prod -t lib/main_prod.dart
```

---

### Environment Configuration

**API Base URLs**:
- **Development**: TBD (to be determined)
- **Staging**: `https://mcafe.azurewebsites.net/api`
- **Production**: `https://mcafebaru.azurewebsites.net/api`

**Environment-Specific Configuration**:
```dart
enum Environment {
  dev,
  staging,
  prod,
}

class AppConfig {
  final Environment environment;
  final String apiBaseUrl;
  final String appName;
  final bool enableLogging;
  final List<String> certificatePins;
  
  AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.appName,
    required this.enableLogging,
    required this.certificatePins,
  });
  
  static AppConfig getConfig(Environment env) {
    switch (env) {
      case Environment.dev:
        return AppConfig(
          environment: env,
          apiBaseUrl: 'TBD',
          appName: 'Easy App Dev',
          enableLogging: true,
          certificatePins: ['DEV_CERT_HASH'],
        );
      case Environment.staging:
        return AppConfig(
          environment: env,
          apiBaseUrl: 'https://mcafe.azurewebsites.net/api',
          appName: 'Easy App Staging',
          enableLogging: true,
          certificatePins: ['STAGING_CERT_HASH'],
        );
      case Environment.prod:
        return AppConfig(
          environment: env,
          apiBaseUrl: 'https://mcafebaru.azurewebsites.net/api',
          appName: 'Easy App',
          enableLogging: false,
          certificatePins: ['PROD_CERT_HASH'],
        );
    }
  }
}
```

---

## Infrastructure Services

### Push Notification Infrastructure

**Services**:
- **Firebase Cloud Messaging (FCM)**: Primary push notification service
- **Huawei Mobile Services (HMS)**: Push notification service for Huawei devices

**Setup Requirements**:
1. **Firebase Setup**:
   - Firebase project creation
   - Android: `google-services.json` configuration
   - iOS: `GoogleService-Info.plist` configuration
   - FCM server key for backend integration

2. **HMS Setup**:
   - Huawei Developer account
   - HMS Core configuration
   - `agconnect-services.json` for Android
   - HMS server key for backend integration

**Configuration Files**:
```
android/app/google-services.json          # Firebase config
ios/Runner/GoogleService-Info.plist       # Firebase config (iOS)
android/app/agconnect-services.json       # HMS config
```

**Backend Integration**:
- Backend registers device tokens (FCM and HMS)
- Backend sends notifications via FCM/HMS
- App receives and handles notifications

---

### Analytics Infrastructure

**Service**: Firebase Analytics

**Setup Requirements**:
1. Firebase project (shared with FCM)
2. Analytics enabled in Firebase console
3. Event tracking configuration

**Implementation**:
```dart
// Analytics service
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  Future<void> logEvent(String name, Map<String, dynamic> parameters) async {
    await _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }
  
  Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }
}
```

**Events to Track**:
- User login/logout
- Feature usage (announcements, QR wallet, eclaims, etc.)
- API errors
- App crashes
- User actions (payments, claim submissions, etc.)

---

### Crash Reporting Infrastructure

**Service**: Firebase Crashlytics

**Setup Requirements**:
1. Firebase project (shared with FCM and Analytics)
2. Crashlytics enabled in Firebase console
3. Crash reporting configuration

**Implementation**:
```dart
// Crash reporting service
class CrashReportingService {
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;
  
  Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? reason,
  }) async {
    await _crashlytics.recordError(
      exception,
      stackTrace,
      reason: reason,
    );
  }
  
  Future<void> log(String message) async {
    await _crashlytics.log(message);
  }
  
  Future<void> setUserId(String userId) async {
    await _crashlytics.setUserId(userId);
  }
}
```

**Error Reporting**:
- Automatic crash reporting
- Custom error logging
- User context (user ID, app version, etc.)
- Breadcrumb logging

---

### Health Data Integration Infrastructure

**Services**:
- **Google Fit (Android)**: Health data service for Android
- **Apple Health (iOS)**: Health data service for iOS

**Setup Requirements**:
1. **Android**:
   - Google Fit API setup
   - OAuth 2.0 credentials
   - Permissions configuration

2. **iOS**:
   - HealthKit capability enabled
   - Privacy permissions configuration
   - Health data types configuration

**Implementation**:
```dart
// Health data service
class HealthDataService {
  final Health _health = Health();
  
  Future<bool> requestPermissions() async {
    return await _health.requestAuthorization([
      HealthDataType.STEPS,
    ]);
  }
  
  Future<List<HealthDataPoint>> getSteps(DateTime start, DateTime end) async {
    return await _health.getHealthDataFromTypes(
      [HealthDataType.STEPS],
      start,
      end,
    );
  }
}
```

**Permissions**:
- Android: `android.permission.ACTIVITY_RECOGNITION`
- iOS: HealthKit permissions in Info.plist

---

## App Store Deployment

### Android Deployment

**Requirements**:
- Google Play Console account
- App signing key
- App bundle configuration
- Store listing assets

**Build Configuration**:
```gradle
// android/app/build.gradle
android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
        }
    }
}
```

**Build Commands**:
```bash
# Build app bundle for Play Store
flutter build appbundle --flavor prod -t lib/main_prod.dart

# Build APK for direct distribution
flutter build apk --flavor prod -t lib/main_prod.dart
```

---

### iOS Deployment

**Requirements**:
- Apple Developer account
- App Store Connect setup
- Provisioning profiles
- Certificates

**Build Configuration**:
```xcconfig
// ios/Flutter/Release.xcconfig
FLUTTER_BUILD_MODE=release
FLUTTER_BUILD_DIR=build
```

**Build Commands**:
```bash
# Build iOS app
flutter build ios --flavor prod -t lib/main_prod.dart --release

# Archive for App Store
# Use Xcode: Product > Archive
```

**App Store Requirements**:
- App Store Connect configuration
- App metadata and screenshots
- Privacy policy URL
- App review submission

---

## OTA (Over-The-Air) Updates

**Requirement**: Optional force update with notification and custom update mechanism

**Implementation Approach**:
- **Version Check**: Check app version on launch
- **Update Detection**: Compare with server version
- **Update Notification**: Show update dialog
- **Update Mechanism**: 
  - App Store/Play Store links for standard updates
  - Custom update mechanism (if required)

**Implementation**:
```dart
// Update service
class UpdateService {
  Future<void> checkForUpdates() async {
    final serverVersion = await apiService.getAppVersion();
    final currentVersion = await getCurrentVersion();
    
    if (serverVersion.isNewerThan(currentVersion)) {
      if (serverVersion.isCritical) {
        _showForceUpdateDialog(serverVersion);
      } else {
        _showOptionalUpdateDialog(serverVersion);
      }
    }
  }
  
  void _showForceUpdateDialog(AppVersion version) {
    // Show non-dismissible update dialog
    // Link to app store
  }
  
  void _showOptionalUpdateDialog(AppVersion version) {
    // Show dismissible update notification
    // Link to app store
  }
}
```

---

## Network Infrastructure

### Certificate Pinning Configuration

**Requirement**: Certificate pinning for all environments

**Implementation**:
```dart
// Certificate pinning configuration
class CertificatePinningConfig {
  static Map<Environment, List<String>> get pins => {
    Environment.dev: [
      'sha256/DEV_CERTIFICATE_HASH_1',
      'sha256/DEV_CERTIFICATE_HASH_2',
    ],
    Environment.staging: [
      'sha256/STAGING_CERTIFICATE_HASH_1',
      'sha256/STAGING_CERTIFICATE_HASH_2',
    ],
    Environment.prod: [
      'sha256/PROD_CERTIFICATE_HASH_1',
      'sha256/PROD_CERTIFICATE_HASH_2',
    ],
  };
}
```

**Certificate Management**:
- Store certificate hashes securely
- Support certificate rotation
- Environment-specific pins
- Strict enforcement (block on pin failure)

---

### API Endpoint Configuration

**Base URLs**:
- Development: TBD
- Staging: `https://mcafe.azurewebsites.net/api`
- Production: `https://mcafebaru.azurewebsites.net/api`

**Microsoft OAuth Endpoints**:
- Authorization: `https://login.microsoftonline.com/<tenant>/oauth2/v2.0/authorize`
- Token: `https://login.microsoftonline.com/<tenant>/oauth2/v2.0/token`

**Azure Graph API Endpoints**:
- Revoke Sessions: `https://graph.microsoft.com/v1.0/me/revokeSignInSessions`
- Invalidate Tokens: `https://graph.microsoft.com/v1.0/me/invalidateAllRefreshTokens`

---

## Infrastructure Summary

### Services Required

| Service | Provider | Purpose | Status |
|---------|----------|---------|--------|
| Push Notifications (FCM) | Firebase | Android/iOS push notifications | Required |
| Push Notifications (HMS) | Huawei | Huawei device push notifications | Required |
| Analytics | Firebase | User analytics and tracking | Required |
| Crash Reporting | Firebase Crashlytics | Crash and error reporting | Required |
| Health Data (Android) | Google Fit | Step data for Android | Required |
| Health Data (iOS) | Apple Health | Step data for iOS | Required |
| App Distribution | Google Play / App Store | App distribution | Required |

### Configuration Files

| File | Location | Purpose |
|------|----------|---------|
| `google-services.json` | `android/app/` | Firebase configuration (Android) |
| `GoogleService-Info.plist` | `ios/Runner/` | Firebase configuration (iOS) |
| `agconnect-services.json` | `android/app/` | HMS configuration |
| `key.properties` | `android/` | Signing key configuration |
| `Info.plist` | `ios/Runner/` | iOS app configuration |
| `pubspec.yaml` | Root | Flutter dependencies |

### Build Flavors

| Flavor | Environment | API Base URL | Logging |
|--------|------------|--------------|---------|
| dev | Development | TBD | Enabled |
| staging | Staging | `https://mcafe.azurewebsites.net/api` | Enabled |
| prod | Production | `https://mcafebaru.azurewebsites.net/api` | Disabled |

---

## Deployment Checklist

### Pre-Deployment
- [ ] All environment configurations set
- [ ] Certificate pins configured for all environments
- [ ] Firebase project created and configured
- [ ] HMS account created and configured (if needed)
- [ ] App signing keys generated
- [ ] Build flavors tested

### Android Deployment
- [ ] App bundle built with production flavor
- [ ] App signed with release key
- [ ] Google Play Console setup complete
- [ ] Store listing assets prepared
- [ ] Privacy policy URL configured
- [ ] App submitted for review

### iOS Deployment
- [ ] iOS app built with production flavor
- [ ] App signed with distribution certificate
- [ ] App Store Connect setup complete
- [ ] Store listing assets prepared
- [ ] Privacy policy URL configured
- [ ] App submitted for review

### Post-Deployment
- [ ] Analytics tracking verified
- [ ] Crash reporting verified
- [ ] Push notifications tested
- [ ] Health data integration tested
- [ ] Certificate pinning verified
- [ ] Update mechanism tested

---

## Notes

- **Environment Configuration**: All environment-specific settings in `AppConfig`
- **Certificate Management**: Certificate pins stored securely, support rotation
- **Service Integration**: All services integrated via dependency injection
- **Build Process**: Automated build process with flavor support
- **Deployment**: Standard app store deployment process

