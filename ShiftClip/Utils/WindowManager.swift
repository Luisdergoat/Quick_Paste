import AppKit
import SwiftUI

/// Manages the lifetime and positioning of the ShiftClip floating popup.
///
/// The popup is a borderless, non-activating ``NSPanel`` that floats above
/// all other windows. It is shown when the user presses ⌘⇧V and dismissed
/// when the user pastes an item, presses Escape, or clicks outside.
final class WindowManager: NSObject, NSWindowDelegate {

    // MARK: - Singleton

    static let shared = WindowManager()

    // MARK: - Private State

    private var panel: NSPanel?

    // MARK: - Init

    private override init() {
        super.init()
    }

    // MARK: - Public API

    /// Shows the clipboard history popup, creating it if necessary.
    func showPopup() {
        if let existing = panel, existing.isVisible {
            // Already visible — bring to front and return.
            existing.makeKeyAndOrderFront(nil)
            return
        }

        createAndShowPanel()
    }

    /// Hides and releases the popup panel.
    func hidePopup() {
        panel?.orderOut(nil)
        panel = nil
    }

    // MARK: - Panel Creation

    private func createAndShowPanel() {
        let popupView = ClipboardPopup {
            WindowManager.shared.hidePopup()
        }

        let hostingController = NSHostingController(rootView: popupView)

        // Use a fixed preferred size; the view itself will size naturally.
        let panelSize = NSSize(width: 400, height: 280)

        let newPanel = NSPanel(
            contentRect: NSRect(origin: .zero, size: panelSize),
            styleMask: [.borderless, .nonactivatingPanel],
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

        // Position the panel centered on the screen that contains the cursor.
        positionPanel(newPanel)

        newPanel.makeKeyAndOrderFront(nil)
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
        // Dismiss the popup when it loses focus.
        hidePopup()
    }
}
