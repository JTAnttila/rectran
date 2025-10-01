#!/bin/bash

# Clean Build Script for Rectran Wear OS
# Cleans the project and rebuilds from scratch

set -e

echo "🧹 Cleaning project..."
./gradlew clean

echo "🗑️  Removing build caches..."
rm -rf .gradle/
rm -rf app/build/
rm -rf build/

echo "🔨 Building fresh..."
./gradlew assembleDebug

echo "✅ Clean build complete!"
