import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var menuBarManager: MenuBarManager
    @StateObject private var state = SettingsState()

    var body: some View {
        SettingsShellView(
            state: state,
            sections: SettingsSection.orderedVisibleSections,
            onSelect: { section in
                withAnimation(SettingsTheme.selectionTransition) {
                    state.selectedSection = section
                }
            }
        ) {
            Group {
                switch state.selectedSection {
                case .appearance:
                    AppearanceSettingsPanel(state: state)
                        .environmentObject(menuBarManager)
                        .transition(.opacity)
                case .behavior:
                    BehaviorSettingsPanel(state: state)
                        .environmentObject(menuBarManager)
                        .transition(.opacity)
                case .lofi:
                    LoFiSettingsPanel(state: state)
                        .transition(.opacity)
                }
            }
            .animation(SettingsTheme.sectionTransition, value: state.selectedSection)
        }
        .overlay {
            if state.globalLoading {
                SettingsLoadingOverlay(message: state.loadingMessageKey.localized)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: state.globalLoading)
    }
}

#Preview {
    SettingsView()
        .environmentObject(MenuBarManager())
}
