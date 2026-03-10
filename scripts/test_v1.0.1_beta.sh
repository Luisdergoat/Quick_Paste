#!/bin/bash

# Cliply v1.0.1 Beta - Comprehensive Test Script
# Tests all new features and bug fixes

set -e

echo "🧪 Cliply v1.0.1 Beta - Test Suite"
echo "=================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# Helper functions
test_start() {
    echo -e "${BLUE}➤ Test: $1${NC}"
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
}

test_pass() {
    echo -e "${GREEN}  ✅ PASS: $1${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

test_fail() {
    echo -e "${RED}  ❌ FAIL: $1${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

test_info() {
    echo -e "${YELLOW}  ℹ️  INFO: $1${NC}"
}

# Find the app
APP_PATH=""
if [ -d "/Applications/Cliply.app" ]; then
    APP_PATH="/Applications/Cliply.app"
elif [ -d "$HOME/Library/Developer/Xcode/DerivedData/cliply-"*"/Build/Products/Debug/Cliply.app" ]; then
    APP_PATH=$(find "$HOME/Library/Developer/Xcode/DerivedData" -name "Cliply.app" -path "*/Debug/*" | head -1)
else
    echo -e "${RED}❌ Cliply.app not found!${NC}"
    echo "Please build the project first or install from DMG."
    exit 1
fi

echo -e "${GREEN}Found Cliply at: $APP_PATH${NC}"
echo ""

# Test 1: App Exists and is Valid
test_start "App Bundle Valid"
if [ -d "$APP_PATH" ]; then
    test_pass "App bundle exists"
else
    test_fail "App bundle not found"
fi

# Test 2: Info.plist Exists and Contains Correct Version
test_start "Version Check (Info.plist)"
PLIST_PATH="$APP_PATH/Contents/Info.plist"
if [ -f "$PLIST_PATH" ]; then
    VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$PLIST_PATH" 2>/dev/null)
    BUILD=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$PLIST_PATH" 2>/dev/null)
    
    if [[ "$VERSION" == "1.0.1 Beta" ]]; then
        test_pass "Version is $VERSION"
    else
        test_fail "Expected version '1.0.1 Beta', got '$VERSION'"
    fi
    
    if [[ "$BUILD" == "2" ]]; then
        test_pass "Build number is $BUILD"
    else
        test_fail "Expected build '2', got '$BUILD'"
    fi
else
    test_fail "Info.plist not found"
fi

# Test 3: Required Files Exist
test_start "Required Files Check"
REQUIRED_FILES=(
    "Contents/MacOS/Cliply"
    "Contents/Resources/Assets.car"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -e "$APP_PATH/$file" ]; then
        test_pass "$file exists"
    else
        test_fail "$file missing"
    fi
done

# Test 4: Source Code Files
test_start "Source Code Structure"
SOURCE_FILES=(
    "cliply/Utils/UpdateManager.swift"
    "cliply/Utils/WindowManager.swift"
    "cliply/Clipboard/ClipboardManager.swift"
    "cliply/UI/ClipboardPopup.swift"
    "cliply/UI/SettingsView.swift"
)

PROJECT_ROOT=$(dirname "$0")/..
for file in "${SOURCE_FILES[@]}"; do
    if [ -f "$PROJECT_ROOT/$file" ]; then
        test_pass "$file exists"
    else
        test_fail "$file missing"
    fi
done

# Test 5: UpdateManager Implementation
test_start "UpdateManager.swift Implementation"
UPDATEMANAGER="$PROJECT_ROOT/cliply/Utils/UpdateManager.swift"
if [ -f "$UPDATEMANAGER" ]; then
    if grep -q "func checkForUpdates" "$UPDATEMANAGER"; then
        test_pass "checkForUpdates() method found"
    else
        test_fail "checkForUpdates() method not found"
    fi
    
    if grep -q "func downloadAndInstall" "$UPDATEMANAGER"; then
        test_pass "downloadAndInstall() method found"
    else
        test_fail "downloadAndInstall() method not found"
    fi
    
    if grep -q "github.com" "$UPDATEMANAGER"; then
        test_pass "GitHub API integration found"
    else
        test_fail "GitHub API integration not found"
    fi
else
    test_fail "UpdateManager.swift not found"
fi

# Test 6: ClipboardManager MRU Implementation
test_start "ClipboardManager MRU/FIFO Implementation"
CLIPBOARDMGR="$PROJECT_ROOT/cliply/Clipboard/ClipboardManager.swift"
if [ -f "$CLIPBOARDMGR" ]; then
    if grep -q "func removeItem" "$CLIPBOARDMGR"; then
        test_pass "removeItem() method found"
    else
        test_fail "removeItem() method not found"
    fi
    
    if grep -q "func moveToFront" "$CLIPBOARDMGR"; then
        test_pass "moveToFront() method found"
    else
        test_fail "moveToFront() method not found"
    fi
    
    if grep -q "maxHistory = 10" "$CLIPBOARDMGR"; then
        test_pass "FIFO limit of 10 items found"
    else
        test_fail "FIFO limit not properly set"
    fi
else
    test_fail "ClipboardManager.swift not found"
fi

# Test 7: ClipboardPopup R-Key Implementation
test_start "ClipboardPopup R-Key Handler"
POPUP="$PROJECT_ROOT/cliply/UI/ClipboardPopup.swift"
if [ -f "$POPUP" ]; then
    if grep -q "case 15:" "$POPUP" && grep -q "R key" "$POPUP"; then
        test_pass "R-key handler (keyCode 15) found"
    else
        test_fail "R-key handler not found"
    fi
    
    if grep -q "onDeleteSelected" "$POPUP"; then
        test_pass "onDeleteSelected callback found"
    else
        test_fail "onDeleteSelected callback not found"
    fi
    
    if grep -q 'keyHint(key: "R"' "$POPUP"; then
        test_pass "R-key hint in footer found"
    else
        test_fail "R-key hint in footer not found"
    fi
else
    test_fail "ClipboardPopup.swift not found"
fi

# Test 8: Settings Window Fix
test_start "WindowManager Settings Fix"
WINDOWMGR="$PROJECT_ROOT/cliply/Utils/WindowManager.swift"
if [ -f "$WINDOWMGR" ]; then
    if grep -q "func showSettings" "$WINDOWMGR"; then
        test_pass "showSettings() method found"
    else
        test_fail "showSettings() method not found"
    fi
    
    if grep -q "isOpaque = true" "$WINDOWMGR"; then
        test_pass "Window opacity fix found"
    else
        test_fail "Window opacity fix not found"
    fi
    
    if grep -q "titlebarAppearsTransparent = false" "$WINDOWMGR"; then
        test_pass "Titlebar visibility fix found"
    else
        test_fail "Titlebar visibility fix not found"
    fi
else
    test_fail "WindowManager.swift not found"
fi

# Test 9: Settings Auto-Update UI
test_start "SettingsView Auto-Update UI"
SETTINGS="$PROJECT_ROOT/cliply/UI/SettingsView.swift"
if [ -f "$SETTINGS" ]; then
    if grep -q "UpdateManager" "$SETTINGS"; then
        test_pass "UpdateManager integration found"
    else
        test_fail "UpdateManager integration not found"
    fi
    
    if grep -q "Check for Updates" "$SETTINGS"; then
        test_pass "Update button found"
    else
        test_fail "Update button not found"
    fi
    
    if grep -q "Auto-Update" "$SETTINGS"; then
        test_pass "Auto-Update section found"
    else
        test_fail "Auto-Update section not found"
    fi
else
    test_fail "SettingsView.swift not found"
fi

# Test 10: Documentation Files
test_start "Documentation Completeness"
DOC_FILES=(
    "README.md"
    "CHANGELOG.md"
    "RELEASE_NOTES_v1.0.1_BETA.md"
    "IMPLEMENTATION_SUMMARY_v1.0.1.md"
)

for doc in "${DOC_FILES[@]}"; do
    if [ -f "$PROJECT_ROOT/$doc" ]; then
        test_pass "$doc exists"
    else
        test_fail "$doc missing"
    fi
done

# Test 11: App Signature (if signed)
test_start "Code Signature Check"
if codesign -v "$APP_PATH" 2>/dev/null; then
    test_pass "App is code-signed"
    SIGNATURE=$(codesign -dvvv "$APP_PATH" 2>&1 | grep "Authority" | head -1)
    test_info "$SIGNATURE"
else
    test_info "App is not code-signed (OK for debug builds)"
fi

# Test 12: App Can Launch
test_start "App Launch Test"
if pgrep -x "Cliply" > /dev/null; then
    test_info "Cliply is already running"
else
    open "$APP_PATH"
    sleep 2
    if pgrep -x "Cliply" > /dev/null; then
        test_pass "App launched successfully"
    else
        test_fail "App failed to launch"
    fi
fi

# Test 13: Accessibility Permissions Info
test_start "Accessibility Permissions"
test_info "Please manually verify Accessibility permissions in:"
test_info "System Settings → Privacy & Security → Accessibility → Cliply"
test_info "This is required for CGEvent Tap functionality"

echo ""
echo "=================================="
echo -e "${BLUE}📊 Test Results Summary${NC}"
echo "=================================="
echo -e "Total Tests:  ${TESTS_TOTAL}"
echo -e "Passed:       ${GREEN}${TESTS_PASSED}${NC}"
echo -e "Failed:       ${RED}${TESTS_FAILED}${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ All tests passed! Cliply v1.0.1 Beta is ready! 🚀${NC}"
    exit 0
else
    echo -e "${RED}❌ Some tests failed. Please review the output above.${NC}"
    exit 1
fi
