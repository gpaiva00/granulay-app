import SwiftUI

@main
struct GranulayApp: App {
    @StateObject private var menuBarManager = MenuBarManager()
    private let performanceOptimizer = PerformanceOptimizer.shared
    
    var body: some Scene {
        Settings {
            SettingsView()
                .environmentObject(menuBarManager)
        }
    }
}