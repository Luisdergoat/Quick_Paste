import SwiftUI
import AppKit

/// The main floating clipboard history popup shown on ⌘⇧V.
///
/// In its **compact** state it displays the 3 most-recent items.
/// The user can expand to the full 10-item history by pressing ↑ or
/// Shift+Tab while at the top of the list.
struct ClipboardPopup: View {

    // MARK: - Environment / Dependencies

    @ObservedObject private var clipboardManager = ClipboardManager.shared

    // MARK: - State

    /// Index of the currently highlighted item.
    @State private var selectedIndex: Int = 0

    /// Whether the expanded 10-item history is shown.
    @State private var isExpanded: Bool = false

    // MARK: - Callback

    /// Called when the popup should be dismissed (e.g. after a paste or Escape).
    let onDismiss: () -> Void

    // MARK: - Body

    var body: some View {
        ZStack {
            // Blurred background — mirrors the frosted-glass style used by
            // Spotlight, Raycast and other macOS panels.
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            if clipboardManager.history.isEmpty {
                emptyState
            } else if isExpanded {
                ExpandedHistoryView(
                    clipboardManager: clipboardManager,
                    selectedIndex: $selectedIndex,
                    onSelect: { item in
                        paste(item: item)
                    },
                    onCollapse: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                            isExpanded = false
                        }
                    }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                compactView
                    .transition(.opacity)
            }
        }
        .frame(width: 400)
        .frame(minHeight: 120)
        .fixedSize(horizontal: false, vertical: true)
        .shadow(color: .black.opacity(0.25), radius: 24, x: 0, y: 8)
        // Keyboard handling is centralised here via NSEvent monitors so that
        // Tab / Shift+Tab are reliably captured regardless of focus state.
        .background(
            KeyEventHandler(
                selectedIndex: $selectedIndex,
                isExpanded: $isExpanded,
                compactCount: clipboardManager.recentItems.count,
                totalCount: clipboardManager.history.count,
                onCommit: commitSelection,
                onDismiss: onDismiss,
                onExpandedCollapse: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        isExpanded = false
                    }
                }
            )
        )
    }

    // MARK: - Compact View

    private var compactView: some View {
        VStack(spacing: 0) {
            // Title bar
            HStack {
                Image(systemName: "doc.on.clipboard")
                    .foregroundColor(.accentColor)
                    .font(.system(size: 13, weight: .semibold))
                Text("ShiftClip")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
                Text("⌘⇧V")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(Color.secondary.opacity(0.1))
                    )
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)

            Divider()
                .padding(.horizontal, 14)

            // Clipboard items
            VStack(spacing: 2) {
                ForEach(Array(clipboardManager.recentItems.enumerated()),
                        id: \.element.id) { index, item in
                    ClipboardItemRow(
                        index: index + 1,
                        item: item,
                        isSelected: index == selectedIndex
                    )
                    .onTapGesture { paste(item: item) }
                }
            }
            .padding(.vertical, 6)

            Divider()
                .padding(.horizontal, 14)

            // Footer hint
            HStack(spacing: 16) {
                Label("Tab to navigate", systemImage: "arrow.up.arrow.down")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                Label("Return to paste", systemImage: "return")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                Spacer()
                Button(action: expandHistory) {
                    HStack(spacing: 4) {
                        Text("Show all")
                            .font(.system(size: 10, weight: .medium))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 9, weight: .medium))
                    }
                    .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 10)
            .padding(.top, 4)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "doc.on.clipboard")
                .font(.system(size: 28))
                .foregroundColor(.secondary)
            Text("No clipboard history yet")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)
            Text("Press ⌘⇧C to copy and save an item.")
                .font(.system(size: 11))
                .foregroundColor(.secondary.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(30)
    }

    // MARK: - Actions

    private func paste(item: ClipboardItem) {
        // Put the item on the system clipboard.
        ClipboardManager.shared.setSystemClipboard(to: item)

        // Dismiss the popup first, then simulate ⌘V so the paste goes to the
        // previously-active app (a small delay lets the panel close fully).
        onDismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            simulatePaste()
        }
    }

    private func commitSelection() {
        if isExpanded {
            let items = clipboardManager.history
            guard selectedIndex < items.count else { return }
            paste(item: items[selectedIndex])
        } else {
            let items = clipboardManager.recentItems
            guard selectedIndex < items.count else { return }
            paste(item: items[selectedIndex])
        }
    }

    private func expandHistory() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
            isExpanded = true
        }
    }

    // MARK: - Paste Simulation

    /// Posts a synthetic ⌘V event so the selected text is pasted into the
    /// frontmost application.
    private func simulatePaste() {
        let src = CGEventSource(stateID: .hidSystemState)
        let vKey = CGKeyCode(0x09) // kVK_ANSI_V

        if let keyDown = CGEvent(keyboardEventSource: src,
                                 virtualKey: vKey, keyDown: true) {
            keyDown.flags = .maskCommand
            keyDown.post(tap: .cghidEventTap)
        }
        if let keyUp = CGEvent(keyboardEventSource: src,
                               virtualKey: vKey, keyDown: false) {
            keyUp.flags = .maskCommand
            keyUp.post(tap: .cghidEventTap)
        }
    }
}

// MARK: - KeyEventHandler

/// An invisible SwiftUI view that installs a local NSEvent monitor to capture
/// keyboard navigation inside the popup (both compact and expanded modes).
private struct KeyEventHandler: NSViewRepresentable {

    @Binding var selectedIndex: Int
    @Binding var isExpanded: Bool
    let compactCount: Int
    let totalCount: Int
    let onCommit: () -> Void
    let onDismiss: () -> Void
    let onExpandedCollapse: () -> Void

    func makeNSView(context: Context) -> NSView {
        KeyCaptureView()
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        guard let view = nsView as? KeyCaptureView else { return }
        view.configure(
            selectedIndex: $selectedIndex,
            isExpanded: $isExpanded,
            compactCount: compactCount,
            totalCount: totalCount,
            onCommit: onCommit,
            onDismiss: onDismiss,
            onExpandedCollapse: onExpandedCollapse
        )
    }

    // MARK: -

    class KeyCaptureView: NSView {
        private var monitor: Any?
        private var selectedIndex: Binding<Int>?
        private var isExpanded: Binding<Bool>?
        private var compactCount: Int = 0
        private var totalCount: Int = 0
        private var onCommit: (() -> Void)?
        private var onDismiss: (() -> Void)?
        private var onExpandedCollapse: (() -> Void)?

        override var acceptsFirstResponder: Bool { true }

        func configure(
            selectedIndex: Binding<Int>,
            isExpanded: Binding<Bool>,
            compactCount: Int,
            totalCount: Int,
            onCommit: @escaping () -> Void,
            onDismiss: @escaping () -> Void,
            onExpandedCollapse: @escaping () -> Void
        ) {
            self.selectedIndex = selectedIndex
            self.isExpanded = isExpanded
            self.compactCount = compactCount
            self.totalCount = totalCount
            self.onCommit = onCommit
            self.onDismiss = onDismiss
            self.onExpandedCollapse = onExpandedCollapse

            if monitor == nil {
                monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
                    [weak self] event in
                    return self?.handleKey(event) ?? event
                }
            }
        }

        private func handleKey(_ event: NSEvent) -> NSEvent? {
            guard let selectedIndex, let isExpanded else { return event }
            // Only handle keys when this view's window is key.
            guard window?.isKeyWindow == true else { return event }

            let mods = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            let isShift = mods.contains(.shift)
            let expanded = isExpanded.wrappedValue
            let maxIndex = expanded ? max(totalCount - 1, 0)
                                    : max(compactCount - 1, 0)

            switch event.keyCode {
            case 48: // Tab
                if isShift {
                    if selectedIndex.wrappedValue == 0 {
                        if expanded {
                            onExpandedCollapse?()
                        } else {
                            // Shift+Tab at top of compact view → expand
                            withAnimation(.spring(response: 0.3,
                                                  dampingFraction: 0.75)) {
                                isExpanded.wrappedValue = true
                            }
                        }
                    } else {
                        selectedIndex.wrappedValue =
                            max(selectedIndex.wrappedValue - 1, 0)
                    }
                } else {
                    selectedIndex.wrappedValue =
                        min(selectedIndex.wrappedValue + 1, maxIndex)
                }
                return nil // consumed

            case 126: // ↑
                if selectedIndex.wrappedValue == 0 {
                    if expanded {
                        onExpandedCollapse?()
                    } else {
                        withAnimation(.spring(response: 0.3,
                                              dampingFraction: 0.75)) {
                            isExpanded.wrappedValue = true
                        }
                    }
                } else {
                    selectedIndex.wrappedValue =
                        max(selectedIndex.wrappedValue - 1, 0)
                }
                return nil

            case 125: // ↓
                selectedIndex.wrappedValue =
                    min(selectedIndex.wrappedValue + 1, maxIndex)
                return nil

            case 36: // Return
                onCommit?()
                return nil

            case 53: // Escape
                onDismiss?()
                return nil

            default:
                return event
            }
        }

        deinit {
            if let monitor {
                NSEvent.removeMonitor(monitor)
            }
        }
    }
}

// MARK: - VisualEffectView

/// Wraps `NSVisualEffectView` for use in SwiftUI.
struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
