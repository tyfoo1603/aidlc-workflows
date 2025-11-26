#!/bin/bash

# Firebase iOS Build Fix Script
# This script performs a complete clean rebuild to fix Firebase modular header issues

set -e

echo "🔧 Fixing Firebase iOS Build Issues..."
echo ""

# Get script directory and project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

echo "📂 Project root: $PROJECT_ROOT"
echo ""

# Step 1: Clean Xcode DerivedData
echo "1️⃣  Cleaning Xcode DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*
echo "   ✅ DerivedData cleaned"
echo ""

# Step 2: Clean Flutter
echo "2️⃣  Cleaning Flutter build..."
flutter clean
echo "   ✅ Flutter cleaned"
echo ""

# Step 3: Remove iOS Pods completely
echo "3️⃣  Removing iOS Pods..."
cd ios
rm -rf Pods Podfile.lock .symlinks
rm -rf ~/Library/Caches/CocoaPods
echo "   ✅ Pods removed"
cd ..
echo ""

# Step 4: Get Flutter dependencies
echo "4️⃣  Getting Flutter dependencies..."
flutter pub get
echo "   ✅ Dependencies fetched"
echo ""

# Step 5: Reinstall Pods
echo "5️⃣  Reinstalling CocoaPods (this may take a few minutes)..."
cd ios
pod deintegrate 2>/dev/null || true
pod repo update
pod install
cd ..
echo "   ✅ Pods installed"
echo ""

echo "✅ Firebase iOS fix complete!"
echo ""
echo "Next steps:"
echo "  Run: flutter run"
echo "  Select: iPhone 15 (option 2)"
echo ""

