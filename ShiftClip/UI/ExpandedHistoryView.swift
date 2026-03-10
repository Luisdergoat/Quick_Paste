import SwiftUI
import AppKit

/// Full scrollable history view showing up to 10 clipboard items.
///
/// Triggered from the compact popup by pressing ↑ or Shift+Tab at the
/// top of the list.
///
/// Keyboard navigation is handled centrally by `ClipboardPopup`'s
/// `KeyEventHandler` so that `NSEvent` monitors are used throughout —
/// this ensures reliable Tab / Shift+Tab capture that SwiftUI's own
/// `keyboardShortcut` modifier does not provide.
struct ExpandedHistoryView: View {

    // MARK: - Input

    @ObservedObject var clipboardManager: ClipboardManager
    @Binding var selectedIndex: Int

    /// Called when the user confirms a selection (Enter key or tap).
    let onSelect: (ClipboardItem) -> Void

    /// Called when the view should collapse back to the compact popup.
    let onCollapse: () -> Void

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // Header
            header

            Divider()
                .padding(.horizontal, 14)

            // Scrollable item list
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 2) {
                        ForEach(Array(clipboardManager.history.enumerated()),
                                id: \.element.id) { index, item in
                            ClipboardItemRow(
                                index: index + 1,
                                item: item,
                                isSelected: index == selectedIndex
                            )
                            .id(index)
                            .onTapGesture { onSelect(item) }
                        }
                    }
                    .padding(.vertical, 6)
                }
                .onChange(of: selectedIndex) { newIndex in
                    withAnimation(.easeInOut(duration: 0.15)) {
                        proxy.scrollTo(newIndex, anchor: .center)
                    }
                }
            }
        }
    }

    // MARK: - Sub-views

    private var header: some View {
        HStack {
            Image(systemName: "clock.arrow.circlepath")
                .foregroundColor(.accentColor)
                .font(.system(size: 13, weight: .semibold))
            Text("Clipboard History")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.primary)
            Spacer()
            Text("\(clipboardManager.history.count) items")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
            Button(action: onCollapse) {
                Image(systemName: "chevron.up")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}
