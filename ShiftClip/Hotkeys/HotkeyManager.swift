import AppKit
import Carbon

/// Registers and handles global keyboard shortcuts.
///
/// ShiftClip intercepts two shortcuts:
///
/// - **⌘⇧C** — "history copy": simulates a standard ⌘C to copy the
///   selection, waits briefly for the clipboard to update, then stores the
///   result in ``ClipboardManager``.
///
/// - **⌘⇧V** — "history paste": shows the ``ClipboardPopup`` floating
///   panel.
///
/// Global event monitoring requires the Accessibility permission granted
/// in System Settings → Privacy & Security → Accessibility.
final class HotkeyManager {

    // MARK: - Singleton

    static let shared = HotkeyManager()

    // MARK: - Private State

    private var globalMonitor: Any?
    private var localMonitor: Any?

    // MARK: - Init / Deinit

    private init() {}

    deinit {
        stop()
    }

    // MARK: - Lifecycle

    /// Starts listening for global keyboard events. Call once on app launch.
    func start() {
        // Monitor events from other applications.
        globalMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: .keyDown
        ) { [weak self] event in
            self?.handle(event: event)
        }

        // Also monitor events from within ShiftClip itself (e.g. when the
        // popup window is key).
        localMonitor = NSEvent.addLocalMonitorForEvents(
            matching: .keyDown
        ) { [weak self] event in
            self?.handle(event: event)
            // Return the event so SwiftUI can also process it (keyboard nav).
            return event
        }
    }

    /// Stops listening for global keyboard events.
    func stop() {
        if let monitor = globalMonitor {
            NSEvent.removeMonitor(monitor)
            globalMonitor = nil
        }
        if let monitor = localMonitor {
            NSEvent.removeMonitor(monitor)
            localMonitor = nil
        }
    }

    // MARK: - Event Handling

    private func handle(event: NSEvent) {
        let mods = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        let shiftCmd: NSEvent.ModifierFlags = [.command, .shift]

        guard mods == shiftCmd else { return }

        switch event.keyCode {
        case kVK_ANSI_C:  // ⌘⇧C
            performHistoryCopy()
        case kVK_ANSI_V:  // ⌘⇧V
            showHistoryPopup()
        default:
            break
        }
    }

    // MARK: - Actions

    /// Simulates ⌘C to copy the current selection, then stores the result.
    private func performHistoryCopy() {
        // Simulate a standard copy so the selected text lands on the clipboard.
        simulateCopy()

        // Give the system a moment to process the copy event before reading.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            ClipboardManager.shared.captureCurrentClipboard()
        }
    }

    /// Shows the history popup panel on the main thread.
    private func showHistoryPopup() {
        DispatchQueue.main.async {
            WindowManager.shared.showPopup()
        }
    }

    // MARK: - Helpers

    /// Posts a synthetic ⌘C key-down/key-up pair using CGEvent so the
    /// frontmost application copies its selection to the clipboard.
    private func simulateCopy() {
        let src = CGEventSource(stateID: .hidSystemState)

        // Key-down for ⌘C
        if let keyDown = CGEvent(keyboardEventSource: src,
                                 virtualKey: CGKeyCode(kVK_ANSI_C),
                                 keyDown: true) {
            keyDown.flags = .maskCommand
            keyDown.post(tap: .cghidEventTap)
        }

        // Key-up for ⌘C
        if let keyUp = CGEvent(keyboardEventSource: src,
                               virtualKey: CGKeyCode(kVK_ANSI_C),
                               keyDown: false) {
            keyUp.flags = .maskCommand
            keyUp.post(tap: .cghidEventTap)
        }
    }
}
