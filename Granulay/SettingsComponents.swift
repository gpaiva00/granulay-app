import SwiftUI

struct SettingsSectionHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.title2.weight(.semibold))

            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(SettingsTheme.mutedText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct SettingsCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(SettingsLayoutMetrics.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(SettingsTheme.primarySurface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(SettingsTheme.elevatedStroke, lineWidth: 1)
            )
            .shadow(color: SettingsTheme.shadow, radius: 10, x: 0, y: 8)
    }
}

struct SettingsSidebarRow: View {
    let section: SettingsSection
    let isSelected: Bool
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: section.icon)
                    .frame(width: 16, height: 16)
                    .foregroundColor(section.isLockedInTrial ? .secondary : (isSelected ? .accentColor : .secondary))

                Text(section.localizedName)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(section.isLockedInTrial ? .secondary : .primary)

                if section.showsUpgradeHint {
                    SettingsBadge(
                        title: NSLocalizedString("settings.badge.trial", comment: "Trial badge title"),
                        icon: section.isLockedInTrial ? "lock.fill" : "sparkles"
                    )
                }

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isSelected ? SettingsTheme.selectedFill : (isHovered ? SettingsTheme.secondarySurface : Color.clear))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(isSelected ? Color.accentColor.opacity(0.35) : (isHovered ? SettingsTheme.subtleStroke : Color.clear), lineWidth: 1)
            )
            .scaleEffect(isHovered ? 1.01 : 1.0)
        }
        .buttonStyle(.plain)
        .focusable(true)
        .onHover { hovering in
            withAnimation(SettingsTheme.hoverTransition) {
                isHovered = hovering
            }
        }
        .accessibilityLabel(section.localizedName)
        .accessibilityHint(section.isLockedInTrial ? NSLocalizedString("settings.trial.upgrade_hint", comment: "Trial upsell hint") : "")
    }
}

struct SettingsBadge: View {
    let title: String
    let icon: String

    var body: some View {
        Label(title, systemImage: icon)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(SettingsTheme.secondarySurface)
            )
            .overlay(
                Capsule().stroke(SettingsTheme.subtleStroke, lineWidth: 1)
            )
            .foregroundColor(.secondary)
            .fixedSize()
    }
}

struct SettingsToggleRow<Accessory: View>: View {
    let title: String
    let subtitle: String?
    let accessory: Accessory

    init(title: String, subtitle: String? = nil, @ViewBuilder accessory: () -> Accessory) {
        self.title = title
        self.subtitle = subtitle
        self.accessory = accessory()
    }

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.medium))

                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(SettingsTheme.mutedText)
                }
            }

            Spacer(minLength: 12)
            accessory
        }
    }
}

struct SettingsChipButtonStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .padding(.vertical, 7)
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isSelected ? Color.accentColor : SettingsTheme.secondarySurface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(isSelected ? Color.accentColor.opacity(0.35) : SettingsTheme.subtleStroke, lineWidth: 1)
            )
            .foregroundColor(isSelected ? .white : .primary)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
    }
}

struct SettingsPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.accentColor.opacity(0.92), Color.accentColor.opacity(0.72)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .foregroundColor(.white)
            .shadow(color: Color.accentColor.opacity(0.25), radius: 8, x: 0, y: 4)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
    }
}

struct SettingsLoadingOverlay: View {
    let message: String

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                ProgressView()
                    .scaleEffect(1.15)

                Text(message)
                    .font(.subheadline)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(SettingsTheme.primarySurface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(SettingsTheme.elevatedStroke, lineWidth: 1)
            )
        }
    }
}
