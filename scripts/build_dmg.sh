#!/bin/bash

# Cliply DMG Build Script
# This script builds the Cliply app and creates a DMG for distribution

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Building Cliply DMG...${NC}"

# Configuration
APP_NAME="Cliply"
BUILD_DIR="build"
DMG_DIR="dmg_temp"
FINAL_DMG="${APP_NAME}.dmg"

# Get version from Info.plist
VERSION=$(defaults read "$(pwd)/cliply/Resources/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "1.0.0")
echo -e "${YELLOW}📦 Version: ${VERSION}${NC}"

# Clean previous builds
echo -e "${YELLOW}🧹 Cleaning previous builds...${NC}"
rm -rf "${BUILD_DIR}"
rm -rf "${DMG_DIR}"
rm -f "${FINAL_DMG}"

# Build the app
echo -e "${YELLOW}🔨 Building ${APP_NAME}.app...${NC}"
xcodebuild -project cliply.xcodeproj \
    -scheme Cliply \
    -configuration Release \
    -derivedDataPath "${BUILD_DIR}" \
    clean build

# Check if build succeeded
if [ ! -d "${BUILD_DIR}/Build/Products/Release/${APP_NAME}.app" ]; then
    echo -e "${RED}❌ Build failed! ${APP_NAME}.app not found${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Build successful!${NC}"

# Create temporary DMG directory
echo -e "${YELLOW}📁 Creating DMG structure...${NC}"
mkdir -p "${DMG_DIR}"
cp -R "${BUILD_DIR}/Build/Products/Release/${APP_NAME}.app" "${DMG_DIR}/"

# Create Applications symlink
ln -s /Applications "${DMG_DIR}/Applications"

# Create DMG
echo -e "${YELLOW}💿 Creating DMG...${NC}"
hdiutil create -volname "${APP_NAME}" \
    -srcfolder "${DMG_DIR}" \
    -ov -format UDZO \
    "${FINAL_DMG}"

# Clean up
echo -e "${YELLOW}🧹 Cleaning up...${NC}"
rm -rf "${BUILD_DIR}"
rm -rf "${DMG_DIR}"

echo -e "${GREEN}✅ DMG created successfully: ${FINAL_DMG}${NC}"
echo -e "${GREEN}🎉 Ready for distribution!${NC}"

# Show file size
SIZE=$(du -h "${FINAL_DMG}" | cut -f1)
echo -e "${YELLOW}📊 File size: ${SIZE}${NC}"
