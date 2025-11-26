# iOS Build Fixes

This document tracks all iOS build fixes applied to this project.

## Fix 1: Firebase Modular Header Error ✅

**Date**: November 25, 2025  
**Status**: Fixed

### Error
```
Include of non-modular header inside framework module 'firebase_messaging.FLTFirebaseMessagingPlugin': 
'/Users/.../ios/Pods/Headers/Public/Firebase/Firebase.h'
```

### Root Cause
Firebase pods contain non-modular headers but Podfile has `use_modular_headers!` enabled, creating a compatibility conflict.

### Solution
Updated `ios/Podfile` with a post_install hook that sets `CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES = YES` for Firebase/Google-related pods.

### Changed Files
- `ios/Podfile` - Added Firebase-specific build settings in post_install

### How to Apply
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter clean
flutter run
```

### Reference
See [FIREBASE_FIX.md](./FIREBASE_FIX.md) for detailed explanation.

---

## Fix 2: Missing Platform Declaration ✅

**Date**: November 25, 2025  
**Status**: Fixed

### Error
CocoaPods couldn't determine iOS deployment target.

### Root Cause
`platform :ios, '12.0'` was commented out in Podfile.

### Solution
Uncommented and updated to `platform :ios, '13.0'`.

### Changed Files
- `ios/Podfile` - Line 2

---

## Fix 3: Missing iOS Permissions ✅

**Date**: November 25, 2025  
**Status**: Fixed

### Error
App would crash when accessing camera, photos, health data, etc.

### Root Cause
Required permission descriptions missing from Info.plist.

### Solution
Added all required permission keys to `ios/Runner/Info.plist`:
- NSCameraUsageDescription
- NSPhotoLibraryUsageDescription
- NSPhotoLibraryAddUsageDescription
- NSHealthShareUsageDescription
- NSHealthUpdateUsageDescription
- NSMotionUsageDescription
- NSFaceIDUsageDescription

### Changed Files
- `ios/Runner/Info.plist`

---

## Fix 4: Missing HealthKit Entitlements ✅

**Date**: November 25, 2025  
**Status**: Fixed

### Error
HealthKit features wouldn't work, potential App Store rejection.

### Root Cause
No entitlements file for HealthKit capability.

### Solution
Created `ios/Runner/Runner.entitlements` with HealthKit capability enabled.

### Changed Files
- `ios/Runner/Runner.entitlements` (new file)

---

## Fix 5: Deployment Target Inconsistency ✅

**Date**: November 25, 2025  
**Status**: Fixed

### Error
Potential compatibility issues with newer dependencies.

### Root Cause
Xcode project had `IPHONEOS_DEPLOYMENT_TARGET = 12.0`.

### Solution
Updated all instances to iOS 13.0 in:
- `ios/Runner.xcodeproj/project.pbxproj`
- `ios/Podfile` (post_install ensures consistency)

---

## Quick Reference

### Clean Rebuild Command
```bash
# Full clean and rebuild
flutter clean
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter pub get
flutter run
```

### Check for Issues
```bash
# Verify Podfile syntax
cd ios && pod install --verbose

# Check Firebase pods
grep -A 5 "Firebase" Podfile.lock

# Verify build settings
cd .. && flutter analyze
```

### Verification Checklist
- [ ] All pods installed successfully
- [ ] No modular header errors
- [ ] All permissions present in Info.plist
- [ ] Entitlements file exists
- [ ] Deployment target is iOS 13.0
- [ ] App builds without errors
- [ ] App runs on simulator

## Related Documentation

- [IOS_SETUP.md](./IOS_SETUP.md) - Complete iOS setup guide
- [IOS_QUICK_START.md](./IOS_QUICK_START.md) - Quick setup steps
- [IOS_FIXES_SUMMARY.md](./IOS_FIXES_SUMMARY.md) - Initial fixes summary
- [FIREBASE_FIX.md](./FIREBASE_FIX.md) - Firebase modular header fix details

## Need Help?

If you encounter build errors not listed here:

1. **Check the error message carefully** - Search for the specific error in the documentation
2. **Clean and rebuild** - Many issues resolve with a clean build
3. **Check pod versions** - Ensure compatible versions in Podfile.lock
4. **Review Xcode logs** - Open project in Xcode for detailed error information
5. **Check Flutter doctor** - Run `flutter doctor -v` to verify setup

## Future Considerations

### Potential Issues to Watch For

1. **Firebase SDK Updates**: Future Firebase versions may change modular header requirements
2. **Flutter Updates**: New Flutter versions may have different iOS requirements  
3. **iOS Version Updates**: New iOS versions may require deployment target changes
4. **New Dependencies**: Additional pods may have similar modular header issues

### Maintenance

When updating dependencies:
1. Check for breaking changes in Firebase
2. Test build after pod updates
3. Update deployment targets if needed
4. Document any new fixes in this file

