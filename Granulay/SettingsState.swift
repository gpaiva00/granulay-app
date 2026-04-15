import SwiftUI

/// Represents the available sections within the Settings window.
/// Note that `.lofi` is currently excluded from `visibleSections` due to the disabled S3 bucket.
enum SettingsSection: String, CaseIterable, Identifiable {
    case appearance
    case behavior
    case lofi

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .appearance: return "sparkles"
        case .behavior: return "gearshape"
        case .lofi: return "music.note"
        }
    }

    var titleKey: String {
        switch self {
        case .appearance: return LocalizationKeys.Settings.Category.appearance
        case .behavior: return LocalizationKeys.Settings.Category.behavior
        case .lofi: return LocalizationKeys.Settings.Category.lofi
        }
    }

    var localizedName: String { titleKey.localized }

    var visualPriority: Int {
        switch self {
        case .appearance: return 0
        case .behavior: return 1
        case .lofi: return 2
        }
    }

    static var visibleSections: [SettingsSection] {
        // Lo-Fi temporariamente desabilitado (bucket S3 indisponível)
        return [.appearance, .behavior]
    }

    static var orderedVisibleSections: [SettingsSection] {
        visibleSections
    }
}

/// `SettingsState` is an `ObservableObject` specifically scoped to the Settings window.
///
/// It handles ephemeral UI state such as the currently selected navigation section
/// and global loading indicators. It separates UI concerns from the core application
/// logic stored in `MenuBarManager`.
final class SettingsState: ObservableObject {
    @Published var selectedSection: SettingsSection = .appearance
    @Published var globalLoading = false
    @Published var loadingMessageKey = LocalizationKeys.Loading.applyingChanges
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
