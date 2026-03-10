# Cliply App Icon Installation

## Das bereitgestellte Icon

Das Icon zeigt:
- **Hintergrund**: Dunkelgrün (#1a3d3d)
- **Dokument**: Beiges Papier (#e8dcc4) mit horizontalen Linien
- **Tab**: Grüner Tab oben links
- **Badge**: Orange/beiger Badge rechts oben
- **Stil**: 3D, skeuomorphisch, mit Schatten

## Icon in Xcode einbinden

### Automatisch mit `sips` Tool:

```bash
cd /Users/lunsold/42/ShiftClip

# Original Icon (sollte mindestens 1024x1024 sein)
ORIGINAL_ICON="path/to/your/icon.png"
ICON_DIR="ShiftClip/Resources/Assets.xcassets/AppIcon.appiconset"

# Erstelle alle benötigten Größen
sips -z 16 16 "$ORIGINAL_ICON" --out "$ICON_DIR/icon_16x16.png"
sips -z 32 32 "$ORIGINAL_ICON" --out "$ICON_DIR/icon_16x16@2x.png"
sips -z 32 32 "$ORIGINAL_ICON" --out "$ICON_DIR/icon_32x32.png"
sips -z 64 64 "$ORIGINAL_ICON" --out "$ICON_DIR/icon_32x32@2x.png"
sips -z 128 128 "$ORIGINAL_ICON" --out "$ICON_DIR/icon_128x128.png"
sips -z 256 256 "$ORIGINAL_ICON" --out "$ICON_DIR/icon_128x128@2x.png"
sips -z 256 256 "$ORIGINAL_ICON" --out "$ICON_DIR/icon_256x256.png"
sips -z 512 512 "$ORIGINAL_ICON" --out "$ICON_DIR/icon_256x256@2x.png"
sips -z 512 512 "$ORIGINAL_ICON" --out "$ICON_DIR/icon_512x512.png"
sips -z 1024 1024 "$ORIGINAL_ICON" --out "$ICON_DIR/icon_512x512@2x.png"
```

### Manuell:

1. Icon öffnen in Preview/Photoshop
2. Exportieren in Größen:
   - 16x16, 32x32, 64x64, 128x128, 256x256, 512x512, 1024x1024
3. Dateien umbenennen nach Schema oben
4. In Ordner kopieren: `ShiftClip/Resources/Assets.xcassets/AppIcon.appiconset/`

## Benötigte Dateien:

```
AppIcon.appiconset/
├── Contents.json (✅ bereits vorhanden)
├── icon_16x16.png (16x16)
├── icon_16x16@2x.png (32x32)
├── icon_32x32.png (32x32)
├── icon_32x32@2x.png (64x64)
├── icon_128x128.png (128x128)
├── icon_128x128@2x.png (256x256)
├── icon_256x256.png (256x256)
├── icon_256x256@2x.png (512x512)
├── icon_512x512.png (512x512)
└── icon_512x512@2x.png (1024x1024)
```

## Verifikation

Nach dem Hinzufügen:
1. Xcode öffnen: `open ShiftClip.xcodeproj`
2. Assets.xcassets öffnen
3. AppIcon auswählen
4. Alle Slots sollten gefüllt sein ✅
5. Build & Run: ⌘R
6. Icon sollte in Menu Bar und App Switcher erscheinen

## Quick Test

```bash
# Prüfe ob Icons vorhanden sind
ls -lh ShiftClip/Resources/Assets.xcassets/AppIcon.appiconset/*.png
```
