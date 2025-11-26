# iOS Setup Guide

This document provides instructions for setting up and running the Easy App on iOS.

## Prerequisites

- macOS with Xcode 14.0 or later
- Flutter SDK 3.27.0 or later
- CocoaPods 1.11.0 or later
- iOS Simulator or physical iOS device (iOS 13.0+)

## Initial Setup

### 1. Install Dependencies

First, install CocoaPods dependencies:

```bash
cd ios
pod install
cd ..
```

This will:
- Download and install all required iOS dependencies
- Create `Podfile.lock` file
- Generate `Runner.xcworkspace`

**Important**: Always use `Runner.xcworkspace` (NOT `Runner.xcodeproj`) when opening in Xcode.

### 2. Firebase Configuration (Required for Push Notifications)

The app requires Firebase for push notifications. Follow these steps:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create or select your project
3. Add an iOS app to your Firebase project
4. Download the `GoogleService-Info.plist` file
5. Place it in `ios/Runner/` directory
6. Open `Runner.xcworkspace` in Xcode
7. Drag and drop `GoogleService-Info.plist` into the Runner target in Xcode

**Note**: Without this file, push notifications won't work, but the app should still build and run.

### 3. Code Signing (For Physical Devices)

If running on a physical device:

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select the Runner target
3. Go to "Signing & Capabilities" tab
4. Select your Development Team
5. Xcode will automatically generate provisioning profiles

## Running the App

### Using Flutter CLI

```bash
# List available iOS simulators
flutter devices

# Run on default simulator
flutter run

# Run on specific device
flutter run -d <device-id>

# Run development flavor
flutter run --flavor dev -t lib/main_dev.dart

# Run staging flavor
flutter run --flavor staging -t lib/main_staging.dart

# Run production flavor
flutter run --flavor prod -t lib/main_prod.dart
```

### Using VS Code

Use the provided launch configurations in `.vscode/launch.json`:
- "Dev" - Development environment
- "Staging" - Staging environment  
- "Prod" - Production environment

### Using Xcode

1. Open `ios/Runner.xcworkspace` (NOT .xcodeproj)
2. Select target device (simulator or physical device)
3. Click Run button or press Cmd+R

## iOS Capabilities Configured

The following capabilities are configured in the project:

### 1. HealthKit
- Enabled in `Runner.entitlements`
- Required for Steps Challenge feature
- Permissions configured in `Info.plist`:
  - `NSHealthShareUsageDescription`
  - `NSHealthUpdateUsageDescription`
  - `NSMotionUsageDescription`

### 2. Camera & Photos
- Required for QR scanning and photo uploads
- Permissions configured in `Info.plist`:
  - `NSCameraUsageDescription`
  - `NSPhotoLibraryUsageDescription`
  - `NSPhotoLibraryAddUsageDescription`

### 3. Deep Linking
- Custom URL scheme: `easyapp://`
- Configured in `Info.plist` under `CFBundleURLTypes`

### 4. Face ID (Biometric Authentication)
- Permission configured in `Info.plist`:
  - `NSFaceIDUsageDescription`

## Configuration Files

### Podfile
- Platform: iOS 13.0+
- Uses frameworks and modular headers
- Installs all Flutter plugin pods

### Info.plist
Key configurations:
- Bundle ID: Set via Xcode build settings
- Display Name: "Easy App"
- Supported orientations: Portrait, Landscape (all)
- URL schemes: `easyapp://`
- All required usage permissions

### Runner.entitlements
- HealthKit capability enabled

## Deployment Targets

- Minimum iOS Version: 13.0
- Supported Devices: iPhone, iPad
- Supported Orientations: All

## Troubleshooting

### Issue: Firebase Modular Header Error
**Error**: `Include of non-modular header inside framework module 'firebase_messaging.FLTFirebaseMessagingPlugin'`

**Solution**: The Podfile has been updated with a fix. Reinstall pods:
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter clean
flutter run
```

**Details**: See [FIREBASE_FIX.md](./FIREBASE_FIX.md) for complete explanation and alternative solutions.

### Issue: "pod: command not found"
**Solution**: Install CocoaPods
```bash
sudo gem install cocoapods
```

### Issue: "Unable to find a specification for..."
**Solution**: Update CocoaPods repository
```bash
cd ios
pod repo update
pod install
cd ..
```

### Issue: "The sandbox is not in sync with the Podfile.lock"
**Solution**: Reinstall pods
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
```

### Issue: Build fails with signing errors
**Solution**: 
1. Open `Runner.xcworkspace` in Xcode
2. Select Runner target
3. Go to Signing & Capabilities
4. Select your team and ensure "Automatically manage signing" is checked

### Issue: Firebase crashes on app launch
**Solution**: Ensure `GoogleService-Info.plist` is properly added to the project:
1. File should be in `ios/Runner/` directory
2. File should be added to Runner target in Xcode
3. Verify Bundle ID matches the one in Firebase Console

### Issue: HealthKit not working
**Solution**: 
1. HealthKit doesn't work in simulator - test on physical device
2. Ensure `Runner.entitlements` is properly linked in Xcode project
3. Verify capability is enabled in Xcode: Signing & Capabilities > HealthKit

### Issue: Camera/Photos permission crashes
**Solution**: Ensure all usage descriptions are present in `Info.plist` (already configured)

## Clean Build

If you encounter persistent build issues:

```bash
# Clean Flutter build
flutter clean

# Clean iOS build
cd ios
rm -rf Pods Podfile.lock
rm -rf ~/Library/Developer/Xcode/DerivedData/*
pod install
cd ..

# Rebuild
flutter pub get
flutter run
```

## Build Flavors

The project supports three build flavors:

1. **Development (dev)**
   - Uses development API endpoints
   - Debug logging enabled
   - Fast iterations

2. **Staging (staging)**
   - Uses staging API endpoints
   - Similar to production
   - For testing before release

3. **Production (prod)**
   - Uses production API endpoints
   - Optimized build
   - For App Store release

## Next Steps

After successful setup:

1. Configure OAuth credentials in `lib/core/config/app_config.dart`
2. Add Firebase configuration files
3. Configure certificate pinning (see `README_CERTIFICATE_PINNING.md`)
4. Test all features on iOS simulator/device
5. Run tests: `flutter test`
6. Build for release: `flutter build ios --release`

## Resources

- [Flutter iOS Setup](https://docs.flutter.dev/get-started/install/macos#ios-setup)
- [CocoaPods](https://cocoapods.org/)
- [Xcode](https://developer.apple.com/xcode/)
- [Firebase iOS Setup](https://firebase.google.com/docs/ios/setup)

