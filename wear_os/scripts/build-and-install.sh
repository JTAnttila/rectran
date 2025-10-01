#!/bin/bash

# Build and Install Script for Rectran Wear OS
# Builds the debug APK and installs it on connected watch

set -e

echo "🔨 Building Rectran Wear OS..."
./gradlew assembleDebug

echo "📱 Finding connected watch..."
WATCH_ID=$(adb devices | grep -v "List" | grep "device" | head -n 1 | awk '{print $1}')

if [ -z "$WATCH_ID" ]; then
    echo "❌ No watch found. Please connect your watch via ADB."
    exit 1
fi

echo "📲 Installing on watch: $WATCH_ID"
adb -s "$WATCH_ID" install -r app/build/outputs/apk/debug/app-debug.apk

echo "✅ Installation complete!"
echo "📱 Launch 'Rectran' on your watch to test."
