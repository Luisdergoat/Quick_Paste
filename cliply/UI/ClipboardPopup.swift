import SwiftUI
import AppKit
import Carbon

/// The main floating clipboard history popup shown on ⌘⇧V.
///
/// Minimalistisches Design mit Dunkelgrün-Beige Farbpalette.
/// Zeigt 3 Items, 'H' erweitert auf 10.
struct ClipboardPopup: View {

    // MARK: - Environment / Dependencies

    @ObservedObject private var clipboardManager = ClipboardManager.shared

    // MARK: - State

    @State private var selectedIndex: Int = 0
    @State private var isExpanded: Bool = false

    // MARK: - Callback

    let onDismiss: () -> Void

    // MARK: - Body

    var body: some View {
        ZStack {
            // Hintergrund: Dunkelgrün
            Color.scDarkGreen
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            if clipboardManager.history.isEmpty {
                emptyState
            } else {
                mainContent
            }
        }
        .frame(width: 480)
        .frame(height: isExpanded ? 520 : 280)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.scBorder, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.4), radius: 30, x: 0, y: 15)
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        .background(
            KeyEventHandler(
                selectedIndex: $selectedIndex,
                isExpanded: $isExpanded,
                compactCount: min(clipboardManager.history.count, 3),
                totalCount: clipboardManager.history.count,
                onCommit: commitSelection,
                onDismiss: {
                    WindowManager.shared.reactivatePreviousApp()
                    onDismiss()
                },
                onExpand: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isExpanded = true
                    }
                },
                onDeleteSelected: deleteSelectedItem
            )
        )
    }

    // MARK: - Main Content

    private var mainContent: some View {
        VStack(spacing: 0) {
            // Header
            headerView
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 12)

            // Divider
            Rectangle()
                .fill(Color.scBorder)
                .frame(height: 1)
                .padding(.horizontal, 20)

            // Items
            ScrollView {
                VStack(spacing: 6) {
                    let items = isExpanded ? clipboardManager.history : Array(clipboardManager.history.prefix(3))
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                        itemRow(index: index, item: item)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }

            // Divider
            Rectangle()
                .fill(Color.scBorder)
                .frame(height: 1)
                .padding(.horizontal, 20)

            // Footer
            footerView
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 14)
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack(spacing: 10) {
            // Icon
            Circle()
                .fill(Color.scLightBeige.opacity(0.15))
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: "doc.on.clipboard")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.scLightBeige)
                )
            
            // Title
            Text("Cliply")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.scLightBeige)
            
            Spacer()
            
            // Count indicator
            Text("\(isExpanded ? clipboardManager.history.count : min(clipboardManager.history.count, 3))")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.scDarkGreen)
                .frame(minWidth: 24, minHeight: 24)
                .background(
                    Circle()
                        .fill(Color.scMediumBeige)
                )
        }
    }

    // MARK: - Item Row

    private func itemRow(index: Int, item: ClipboardItem) -> some View {
        let isSelected = index == selectedIndex
        
        return HStack(spacing: 12) {
            // Index badge
            Text("\(index + 1)")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(isSelected ? .scDarkGreen : .scMediumBeige)
                .frame(width: 28, height: 28)
                .background(
                    Circle()
                        .fill(isSelected ? Color.scLightBeige : Color.scCardBackground)
                )
            
            // Text preview
            Text(item.preview)
                .font(.system(size: 13, weight: isSelected ? .medium : .regular))
                .foregroundColor(.scLightBeige)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Selection indicator
            if isSelected {
                Circle()
                    .fill(Color.scMediumBeige)
                    .frame(width: 6, height: 6)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(isSelected ? Color.scSelectedItem : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(
                    isSelected ? Color.scBorder : Color.clear,
                    lineWidth: 1
                )
        )
    }

    // MARK: - Footer

    private var footerView: some View {
        HStack(spacing: 16) {
            // Keyboard hints
            HStack(spacing: 12) {
                keyHint(key: "⇥", label: "Next")
                keyHint(key: "↩", label: "Paste")
                keyHint(key: "H", label: isExpanded ? "Less" : "More")
                keyHint(key: "R", label: "Remove")
                keyHint(key: "D", label: "Clear All")
                keyHint(key: "⎋", label: "Close")
            }
            
            Spacer()
        }
    }

    private func keyHint(key: String, label: String) -> some View {
        HStack(spacing: 4) {
            Text(key)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(.scDarkGreen)
                .frame(minWidth: 18, minHeight: 18)
                .background(
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(Color.scMediumBeige)
                )
            
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.scSecondary)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Circle()
                .fill(Color.scCardBackground)
                .frame(width: 64, height: 64)
                .overlay(
                    Image(systemName: "doc.on.clipboard")
                        .font(.system(size: 28, weight: .light))
                        .foregroundColor(.scSecondary)
                )
            
            Text("No History")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.scLightBeige)
            
            Text("Press ⌘⇧C to copy and save")
                .font(.system(size: 11))
                .foregroundColor(.scSecondary)
        }
        .padding(40)
    }

    // MARK: - Actions

    private func paste(item: ClipboardItem) {
        print("📋 Pasting item: \(item.text.prefix(30))...")
        
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(item.text, forType: .string)
        
        WindowManager.shared.reactivatePreviousApp()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let src = CGEventSource(stateID: .hidSystemState)
            
            if let keyDown = CGEvent(keyboardEventSource: src,
                                     virtualKey: CGKeyCode(kVK_ANSI_V),
                                     keyDown: true) {
                keyDown.flags = .maskCommand
                keyDown.post(tap: .cghidEventTap)
            }
            
            if let keyUp = CGEvent(keyboardEventSource: src,
                                   virtualKey: CGKeyCode(kVK_ANSI_V),
                                   keyDown: false) {
                keyUp.flags = .maskCommand
                keyUp.post(tap: .cghidEventTap)
            }
            
            print("✅ Pasted to previous app")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            print("🚪 Closing popup after paste")
            onDismiss()
        }
    }

    private func commitSelection() {
        let items = isExpanded ? clipboardManager.history : Array(clipboardManager.history.prefix(3))
        guard selectedIndex < items.count else { return }
        
        // Move selected item to front (most recently used)
        ClipboardManager.shared.moveToFront(at: selectedIndex)
        
        paste(item: items[selectedIndex])
    }
    
    private func deleteSelectedItem() {
        let items = isExpanded ? clipboardManager.history : Array(clipboardManager.history.prefix(3))
        guard selectedIndex < items.count else { return }
        
        print("🗑️ Deleting selected item at index \(selectedIndex)")
        ClipboardManager.shared.removeItem(at: selectedIndex)
        
        // Adjust selection if needed
        let maxIndex = isExpanded ? max(clipboardManager.history.count - 1, 0) : max(min(clipboardManager.history.count, 3) - 1, 0)
        if selectedIndex > maxIndex {
            selectedIndex = max(maxIndex, 0)
        }
        
        // Close popup if no items left
        if clipboardManager.history.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onDismiss()
            }
        }
    }
}

// MARK: - KeyHint

private struct KeyHint: View {
    let symbol: String
    let label: String
    
    var body: some View {
        HStack(spacing: 6) {
            Text(symbol)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)
                .frame(minWidth: 24)
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color.secondary.opacity(0.08))
                )
            
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary.opacity(0.8))
        }
    }
}

// MARK: - KeyEventHandler

/// Captures keyboard events using Carbon Hotkeys (official system shortcuts - NO BOP!)
private struct KeyEventHandler: NSViewRepresentable {

    @Binding var selectedIndex: Int
    @Binding var isExpanded: Bool
    let compactCount: Int
    let totalCount: Int
    let onCommit: () -> Void
    let onDismiss: () -> Void
    let onExpand: () -> Void
    let onDeleteSelected: () -> Void

    func makeNSView(context: Context) -> KeyCaptureView {
        let view = KeyCaptureView()
        view.configure(
            selectedIndex: $selectedIndex,
            isExpanded: $isExpanded,
            compactCount: compactCount,
            totalCount: totalCount,
            onCommit: onCommit,
            onDismiss: onDismiss,
            onExpand: onExpand,
            onDeleteSelected: onDeleteSelected
        )
        return view
    }

    func updateNSView(_ nsView: KeyCaptureView, context: Context) {
        nsView.configure(
            selectedIndex: $selectedIndex,
            isExpanded: $isExpanded,
            compactCount: compactCount,
            totalCount: totalCount,
            onCommit: onCommit,
            onDismiss: onDismiss,
            onExpand: onExpand,
            onDeleteSelected: onDeleteSelected
        )
    }

    // MARK: -

    class KeyCaptureView: NSView {
        private var localMonitor: Any?
        private var selectedIndex: Binding<Int>?
        private var isExpanded: Binding<Bool>?
        private var compactCount: Int = 0
        private var totalCount: Int = 0
        private var onCommit: (() -> Void)?
        private var onDismiss: (() -> Void)?
        private var onExpand: (() -> Void)?
        private var onDeleteSelected: (() -> Void)?
        private var isActive: Bool = false

        override var acceptsFirstResponder: Bool { true }

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            
            if window != nil {
                installMonitor()
                // CRITICAL: Become first responder to ensure we get events
                DispatchQueue.main.async { [weak self] in
                    self?.window?.makeFirstResponder(self)
                    print("🎯 KeyCaptureView: First responder set")
                }
            } else {
                removeMonitor()
            }
        }

        func configure(
            selectedIndex: Binding<Int>,
            isExpanded: Binding<Bool>,
            compactCount: Int,
            totalCount: Int,
            onCommit: @escaping () -> Void,
            onDismiss: @escaping () -> Void,
            onExpand: @escaping () -> Void,
            onDeleteSelected: @escaping () -> Void
        ) {
            self.selectedIndex = selectedIndex
            self.isExpanded = isExpanded
            self.compactCount = compactCount
            self.totalCount = totalCount
            self.onCommit = onCommit
            self.onDismiss = onDismiss
            self.onExpand = onExpand
            self.onDeleteSelected = onDeleteSelected
            
            // Reinstall if already active (for updates)
            if isActive {
                removeMonitor()
                installMonitor()
            }
        }
        
        private func installMonitor() {
            guard !isActive, localMonitor == nil else { return }
            
            // LOCAL monitor mit korrektem Event-Consumption
            localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
                [weak self] event -> NSEvent? in
                guard let self = self else { return event }
                
                // Check window is visible
                guard let window = self.window, window.isVisible else {
                    return event
                }
                
                // Handle and consume our keys
                return self.handleKeyEvent(event)
            }
            
            isActive = true
            print("✅ KeyCaptureView: Local Monitor installed")
        }
        
        private func removeMonitor() {
            guard isActive, let monitor = localMonitor else { return }
            
            NSEvent.removeMonitor(monitor)
            localMonitor = nil
            isActive = false
            print("🧹 KeyCaptureView: Monitor removed")
        }

        // Override keyDown to handle events directly
        override func keyDown(with event: NSEvent) {
            print("🔑 keyDown called: \(event.keyCode)")
            
            guard let selectedIndex, let isExpanded else {
                super.keyDown(with: event)
                return
            }
            
            let expanded = isExpanded.wrappedValue
            let maxIndex = expanded ? max(totalCount - 1, 0) : max(compactCount - 1, 0)

            switch Int(event.keyCode) {
            case 48: // Tab
                let current = selectedIndex.wrappedValue
                if current >= maxIndex {
                    selectedIndex.wrappedValue = 0
                    print("🔄 Loop → 0")
                } else {
                    selectedIndex.wrappedValue = current + 1
                    print("⬇️ Tab → \(selectedIndex.wrappedValue)")
                }
                // Event consumed - don't call super

            case 36: // Return/Enter
                print("↩️ Enter - committing")
                DispatchQueue.main.async { [weak self] in
                    self?.onCommit?()
                }
                // Event consumed - don't call super

            case 53: // Escape
                print("⎋ Esc - dismissing")
                removeMonitor()
                // CRITICAL: Reactivate previous app before dismissing!
                WindowManager.shared.reactivatePreviousApp()
                DispatchQueue.main.async { [weak self] in
                    self?.onDismiss?()
                }
                // Event consumed - don't call super
                
            case 4: // H key
                print("🔄 H - toggle expand")
                if expanded {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        isExpanded.wrappedValue = false
                        selectedIndex.wrappedValue = 0
                    }
                } else {
                    onExpand?()
                }
                // Event consumed - don't call super
                
            case 2: // D key - Delete History
                print("🗑️ D - delete history")
                ClipboardManager.shared.clearHistory()
                // Event consumed - don't call super
                
            case 15: // R key - Remove selected item
                print("🗑️ R - remove selected item")
                DispatchQueue.main.async { [weak self] in
                    self?.onDeleteSelected?()
                }
                // Event consumed - don't call super

            default:
                // Andere Tasten an System weitergeben
                super.keyDown(with: event)
            }
        }

        private func handleKeyEvent(_ event: NSEvent) -> NSEvent? {
            guard let selectedIndex, let isExpanded else { return event }
            
            guard let window = window, window.isVisible else { return event }
            
            let expanded = isExpanded.wrappedValue
            let maxIndex = expanded ? max(totalCount - 1, 0) : max(compactCount - 1, 0)

            print("⌨️ Monitor Key: \(event.keyCode)")

            switch Int(event.keyCode) {
            case 48: // Tab
                let current = selectedIndex.wrappedValue
                if current >= maxIndex {
                    selectedIndex.wrappedValue = 0
                    print("🔄 Loop → 0")
                } else {
                    selectedIndex.wrappedValue = current + 1
                    print("⬇️ Tab → \(selectedIndex.wrappedValue)")
                }
                return nil // CONSUMED

            case 36: // Return/Enter
                print("↩️ Enter - committing")
                DispatchQueue.main.async { [weak self] in
                    self?.onCommit?()
                }
                return nil // CONSUMED

            case 53: // Escape
                print("⎋ Esc - dismissing")
                removeMonitor()
                // CRITICAL: Reactivate previous app (Safari) before dismissing!
                WindowManager.shared.reactivatePreviousApp()
                DispatchQueue.main.async { [weak self] in
                    self?.onDismiss?()
                }
                return nil // CONSUMED
                
            case 4: // H key
                print("🔄 H - toggle expand")
                if expanded {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        isExpanded.wrappedValue = false
                        selectedIndex.wrappedValue = 0
                    }
                } else {
                    onExpand?()
                }
                return nil // CONSUMED
                
            case 2: // D key - Delete History
                print("🗑️ D - delete history")
                ClipboardManager.shared.clearHistory()
                return nil // CONSUMED
                
            case 15: // R key - Remove selected item
                print("🗑️ R - remove selected item")
                DispatchQueue.main.async { [weak self] in
                    self?.onDeleteSelected?()
                }
                return nil // CONSUMED

            default:
                // Andere Tasten durchlassen
                return event
            }
        }

        deinit {
            removeMonitor()
            print("💀 KeyCaptureView: deinitialized")
        }
    }
}

// MARK: - VisualEffectView

/// Wraps `NSVisualEffectView` for Apple Liquid Glass effect
struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        view.wantsLayer = true
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
