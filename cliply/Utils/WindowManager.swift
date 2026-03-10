import AppKit
import SwiftUI

/// Manages the lifetime and positioning of the Cliply floating popup.
///
/// The popup is a borderless, non-activating ``NSPanel`` that floats above
/// all other windows. It is shown when the user presses ⌘⇧V and dismissed
/// when the user pastes an item, presses Escape, or clicks outside.
final class WindowManager: NSObject, NSWindowDelegate {

    // MARK: - Singleton

    static let shared = WindowManager()

    // MARK: - Private State

    private var panel: NSPanel?
    private var previousApp: NSRunningApplication?
    private var settingsWindow: NSWindow?

    // MARK: - Init

    private override init() {
        super.init()
    }

    // MARK: - Public API

    /// Shows the clipboard history popup, creating it if necessary.
    func showPopup() {
        if let existing = panel, existing.isVisible {
            // Already visible — bring to front and return.
            existing.orderFront(nil)
            return
        }

        createAndShowPanel()
    }

    /// Hides and releases the popup panel.
    func hidePopup() {
        print("🚪 WindowManager: Hiding popup")
        
        // Order out first
        panel?.orderOut(nil)
        
        // Small delay to ensure view cleanup
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            self?.panel = nil
            print("✅ WindowManager: Panel released")
        }
    }
    
    /// Reactivates the previously active app (e.g. Safari) after paste
    func reactivatePreviousApp() {
        guard let app = previousApp else {
            print("⚠️ No previous app to reactivate")
            return
        }
        
        app.activate(options: [])
        print("🔄 Reactivated: \(app.localizedName ?? "unknown")")
    }
    
    /// Shows the settings window
    func showSettings() {
        print("🔧 WindowManager: showSettings() called")
        
        // Close existing window if present
        if let existing = settingsWindow {
            print("   Closing existing settings window")
            existing.close()
            settingsWindow = nil
        }
        
        // Always create a fresh window
        createSettingsWindow()
    }
    
    private func createSettingsWindow() {
        print("   Creating new settings window...")
        
        let settingsView = SettingsView()
        let hostingController = NSHostingController(rootView: settingsView)
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 580, height: 700),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        window.contentViewController = hostingController
        window.title = "Cliply Settings"
        window.titlebarAppearsTransparent = false
        window.titleVisibility = .visible
        window.backgroundColor = NSColor(red: 0.12, green: 0.16, blue: 0.14, alpha: 1.0)
        window.isOpaque = true
        window.center()
        window.isReleasedWhenClosed = false
        window.delegate = self
        
        // Store before showing
        self.settingsWindow = window
        
        // Show window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        print("✅ WindowManager: Settings window created and shown")
    }

    // MARK: - Panel Creation

    private func createAndShowPanel() {
        // Save the currently active app
        previousApp = NSWorkspace.shared.frontmostApplication
        print("💾 Saved previous app: \(previousApp?.localizedName ?? "unknown")")
        
        let popupView = ClipboardPopup {
            WindowManager.shared.hidePopup()
        }

        let hostingController = NSHostingController(rootView: popupView)

        // Use a fixed preferred size; the view itself will size naturally.
        let panelSize = NSSize(width: 420, height: 300)

        let newPanel = NSPanel(
            contentRect: NSRect(origin: .zero, size: panelSize),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        newPanel.contentViewController = hostingController
        newPanel.isFloatingPanel = true
        newPanel.level = .floating
        newPanel.backgroundColor = .clear
        newPanel.isOpaque = false
        newPanel.hasShadow = true
        newPanel.delegate = self
        
        // Panel appearance
        newPanel.titlebarAppearsTransparent = true
        newPanel.titleVisibility = .hidden
        newPanel.standardWindowButton(.closeButton)?.isHidden = true
        newPanel.standardWindowButton(.miniaturizeButton)?.isHidden = true
        newPanel.standardWindowButton(.zoomButton)?.isHidden = true
        
        // Panel behavior
        newPanel.hidesOnDeactivate = false
        newPanel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        newPanel.isMovableByWindowBackground = false

        // Position the panel centered on the screen that contains the cursor.
        positionPanel(newPanel)

        // CRITICAL: Make panel KEY window to receive keyboard events!
        newPanel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        print("🪟 WindowManager: Panel shown and KEY (empfängt Tastatur!)")
        
        self.panel = newPanel
    }

    // MARK: - Positioning

    private func positionPanel(_ panel: NSPanel) {
        // Determine screen based on current cursor position.
        let mouseLocation = NSEvent.mouseLocation
        let screen = NSScreen.screens.first {
            NSMouseInRect(mouseLocation, $0.frame, false)
        } ?? NSScreen.main ?? NSScreen.screens[0]

        let screenFrame = screen.visibleFrame
        let panelFrame = panel.frame

        let x = screenFrame.midX - panelFrame.width / 2
        let y = screenFrame.midY - panelFrame.height / 2 + screenFrame.height * 0.1

        panel.setFrameOrigin(NSPoint(x: x, y: y))
    }

    // MARK: - NSWindowDelegate

    func windowDidResignKey(_ notification: Notification) {
        // Only applies to popup panel, not settings window
        if let window = notification.object as? NSWindow, window == panel {
            print("⚠️ WindowManager: Panel resigned key (but not dismissing)")
        }
    }
    
    func windowWillClose(_ notification: Notification) {
        if let window = notification.object as? NSWindow {
            if window == settingsWindow {
                print("🚪 WindowManager: Settings window closing")
                settingsWindow = nil
            } else if window == panel {
                print("🚪 WindowManager: Panel closing")
                panel = nil
            }
        }
    }
}
