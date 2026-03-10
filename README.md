<div align="center">

# ShiftClip

**A curated clipboard history manager for macOS.**

ShiftClip only saves what you *intend* to save — copy with ⌘⇧C to store an item, ⌘⇧V to retrieve it.

![macOS 13+](https://img.shields.io/badge/macOS-13%2B-blue?style=flat-square)
![Swift 5.9](https://img.shields.io/badge/Swift-5.9-orange?style=flat-square)
![SwiftUI](https://img.shields.io/badge/SwiftUI-✓-green?style=flat-square)
![License: MIT](https://img.shields.io/badge/License-MIT-lightgrey?style=flat-square)

</div>

---

## Overview

Most clipboard managers record everything you copy. ShiftClip takes a different approach: it only stores clipboard entries when you **intentionally** invoke ⌘⇧C. Normal ⌘C works exactly as before — no surprises, no accidental history pollution.

The result is a focused, curated history of the things you actually meant to save.

---

## Features

- **Curated history** — stores items only on ⌘⇧C, not on every ⌘C
- **Compact popup** — ⌘⇧V shows the 3 most-recent items in a floating panel
- **Keyboard navigation** — Tab / Shift+Tab / ↑ / ↓ to move, Return to paste
- **Expanded history** — press ↑ or Shift+Tab at the top to reveal all 10 items
- **Instant paste** — selecting an item places it on the clipboard and simulates ⌘V
- **Menu bar only** — no Dock icon, stays out of your way
- **Native macOS look** — frosted-glass background, smooth spring animations, rounded corners

---

## Keyboard Shortcuts

| Shortcut | Action |
|---|---|
| ⌘C | Normal copy — **not** stored in history |
| **⌘⇧C** | History copy — copies selection **and** saves to history |
| ⌘V | Normal paste |
| **⌘⇧V** | Show clipboard history popup |
| Tab | Move selection down in popup |
| Shift+Tab | Move selection up (or expand history at top) |
| ↑ / ↓ | Navigate items (↑ at top expands history) |
| Return | Paste selected item |
| Escape | Dismiss popup |

---

## Screenshots

> *Screenshots will be added once the app is running on macOS.*

| Compact popup (⌘⇧V) | Expanded history |
|---|---|
| *(screenshot)* | *(screenshot)* |

---

## Requirements

- macOS 13 Ventura or later
- Xcode 15 or later
- **Accessibility permission** (required for global keyboard shortcuts)

---

## Installation

### Build from Source

1. **Clone the repository**

   ```bash
   git clone https://github.com/Luisdergoat/Quick_Paste.git ShiftClip
   cd ShiftClip
   ```

2. **Open in Xcode**

   ```bash
   open ShiftClip.xcodeproj
   ```

3. **Select your signing team**

   In Xcode → ShiftClip target → Signing & Capabilities, select your personal team.

4. **Build & Run**

   Press ⌘R. ShiftClip will appear in your menu bar as a clipboard icon.

5. **Grant Accessibility permission**

   On first launch, ShiftClip will prompt you to open System Settings → Privacy & Security → Accessibility. Add ShiftClip to the allowed list and relaunch.

---

## Architecture

```
ShiftClip/
│
├── App/
│   └── ShiftClipApp.swift        # @main entry point, AppDelegate, menu bar item
│
├── Clipboard/
│   └── ClipboardManager.swift    # History storage, max-10 ring buffer, NSPasteboard API
│
├── Hotkeys/
│   └── HotkeyManager.swift       # Global NSEvent monitors for ⌘⇧C / ⌘⇧V
│
├── UI/
│   ├── ClipboardPopup.swift       # Root floating panel view + KeyEventHandler
│   ├── ClipboardItemRow.swift     # Individual history row (index badge + preview)
│   └── ExpandedHistoryView.swift  # Full scrollable 10-item history
│
├── Models/
│   └── ClipboardItem.swift        # Value type: id, text, timestamp, preview
│
├── Utils/
│   └── WindowManager.swift        # NSPanel lifecycle + screen positioning
│
└── Resources/
    ├── Info.plist                  # Bundle metadata, LSUIElement = true
    └── ShiftClip.entitlements      # Hardened runtime entitlements
```

### Key design decisions

- **`LSUIElement = true`** hides the Dock icon; the app lives in the menu bar.
- **`NSPanel` with `.nonactivatingPanel`** keeps the popup from stealing focus from the active app, so ⌘V pastes into the correct window.
- **Simulated ⌘C on ⌘⇧C** — ShiftClip posts a CGEvent ⌘C to the frontmost app, waits 150 ms for the clipboard to update, then reads and stores the result.
- **ObservableObject + @Published** — `ClipboardManager` drives the SwiftUI popup reactively; no polling needed.

---

## How It Works

```
User presses ⌘⇧C
       │
       ▼
HotkeyManager detects event
       │
       ▼
Simulates ⌘C via CGEvent → frontmost app copies selection
       │
  150 ms delay
       │
       ▼
ClipboardManager reads NSPasteboard.general
       │
       ▼
Prepends ClipboardItem to history array (max 10)

─────────────────────────────────────────

User presses ⌘⇧V
       │
       ▼
HotkeyManager calls WindowManager.showPopup()
       │
       ▼
NSPanel with ClipboardPopup view is shown
       │
User navigates with Tab / ↑↓ and presses Return
       │
       ▼
ClipboardManager.setSystemClipboard(to: item)
       │
       ▼
Panel closes → CGEvent ⌘V posted to frontmost app
```

---

## Contributing

Pull requests are welcome. For major changes please open an issue first to discuss what you would like to change.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Commit your changes (`git commit -m 'Add your feature'`)
4. Push to the branch (`git push origin feature/your-feature`)
5. Open a Pull Request

---

## License

This project is licensed under the **MIT License**.

```
MIT License

Copyright (c) 2024 ShiftClip Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

<div align="center">
Made with ♥ for macOS
</div>