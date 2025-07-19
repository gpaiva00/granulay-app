import Foundation
import Security
import SwiftUI

enum SettingsCategory: String, CaseIterable {
    case appearance = "appearance"
    case behavior = "behavior"
    case lofi = "lofi"
    case updates = "updates"
    case support = "support"
    
    var localizedName: String {
        switch self {
        case .appearance: return LocalizationKeys.Settings.Category.appearance.localized
        case .behavior: return LocalizationKeys.Settings.Category.behavior.localized
        case .lofi: return LocalizationKeys.Settings.Category.lofi.localized
        case .updates: return LocalizationKeys.Settings.Category.updates.localized
        case .support: return LocalizationKeys.Settings.Category.support.localized
        }
    }
    
    var icon: String {
        switch self {
        case .appearance: return "paintbrush"
        case .behavior: return "gearshape"
        case .lofi: return "music.note"
        case .updates: return "arrow.triangle.2.circlepath"
        case .support: return "questionmark.circle"
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var menuBarManager: MenuBarManager
    @StateObject private var updateManager = UpdateManager.shared
    @State private var selectedCategory: SettingsCategory = .appearance
    @State private var isLoading = false
    @State private var feedbackMessage = ""
    @State private var showFeedbackSent = false
    @State private var loadingMessage = LocalizationKeys.Loading.applyingChanges.localized
    @State private var isLoFiLoading = false

    var body: some View {
        HSplitView {
            // Sidebar
            VStack(alignment: .leading, spacing: 0) {
                HeaderView()
                    .padding(.horizontal, 28)
                    .padding(.vertical, 20)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(SettingsCategory.allCases, id: \.self) { category in
                        CategoryRow(
                            category: category,
                            isSelected: selectedCategory == category
                        ) {
                            selectedCategory = category
                        }
                    }
                }
                .padding(.vertical, 12)
                
                Spacer()
                
                // Versão no rodapé
                HStack {
                    Text("v\(appVersion)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .frame(width: 200)
            .background(Color(NSColor.controlBackgroundColor))
            
            // Conteúdo principal
            ScrollView {
                VStack(spacing: 0) {
                    switch selectedCategory {
                    case .appearance:
                        AppearanceSettingsView(isLoading: $isLoading)
                            .environmentObject(menuBarManager)
                    case .behavior:
                        BehaviorSettingsView(isLoading: $isLoading)
                            .environmentObject(menuBarManager)
                    case .lofi:
                        LoFiSettingsView(isLoading: $isLoFiLoading)
                    case .updates:
                        UpdatesSettingsView(isLoading: $isLoading)
                            .environmentObject(updateManager)
                    case .support:
                        SupportSettingsView(
                            feedbackMessage: $feedbackMessage,
                            isLoading: $isLoading,
                            showFeedbackSent: $showFeedbackSent,
                            loadingMessage: $loadingMessage
                        )
                    }
                }
                .padding(24)
            }
            .frame(minWidth: 400)
        }
        .frame(width: 680, height: 550)
        .overlay(
            Group {
                if isLoading {
                    LoadingOverlay(message: loadingMessage)
                }
            }
        )
    }
}

struct LoadingOverlay: View {
    var message: String = LocalizationKeys.Loading.applyingChanges.localized

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                ProgressView()
                    .scaleEffect(1.2)

                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            .padding(20)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(12)
            .shadow(radius: 10)
        }
    }
}

struct CategoryRow: View {
    let category: SettingsCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: category.icon)
                    .frame(width: 16, height: 16)
                    .foregroundColor(isSelected ? .accentColor : .secondary)
                
                HStack(spacing: 6) {
                    Text(category.localizedName)
                        .font(.subheadline)
                        .foregroundColor(isSelected ? .primary : .secondary)
                    
                    if category == .lofi {
                        Text(LocalizationKeys.App.beta.localized)
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.orange)
                            )
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct HeaderView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image("SettingsViewIcon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
                .foregroundColor(.accentColor)

            Text("Granulay")
                .font(.title2)
                .fontWeight(.semibold)

            Text(LocalizationKeys.App.tagline.localized)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Appearance Settings
struct AppearanceSettingsView: View {
    @EnvironmentObject var menuBarManager: MenuBarManager
    @Binding var isLoading: Bool

    private func withLoadingDelay(_ action: @escaping () -> Void) {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                isLoading = false
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 16) {
                Text(LocalizationKeys.Settings.Appearance.title.localized)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(LocalizationKeys.Settings.Appearance.description.localized)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            SettingsCard {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text(LocalizationKeys.Settings.enableEffect.localized)
                            .font(.subheadline)

                        Spacer()

                        Toggle(
                            "",
                            isOn: Binding(
                                get: { menuBarManager.isGrainEnabled },
                                set: { newValue in
                                    withLoadingDelay {
                                        menuBarManager.isGrainEnabled = newValue
                                    }
                                }
                            )
                        )
                        .toggleStyle(SwitchToggleStyle())
                        .disabled(isLoading)
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 12) {
                        Text(LocalizationKeys.Settings.intensity.localized)
                            .font(.subheadline)

                        HStack(spacing: 10) {
                            Button(LocalizationKeys.Settings.Intensity.weak.localized) {
                                withLoadingDelay {
                                    menuBarManager.grainIntensity = 0.1
                                }
                            }
                            .buttonStyle(
                                IntensityButtonStyle(isSelected: menuBarManager.grainIntensity <= 0.15)
                            )
                            .disabled(!menuBarManager.isGrainEnabled || isLoading)

                            Button(LocalizationKeys.Settings.Intensity.medium.localized) {
                                withLoadingDelay {
                                    menuBarManager.grainIntensity = 0.2
                                }
                            }
                            .buttonStyle(
                                IntensityButtonStyle(
                                    isSelected: menuBarManager.grainIntensity > 0.15
                                        && menuBarManager.grainIntensity <= 0.25)
                            )
                            .disabled(!menuBarManager.isGrainEnabled || isLoading)

                            Button(LocalizationKeys.Settings.Intensity.strong.localized) {
                                withLoadingDelay {
                                    menuBarManager.grainIntensity = 0.3
                                }
                            }
                            .buttonStyle(
                                IntensityButtonStyle(isSelected: menuBarManager.grainIntensity > 0.25)
                            )
                            .disabled(!menuBarManager.isGrainEnabled || isLoading)
                        }
                        .frame(maxWidth: .infinity)
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 12) {
                        Text(LocalizationKeys.Settings.grainStyle.localized)
                            .font(.subheadline)

                        HStack(spacing: 10) {
                            ForEach(GrainStyle.allCases, id: \.self) { style in
                                Button(style.localizedName) {
                                    withLoadingDelay {
                                        menuBarManager.grainStyle = style
                                    }
                                }
                                .buttonStyle(
                                    IntensityButtonStyle(isSelected: menuBarManager.grainStyle == style)
                                )
                                .disabled(!menuBarManager.isGrainEnabled || isLoading)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }

                    Divider()

                    HStack {
                        Text(LocalizationKeys.Settings.preserveBrightness.localized)
                            .font(.subheadline)

                        Spacer()

                        Toggle(
                            "",
                            isOn: Binding(
                                get: { menuBarManager.preserveBrightness },
                                set: { newValue in
                                    withLoadingDelay {
                                        menuBarManager.preserveBrightness = newValue
                                    }
                                }
                            )
                        )
                        .toggleStyle(SwitchToggleStyle())
                        .disabled(!menuBarManager.isGrainEnabled || isLoading)
                    }
                }
            }
        }
    }
}

// MARK: - Behavior Settings
struct BehaviorSettingsView: View {
    @EnvironmentObject var menuBarManager: MenuBarManager
    @Binding var isLoading: Bool

    private func withLoadingDelay(_ action: @escaping () -> Void) {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                isLoading = false
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 16) {
                Text(LocalizationKeys.Settings.Behavior.title.localized)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(LocalizationKeys.Settings.Behavior.description.localized)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            SettingsCard {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text(LocalizationKeys.Settings.showInDock.localized)
                            .font(.subheadline)

                        Spacer()

                        Toggle(
                            "",
                            isOn: Binding(
                                get: { menuBarManager.showInDock },
                                set: { newValue in
                                    withLoadingDelay {
                                        menuBarManager.showInDock = newValue
                                    }
                                }
                            )
                        )
                        .toggleStyle(SwitchToggleStyle())
                        .disabled(isLoading)
                    }
                }
            }
            
            SettingsCard {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(LocalizationKeys.Settings.Behavior.resetTitle.localized)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text(LocalizationKeys.Settings.Behavior.resetDescription.localized)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Button(LocalizationKeys.Settings.reset.localized) {
                                withLoadingDelay {
                                    menuBarManager.resetToDefaults()
                                }
                            }
                            .buttonStyle(BorderedButtonStyle())
                            .disabled(isLoading)
                            
                            Spacer()
                        }
                    }
                }
            }
            
        }
    }
}

// MARK: - Updates Settings
struct UpdatesSettingsView: View {
    @EnvironmentObject var updateManager: UpdateManager
    @Binding var isLoading: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 16) {
                Text(LocalizationKeys.Settings.UpdatesSection.title.localized)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(LocalizationKeys.Settings.UpdatesSection.description.localized)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            SettingsCard {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text(LocalizationKeys.Settings.autoUpdates.localized)
                            .font(.subheadline)

                        Spacer()

                        Toggle("", isOn: $updateManager.automaticUpdatesEnabled)
                            .toggleStyle(SwitchToggleStyle())
                            .disabled(isLoading)
                    }

                    if !updateManager.automaticUpdatesEnabled {
                        Text(LocalizationKeys.Settings.autoUpdatesDescription.localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }

                    Divider()

                    HStack {
                        Button(LocalizationKeys.Settings.checkUpdates.localized) {
                            updateManager.checkForUpdates()
                        }
                        .buttonStyle(BorderedButtonStyle())
                        .disabled(isLoading)

                        Spacer()
                    }
                }
            }
        }
    }
}

// MARK: - LoFi Settings
struct LoFiSettingsView: View {
    @Binding var isLoading: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 16) {
                Text(LocalizationKeys.Settings.LoFiSection.title.localized)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(LocalizationKeys.Settings.LoFiSection.description.localized)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            SettingsCard {
                LoFiControlsView(isLoading: $isLoading)
                    .disabled(isLoading)
            }
            
            Spacer()
        }
        
    }
}

// MARK: - Support Settings
struct SupportSettingsView: View {
    @Binding var feedbackMessage: String
    @Binding var isLoading: Bool
    @Binding var showFeedbackSent: Bool
    @Binding var loadingMessage: String
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 16) {
                Text(LocalizationKeys.Settings.Support.title.localized)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(LocalizationKeys.Settings.Support.description.localized)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            SettingsCard {
                VStack(alignment: .leading, spacing: 16) {
                    Text(LocalizationKeys.Settings.feedbackPlaceholder.localized)
                        .font(.subheadline)

                    TextEditor(text: $feedbackMessage)
                        .frame(height: 100)
                        .padding(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .disabled(isLoading)

                    HStack {
                        Button(LocalizationKeys.Settings.feedbackSend.localized) {
                            sendFeedback()
                        }
                        .buttonStyle(BorderedButtonStyle())
                        .disabled(
                            isLoading
                                || feedbackMessage.trimmingCharacters(in: .whitespacesAndNewlines)
                                    .isEmpty
                        )

                        Spacer()

                        if showFeedbackSent {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text(LocalizationKeys.Settings.feedbackSent.localized)
                                    .foregroundColor(.green)
                            }
                            .transition(.opacity)
                        }
                    }

                    if showError {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }
    
    private func sendFeedback() {
        guard !feedbackMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = LocalizationKeys.Settings.Feedback.validation.localized
            showError = true
            return
        }

        loadingMessage = LocalizationKeys.Loading.sendingFeedback.localized
        isLoading = true

        // Implementação real da chamada para a API Resend
        let url = URL(string: "https://api.resend.com/emails")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Obter a chave da API diretamente do Info.plist
        let apiKey = Bundle.main.infoDictionary?["ResendApiKey"] as? String ?? ""
        if !apiKey.isEmpty {
            request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        } else {
            // Se não encontrar a chave no Info.plist, mostrar erro
            self.errorMessage = LocalizationKeys.Settings.feedbackError.localized
            self.showError = true
            self.isLoading = false
            self.loadingMessage = LocalizationKeys.Loading.applyingChanges.localized
            return
        }

        let emailContent = feedbackMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        let appVersion =
            Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let osVersion = ProcessInfo.processInfo.operatingSystemVersionString

        let emailBody = """
            <p><strong>Feedback do Granulay:</strong></p>
            <p>\(emailContent)</p>
            <hr>
            <p><small>Versão do App: \(appVersion)<br>Sistema: macOS \(osVersion)</small></p>
            """

        let emailData: [String: Any] = [
            "from": "Granulay <support@granulay.com.br>",
            "to": ["support@granulay.com.br"],
            "subject": "Feedback do Granulay",
            "html": emailBody,
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: emailData)
            request.httpBody = jsonData

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.errorMessage = "\(LocalizationKeys.Settings.feedbackError.localized): \(error.localizedDescription)"
                        self.showError = true
                        self.isLoading = false
                        self.loadingMessage = LocalizationKeys.Loading.applyingChanges.localized
                        return
                    }

                    if let httpResponse = response as? HTTPURLResponse,
                        !(200...299).contains(httpResponse.statusCode)
                    {
                        self.errorMessage = "\(LocalizationKeys.Settings.feedbackError.localized): \(httpResponse.statusCode)"
                        self.showError = true
                        self.isLoading = false
                        self.loadingMessage = LocalizationKeys.Loading.applyingChanges.localized
                        return
                    }

                    // Sucesso
                    self.feedbackMessage = ""
                    self.isLoading = false
                    self.showFeedbackSent = true
                    self.loadingMessage = LocalizationKeys.Loading.applyingChanges.localized

                    // Esconde a mensagem de sucesso após 3 segundos
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.showFeedbackSent = false
                    }
                }
            }

            task.resume()
        } catch {
            print("Erro ao enviar feedback: \(error.localizedDescription)")

            self.errorMessage = "\(LocalizationKeys.Settings.feedbackError.localized): \(error.localizedDescription)"
            self.showError = true
            self.isLoading = false
            self.loadingMessage = LocalizationKeys.Loading.applyingChanges.localized
        }
    }
}

// MARK: - Reusable Components
struct SettingsCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(20)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(12)
    }
}

// Classe para gerenciar o armazenamento seguro de chaves no Keychain
class KeychainManager {
    static let shared = KeychainManager()

    private init() {
        // Inicializa a chave da API se ainda não estiver configurada
        initializeApiKeyIfNeeded()
    }

    // Chave para identificar o item no Keychain
    private let resendApiKeyIdentifier = "com.granulay.resendApiKey"

    // Chave para verificar se a inicialização já foi feita
    private let initializationKey = "com.granulay.apiKeyInitialized"

    // Chave da API Resend - será substituída durante o build
    private let defaultResendApiKey = "re_a4iN2Cvt_CSnKrDJo5i8r2pkmQwLvVjK9"

    // Inicializa a chave da API se ainda não estiver configurada
    private func initializeApiKeyIfNeeded() {
        // Verifica se a chave já existe
        if getApiKey() == nil {
            // Obtém a chave da API da constante privada
            let defaultApiKey = defaultResendApiKey

            // Salva a chave no Keychain
            _ = saveApiKey(defaultApiKey)
        }
    }

    // Salva a chave da API no Keychain
    func saveApiKey(_ apiKey: String) -> Bool {
        // Remover qualquer chave existente primeiro
        _ = deleteApiKey()

        guard let data = apiKey.data(using: .utf8) else {
            print("Erro ao converter a chave da API para dados")
            return false
        }

        // Criar o dicionário de consulta para o Keychain
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: resendApiKeyIdentifier,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
        ]

        // Adicionar o item ao Keychain
        let status = SecItemAdd(query as CFDictionary, nil)

        if status == errSecSuccess {
            return true
        } else {
            print("Erro ao salvar a chave da API no Keychain: \(status)")
            return false
        }
    }

    // Recupera a chave da API do Keychain
    func getApiKey() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: resendApiKeyIdentifier,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == errSecSuccess, let data = dataTypeRef as? Data,
            let apiKey = String(data: data, encoding: .utf8)
        {
            return apiKey
        } else {
            if status != errSecItemNotFound {
                print("Erro ao recuperar a chave da API do Keychain: \(status)")
            }
            return nil
        }
    }

    // Remove a chave da API do Keychain
    func deleteApiKey() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: resendApiKeyIdentifier,
        ]

        let status = SecItemDelete(query as CFDictionary)

        // errSecItemNotFound não é um erro se estamos tentando excluir algo que não existe
        if status == errSecSuccess || status == errSecItemNotFound {
            return true
        } else {
            print("Erro ao excluir a chave da API do Keychain: \(status)")
            return false
        }
    }
}



#Preview {
    SettingsView()
        .environmentObject(MenuBarManager())
}

private var appVersion: String {
    Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
}

struct IntensityButtonStyle: ButtonStyle {
    var isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.accentColor : Color(NSColor.controlBackgroundColor))
            )
            .foregroundColor(isSelected ? .white : .primary)
            .font(.subheadline.bold())
            .contentShape(Rectangle())
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}
