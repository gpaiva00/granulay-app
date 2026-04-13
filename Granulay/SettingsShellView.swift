import SwiftUI

struct SettingsShellView<Content: View>: View {
    @ObservedObject var state: SettingsState
    let sections: [SettingsSection]
    let onSelect: (SettingsSection) -> Void
    let content: Content

    init(
        state: SettingsState,
        sections: [SettingsSection],
        onSelect: @escaping (SettingsSection) -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.state = state
        self.sections = sections
        self.onSelect = onSelect
        self.content = content()
    }

    var body: some View {
        ZStack {
            SettingsTheme.backgroundGradient
                .ignoresSafeArea()

            HSplitView {
                sidebar
                    .frame(width: SettingsLayoutMetrics.sidebarWidth)

                ScrollView {
                    content
                        .frame(maxWidth: SettingsLayoutMetrics.contentMaxWidth, alignment: .leading)
                        .padding(SettingsLayoutMetrics.pagePadding)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                }
            }
            .frame(minWidth: SettingsLayoutMetrics.windowMinWidth, minHeight: SettingsLayoutMetrics.windowMinHeight)
        }
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image("SettingsViewIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 34, height: 34)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Granulay")
                        .font(.title3.weight(.semibold))

                    Text(NSLocalizedString("settings.shell.subtitle", comment: "Settings shell subtitle"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            .padding(.bottom, 4)

            VStack(spacing: 4) {
                ForEach(sections) { section in
                    SettingsSidebarRow(section: section, isSelected: section == state.selectedSection) {
                        onSelect(section)
                    }
                }
            }

            Spacer(minLength: 18)

            Text("v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 18)
        .background(SettingsTheme.sidebarBackground)
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(SettingsTheme.subtleStroke)
                .frame(width: 1)
        }
    }
}
