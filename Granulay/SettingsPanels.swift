import Foundation
import SwiftUI

/// `AppearanceSettingsPanel` provides controls for configuring the visual output of the grain.
/// It reads from and writes to `MenuBarManager` state, including toggling the effect,
/// adjusting normal and matte intensities, and enabling/disabling animation.
struct AppearanceSettingsPanel: View {
    @EnvironmentObject var menuBarManager: MenuBarManager
    @ObservedObject var state: SettingsState

    var body: some View {
        VStack(alignment: .leading, spacing: SettingsLayoutMetrics.sectionSpacing) {
            SettingsSectionHeader(
                title: LocalizationKeys.Settings.Appearance.title.localized,
                subtitle: LocalizationKeys.Settings.Appearance.description.localized
            )

            Text(LocalizationKeys.Settings.Appearance.grainTitle.localized)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.secondary)

            SettingsCard {
                VStack(alignment: .leading, spacing: 16) {
                    SettingsToggleRow(
                        title: LocalizationKeys.Settings.enableEffect.localized
                    ) {
                        Toggle("", isOn: Binding(
                            get: { menuBarManager.isGrainEnabled },
                            set: { newValue in
                                applyChange {
                                    menuBarManager.isGrainEnabled = newValue
                                }
                            }
                        ))
                        .toggleStyle(.switch)
                        .labelsHidden()
                        .disabled(state.globalLoading)
                        .accessibilityLabel(LocalizationKeys.Settings.enableEffect.localized)
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 10) {
                        Text(LocalizationKeys.Settings.intensity.localized)
                            .font(.subheadline.weight(.medium))

                        intensityPresetButtons(
                            currentValue: menuBarManager.grainIntensity,
                            isEnabled: menuBarManager.isGrainEnabled
                        ) { value in
                            menuBarManager.grainIntensity = value
                        }
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 10) {
                        Text(LocalizationKeys.Settings.Appearance.motionTitle.localized)
                            .font(.subheadline.weight(.medium))

                        HStack(spacing: 10) {
                            Button(LocalizationKeys.Settings.Appearance.motionMoving.localized) {
                                applyChange { menuBarManager.isGrainAnimated = true }
                            }
                            .buttonStyle(SettingsChipButtonStyle(isSelected: menuBarManager.isGrainAnimated))
                            .disabled(!menuBarManager.isGrainEnabled || state.globalLoading)

                            Button(LocalizationKeys.Settings.Appearance.motionStatic.localized) {
                                applyChange { menuBarManager.isGrainAnimated = false }
                            }
                            .buttonStyle(SettingsChipButtonStyle(isSelected: !menuBarManager.isGrainAnimated))
                            .disabled(!menuBarManager.isGrainEnabled || state.globalLoading)
                        }
                        .opacity(menuBarManager.isGrainEnabled ? 1 : 0.55)
                    }

                    Divider()

                    SettingsToggleRow(
                        title: LocalizationKeys.Settings.preserveBrightness.localized,
                        subtitle: LocalizationKeys.Settings.preserveBrightnessDescription.localized
                    ) {
                        Toggle("", isOn: Binding(
                            get: { menuBarManager.preserveBrightness },
                            set: { newValue in
                                applyChange { menuBarManager.preserveBrightness = newValue }
                            }
                        ))
                        .toggleStyle(.switch)
                        .labelsHidden()
                        .disabled(!menuBarManager.isGrainEnabled || state.globalLoading)
                    }
                }
            }

            Text(LocalizationKeys.Settings.Appearance.matteTitle.localized)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.secondary)

            SettingsCard {
                VStack(alignment: .leading, spacing: 16) {
                    SettingsToggleRow(
                        title: LocalizationKeys.Settings.Appearance.matteMode.localized,
                        subtitle: LocalizationKeys.Settings.Appearance.matteModeDescription.localized
                    ) {
                        Toggle("", isOn: Binding(
                            get: { menuBarManager.isMatteModeEnabled },
                            set: { newValue in
                                applyChange { menuBarManager.isMatteModeEnabled = newValue }
                            }
                        ))
                        .toggleStyle(.switch)
                        .labelsHidden()
                        .disabled(state.globalLoading)
                        .accessibilityLabel(LocalizationKeys.Settings.Appearance.matteMode.localized)
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 10) {
                        Text(LocalizationKeys.Settings.intensity.localized)
                            .font(.subheadline.weight(.medium))

                        intensityPresetButtons(
                            currentValue: menuBarManager.matteIntensity,
                            isEnabled: menuBarManager.isMatteModeEnabled
                        ) { value in
                            menuBarManager.matteIntensity = value
                        }
                    }
                }
            }
        }
        .transition(.opacity)
    }

    @ViewBuilder
    private func intensityPresetButtons(
        currentValue: Double,
        isEnabled: Bool,
        onSelect: @escaping (Double) -> Void
    ) -> some View {
        HStack(spacing: 10) {
            ForEach(IntensityPreset.allCases, id: \.self) { preset in
                Button(preset.title) {
                    applyChange { onSelect(preset.value) }
                }
                .buttonStyle(SettingsChipButtonStyle(isSelected: preset.isSelected(for: currentValue)))
                .disabled(!isEnabled)
            }
        }
        .opacity(isEnabled ? 1 : 0.55)
    }

    private func applyChange(_ action: @escaping () -> Void) {
        SettingsActionRunner.perform(
            isLoading: $state.globalLoading,
            loadingMessageKey: $state.loadingMessageKey,
            messageKey: LocalizationKeys.Loading.applyingChanges,
            action: action
        )
    }
}

private enum IntensityPreset: CaseIterable {
    case weak
    case medium
    case strong

    var title: String {
        switch self {
        case .weak:
            return LocalizationKeys.Settings.Intensity.weak.localized
        case .medium:
            return LocalizationKeys.Settings.Intensity.medium.localized
        case .strong:
            return LocalizationKeys.Settings.Intensity.strong.localized
        }
    }

    var value: Double {
        switch self {
        case .weak:
            return 0.1
        case .medium:
            return 0.2
        case .strong:
            return 0.45
        }
    }

    func isSelected(for intensity: Double) -> Bool {
        switch self {
        case .weak:
            return intensity <= 0.15
        case .medium:
            return intensity > 0.15 && intensity <= 0.3
        case .strong:
            return intensity > 0.3
        }
    }
}

/// `BehaviorSettingsPanel` allows the user to configure app-wide behaviors, such as
/// whether the application icon appears in the macOS Dock, and provides a way to
/// reset all preferences to their default states.
struct BehaviorSettingsPanel: View {
    @EnvironmentObject var menuBarManager: MenuBarManager
    @ObservedObject var state: SettingsState

    var body: some View {
        VStack(alignment: .leading, spacing: SettingsLayoutMetrics.sectionSpacing) {
            SettingsSectionHeader(
                title: LocalizationKeys.Settings.Behavior.title.localized,
                subtitle: LocalizationKeys.Settings.Behavior.description.localized
            )

            SettingsCard {
                VStack(alignment: .leading, spacing: 16) {
                    SettingsToggleRow(
                        title: LocalizationKeys.Settings.showInDock.localized,
                        subtitle: LocalizationKeys.Settings.showInDockDescription.localized
                    ) {
                        Toggle("", isOn: Binding(
                            get: { menuBarManager.showInDock },
                            set: { newValue in
                                applyChange { menuBarManager.showInDock = newValue }
                            }
                        ))
                        .toggleStyle(.switch)
                        .labelsHidden()
                        .disabled(state.globalLoading)
                        .accessibilityLabel(LocalizationKeys.Settings.showInDock.localized)
                    }
                }
            }

            SettingsCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text(LocalizationKeys.Settings.Behavior.resetTitle.localized)
                        .font(.subheadline.weight(.semibold))

                    Text(LocalizationKeys.Settings.Behavior.resetDescription.localized)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Button(LocalizationKeys.Settings.reset.localized) {
                        applyChange { menuBarManager.resetToDefaults() }
                    }
                    .buttonStyle(.bordered)
                    .disabled(state.globalLoading)
                }
            }
        }
    }

    private func applyChange(_ action: @escaping () -> Void) {
        SettingsActionRunner.perform(
            isLoading: $state.globalLoading,
            loadingMessageKey: $state.loadingMessageKey,
            messageKey: LocalizationKeys.Loading.applyingChanges,
            action: action
        )
    }
}

struct LoFiSettingsPanel: View {
    @ObservedObject var state: SettingsState

    var body: some View {
        VStack(alignment: .leading, spacing: SettingsLayoutMetrics.sectionSpacing) {
            SettingsSectionHeader(
                title: LocalizationKeys.Settings.LoFiSection.title.localized,
                subtitle: LocalizationKeys.Settings.LoFiSection.description.localized
            )

            SettingsCard {
                LoFiControlsView(isLoading: $state.globalLoading)
            }
        }
    }
}
