import SwiftUI

@main
struct GranulayApp: App {
    @StateObject private var menuBarManager = MenuBarManager()
    
    var body: some Scene {
        Settings {
            SettingsView()
                .environmentObject(menuBarManager)
        }
    }
}