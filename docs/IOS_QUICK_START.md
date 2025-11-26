# iOS Quick Start

## ⚡ Fast Setup

### Automated (Recommended)
```bash
./scripts/clean_rebuild_ios.sh
flutter run
```

### Manual (5 Steps)

#### 1. Clean Xcode DerivedData
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/*
```

#### 2. Clean Flutter & Pods
```bash
flutter clean
cd ios
rm -rf Pods Podfile.lock
cd ..
```

#### 3. Get Dependencies
```bash
flutter pub get
```

#### 4. Install Pods
```bash
cd ios
pod install
cd ..
```

#### 5. Run the App
```bash
flutter run
```

## 🎯 What Was Fixed

✅ **Podfile** - Platform declaration enabled (iOS 13.0)  
✅ **Info.plist** - All required permissions added  
✅ **Entitlements** - HealthKit capability configured  
✅ **Deployment Target** - Updated to iOS 13.0  

## 📱 Run Options

### Flutter CLI
```bash
# Default (dev)
flutter run

# Specific flavor
flutter run --flavor dev -t lib/main_dev.dart
flutter run --flavor staging -t lib/main_staging.dart
flutter run --flavor prod -t lib/main_prod.dart
```

### VS Code
Use launch configurations:
- **Dev** (F5)
- **Staging**
- **Prod**

### Xcode
1. Open `ios/Runner.xcworkspace`
2. Select simulator/device
3. Press **Cmd+R**

## ⚠️ Optional Setup

### Firebase (for Push Notifications)
1. Download `GoogleService-Info.plist` from Firebase Console
2. Place in `ios/Runner/` directory
3. Drag into Xcode project (Runner target)

### Code Signing (for Physical Device)
1. Open workspace in Xcode
2. Select Runner target → Signing & Capabilities
3. Choose your Development Team
4. Enable "Automatically manage signing"

## 🔧 Troubleshooting

### Firebase Modular Header Error
If you see "Include of non-modular header inside framework module":

**CRITICAL: Must clean DerivedData!**
```bash
# Use automated script (recommended)
./scripts/clean_rebuild_ios.sh

# Or manually:
rm -rf ~/Library/Developer/Xcode/DerivedData/*
flutter clean
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter pub get
flutter run
```
**See [FIREBASE_FIX_V2.md](./FIREBASE_FIX_V2.md) for complete solution**

### Pods Error
```bash
cd ios
pod repo update
pod install
cd ..
```

### Build Error
```bash
flutter clean
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter pub get
flutter run
```

### Signing Error
- Open Xcode workspace
- Fix signing in Signing & Capabilities tab

## 📖 More Info

- **Detailed Guide**: [IOS_SETUP.md](./IOS_SETUP.md)
- **Fixes Applied**: [IOS_FIXES_SUMMARY.md](./IOS_FIXES_SUMMARY.md)
- **Firebase Fix**: [FIREBASE_FIX_V2.md](./FIREBASE_FIX_V2.md) ⚡ **Important!**
- **Build Fixes**: [BUILD_FIXES.md](./BUILD_FIXES.md)
- **Certificate Pinning**: [README_CERTIFICATE_PINNING.md](../README_CERTIFICATE_PINNING.md)

## ✨ Features Ready

✅ Authentication  
✅ Home Page  
✅ Navigation  
✅ Profile  
✅ QR Code  
✅ Announcements  
✅ WebView Features  
✅ Camera Access  
✅ Photo Library  
✅ HealthKit (device only)  
⚠️ Push Notifications (needs Firebase config)  

## 🚀 You're All Set!

Your iOS configuration is now ready. Just run `flutter run` and start developing!

