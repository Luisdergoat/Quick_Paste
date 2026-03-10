# Changelog

All notable changes to Cliply will be documented in this file.

## [Unreleased]

### Planned
- Homebrew tap for easy installation
- Search functionality in clipboard history
- Pinning important items
- Custom themes and colors
- Export/import clipboard history

## [1.0.2 Beta] - 2026-03-11

### Added
- Auto-update checks from GitHub releases, including release-note display, DMG detection, download flow, and install instructions.
- Single-item removal in the popup with `R` for granular history cleanup.
- Dedicated auto-update section in Settings with progress feedback and latest-version status.
- Expanded popup footer guidance for `R` remove and `D` clear-all actions.

### Changed
- Recently pasted items now move to the top of the history using MRU ordering.
- Settings window layout was expanded and polished for the new update controls.
- Popup width increased to better fit history content and keyboard hints.
- History handling is now explicitly capped at 10 items with clearer FIFO behavior.

### Fixed
- Settings window creation and lifecycle handling so the window reliably opens and remains visible.
- Transparent or invalid settings-window rendering by using a standard titled window configuration.
- Selection index handling after item deletion in compact and expanded popup modes.
- Update-check UX with clearer no-update, download-failure, and install-follow-up messaging.

### Technical
- Added `UpdateManager.swift` for GitHub API integration and semantic version comparison.
- Added `removeItem(at:)` and `moveToFront(at:)` to `ClipboardManager`.
- Extended `ClipboardPopup` keyboard event handling with a dedicated delete-selected callback.
- Improved `WindowManager` ownership of settings and popup windows.

## [1.0.1 Beta] - 2026-03-10

### Changed
- App is now disabled by default on first launch
- Settings window opens automatically on first launch
- Clicking the menu bar icon now opens Settings (right-click for menu)
- Removed ⌘⇧S keyboard shortcut for Settings
- Complete rewrite of `HotkeyManager` using CGEvent Tap to prevent the system beep

### Fixed
- System beep sound eliminated for `⌘⇧C` and `⌘⇧V`
- Keyboard shortcuts now consume events before the system handles them
- Accessibility permission flow is clearer during first launch

### Technical
- Replaced NSEvent monitors with CGEvent Tap
- Intercepted events at `.headInsertEventTap`
- Added tap auto-reactivation when disabled by macOS

## [1.0.0] - 2026-03-10

### Added
- Initial release of Cliply
- Curated clipboard history (`⌘⇧C` to save)
- Quick access popup (`⌘⇧V` to view)
- Keyboard navigation (Tab, Arrow keys, Return)
- Expandable history (up to 10 items)
- Native macOS design with frosted glass
- Menu bar integration
- Dark mode support
- Privacy-first approach (local storage only)
- Accessibility permissions handling

### Features
- Only saves clipboard items when explicitly requested
- Lightweight and fast
- No network access
- No cloud sync
- Native SwiftUI interface
- Spring animations
- Auto-paste selected items

[Unreleased]: https://github.com/luisdergoat/cliply/compare/v1.0.2-beta...HEAD
[1.0.2 Beta]: https://github.com/luisdergoat/cliply/releases/tag/v1.0.2-beta
[1.0.1 Beta]: https://github.com/luisdergoat/cliply/releases/tag/v1.0.1-beta
[1.0.0]: https://github.com/luisdergoat/cliply/releases/tag/v1.0.0
