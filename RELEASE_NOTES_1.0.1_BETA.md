# Cliply v1.0.1 Beta - Release Notes

**Release Datum:** 10. März 2026  
**Status:** Beta (Early Access)

## 🎉 Was ist neu?

### Verbessertes Erststart-Erlebnis
- **App standardmäßig deaktiviert**: Bei der ersten Installation ist Cliply standardmäßig deaktiviert, sodass Sie die Kontrolle haben
- **Automatische Settings-Anzeige**: Beim ersten Start öffnet sich automatisch das Einstellungsfenster, damit Sie Cliply aktivieren können
- **Einfacher Zugriff**: Klicken Sie auf das Menüleisten-Icon, um jederzeit die Einstellungen zu öffnen (Rechtsklick für das Menü)

### Tastaturkürzel-Verbesserungen
- **⌘⇧S entfernt**: Der Settings-Shortcut wurde entfernt - klicken Sie stattdessen einfach auf das Icon in der Menüleiste
- **Kein Beep mehr!** 🎵: Die Shortcuts ⌘⇧C und ⌘⇧V verursachen jetzt kein nerviges System-Beep mehr
- **Saubere Event-Behandlung**: Tastatur-Events werden jetzt korrekt konsumiert

### Weitere Änderungen
- History bleibt bei maximal 10 Items (war bereits implementiert, wird jetzt betont)
- Bessere Code-Organisation und Wartbarkeit
- Aktualisierte Dokumentation

## 🐛 Bekannte Probleme (Beta)

Da dies eine Beta-Version ist, könnten noch kleinere Bugs auftreten:
- Melden Sie Probleme über GitHub Issues
- Feedback ist herzlich willkommen!

## 📦 Installation

### Via DMG (empfohlen)
1. Laden Sie `Cliply.dmg` herunter
2. Öffnen Sie die DMG-Datei
3. Ziehen Sie Cliply in den Applications-Ordner
4. Starten Sie Cliply aus dem Applications-Ordner
5. Bei erstem Start öffnen sich die Einstellungen - aktivieren Sie Cliply dort

### Aus dem Quellcode
```bash
git clone https://github.com/luisdergoat/cliply.git
cd cliply
open cliply.xcodeproj
```

## ⌨️ Tastaturkürzel

| Shortcut | Aktion |
|----------|--------|
| ⌘⇧C | Kopiert die Auswahl und speichert sie in der History |
| ⌘⇧V | Zeigt die Clipboard-History an |

## 🔄 Von v1.0.0 upgraden

Einfach die alte Version beenden und die neue installieren. Ihre Einstellungen bleiben erhalten.

## 💬 Feedback

Haben Sie Vorschläge oder Probleme gefunden?
- GitHub Issues: https://github.com/luisdergoat/cliply/issues
- GitHub: @Luisdergoat

## 📝 Vollständige Änderungsliste

Siehe [CHANGELOG.md](CHANGELOG.md) für alle Details.

---

**Danke, dass Sie Cliply testen!** 🙏
