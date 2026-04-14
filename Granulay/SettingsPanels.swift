import Foundation
import SwiftUI

struct AppearanceSettingsPanel: View {
    @EnvironmentObject var menuBarManager: MenuBarManager
    @ObservedObject var state: SettingsState

    var body: some View {
        VStack(alignment: .leading, spacing: SettingsLayoutMetrics.sectionSpacing) {
            SettingsSectionHeader(
                title: LocalizationKeys.Settings.Appearance.title.localized,
                subtitle: LocalizationKeys.Settings.Appearance.description.localized
            )

            GrainPreviewCard()
                .environmentObject(menuBarManager)

            SettingsCard {
                VStack(alignment: .leading, spacing: 16) {
                    SettingsToggleRow(
                        title: LocalizationKeys.Settings.enableEffect.localized,
                        subtitle: NSLocalizedString("settings.preview.description", comment: "Preview subtitle")
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

                        HStack(spacing: 10) {
                            Button(LocalizationKeys.Settings.Intensity.weak.localized) {
                                applyChange { menuBarManager.grainIntensity = 0.1 }
                            }
                            .buttonStyle(SettingsChipButtonStyle(isSelected: menuBarManager.grainIntensity <= 0.15))
                            .disabled(!menuBarManager.isGrainEnabled)

                            Button(LocalizationKeys.Settings.Intensity.medium.localized) {
                                applyChange { menuBarManager.grainIntensity = 0.2 }
                            }
                            .buttonStyle(SettingsChipButtonStyle(isSelected: menuBarManager.grainIntensity > 0.15 && menuBarManager.grainIntensity <= 0.25))
                            .disabled(!menuBarManager.isGrainEnabled)

                            Button(LocalizationKeys.Settings.Intensity.strong.localized) {
                                applyChange { menuBarManager.grainIntensity = 0.3 }
                            }
                            .buttonStyle(SettingsChipButtonStyle(isSelected: menuBarManager.grainIntensity > 0.25))
                            .disabled(!menuBarManager.isGrainEnabled)
                        }
                        .opacity(menuBarManager.isGrainEnabled ? 1 : 0.55)
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
                        .disabled(!menuBarManager.isGrainEnabled || state.globalLoading)
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
        }
        .transition(.opacity)
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

struct GrainPreviewCard: View {
    @EnvironmentObject var menuBarManager: MenuBarManager

    var body: some View {
        SettingsCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(NSLocalizedString("settings.preview.title", comment: "Preview card title"))
                            .font(.headline)
                        Text(NSLocalizedString("settings.preview.description", comment: "Preview card description"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }

                ZStack {
                    LinearGradient(
                        colors: [Color.black.opacity(0.92), Color.black.opacity(0.75)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    GrainEffect(
                        intensity: menuBarManager.isGrainEnabled ? menuBarManager.grainIntensity : 0.15,
                        preserveBrightness: menuBarManager.preserveBrightness,
                        isAnimated: menuBarManager.isGrainAnimated,
                        isMatteMode: menuBarManager.isMatteModeEnabled
                    )
                    .opacity(menuBarManager.isGrainEnabled ? 1 : 0.4)

                    VStack {
                        Spacer()
                        HStack {
                            Text("\(LocalizationKeys.Settings.intensity.localized): \(Int(menuBarManager.grainIntensity * 100))%")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.9))
                            Spacer()
                            Text(menuBarManager.isGrainEnabled
                                 ? NSLocalizedString("settings.preview.status.enabled", comment: "Preview enabled state")
                                 : NSLocalizedString("settings.preview.status.disabled", comment: "Preview disabled state"))
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(10)
                        .background(Color.black.opacity(0.28))
                    }
                }
                .frame(height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .accessibilityElement(children: .combine)
                .accessibilityLabel(NSLocalizedString("settings.preview.title", comment: "Preview card title"))
            }
        }
    }
}

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
                LoFiControlsView(isLoading: $state.globalLoading, loadingMessageKey: $state.loadingMessageKey, embeddedInCard: false)
            }
        }
    }
}

struct SupportSettingsPanel: View {
    @ObservedObject var state: SettingsState

    var body: some View {
        VStack(alignment: .leading, spacing: SettingsLayoutMetrics.sectionSpacing) {
            SettingsSectionHeader(
                title: LocalizationKeys.Settings.Support.title.localized,
                subtitle: LocalizationKeys.Settings.Support.description.localized
            )

            SettingsCard {
                VStack(alignment: .leading, spacing: 14) {
                    Text(LocalizationKeys.Settings.feedbackPlaceholder.localized)
                        .font(.subheadline)

                    TextEditor(text: $state.feedbackDraft)
                        .frame(height: 120)
                        .padding(6)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(SettingsTheme.secondarySurface)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(SettingsTheme.subtleStroke, lineWidth: 1)
                        )
                        .disabled(state.globalLoading)
                        .accessibilityLabel(NSLocalizedString("settings.feedback.editor.accessibility", comment: "Feedback editor accessibility label"))

                    HStack(spacing: 12) {
                        Button(LocalizationKeys.Settings.feedbackSend.localized) {
                            sendFeedback()
                        }
                        .buttonStyle(SettingsPrimaryButtonStyle())
                        .disabled(!state.canSendFeedback)

                        switch state.feedbackSendState {
                        case .idle:
                            EmptyView()
                        case .sending:
                            Label(LocalizationKeys.Loading.sendingFeedback.localized, systemImage: "hourglass")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        case .success:
                            Label(LocalizationKeys.Settings.feedbackSent.localized, systemImage: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(SettingsTheme.success)
                        case .error(let message):
                            Text(message)
                                .font(.caption)
                                .foregroundColor(SettingsTheme.danger)
                        }

                        Spacer()
                    }
                }
            }
        }
    }

    private func sendFeedback() {
        let trimmedMessage = state.feedbackDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else {
            state.feedbackSendState = .error(LocalizationKeys.Settings.Feedback.validation.localized)
            state.resetFeedbackStateAfterDelay()
            return
        }

        state.feedbackSendState = .sending
        state.globalLoading = true
        state.loadingMessageKey = LocalizationKeys.Loading.sendingFeedback

        FeedbackService.sendFeedback(message: trimmedMessage) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    state.feedbackDraft = ""
                    state.feedbackSendState = .success
                    state.resetFeedbackStateAfterDelay()
                case .failure(let error):
                    state.feedbackSendState = .error("\(LocalizationKeys.Settings.feedbackError.localized): \(error.localizedDescription)")
                    state.resetFeedbackStateAfterDelay()
                }

                state.globalLoading = false
                state.loadingMessageKey = LocalizationKeys.Loading.applyingChanges
            }
        }
    }
}
