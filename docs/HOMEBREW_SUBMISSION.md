# How to Submit Cliply to Homebrew

This guide explains how to submit Cliply to the official Homebrew Cask repository.

## Option 1: Official Homebrew Cask (Recommended)

Once Cliply reaches a stable version with several users, you can submit it to the official Homebrew Cask repository.

### Prerequisites

- At least 50+ GitHub stars (recommended)
- Stable release with proper versioning
- Active maintenance and support
- Good documentation

### Steps to Submit

1. **Fork the homebrew-cask repository**

   Go to [homebrew/homebrew-cask](https://github.com/Homebrew/homebrew-cask) and fork it.

2. **Create the cask file**

   In your fork, create a file: `Casks/c/cliply.rb`

   ```ruby
   cask "cliply" do
     version "1.0.0"
     sha256 "SHA256_HASH_OF_DMG"

     url "https://github.com/luisdergoat/cliply/releases/download/v#{version}/Cliply.dmg"
     name "Cliply"
     desc "Curated clipboard manager that only saves what you intend to save"
     homepage "https://github.com/luisdergoat/cliply"

     livecheck do
       url :url
       strategy :github_latest
     end

     app "Cliply.app"

     zap trash: [
       "~/Library/Preferences/com.luisdergoat.cliply.plist",
       "~/Library/Application Support/Cliply",
       "~/Library/Caches/com.luisdergoat.cliply",
     ]
   end
   ```

3. **Get the SHA256 hash**

   ```bash
   shasum -a 256 Cliply.dmg
   ```

4. **Test the cask**

   ```bash
   brew install --cask --verbose ./Casks/c/cliply.rb
   brew audit --cask --strict cliply
   ```

5. **Create a Pull Request**

   - Commit your changes
   - Push to your fork
   - Create a PR to homebrew-cask
   - Title: `cliply 1.0.0 (new cask)`

6. **Wait for review**

   The Homebrew maintainers will review your submission. Address any feedback.

## Option 2: Personal Tap (Current Setup)

For now, users can install via your personal tap:

```bash
brew tap luisdergoat/cliply
brew install --cask cliply
```

### Maintaining Your Tap

The tap is just this GitHub repository! When you create a new release:

1. Update `Casks/cliply.rb` with the new version and SHA256
2. Commit and push
3. Users can update with:
   ```bash
   brew update
   brew upgrade --cask cliply
   ```

### Making Your Tap Public

1. Ensure the repository is public
2. Push the Casks folder to the root of your repo
3. Tell users to run:
   ```bash
   brew tap luisdergoat/cliply https://github.com/luisdergoat/cliply
   ```

## Testing Installation

Test your cask thoroughly before submitting:

```bash
# Install
brew install --cask cliply

# Test the app launches
open -a Cliply

# Uninstall
brew uninstall --cask cliply

# Test zap (removes all data)
brew uninstall --cask --zap cliply
```

## Homebrew Cask Guidelines

Make sure your cask follows all guidelines:

- [ ] Binary is signed with Developer ID
- [ ] DMG is notarized by Apple
- [ ] Version matches GitHub release tag
- [ ] SHA256 is correct
- [ ] App installs to /Applications
- [ ] No installation requires admin password
- [ ] Uninstall removes all traces (zap stanza)

## Notarizing Your App

For official Homebrew submission, your app must be notarized:

1. **Archive the app**

   In Xcode: Product → Archive

2. **Export for distribution**

   Select "Export" → "Developer ID"

3. **Notarize**

   ```bash
   xcrun notarytool submit Cliply.dmg \
     --apple-id "your@email.com" \
     --team-id "YOUR_TEAM_ID" \
     --password "APP_SPECIFIC_PASSWORD" \
     --wait
   ```

4. **Staple the notarization**

   ```bash
   xcrun stapler staple Cliply.dmg
   ```

## Useful Resources

- [Homebrew Cask Documentation](https://docs.brew.sh/Cask-Cookbook)
- [Homebrew Cask Style Guide](https://docs.brew.sh/Cask-Cookbook#stanza-order)
- [Apple Notarization Guide](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution)

## Common Issues

### "This app is damaged and can't be opened"

Your app needs to be signed and notarized. See notarization guide above.

### "Cask validation failed"

Run `brew audit --cask --strict cliply` to see specific issues.

### SHA256 mismatch

Regenerate the SHA256 after any changes to the DMG:
```bash
shasum -a 256 Cliply.dmg
```

---

**Need help?** Ask in [Homebrew Discussions](https://github.com/orgs/Homebrew/discussions) or open an issue!
