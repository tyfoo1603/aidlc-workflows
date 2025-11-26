# Easy App - Flutter Mobile Application

A Flutter mobile application for Astro employees providing authentication, employee profiles, announcements, QR wallet, eclaims, and more.

## Project Overview

- **Platform**: Android, iOS, Web
- **Framework**: Flutter 3.27.0+
- **State Management**: BLoC/Cubit
- **Dependency Injection**: get_it
- **Architecture**: Clean Architecture with Feature-based organization

## Quick Start

### Prerequisites

- Flutter SDK 3.27.0 or later
- For iOS: Xcode 14.0+, CocoaPods
- For Android: Android Studio, Android SDK

### Setup

#### iOS Setup (3 Steps)
```bash
# 1. Install CocoaPods dependencies
cd ios && pod install && cd ..

# 2. Clean and get packages
flutter clean && flutter pub get

# 3. Run the app
flutter run
```

**See [iOS Quick Start](./docs/IOS_QUICK_START.md) for detailed iOS setup**

#### Android Setup
```bash
# Clean and get packages
flutter clean && flutter pub get

# Run the app
flutter run
```

### Run Commands

```bash
# Development environment
flutter run --flavor dev -t lib/main_dev.dart

# Staging environment
flutter run --flavor staging -t lib/main_staging.dart

# Production environment
flutter run --flavor prod -t lib/main_prod.dart
```

## Build Flavors

- **dev**: Development environment with debug logging
- **staging**: Staging environment for testing
- **prod**: Production environment for release

## Features

- ✅ **Authentication**: Microsoft OAuth login
- ✅ **Home**: Dashboard with user info and module navigation
- ✅ **Profile**: Employee profile management
- ✅ **Announcements**: Company announcements and updates
- ✅ **QR Wallet**: Digital wallet with QR code
- ✅ **E-claims**: Submit and track expense claims
- ✅ **AstroDesk**: IT support and helpdesk
- ✅ **Steps Challenge**: Track daily steps with health integration
- ✅ **WebView Features**: Report Piracy, Settings, etc.

## Project Structure

```
lib/
├── core/                 # Shared infrastructure
│   ├── config/          # App configuration
│   ├── error/           # Error handling
│   ├── network/         # API service, interceptors
│   ├── storage/         # Local storage, secure storage
│   ├── navigation/      # Routing, navigation
│   └── di/              # Dependency injection
├── features/            # Feature modules
│   ├── auth/           # Authentication
│   ├── home/           # Home dashboard
│   ├── profile/        # User profile
│   ├── announcements/  # Announcements
│   ├── qr_wallet/      # QR Wallet
│   ├── eclaims/        # E-claims
│   └── ...
└── main_*.dart         # Entry points for each flavor
```

## Documentation

### Setup Guides
- **[iOS Quick Start](./docs/IOS_QUICK_START.md)** - Fast iOS setup (3 steps)
- **[iOS Setup Guide](./docs/IOS_SETUP.md)** - Comprehensive iOS setup
- **[iOS Fixes Summary](./docs/IOS_FIXES_SUMMARY.md)** - Recent iOS fixes

### Security
- **[Certificate Pinning](./README_CERTIFICATE_PINNING.md)** - API security setup

### Architecture & Design
- **[Requirements](./aidlc-docs/inception/requirements/requirements.md)** - Full requirements
- **[User Stories](./aidlc-docs/inception/user-stories/stories.md)** - User stories
- **[Application Design](./aidlc-docs/inception/application-design/)** - Architecture docs
- **[Infrastructure Design](./aidlc-docs/construction/unit-1-easy-app-complete-application/infrastructure-design/)** - Infrastructure details

## Configuration

### Environment Variables

Configure the following in `lib/core/config/app_config.dart`:

- API endpoints (dev/staging/prod)
- OAuth credentials (tenant, client ID, secret)
- Certificate pins (for certificate pinning)

### Firebase Configuration

For push notifications (optional):
1. Download `GoogleService-Info.plist` (iOS) and `google-services.json` (Android)
2. Place in respective platform directories
3. See [iOS Setup Guide](./docs/IOS_SETUP.md) for details

## Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/features/auth/auth_test.dart

# Run with coverage
flutter test --coverage
```

## Build

```bash
# Build Android APK
flutter build apk --flavor prod -t lib/main_prod.dart

# Build Android App Bundle
flutter build appbundle --flavor prod -t lib/main_prod.dart

# Build iOS
flutter build ios --flavor prod -t lib/main_prod.dart
```

## Dependencies

### Core
- **flutter_bloc**: State management
- **get_it**: Dependency injection
- **dio**: HTTP client
- **go_router**: Navigation

### Storage
- **hive**: Local database
- **flutter_secure_storage**: Secure token storage
- **shared_preferences**: Key-value storage

### UI
- **cached_network_image**: Image loading and caching
- **webview_flutter**: WebView integration
- **qr_flutter**: QR code generation

### Features
- **firebase_core/messaging**: Push notifications
- **health**: HealthKit/Google Fit integration
- **image_picker**: Photo selection
- **url_launcher**: External links

## Troubleshooting

### iOS Issues
See [iOS Setup Guide](./docs/IOS_SETUP.md#troubleshooting) for common iOS issues and solutions.

### Common Issues

**"Waiting for another flutter command to release the startup lock"**
```bash
killall -9 dart
```

**"Could not resolve all files for configuration"**
```bash
flutter clean
flutter pub get
```

**Certificate pinning errors**
See [Certificate Pinning Guide](./README_CERTIFICATE_PINNING.md)

## Development Workflow

This project was built using the [AI-DLC (AI-Driven Development Life Cycle)](./README.md) methodology. All design artifacts and documentation are available in the `aidlc-docs/` directory.

### AIDLC Artifacts
- **Inception Phase**: Requirements, user stories, application design
- **Construction Phase**: Functional design, NFR design, infrastructure design, code
- **Audit Log**: Complete development history in `audit.md`

## Contributing

1. Follow Flutter best practices and style guide
2. Write tests for new features
3. Update documentation as needed
4. Run `flutter analyze` before committing
5. Ensure all tests pass: `flutter test`

## License

[Your License Here]

## Support

For questions or issues:
- Check the documentation in `docs/` directory
- Review AIDLC artifacts in `aidlc-docs/` directory
- Check the audit log: `audit.md`

