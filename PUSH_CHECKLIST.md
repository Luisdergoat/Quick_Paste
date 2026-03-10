# ✅ GitHub Push Checklist

Bevor du das Projekt auf GitHub pushst, gehe diese Checkliste durch:

## 📝 Vorbereitung

### 1. GitHub Repository URLs aktualisieren

Suche und ersetze `luisdergoat` mit deinem GitHub-Username in:

- [ ] `README.md` (alle Links)
- [ ] `.github/FUNDING.yml`
- [ ] `Casks/cliply.rb`
- [ ] `docs/HOMEBREW_INSTALLATION.md`
- [ ] `docs/HOMEBREW_SUBMISSION.md`
- [ ] `docs/RELEASE_GUIDE.md`
- [ ] `CONTRIBUTING.md`
- [ ] `PROJECT_STRUCTURE.md`
- [ ] `SETUP_COMPLETE.md`

**Schnell-Befehl:**
```bash
cd /Users/lunsold/42/ShiftClip
find . -type f \( -name "*.md" -o -name "*.yml" -o -name "*.rb" \) \
  -not -path "*/\.*" \
  -exec sed -i '' 's/luisdergoat/DEIN_USERNAME/g' {} +
```

### 2. Buy Me a Coffee URL aktualisieren

Wenn deine URL anders ist, aktualisiere in:

- [ ] `.github/FUNDING.yml`
- [ ] `README.md`

**Deine URL:** `https://www.buymeacoffee.com/DEIN_USERNAME`

### 3. Bundle Identifier prüfen

Öffne `cliply/Resources/Info.plist` und prüfe:

```xml
<key>CFBundleIdentifier</key>
<string>com.DEINNAME.cliply</string>
```

Ändere `com.luisdergoat.cliply` falls nötig.

### 4. Code Signing Team einstellen

- [ ] Öffne `cliply.xcodeproj` in Xcode
- [ ] Wähle Target "Cliply"
- [ ] Signing & Capabilities → Team auswählen

## 🚀 GitHub Repository erstellen

### Option A: GitHub CLI (empfohlen)

```bash
cd /Users/lunsold/42/ShiftClip

# Repository erstellen
gh repo create cliply --public --source=. --remote=origin

# Pushen
git add .
git commit -m "Initial commit: Complete DockDoor-style setup"
git push -u origin main
```

### Option B: Manuell

1. Gehe zu https://github.com/new
2. Repository Name: `cliply`
3. Beschreibung: `A curated clipboard manager that only saves what you intend to save`
4. Public
5. **NICHT** "Initialize with README" anklicken
6. Create repository

Dann:
```bash
cd /Users/lunsold/42/ShiftClip

git init
git add .
git commit -m "Initial commit: Complete DockDoor-style setup"
git branch -M main
git remote add origin https://github.com/DEIN_USERNAME/cliply.git
git push -u origin main
```

## 📦 Ersten Release erstellen

### 1. App bauen und testen

```bash
# In Xcode öffnen
open cliply.xcodeproj

# Build (Cmd+B) und testen (Cmd+R)
```

### 2. DMG erstellen

```bash
./scripts/build_dmg.sh
```

### 3. Git Tag erstellen

```bash
git tag -a v1.0.0 -m "Initial release v1.0.0"
git push origin v1.0.0
```

### 4. GitHub Release erstellen

**Option A: Automatisch (GitHub Actions)**

Die DMG wird automatisch gebaut und hochgeladen!

1. Gehe zu: `https://github.com/DEIN_USERNAME/cliply/releases`
2. Du siehst automatisch den Release mit DMG

**Option B: Manuell**

1. Gehe zu: `https://github.com/DEIN_USERNAME/cliply/releases/new`
2. Tag: `v1.0.0` (auswählen)
3. Release title: `Cliply v1.0.0 - Initial Release`
4. Beschreibung aus `CHANGELOG.md` kopieren:

```markdown
## 🎉 Initial Release

### Features
- ✨ Curated clipboard history (⌘⇧C to save)
- ⚡ Quick access popup (⌘⇧V to view)
- ⌨️ Full keyboard navigation
- 📚 Expandable history (up to 10 items)
- 🎨 Native macOS design with frosted glass
- 🔒 Privacy-first (local storage only)

### Installation

Download the DMG below and drag Cliply to your Applications folder.

Or install via Homebrew:
\`\`\`bash
brew tap DEIN_USERNAME/cliply
brew install --cask cliply
\`\`\`
```

5. `Cliply.dmg` hochladen (drag & drop)
6. "Publish release" klicken

## 💰 Sponsoring aktivieren

### GitHub Sponsors

1. Gehe zu: `https://github.com/sponsors`
2. Klick "Join the waitlist" oder "Set up GitHub Sponsors"
3. Folge den Anweisungen

### Buy Me a Coffee

1. Gehe zu: `https://www.buymeacoffee.com`
2. Erstelle einen Account
3. Notiere deine URL (z.B. `https://www.buymeacoffee.com/DEINNAME`)
4. Update in `.github/FUNDING.yml`

### Sponsor Button prüfen

Nach dem Push sollte auf deiner GitHub-Repo-Seite ein **"♥️ Sponsor"** Button erscheinen!

## 📸 Screenshots hinzufügen

1. Starte Cliply und mache Screenshots:
   - Popup (⌘⇧V)
   - Expanded History
   - Menu Bar Icon
   - Settings

2. Speichere in `resources/screenshots/`:
   ```
   resources/screenshots/
   ├── popup.png
   ├── expanded.png
   ├── menubar.png
   └── settings.png
   ```

3. Füge in README.md ein:
   ```markdown
   ## 📸 Screenshots
   
   <div align="center">
   <img src="resources/screenshots/popup.png" alt="Cliply Popup" width="600">
   <img src="resources/screenshots/expanded.png" alt="Expanded History" width="600">
   </div>
   ```

4. Commit und push:
   ```bash
   git add resources/screenshots/
   git commit -m "Add screenshots"
   git push
   ```

## 🍺 Homebrew testen

Nach dem ersten Release:

```bash
# Tap hinzufügen
brew tap DEIN_USERNAME/cliply

# Installieren
brew install --cask cliply

# Testen
open -a Cliply

# Deinstallieren (zum Testen)
brew uninstall --cask cliply
```

## 🔒 Repository Settings

Gehe zu Repository Settings und aktiviere:

- [ ] **Issues** aktivieren
- [ ] **Discussions** aktivieren (optional)
- [ ] **Sponsorship** aktivieren
- [ ] **Allow squash merging** (für PRs)
- [ ] Branch protection für `main` einrichten (optional)

## 🌟 Promotion

Nach dem Push:

1. **Social Media**
   - [ ] Tweet über dein neues Projekt
   - [ ] Post auf Reddit (r/macapps, r/MacOS)
   - [ ] Share auf LinkedIn

2. **Communities**
   - [ ] Hacker News (Show HN)
   - [ ] Product Hunt (nach ein paar Features)
   - [ ] macOS Development Communities

3. **README Badge**
   - [ ] Füge Badges hinzu (bereits in README)
   - [ ] Share deine GitHub URL

## ✅ Final Checklist

Vor dem Push:

- [ ] Alle URLs aktualisiert (Username, Buy Me a Coffee)
- [ ] Bundle Identifier geprüft
- [ ] Code signing in Xcode konfiguriert
- [ ] App buildet ohne Fehler
- [ ] Icons sind alle vorhanden
- [ ] README reviewed
- [ ] LICENSE vorhanden
- [ ] .gitignore vorhanden

Nach dem Push:

- [ ] Repository auf GitHub sichtbar
- [ ] README zeigt korrekt an
- [ ] Sponsor Button erscheint
- [ ] Ersten Release erstellt
- [ ] DMG heruntergeladen und getestet
- [ ] Homebrew tap getestet
- [ ] Screenshots hinzugefügt

## 🎉 Fertig!

Wenn alles funktioniert:

1. ⭐ Stern dein eigenes Repo (warum nicht? 😄)
2. 📢 Share es mit der Welt
3. 🐛 Warte auf Issues und Feedback
4. 🔧 Verbessere basierend auf User-Feedback
5. 💖 Freue dich über deine ersten Sponsors!

---

**Viel Erfolg mit Cliply! 🚀**

Wenn du Fragen hast, schau in die Dokumentation oder die erstellten Guides in `docs/`.
