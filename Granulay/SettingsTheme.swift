import SwiftUI

struct SettingsLayoutMetrics {
    static let windowInitialWidth: CGFloat = 720
    static let windowInitialHeight: CGFloat = 660
    static let windowMinWidth: CGFloat = 680
    static let windowMinHeight: CGFloat = 560

    static let sidebarWidth: CGFloat = 230
    static let contentMaxWidth: CGFloat = 460
    static let pagePadding: CGFloat = 28
    static let sectionSpacing: CGFloat = 22
    static let cardPadding: CGFloat = 20
}

enum SettingsTheme {
    private static func dynamicColor(
        light: (CGFloat, CGFloat, CGFloat),
        dark: (CGFloat, CGFloat, CGFloat),
        alpha: CGFloat = 1
    ) -> Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            let match = appearance.bestMatch(from: [.darkAqua, .vibrantDark])
            let rgb = (match == .darkAqua || match == .vibrantDark) ? dark : light
            return NSColor(calibratedRed: rgb.0, green: rgb.1, blue: rgb.2, alpha: alpha)
        })
    }

    static let backgroundGradient = LinearGradient(
        colors: [
            dynamicColor(light: (0.95, 0.97, 0.99), dark: (0.08, 0.09, 0.12)),
            dynamicColor(light: (0.91, 0.94, 0.97), dark: (0.05, 0.06, 0.09)),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let sidebarBackground = dynamicColor(light: (0.98, 0.99, 1.0), dark: (0.09, 0.10, 0.13), alpha: 0.92)
    static let primarySurface = dynamicColor(light: (0.99, 1.0, 1.0), dark: (0.13, 0.14, 0.18), alpha: 0.84)
    static let secondarySurface = dynamicColor(light: (0.94, 0.96, 0.99), dark: (0.16, 0.18, 0.22), alpha: 0.68)
    static let elevatedStroke = Color.primary.opacity(0.08)
    static let subtleStroke = Color.primary.opacity(0.06)
    static let selectedFill = Color.accentColor.opacity(0.18)
    static let mutedText = Color.secondary
    static let success = Color.green
    static let danger = Color.red
    static let shadow = Color.black.opacity(0.12)

    static let sectionTransition = Animation.easeInOut(duration: 0.2)
    static let selectionTransition = Animation.easeInOut(duration: 0.18)
    static let hoverTransition = Animation.easeInOut(duration: 0.12)
}
