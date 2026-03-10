#!/bin/bash

# Cliply Icon Installation Script
# Konvertiert das bereitgestellte Icon in alle benötigten Größen

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ICON_DIR="$SCRIPT_DIR/cliply/Resources/Assets.xcassets/AppIcon.appiconset"

# Farben für Output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Cliply Icon Installation Tool     ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Prüfe ob sips verfügbar ist (macOS Tool)
if ! command -v sips &> /dev/null; then
    echo -e "${RED}✗ 'sips' Tool nicht gefunden!${NC}"
    echo "  Bitte auf macOS ausführen."
    exit 1
fi

# Suche nach Icon-Datei
ORIGINAL_ICON=""
for ext in png jpg jpeg; do
    if [ -f "$SCRIPT_DIR/cliply_icon.$ext" ]; then
        ORIGINAL_ICON="$SCRIPT_DIR/cliply_icon.$ext"
        break
    fi
    if [ -f "$SCRIPT_DIR/icon.$ext" ]; then
        ORIGINAL_ICON="$SCRIPT_DIR/icon.$ext"
        break
    fi
    if [ -f "$SCRIPT_DIR/app_icon.$ext" ]; then
        ORIGINAL_ICON="$SCRIPT_DIR/app_icon.$ext"
        break
    fi
done

if [ -z "$ORIGINAL_ICON" ]; then
    echo -e "${RED}✗ Icon-Datei nicht gefunden!${NC}"
    echo ""
    echo "Bitte Icon-Datei als eine der folgenden Namen ablegen:"
    echo "  • cliply_icon.png"
    echo "  • icon.png"
    echo "  • app_icon.png"
    echo ""
    echo "Icon sollte mindestens 1024x1024 Pixel groß sein."
    exit 1
fi

echo -e "${GREEN}✓ Icon gefunden:${NC} $ORIGINAL_ICON"
echo ""

# Erstelle Icon-Verzeichnis falls nötig
mkdir -p "$ICON_DIR"

# Konvertiere Icon in alle benötigten Größen
echo "Konvertiere Icon..."
echo ""

declare -a FILENAMES=(
    "icon_16x16.png:16"
    "icon_16x16@2x.png:32"
    "icon_32x32.png:32"
    "icon_32x32@2x.png:64"
    "icon_128x128.png:128"
    "icon_128x128@2x.png:256"
    "icon_256x256.png:256"
    "icon_256x256@2x.png:512"
    "icon_512x512.png:512"
    "icon_512x512@2x.png:1024"
)

for entry in "${FILENAMES[@]}"; do
    filename="${entry%%:*}"
    size="${entry##*:}"
    output="$ICON_DIR/$filename"
    
    if sips -z "$size" "$size" "$ORIGINAL_ICON" --out "$output" &> /dev/null; then
        echo -e "${GREEN}✓${NC} $filename (${size}x${size})"
    else
        echo -e "${RED}✗${NC} $filename (${size}x${size}) - FEHLER"
    fi
done

echo ""
echo -e "${GREEN}✓ Icon-Installation abgeschlossen!${NC}"
echo ""
echo "Nächste Schritte:"
echo "  1. Xcode öffnen: ${BLUE}open ShiftClip.xcodeproj${NC}"
echo "  2. Assets.xcassets → AppIcon überprüfen"
echo "  3. Build & Run: ${BLUE}⌘R${NC}"
echo ""
echo -e "${GREEN}✓ Icon sollte jetzt in Menu Bar erscheinen!${NC}"
