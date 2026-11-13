#!/bin/bash
set -e

PROJ_DIR="/Users/zouh/.gemini/antigravity/scratch/PickupCode-iOS"
VERSION="2.1.5"
cd "$PROJ_DIR"

echo "=== 1. Cleaning previous builds ==="
rm -rf build ipa_build PickupCode-*.ipa 取件快码-*.ipa

echo "=== 2. Building Main App with xcodebuild ==="
xcodebuild clean build \
  -project PickupCode.xcodeproj \
  -scheme PickupCode \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -derivedDataPath build \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO

echo "=== 3. Compiling PickupCodeWidget with swiftc ==="
mkdir -p /tmp/clang-module-cache
xcrun --sdk iphoneos swiftc \
  -target arm64-apple-ios16.0 \
  -O \
  -parse-as-library \
  -module-cache-path /tmp/clang-module-cache \
  -emit-executable \
  -o "$PROJ_DIR/PickupCodeWidget/PickupCodeWidget" \
  "$PROJ_DIR/PickupCodeWidget/PickupCodeWidget.swift" \
  -framework WidgetKit \
  -framework SwiftUI \
  -framework Foundation \
  -framework UIKit \
  -Xlinker -rpath -Xlinker @executable_path/Frameworks \
  -Xlinker -rpath -Xlinker @executable_path/../../Frameworks

codesign -s - --force "$PROJ_DIR/PickupCodeWidget/PickupCodeWidget"

echo "=== 4. Packaging App Bundle & PlugIns ==="
mkdir -p ipa_build/Payload
cp -R build/Build/Products/Release-iphoneos/PickupCode.app ipa_build/Payload/

# Copy all platform icons & images to main bundle
cp PickupCode/Resources/Images/*.png ipa_build/Payload/PickupCode.app/

# Setup Widget Extension inside PlugIns
WIDGET_DIR="ipa_build/Payload/PickupCode.app/PlugIns/PickupCodeWidget.appex"
mkdir -p "$WIDGET_DIR"
cp "$PROJ_DIR/PickupCodeWidget/PickupCodeWidget" "$WIDGET_DIR/"
cp "$PROJ_DIR/PickupCodeWidget/Info.plist" "$WIDGET_DIR/"
cp PickupCode/Resources/Images/*.png "$WIDGET_DIR/"

codesign -s - --force "$WIDGET_DIR" || true

echo "=== 5. Zipping IPA ==="
cd ipa_build
zip -qry "../PickupCode-${VERSION}.ipa" Payload
cd ..
cp "PickupCode-${VERSION}.ipa" "取件快码-${VERSION}.ipa"

mkdir -p release_assets
cp "PickupCode-${VERSION}.ipa" release_assets/
cp "取件快码-${VERSION}.ipa" release_assets/
cp "PickupCode-${VERSION}.ipa" /Users/zouh/Downloads/ 2>/dev/null || true
cp "取件快码-${VERSION}.ipa" /Users/zouh/Downloads/ 2>/dev/null || true

echo "=== 6. Build Completed ==="
ls -lh "PickupCode-${VERSION}.ipa" "取件快码-${VERSION}.ipa" release_assets/
