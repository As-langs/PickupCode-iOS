#!/bin/bash
set -e

PROJ_DIR="/Users/zouh/.gemini/antigravity/scratch/PickupCode-iOS"
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
xcrun --sdk iphoneos swiftc \
  -target arm64-apple-ios16.0 \
  -O \
  -parse-as-library \
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
cp PickupCode/Resources/Images/ic_taobao.png "$WIDGET_DIR/"
cp PickupCode/Resources/Images/ic_jd.png "$WIDGET_DIR/"
cp PickupCode/Resources/Images/ic_pinduoduo.png "$WIDGET_DIR/"

codesign -s - --force "$WIDGET_DIR" || true

echo "=== 5. Zipping IPA ==="
cd ipa_build
zip -qry ../PickupCode-1.0.1.ipa Payload
cd ..
cp PickupCode-1.0.1.ipa 取件快码-1.0.1.ipa

echo "=== 6. Build Completed ==="
ls -lh PickupCode-1.0.1.ipa 取件快码-1.0.1.ipa
