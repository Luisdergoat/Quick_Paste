# Changelog

All notable changes to Cliply will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- Homebrew tap for easy installation
- Search functionality in clipboard history
- Pinning important items
- Custom themes and colors
- Export/import clipboard history

## [1.0.1 Beta] - 2026-03-10

### Changed
- App is now disabled by default on first launch
- Settings window opens automatically on first launch
- Clicking the menu bar icon now opens Settings (right-click for menu)
- Removed ⌘⇧S keyboard shortcut for Settings
- **Complete rewrite of HotkeyManager using CGEvent Tap** (prevents system beep!)

### Fixed
- **System beep sound eliminated!** Shortcuts now use CGEvent Tap to intercept events before the system
- Keyboard shortcuts (⌘⇧C and ⌘⇧V) properly consume events
- Events are now marked as "handled" by the system

### Technical
- Replaced NSEvent monitors with CGEvent Tap
- Events intercepted at `.headInsertEventTap` level
- `return nil` in callback consumes events completely
- Auto-reactivation of tap if disabled by system
- Improved Accessibility permission description

### Improved
- Better first-time user experience with guided setup
- Clear feedback when Accessibility permission is missing

## [1.0.0] - 2026-03-10

### Added
- Initial release of Cliply
- Curated clipboard history (⌘⇧C to save)
- Quick access popup (⌘⇧V to view)
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

[Unreleased]: https://github.com/luisdergoat/cliply/compare/v1.0.1-beta...HEAD
[1.0.1 Beta]: https://github.com/luisdergoat/cliply/releases/tag/v1.0.1-beta
[1.0.0]: https://github.com/luisdergoat/cliply/releases/tag/v1.0.0
