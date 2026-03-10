# Release Guide

This guide explains how to create a new release of Cliply.

## Prerequisites

- Push access to the repository
- Xcode installed
- All tests passing
- CHANGELOG.md updated

## Release Process

### 1. Update Version Numbers

Update the version in the following files:

**Info.plist** (`cliply/Resources/Info.plist`):
```xml
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
<key>CFBundleVersion</key>
<string>1</string>
```

**Homebrew Cask** (`Casks/cliply.rb`):
```ruby
version "1.0.0"
```

### 2. Update CHANGELOG.md

Move items from `[Unreleased]` to a new version section:

```markdown
## [1.0.0] - 2026-03-10

### Added
- New feature X
- New feature Y

### Fixed
- Bug fix Z
```

### 3. Commit Changes

```bash
git add .
git commit -m "Release v1.0.0"
git push origin main
```

### 4. Create a Git Tag

```bash
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

### 5. Create GitHub Release

#### Option A: Automatic (GitHub Actions)

When you push a tag, GitHub Actions will automatically:
1. Build the app
2. Create a DMG
3. Upload it to the release

#### Option B: Manual

1. Go to [GitHub Releases](https://github.com/luisdergoat/cliply/releases)
2. Click "Draft a new release"
3. Select the tag you just created
4. Fill in release notes (copy from CHANGELOG.md)
5. Build the DMG manually:

```bash
./scripts/build_dmg.sh
```

6. Upload `Cliply.dmg` to the release
7. Click "Publish release"

### 6. Update Homebrew Cask (if needed)

If the download URL changed, update the Homebrew cask:

```ruby
cask "cliply" do
  version "1.0.0"
  sha256 "YOUR_SHA256_HERE"
  
  url "https://github.com/luisdergoat/cliply/releases/download/v#{version}/Cliply.dmg"
  # ...
end
```

Get the SHA256:
```bash
shasum -a 256 Cliply.dmg
```

### 7. Test the Release

Test the installation:

```bash
# Download and test DMG
curl -L -O https://github.com/luisdergoat/cliply/releases/latest/download/Cliply.dmg
open Cliply.dmg

# Test Homebrew (if available)
brew uninstall --cask cliply
brew install --cask cliply
```

### 8. Announce the Release

Share on:
- GitHub Discussions
- Twitter/X
- Reddit (r/macapps, r/MacOS)
- Product Hunt (for major releases)

## Release Checklist

- [ ] Version numbers updated in all files
- [ ] CHANGELOG.md updated
- [ ] All tests passing
- [ ] Code builds without warnings
- [ ] Git tag created and pushed
- [ ] GitHub release created with DMG
- [ ] Homebrew cask updated (if needed)
- [ ] Installation tested
- [ ] Release announced

## Versioning Guidelines

We follow [Semantic Versioning](https://semver.org/):

- **Major** (1.0.0 → 2.0.0): Breaking changes
- **Minor** (1.0.0 → 1.1.0): New features (backwards compatible)
- **Patch** (1.0.0 → 1.0.1): Bug fixes

## Hotfix Process

For urgent bug fixes:

1. Create a hotfix branch from the latest release tag:
   ```bash
   git checkout -b hotfix/1.0.1 v1.0.0
   ```

2. Make the fix and update version to 1.0.1

3. Create a new release following the normal process

4. Merge the hotfix back into main:
   ```bash
   git checkout main
   git merge hotfix/1.0.1
   git push origin main
   ```

## Beta Releases

For testing before stable release:

1. Create a pre-release tag:
   ```bash
   git tag -a v1.1.0-beta.1 -m "Beta release v1.1.0-beta.1"
   git push origin v1.1.0-beta.1
   ```

2. Create a GitHub release marked as "Pre-release"

3. Share with beta testers only

## Rolling Back a Release

If a release has critical issues:

1. Delete the GitHub release
2. Delete the tag:
   ```bash
   git tag -d v1.0.0
   git push origin :refs/tags/v1.0.0
   ```
3. Fix the issues
4. Create a new patch release (1.0.1)

## Troubleshooting

### GitHub Actions fails

Check:
- Xcode version in workflow
- Code signing certificates
- Build settings

### DMG creation fails

- Ensure all files are committed
- Check disk space
- Verify Xcode command line tools installed

### Homebrew cask fails

- Verify URL is accessible
- Check SHA256 hash matches
- Test with `brew install --cask --verbose cliply`

---

**Need help?** Open an issue on GitHub!
