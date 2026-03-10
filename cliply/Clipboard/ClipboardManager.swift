import AppKit
import Combine
import Carbon

/// Manages the curated clipboard history with improved capture and polling.
///
/// Items are added when the user explicitly invokes the history-copy
/// shortcut (⌘⇧C). Uses NSPasteboard.changeCount polling to detect changes.
/// The history keeps a maximum of 10 items, newest first.
final class ClipboardManager: ObservableObject {

    // MARK: - Singleton

    static let shared = ClipboardManager()

    // MARK: - Published State

    /// Full history (max 10), newest item at index 0.
    @Published private(set) var history: [ClipboardItem] = []

    /// The three most-recent items shown in the compact popup.
    var recentItems: [ClipboardItem] {
        Array(history.prefix(3))
    }

    // MARK: - Constants

    private let maxHistory = 10
    
    // MARK: - Private State
    
    private var lastChangeCount: Int = 0
    private var pollingTimer: Timer?

    // MARK: - Init

    private init() {
        lastChangeCount = NSPasteboard.general.changeCount
        startPolling()
    }

    // MARK: - Polling

    /// Starts polling the clipboard for changes (for better capture reliability).
    private func startPolling() {
        pollingTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            self?.checkClipboardChange()
        }
    }

    private func checkClipboardChange() {
        let currentCount = NSPasteboard.general.changeCount
        if currentCount != lastChangeCount {
            lastChangeCount = currentCount
            // Clipboard changed - this helps detect external changes
        }
    }

    // MARK: - Public API
    
    /// Start monitoring clipboard changes
    func startMonitoring() {
        guard pollingTimer == nil else { return }
        startPolling()
        print("✅ ClipboardManager: Monitoring started")
    }
    
    /// Stop monitoring clipboard changes
    func stopMonitoring() {
        pollingTimer?.invalidate()
        pollingTimer = nil
        print("🛑 ClipboardManager: Monitoring stopped")
    }
    
    /// Clear entire clipboard history
    func clearHistory() {
        history.removeAll()
        print("🗑️ ClipboardManager: History cleared")
    }

    /// Manually capture the current clipboard content and add to history if new.
    /// the history if it is non-empty and not a duplicate of the most-recent
    /// entry. Called after ⌘⇧C is pressed.
    func captureCurrentClipboard() {
        // Small delay to ensure clipboard is updated
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            
            let pasteboard = NSPasteboard.general
            self.lastChangeCount = pasteboard.changeCount
            
            guard let text = pasteboard.string(forType: .string),
                  !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                print("❌ ClipboardManager: No valid text on clipboard")
                return
            }

            // Avoid consecutive duplicate entries
            if let latest = self.history.first, latest.text == text {
                print("⚠️ ClipboardManager: Duplicate entry, skipping")
                return
            }

            let item = ClipboardItem(text: text)
            self.history.insert(item, at: 0)
            
            print("✅ ClipboardManager: Captured '\(text.prefix(30))...' (total items: \(self.history.count))")

            // Trim to maximum allowed history size
            if self.history.count > self.maxHistory {
                self.history = Array(self.history.prefix(self.maxHistory))
            }
        }
    }

    /// Places the given clipboard item onto the system clipboard and simulates paste.
    func pasteItem(_ item: ClipboardItem) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(item.text, forType: .string)
        lastChangeCount = NSPasteboard.general.changeCount
        
        print("✅ ClipboardManager: Set clipboard to '\(item.text.prefix(30))...'")
        
        // Simulate ⌘V paste
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.simulatePaste()
        }
    }

    /// Simulates ⌘V keyboard event to paste.
    private func simulatePaste() {
        let src = CGEventSource(stateID: .hidSystemState)
        
        // Key-down for ⌘V
        if let keyDown = CGEvent(keyboardEventSource: src,
                                 virtualKey: CGKeyCode(kVK_ANSI_V),
                                 keyDown: true) {
            keyDown.flags = .maskCommand
            keyDown.post(tap: .cghidEventTap)
        }
        
        // Key-up for ⌘V
        if let keyUp = CGEvent(keyboardEventSource: src,
                               virtualKey: CGKeyCode(kVK_ANSI_V),
                               keyDown: false) {
            keyUp.flags = .maskCommand
            keyUp.post(tap: .cghidEventTap)
        }
        
        print("✅ ClipboardManager: Simulated ⌘V paste")
    }
}
