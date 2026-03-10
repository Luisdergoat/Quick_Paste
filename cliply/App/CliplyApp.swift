import SwiftUI
import AppKit

/// Application entry point.
///
/// Cliply runs as a menu-bar-only app (no Dock icon) to stay out of the
/// way. On launch it:
/// 1. Verifies Accessibility permission (required for global hotkeys).
/// 2. Starts the ``HotkeyManager``.
/// 3. Installs a menu-bar status item with a Quit option.
@main
struct CliplyApp: App {

@NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

var body: some Scene {
// No main window — the app lives entirely in the menu bar.
Settings { EmptyView() }
}
}

// MARK: - AppDelegate

final class AppDelegate: NSObject, NSApplicationDelegate {

private var statusItem: NSStatusItem?

func applicationDidFinishLaunching(_ notification: Notification) {
// Hide the Dock icon so the app feels like a background utility.
NSApp.setActivationPolicy(.accessory)

// Prompt for Accessibility access if not yet granted.
requestAccessibilityPermissionIfNeeded()

// Check if this is the first launch
let defaults = UserDefaults.standard
let hasLaunchedBefore = defaults.bool(forKey: "hasLaunchedBefore")

if !hasLaunchedBefore {
    // First launch: disable by default
    defaults.set(false, forKey: "cliplyEnabled")
    defaults.set(true, forKey: "hasLaunchedBefore")
    defaults.synchronize()
    
    // Show settings window to let user activate the app
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        WindowManager.shared.showSettings()
    }
} else {
    // Not first launch: check if enabled
    let isEnabled = defaults.bool(forKey: "cliplyEnabled")
    if isEnabled {
        // Start global hotkey monitoring only if enabled.
        HotkeyManager.shared.start()
    }
}

// Set up the menu-bar status item.
setupStatusItem()
}

// MARK: - Status Item

private func setupStatusItem() {
statusItem = NSStatusBar.system.statusItem(
    withLength: NSStatusItem.squareLength
)

if let button = statusItem?.button {
    button.image = NSImage(
        systemSymbolName: "doc.on.clipboard",
        accessibilityDescription: "Cliply"
    )
    // Send action on left click
    button.sendAction(on: [.leftMouseUp, .rightMouseUp])
    button.action = #selector(statusItemClicked(_:))
    button.target = self
}

let menu = NSMenu()
menu.addItem(withTitle: "Cliply", action: nil, keyEquivalent: "")
    .isEnabled = false

menu.addItem(.separator())

menu.addItem(
    withTitle: "Settings...",
    action: #selector(openSettings),
    keyEquivalent: ","
).target = self

menu.addItem(.separator())

menu.addItem(
    withTitle: "Show History  ⌘⇧V",
    action: #selector(showHistoryFromMenu),
    keyEquivalent: ""
).target = self

menu.addItem(
    withTitle: "Clear History",
    action: #selector(clearHistory),
    keyEquivalent: ""
).target = self

menu.addItem(.separator())

menu.addItem(
    withTitle: "Quit Cliply",
    action: #selector(NSApplication.terminate(_:)),
    keyEquivalent: "q"
)

statusItem?.menu = menu
}

// MARK: - Menu Actions

@objc private func statusItemClicked(_ sender: NSStatusBarButton) {
guard let event = NSApp.currentEvent else { return }

if event.type == .rightMouseUp {
    // Right click: show menu
    statusItem?.menu?.popUp(positioning: nil, at: NSPoint(x: 0, y: sender.bounds.height), in: sender)
} else {
    // Left click: open settings
    WindowManager.shared.showSettings()
}
}

@objc private func openSettings() {
WindowManager.shared.showSettings()
}

@objc private func showHistoryFromMenu() {
WindowManager.shared.showPopup()
}

@objc private func clearHistory() {
ClipboardManager.shared.clearHistory()
}

// MARK: - Accessibility

/// Prompts the user to grant Accessibility access if it has not yet been
/// granted. Accessibility is required so Cliply can:
/// - Listen for global keyboard shortcuts via ``NSEvent`` monitors.
/// - Post synthetic ⌘C / ⌘V events via ``CGEvent``.
private func requestAccessibilityPermissionIfNeeded() {
let options: NSDictionary = [
    kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true
]
let trusted = AXIsProcessTrustedWithOptions(options)
if !trusted {
    showAccessibilityAlert()
}
}

private func showAccessibilityAlert() {
let alert = NSAlert()
alert.messageText = "Accessibility Permission Required"
alert.informativeText =
    "Cliply needs Accessibility access to intercept global " +
    "keyboard shortcuts.\n\n" +
    "Please grant access in System Settings → Privacy & Security → " +
    "Accessibility, then relaunch Cliply."
alert.alertStyle = .warning
alert.addButton(withTitle: "Open System Settings")
alert.addButton(withTitle: "Later")

if alert.runModal() == .alertFirstButtonReturn {
    NSWorkspace.shared.open(
        URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
    )
}
}
}
