# Cliply - Design Assets

## App Icon

Das App Icon verwendet die **Dunkelgrün-Beige** Farbpalette:

### Farben:
- **Dunkelgrün**: `#1a3d3d` (RGB: 26, 61, 61)
- **Mittel-Grün**: `#2d5555` (RGB: 45, 85, 85)
- **Hell-Beige**: `#e8dcc4` (RGB: 232, 220, 196)
- **Mittel-Beige**: `#d4c5a9` (RGB: 212, 197, 169)

### Icon-Design:
1. **Hintergrund**: Dunkelgrün (#1a3d3d)
2. **Symbol**: Dokument/Clipboard Icon in Beige (#e8dcc4)
3. **Stil**: Minimalistisch, clean, geometric

### Benötigte Größen:
- 16x16 px (1x + 2x)
- 32x32 px (1x + 2x)
- 128x128 px (1x + 2x)
- 256x256 px (1x + 2x)
- 512x512 px (1x + 2x)

### Wo Icons ablegen:
`Cliply/Resources/Assets.xcassets/AppIcon.appiconset/`

Dateien:
- `icon_16x16.png` (16x16)
- `icon_16x16@2x.png` (32x32)
- `icon_32x32.png` (32x32)
- `icon_32x32@2x.png` (64x64)
- `icon_128x128.png` (128x128)
- `icon_128x128@2x.png` (256x256)
- `icon_256x256.png` (256x256)
- `icon_256x256@2x.png` (512x512)
- `icon_512x512.png` (512x512)
- `icon_512x512@2x.png` (1024x1024)

## Berechtigungen

Die App benötigt folgende Berechtigungen:

### Accessibility (bereits konfiguriert)
- **Info.plist**: `NSAccessibilityUsageDescription`
- **Zweck**: Globale Tastaturshortcuts (⌘⇧C, ⌘⇧V)
- **User wird automatisch gefragt** beim ersten Start

### Entitlements (bereits konfiguriert)
- **Datei**: `Cliply/Resources/Cliply.entitlements`
- **Hardened Runtime**: Aktiviert für Sicherheit

## UI Design

### Farbpalette (wie im Code)
```swift
// Primary Colors
Color.scDarkGreen = #1a3d3d
Color.scMediumGreen = #2d5555

// Secondary Colors
Color.scLightBeige = #e8dcc4
Color.scMediumBeige = #d4c5a9
```

### Design-Prinzipien:
1. **Minimalistisch** - Nur das Nötigste
2. **Clean** - Klare Hierarchie
3. **Modern** - Runde Ecken, subtile Schatten
4. **Funktional** - Tastatur-first
5. **Konsistent** - Einheitliche Farbpalette

### Komponenten:
- **Header**: Icon + Titel + Count Badge
- **Items**: Inline Rows mit Index Badge
- **Footer**: Keyboard Hints (⇥ ↩ H ⎋)
- **Empty State**: Minimalistisch mit Icon

## Build & Run

1. Xcode öffnen: `Cliply.xcodeproj`
2. App Icons hinzufügen (siehe oben)
3. Build: **⌘B**
4. Run: **⌘R**
5. Accessibility Permission gewähren

## Keyboard Shortcuts

- **⌘⇧C**: Copy & Save to History
- **⌘⇧V**: Show History Popup
- **Tab**: Navigate Items (loop)
- **Enter**: Paste Selected Item
- **H**: Expand/Collapse (3 ↔ 10 items)
- **Esc**: Close Popup

## Features

✅ Minimalistisches Dunkelgrün-Beige Design
✅ Clean UI - nur das Nötigste
✅ Tastatur-Navigation mit Loop
✅ Focus Management (Panel wird Key)
✅ Safari/Apps werden nach Paste reaktiviert
✅ Popup schließt nach jedem Paste
✅ Kein BOP-Sound
✅ Accessibility Permission Handling
