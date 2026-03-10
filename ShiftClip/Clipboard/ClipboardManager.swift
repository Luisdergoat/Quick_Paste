import AppKit
import Combine

/// Manages the curated clipboard history.
///
/// Items are added only when the user explicitly invokes the history-copy
/// shortcut (⌘⇧C). Normal ⌘C is never stored. The history keeps a maximum
/// of 10 items, newest first.
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

    // MARK: - Init

    private init() {}

    // MARK: - Public API

    /// Reads the current system clipboard text and stores it at the front of
    /// the history if it is non-empty and not a duplicate of the most-recent
    /// entry. Also replaces the system clipboard with the same string so the
    /// item is ready to paste immediately.
    func captureCurrentClipboard() {
        guard let text = NSPasteboard.general.string(forType: .string),
              !text.isEmpty else { return }

        // Avoid consecutive duplicate entries.
        if let latest = history.first, latest.text == text { return }

        let item = ClipboardItem(text: text)
        history.insert(item, at: 0)

        // Trim to maximum allowed history size.
        if history.count > maxHistory {
            history = Array(history.prefix(maxHistory))
        }
    }

    /// Places the given clipboard item onto the system clipboard so the user
    /// can paste it with the standard ⌘V shortcut.
    func setSystemClipboard(to item: ClipboardItem) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(item.text, forType: .string)
    }

    /// Removes all items from the history.
    func clearHistory() {
        history.removeAll()
    }
}
