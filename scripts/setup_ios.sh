#!/bin/bash

# iOS Setup Script for Easy App
# This script automates the iOS setup process

set -e  # Exit on error

echo "🚀 Starting iOS setup..."
echo ""

# Check if we're in the project root
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: Please run this script from the project root directory"
    exit 1
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Error: Flutter is not installed or not in PATH"
    echo "Please install Flutter: https://docs.flutter.dev/get-started/install"
    exit 1
fi

echo "✅ Flutter found: $(flutter --version | head -n 1)"
echo ""

# Check if CocoaPods is installed
if ! command -v pod &> /dev/null; then
    echo "⚠️  Warning: CocoaPods is not installed"
    echo "Installing CocoaPods..."
    sudo gem install cocoapods
    if [ $? -ne 0 ]; then
        echo "❌ Error: Failed to install CocoaPods"
        echo "Please install manually: https://cocoapods.org/"
        exit 1
    fi
fi

echo "✅ CocoaPods found: $(pod --version)"
echo ""

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
echo ""

# Get Flutter dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get
echo ""

# Check if GoogleService-Info.plist exists
if [ ! -f "ios/Runner/GoogleService-Info.plist" ]; then
    echo "⚠️  Warning: GoogleService-Info.plist not found"
    echo "Push notifications will not work without Firebase configuration."
    echo "Please follow the instructions in docs/IOS_SETUP.md to add Firebase."
    echo ""
else
    echo "✅ GoogleService-Info.plist found"
    echo ""
fi

# Install CocoaPods dependencies
echo "📦 Installing CocoaPods dependencies..."
cd ios
pod repo update
pod install
cd ..
echo ""

# Check if installation was successful
if [ -f "ios/Podfile.lock" ]; then
    echo "✅ CocoaPods dependencies installed successfully"
    echo ""
else
    echo "❌ Error: Failed to install CocoaPods dependencies"
    exit 1
fi

# List available iOS simulators
echo "📱 Available iOS simulators:"
flutter devices | grep "ios" || echo "No iOS devices found. Please install Xcode and iOS Simulator."
echo ""

echo "✅ iOS setup complete!"
echo ""
echo "Next steps:"
echo "1. Open ios/Runner.xcworkspace in Xcode (NOT Runner.xcodeproj)"
echo "2. Configure signing if running on physical device"
echo "3. Add GoogleService-Info.plist if not already done (see docs/IOS_SETUP.md)"
echo "4. Run the app:"
echo "   - Using Flutter: flutter run"
echo "   - Using VS Code: Use launch configurations"
echo "   - Using Xcode: Open workspace and press Cmd+R"
echo ""
echo "For more information, see docs/IOS_SETUP.md"

