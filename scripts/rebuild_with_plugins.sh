#!/bin/bash

# Script to rebuild Flutter app with new plugins

echo "🧹 Cleaning Flutter build..."
flutter clean

echo "📦 Getting Flutter dependencies..."
flutter pub get

echo "🍎 Installing iOS CocoaPods dependencies..."
cd ios
pod install
cd ..

echo "✅ Setup complete! Now run 'flutter run' to start your app."
echo ""
echo "Note: Make sure to completely stop and restart your app (not hot reload)."

