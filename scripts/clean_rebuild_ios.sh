#!/bin/bash

# Complete iOS Clean and Rebuild Script
# This script performs a thorough clean and rebuild for iOS

set -e  # Exit on error

echo "🧹 Starting complete iOS clean and rebuild..."
echo ""

# Check if we're in the project root
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: Please run this script from the project root directory"
    exit 1
fi

# Step 1: Clean Xcode DerivedData
echo "🗑️  Step 1/6: Cleaning Xcode DerivedData..."
if [ -d "$HOME/Library/Developer/Xcode/DerivedData" ]; then
    rm -rf ~/Library/Developer/Xcode/DerivedData/*
    echo "✅ DerivedData cleaned"
else
    echo "ℹ️  DerivedData directory not found (that's okay)"
fi
echo ""

# Step 2: Clean Flutter build
echo "🗑️  Step 2/6: Cleaning Flutter build..."
flutter clean
echo "✅ Flutter build cleaned"
echo ""

# Step 3: Clean iOS Pods
echo "🗑️  Step 3/6: Cleaning iOS Pods..."
cd ios
if [ -d "Pods" ]; then
    rm -rf Pods
    echo "✅ Pods directory removed"
fi
if [ -f "Podfile.lock" ]; then
    rm -f Podfile.lock
    echo "✅ Podfile.lock removed"
fi
if [ -d ".symlinks" ]; then
    rm -rf .symlinks
    echo "✅ .symlinks removed"
fi
cd ..
echo ""

# Step 4: Get Flutter dependencies
echo "📦 Step 4/6: Getting Flutter dependencies..."
flutter pub get
echo "✅ Flutter dependencies fetched"
echo ""

# Step 5: Install CocoaPods
echo "📦 Step 5/6: Installing CocoaPods dependencies..."
cd ios
pod install --repo-update
cd ..
echo "✅ CocoaPods dependencies installed"
echo ""

# Step 6: Verify installation
echo "🔍 Step 6/6: Verifying installation..."
if [ -f "ios/Podfile.lock" ]; then
    echo "✅ Podfile.lock created"
else
    echo "❌ Error: Podfile.lock not created"
    exit 1
fi

if [ -d "ios/Pods" ]; then
    echo "✅ Pods directory created"
else
    echo "❌ Error: Pods directory not created"
    exit 1
fi

echo ""
echo "✅ Clean and rebuild complete!"
echo ""
echo "Next steps:"
echo "1. Run the app: flutter run"
echo "2. Or open in Xcode: open ios/Runner.xcworkspace"
echo ""
echo "If you still encounter build errors, try:"
echo "  - Restart your IDE"
echo "  - Restart your Mac"
echo "  - Check Xcode for specific error details"

