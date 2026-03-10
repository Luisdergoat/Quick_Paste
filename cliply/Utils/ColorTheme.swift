import SwiftUI

/// Cliply Color Theme - Dunkelgrün & Beige Palette
extension Color {
    // MARK: - Primary Colors (Dunkelgrün)
    static let scDarkGreen = Color(red: 0.102, green: 0.333, blue: 0.333) // #1a3d3d
    static let scMediumGreen = Color(red: 0.176, green: 0.333, blue: 0.333) // #2d5555
    
    // MARK: - Secondary Colors (Beige/Sand)
    static let scLightBeige = Color(red: 0.910, green: 0.863, blue: 0.769) // #e8dcc4
    static let scMediumBeige = Color(red: 0.831, green: 0.773, blue: 0.663) // #d4c5a9
    
    // MARK: - Semantic Colors
    static let scBackground = scDarkGreen
    static let scSurface = scMediumGreen
    static let scPrimary = scLightBeige
    static let scSecondary = scMediumBeige
    static let scAccent = scLightBeige
    
    // MARK: - UI Colors
    static let scCardBackground = Color.black.opacity(0.2)
    static let scBorder = scLightBeige.opacity(0.2)
    static let scSelectedItem = scLightBeige.opacity(0.15)
    static let scHover = scLightBeige.opacity(0.08)
}
