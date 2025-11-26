# iOS Configuration Fixes Summary

**Date**: November 25, 2025  
**Issue**: Unable to run iOS simulator with the project

## Problems Identified

### 1. Missing Platform Declaration in Podfile
**Issue**: The `platform :ios, '12.0'` line in Podfile was commented out  
**Impact**: CocoaPods couldn't determine the iOS deployment target  
**Fix**: Uncommented and updated to `platform :ios, '13.0'`

### 2. Pods Not Installed
**Issue**: No `Podfile.lock` file found, indicating pods were never installed  
**Impact**: Required iOS dependencies not available, app cannot build  
**Fix**: User needs to run `pod install` (automated in setup script)

### 3. Missing iOS Permissions in Info.plist
**Issue**: Several required permissions were missing for iOS features  
**Impact**: App would crash when accessing camera, photos, health data, etc.  
**Permissions Added**:
- `NSCameraUsageDescription` - For QR code scanning
- `NSPhotoLibraryUsageDescription` - For photo uploads
- `NSPhotoLibraryAddUsageDescription` - For saving photos
- `NSHealthShareUsageDescription` - For reading step data
- `NSHealthUpdateUsageDescription` - For updating health data
- `NSMotionUsageDescription` - For motion and fitness tracking
- `NSFaceIDUsageDescription` - For biometric authentication

### 4. Missing Runner.entitlements
**Issue**: No entitlements file for HealthKit capability  
**Impact**: HealthKit features wouldn't work, potential App Store rejection  
**Fix**: Created `ios/Runner/Runner.entitlements` with HealthKit capability

### 5. Inconsistent Deployment Target
**Issue**: Xcode project had `IPHONEOS_DEPLOYMENT_TARGET = 12.0`  
**Impact**: Potential compatibility issues with newer dependencies  
**Fix**: Updated all instances to iOS 13.0 to match modern requirements

## Changes Made

### Modified Files

#### 1. `ios/Podfile`
```ruby
# Before
# platform :ios, '12.0'

# After
platform :ios, '13.0'
```

#### 2. `ios/Runner/Info.plist`
Added 7 new permission keys with descriptions for:
- Camera access
- Photo library access
- Health data access
- Motion data access
- Face ID authentication

#### 3. `ios/Runner.xcodeproj/project.pbxproj`
```
# Before
IPHONEOS_DEPLOYMENT_TARGET = 12.0;

# After
IPHONEOS_DEPLOYMENT_TARGET = 13.0;
```

### Created Files

#### 1. `ios/Runner/Runner.entitlements`
New entitlements file with:
- HealthKit capability enabled
- Required for Steps Challenge feature

#### 2. `docs/IOS_SETUP.md`
Comprehensive iOS setup guide covering:
- Prerequisites
- Initial setup steps
- Firebase configuration
- Code signing
- Running the app
- iOS capabilities
- Configuration files
- Troubleshooting
- Build flavors

#### 3. `scripts/setup_ios.sh`
Automated setup script that:
- Checks Flutter and CocoaPods installation
- Cleans previous builds
- Installs dependencies
- Runs pod install
- Lists available simulators
- Provides next steps

## How to Use

### Quick Start (Automated)
```bash
# From project root
./scripts/setup_ios.sh
```

### Manual Setup
```bash
# 1. Clean and get dependencies
flutter clean
flutter pub get

# 2. Install CocoaPods dependencies
cd ios
pod install
cd ..

# 3. Run the app
flutter run
```

### Using Xcode
1. Open `ios/Runner.xcworkspace` (NOT Runner.xcodeproj)
2. Select target device/simulator
3. Press Cmd+R to run

## Verification Checklist

After applying fixes, verify:
- [ ] `ios/Podfile.lock` exists
- [ ] `ios/Pods/` directory exists
- [ ] `ios/Runner.xcworkspace` exists
- [ ] `ios/Runner/Runner.entitlements` exists
- [ ] All Info.plist permissions are present
- [ ] Platform target is iOS 13.0
- [ ] App builds successfully: `flutter build ios --debug`
- [ ] App runs on simulator: `flutter run`

## Additional Setup (Optional)

### Firebase Configuration
For push notifications to work:
1. Download `GoogleService-Info.plist` from Firebase Console
2. Place in `ios/Runner/` directory
3. Add to Xcode project (drag and drop into Runner target)

### Code Signing (Physical Device)
For running on physical device:
1. Open `Runner.xcworkspace` in Xcode
2. Select Runner target
3. Go to Signing & Capabilities
4. Select your Development Team
5. Enable "Automatically manage signing"

## Known Limitations

1. **HealthKit**: Only works on physical devices, not in simulator
2. **Push Notifications**: Requires Firebase configuration
3. **Huawei Push**: iOS doesn't support HMS, only FCM
4. **Certificate Pinning**: Needs server certificates configured (see `README_CERTIFICATE_PINNING.md`)

## Testing Recommendations

After setup, test the following features on iOS:

### Simulator Testing
- ✅ Login flow
- ✅ Navigation
- ✅ Home page loading
- ✅ Profile display
- ✅ QR code generation
- ✅ Announcements
- ✅ WebView features
- ❌ HealthKit (simulator not supported)
- ❌ Push notifications (simulator limited support)

### Physical Device Testing
- ✅ All simulator features
- ✅ HealthKit / Steps Challenge
- ✅ Push notifications
- ✅ Camera QR scanning
- ✅ Photo uploads
- ✅ Face ID authentication

## Troubleshooting

### "pod: command not found"
```bash
sudo gem install cocoapods
```

### "Unable to find a specification for..."
```bash
cd ios
pod repo update
pod install
cd ..
```

### "The sandbox is not in sync"
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
```

### Build errors in Xcode
```bash
# Clean all builds
flutter clean
cd ios
rm -rf Pods Podfile.lock
rm -rf ~/Library/Developer/Xcode/DerivedData/*
pod install
cd ..
flutter pub get
```

## References

- [iOS Setup Guide](./IOS_SETUP.md) - Detailed setup instructions
- [Certificate Pinning](../README_CERTIFICATE_PINNING.md) - Security configuration
- [Flutter iOS Setup](https://docs.flutter.dev/get-started/install/macos#ios-setup) - Official docs
- [CocoaPods](https://cocoapods.org/) - Dependency manager

## Support

For additional help:
1. Check `docs/IOS_SETUP.md` for detailed instructions
2. Review Flutter doctor output: `flutter doctor -v`
3. Check Xcode build logs for specific errors
4. Ensure all prerequisites are met (Xcode, CocoaPods, Flutter SDK)

