# Homebrew Installation Guide

This guide explains how to install Cliply using Homebrew.

## Prerequisites

- macOS 13 Ventura or later
- [Homebrew](https://brew.sh) installed

## Installation Steps

### Step 1: Install Homebrew (if not already installed)

If you don't have Homebrew installed, run:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Step 2: Add the Cliply Tap

```bash
brew tap luisdergoat/cliply
```

This adds the Cliply repository to your Homebrew sources.

### Step 3: Install Cliply

```bash
brew install --cask cliply
```

Homebrew will:
1. Download the latest Cliply.dmg
2. Extract and install Cliply.app to your Applications folder
3. Set up necessary permissions

### Step 4: Launch Cliply

Launch Cliply from:
- **Spotlight**: Press `⌘Space` and type "Cliply"
- **Applications**: Open Finder → Applications → Cliply

### Step 5: Grant Permissions

On first launch, you'll need to grant accessibility permissions:

1. Cliply will prompt you to open System Settings
2. Go to **Privacy & Security** → **Accessibility**
3. Toggle **Cliply** on
4. Relaunch Cliply

## Updating Cliply

To update to the latest version:

```bash
brew update
brew upgrade --cask cliply
```

## Uninstalling Cliply

To completely remove Cliply:

```bash
brew uninstall --cask cliply
```

To also remove preferences and cache:

```bash
brew uninstall --cask --zap cliply
```

This will remove:
- `~/Library/Preferences/com.luisdergoat.cliply.plist`
- `~/Library/Application Support/Cliply`
- `~/Library/Caches/com.luisdergoat.cliply`

## Troubleshooting

### "cliply cannot be opened because the developer cannot be verified"

If you see this security warning:

1. Right-click on Cliply.app in Applications
2. Select "Open"
3. Click "Open" in the dialog

Or disable Gatekeeper temporarily:

```bash
sudo spctl --master-disable
```

(Re-enable after opening Cliply for the first time)

### Homebrew command not found

Make sure Homebrew is in your PATH:

```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### Accessibility permissions not working

1. Remove Cliply from Accessibility list in System Settings
2. Quit Cliply completely
3. Relaunch Cliply
4. Grant permissions again

## Alternative Installation Methods

If Homebrew doesn't work for you, try:

### Direct DMG Download

1. Download from [GitHub Releases](https://github.com/luisdergoat/cliply/releases/latest)
2. Open the DMG file
3. Drag Cliply.app to Applications

### Build from Source

See [README.md](../README.md#building-from-source) for instructions.

## Getting Help

- [Report Issues](https://github.com/luisdergoat/cliply/issues)
- [Read FAQ](https://github.com/luisdergoat/cliply/wiki)
- [Contributing Guide](../CONTRIBUTING.md)

---

**Happy clipping!** 📋✨
