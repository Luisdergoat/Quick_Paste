import AppKit
import Carbon

/// Registers and handles global keyboard shortcuts using CGEvent Tap.
///
/// Cliply intercepts two shortcuts:
///
/// - **⌘⇧C** — "history copy": simulates a standard ⌘C to copy the
///   selection, waits briefly for the clipboard to update, then stores the
///   result in ``ClipboardManager``.
///
/// - **⌘⇧V** — "history paste": shows the ``ClipboardPopup`` floating
///   panel.
///
/// Uses CGEvent Tap to intercept events BEFORE the system processes them,
/// preventing the system beep sound when no default handler exists.
/// Requires Accessibility permission in System Settings → Privacy & Security → Accessibility.
final class HotkeyManager {

    // MARK: - Singleton

    static let shared = HotkeyManager()

    // MARK: - Private State

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?

    // MARK: - Init / Deinit

    private init() {}

    deinit {
        stop()
    }

    // MARK: - Lifecycle

    /// Starts listening for global keyboard events using CGEvent Tap.
    func start() {
        print("🎹 HotkeyManager: Starting CGEvent Tap monitoring...")
        
        // Stop any existing tap first
        stop()
        
        // Create event tap to intercept keyboard events
        let eventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.flagsChanged.rawValue)
        
        guard let eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
                return HotkeyManager.eventTapCallback(proxy: proxy, type: type, event: event, refcon: refcon)
            },
            userInfo: nil
        ) else {
            print("❌ HotkeyManager: Failed to create event tap - Accessibility permission required!")
            print("   Please grant Accessibility access in System Settings → Privacy & Security → Accessibility")
            return
        }
        
        // Create run loop source and add to current run loop
        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
        
        self.eventTap = eventTap
        self.runLoopSource = runLoopSource
        
        print("✅ HotkeyManager: CGEvent Tap active - no more beep!")
    }

    /// Starts listening for global keyboard events.
    func registerHotkeys() {
        start()
    }
    
    /// Stops listening for global keyboard events.
    func unregisterHotkeys() {
        stop()
    }
    
    /// Stops listening for global keyboard events.
    func stop() {
        if let eventTap = eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
            CFMachPortInvalidate(eventTap)
            self.eventTap = nil
        }
        
        if let runLoopSource = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            self.runLoopSource = nil
        }
        
        print("🛑 HotkeyManager: CGEvent Tap stopped")
    }

    // MARK: - Event Tap Callback

    private static func eventTapCallback(
        proxy: CGEventTapProxy,
        type: CGEventType,
        event: CGEvent,
        refcon: UnsafeMutableRawPointer?
    ) -> Unmanaged<CGEvent>? {
        
        // Handle tap disabled event
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            if let eventTap = shared.eventTap {
                CGEvent.tapEnable(tap: eventTap, enable: true)
                print("🔄 HotkeyManager: Re-enabled event tap")
            }
            return Unmanaged.passRetained(event)
        }
        
        // Only process key down events
        guard type == .keyDown else {
            return Unmanaged.passRetained(event)
        }
        
        // Get key code and flags
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        let flags = event.flags
        
        // Check for ⌘⇧ combination
        let hasCmd = flags.contains(.maskCommand)
        let hasShift = flags.contains(.maskShift)
        let hasOnlyRequiredModifiers = hasCmd && hasShift && 
            !flags.contains(.maskControl) && 
            !flags.contains(.maskAlternate)
        
        guard hasOnlyRequiredModifiers else {
            return Unmanaged.passRetained(event)
        }
        
        // Check for our specific key codes
        switch keyCode {
        case 8:  // C key
            print("⌨️ HotkeyManager: ⌘⇧C detected via CGEvent Tap")
            shared.performHistoryCopy()
            // Return nil to CONSUME the event and prevent beep!
            return nil
            
        case 9:  // V key
            print("⌨️ HotkeyManager: ⌘⇧V detected via CGEvent Tap")
            shared.showHistoryPopup()
            // Return nil to CONSUME the event and prevent beep!
            return nil
            
        default:
            break
        }
        
        // Pass through other events
        return Unmanaged.passRetained(event)
    }

    // MARK: - Actions

    /// Simulates ⌘C to copy the current selection, then stores the result.
    private func performHistoryCopy() {
        print("📋 HotkeyManager: Simulating ⌘C...")
        
        // Simulate a standard copy so the selected text lands on the clipboard.
        simulateCopy()

        // Give the system a moment to process the copy event before reading.
        // Increased to 200ms for better reliability in Safari and other apps.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            print("📋 HotkeyManager: Capturing clipboard...")
            ClipboardManager.shared.captureCurrentClipboard()
        }
    }

    /// Shows the history popup panel on the main thread.
    private func showHistoryPopup() {
        DispatchQueue.main.async {
            print("🪟 HotkeyManager: Showing history popup...")
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
        
        print("✅ HotkeyManager: ⌘C simulated")
    }
}
