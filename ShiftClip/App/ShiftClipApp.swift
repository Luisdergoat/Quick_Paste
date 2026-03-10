import SwiftUI
import AppKit

/// Application entry point.
///
/// ShiftClip runs as a menu-bar-only app (no Dock icon) to stay out of the
/// way. On launch it:
/// 1. Verifies Accessibility permission (required for global hotkeys).
/// 2. Starts the ``HotkeyManager``.
/// 3. Installs a menu-bar status item with a Quit option.
@main
struct ShiftClipApp: App {

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

        // Start global hotkey monitoring.
        HotkeyManager.shared.start()

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
                accessibilityDescription: "ShiftClip"
            )
        }

        let menu = NSMenu()
        menu.addItem(withTitle: "ShiftClip", action: nil, keyEquivalent: "")
            .isEnabled = false

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
            withTitle: "Quit ShiftClip",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )

        statusItem?.menu = menu
    }

    // MARK: - Menu Actions

    @objc private func showHistoryFromMenu() {
        WindowManager.shared.showPopup()
    }

    @objc private func clearHistory() {
        ClipboardManager.shared.clearHistory()
    }

    // MARK: - Accessibility

    /// Prompts the user to grant Accessibility access if it has not yet been
    /// granted. Accessibility is required so ShiftClip can:
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
            "ShiftClip needs Accessibility access to intercept global " +
            "keyboard shortcuts.\n\n" +
            "Please grant access in System Settings → Privacy & Security → " +
            "Accessibility, then relaunch ShiftClip."
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
