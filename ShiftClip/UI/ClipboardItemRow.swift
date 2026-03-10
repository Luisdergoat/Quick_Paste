import SwiftUI
import AppKit

/// A single row displayed inside the clipboard history popup.
///
/// Shows a 1-based index badge and a truncated text preview. The row
/// highlights when it is the currently selected item.
struct ClipboardItemRow: View {

    // MARK: - Input

    let index: Int
    let item: ClipboardItem
    let isSelected: Bool

    // MARK: - Body

    var body: some View {
        HStack(spacing: 10) {
            // Index badge
            Text("\(index)")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(isSelected ? .white : .secondary)
                .frame(width: 22, height: 22)
                .background(
                    Circle()
                        .fill(isSelected
                              ? Color.accentColor
                              : Color.secondary.opacity(0.15))
                )

            // Item text preview
            Text(item.preview)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(isSelected ? .primary : .primary.opacity(0.85))
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: 0)

            // Timestamp
            Text(item.timestamp, style: .relative)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(isSelected
                      ? Color.accentColor.opacity(0.12)
                      : Color.clear)
        )
        .contentShape(Rectangle())
    }
}
