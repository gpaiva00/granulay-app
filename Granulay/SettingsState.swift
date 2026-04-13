import SwiftUI

enum SettingsSection: String, CaseIterable, Identifiable {
    case appearance
    case behavior
    case lofi
    case support

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .appearance: return "sparkles"
        case .behavior: return "gearshape"
        case .lofi: return "music.note"
        case .support: return "questionmark.circle"
        }
    }

    var titleKey: String {
        switch self {
        case .appearance: return LocalizationKeys.Settings.Category.appearance
        case .behavior: return LocalizationKeys.Settings.Category.behavior
        case .lofi: return LocalizationKeys.Settings.Category.lofi
        case .support: return LocalizationKeys.Settings.Category.support
        }
    }

    var localizedName: String { titleKey.localized }

    var isLockedInTrial: Bool {
        return false
    }

    var showsUpgradeHint: Bool {
        false
    }

    var visualPriority: Int {
        switch self {
        case .appearance: return 0
        case .behavior: return 1
        case .lofi: return 2
        case .support: return 3
        }
    }

    static var visibleSections: [SettingsSection] {
        return [.appearance, .behavior, .lofi, .support]
    }

    static var orderedVisibleSections: [SettingsSection] {
        visibleSections
    }
}

enum FeedbackSendState {
    case idle
    case sending
    case success
    case error(String)
}

final class SettingsState: ObservableObject {
    @Published var selectedSection: SettingsSection = .appearance
    @Published var globalLoading = false
    @Published var loadingMessageKey = LocalizationKeys.Loading.applyingChanges
    @Published var feedbackDraft = ""
    @Published var feedbackSendState: FeedbackSendState = .idle

    var canSendFeedback: Bool {
        !feedbackDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !globalLoading
    }

    func resetFeedbackStateAfterDelay(_ seconds: TimeInterval = 2.5) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            self.feedbackSendState = .idle
        }
    }
}

enum SettingsActionRunner {
    static func perform(
        isLoading: Binding<Bool>,
        loadingMessageKey: Binding<String>? = nil,
        messageKey: String = LocalizationKeys.Loading.applyingChanges,
        actionDelay: TimeInterval = 0.08,
        completionDelay: TimeInterval = 0.6,
        action: @escaping () -> Void
    ) {
        isLoading.wrappedValue = true
        loadingMessageKey?.wrappedValue = messageKey

        DispatchQueue.main.asyncAfter(deadline: .now() + actionDelay) {
            action()

            DispatchQueue.main.asyncAfter(deadline: .now() + completionDelay) {
                isLoading.wrappedValue = false
                loadingMessageKey?.wrappedValue = LocalizationKeys.Loading.applyingChanges
            }
        }
    }
}
