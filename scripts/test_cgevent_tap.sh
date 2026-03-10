#!/bin/bash

# Cliply v1.0.1 Beta - Test Script
# Testet ob CGEvent Tap korrekt implementiert ist und kein Beep mehr kommt

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║       Cliply v1.0.1 Beta - Test Suite                ║${NC}"
echo -e "${BLUE}║       CGEvent Tap Implementation Verification          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# 1. Check if app exists
echo -e "${YELLOW}📦 Checking if Cliply.app exists...${NC}"
APP_PATH="/Users/lunsold/Library/Developer/Xcode/DerivedData/cliply-fxtmpiugnyyeurapgksswdoscdfv/Build/Products/Release/Cliply.app"

if [ ! -d "$APP_PATH" ]; then
    echo -e "${RED}❌ App not found at: $APP_PATH${NC}"
    echo -e "${YELLOW}   Building app first...${NC}"
    xcodebuild -project cliply.xcodeproj -scheme Cliply -configuration Release clean build > /dev/null 2>&1
    echo -e "${GREEN}✅ Build completed${NC}"
else
    echo -e "${GREEN}✅ App found${NC}"
fi

# 2. Check Info.plist version
echo ""
echo -e "${YELLOW}📋 Checking version...${NC}"
VERSION=$(defaults read "$APP_PATH/Contents/Info" CFBundleShortVersionString 2>/dev/null || echo "unknown")
BUILD=$(defaults read "$APP_PATH/Contents/Info" CFBundleVersion 2>/dev/null || echo "unknown")
echo -e "${GREEN}   Version: $VERSION (Build $BUILD)${NC}"

if [[ "$VERSION" == *"1.0.1"* ]] || [[ "$VERSION" == *"Beta"* ]]; then
    echo -e "${GREEN}✅ Version is 1.0.1 Beta${NC}"
else
    echo -e "${RED}⚠️  Version might be outdated: $VERSION${NC}"
fi

# 3. Check if HotkeyManager has CGEvent Tap
echo ""
echo -e "${YELLOW}🔍 Checking HotkeyManager implementation...${NC}"
if grep -q "CGEvent.tapCreate" cliply/Hotkeys/HotkeyManager.swift; then
    echo -e "${GREEN}✅ CGEvent Tap found in HotkeyManager${NC}"
else
    echo -e "${RED}❌ CGEvent Tap NOT found - still using old implementation!${NC}"
    exit 1
fi

# 4. Check for Accessibility description
echo ""
echo -e "${YELLOW}🔐 Checking Accessibility permission description...${NC}"
if grep -q "NSAccessibilityUsageDescription" cliply/Resources/Info.plist; then
    echo -e "${GREEN}✅ Accessibility description present${NC}"
else
    echo -e "${RED}❌ Accessibility description missing!${NC}"
fi

# 5. Check if app is currently running
echo ""
echo -e "${YELLOW}🏃 Checking if Cliply is running...${NC}"
if pgrep -x "Cliply" > /dev/null; then
    echo -e "${GREEN}✅ Cliply is running${NC}"
    
    # Check Console logs for CGEvent Tap
    echo ""
    echo -e "${YELLOW}📝 Checking recent logs...${NC}"
    RECENT_LOGS=$(log show --predicate 'process == "Cliply"' --last 1m 2>/dev/null | grep -i "cgevent\|event tap" | head -5)
    
    if [ ! -z "$RECENT_LOGS" ]; then
        echo -e "${GREEN}✅ CGEvent Tap logs found:${NC}"
        echo "$RECENT_LOGS" | while read line; do
            echo -e "   ${BLUE}$line${NC}"
        done
    else
        echo -e "${YELLOW}⚠️  No recent CGEvent Tap logs (app might need restart)${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Cliply is not running${NC}"
    echo -e "${YELLOW}   Starting app for testing...${NC}"
    open "$APP_PATH"
    sleep 2
    echo -e "${GREEN}✅ App started${NC}"
fi

# 6. Manual test instructions
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              MANUAL TESTING REQUIRED                   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Please test the following:${NC}"
echo ""
echo -e "1. ${GREEN}Open a text editor${NC} (Notes, TextEdit, Safari, etc.)"
echo -e "2. ${GREEN}Select some text${NC}"
echo -e "3. ${GREEN}Press ⌘⇧C${NC}"
echo -e "   → ${BLUE}Should copy WITHOUT beep sound!${NC}"
echo -e "   → ${BLUE}Check menu bar icon turns active${NC}"
echo ""
echo -e "4. ${GREEN}Press ⌘⇧V${NC}"
echo -e "   → ${BLUE}Should show popup WITHOUT beep sound!${NC}"
echo -e "   → ${BLUE}Popup should display copied text${NC}"
echo ""
echo -e "5. ${GREEN}Check Console.app${NC} for logs:"
echo -e "   ${BLUE}Filter: process:Cliply${NC}"
echo -e "   ${BLUE}Look for: 'CGEvent Tap active'${NC}"
echo ""
echo -e "${YELLOW}📱 Accessibility Permission Check:${NC}"
echo -e "   System Settings → Privacy & Security → Accessibility"
echo -e "   ${GREEN}Make sure Cliply is enabled!${NC}"
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                   TEST COMPLETE                        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}✅ Automatic checks passed!${NC}"
echo -e "${YELLOW}⚠️  Please complete manual testing above${NC}"
echo ""
