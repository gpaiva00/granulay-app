import Foundation
import Security
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var menuBarManager: MenuBarManager
    @StateObject private var updateManager = UpdateManager.shared
    @State private var isLoading = false
    @State private var feedbackMessage = ""
    @State private var showFeedbackSent = false
    @State private var loadingMessage = "Aplicando alterações..."

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HeaderView()

                ControlsSection(isLoading: $isLoading)
                    .environmentObject(menuBarManager)

                UpdatesSection(isLoading: $isLoading)
                    .environmentObject(updateManager)

                FeedbackSection(
                    feedbackMessage: $feedbackMessage, isLoading: $isLoading,
                    showFeedbackSent: $showFeedbackSent, loadingMessage: $loadingMessage)

                ActionButtons(isLoading: $isLoading)
                    .environmentObject(menuBarManager)
            }
            .padding(24)
        }
        .frame(width: 480, height: 550)
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
    var message: String = "Aplicando alterações..."

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

struct HeaderView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image("SettingsViewIcon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .foregroundColor(.accentColor)

            HStack(spacing: 8) {
                Text("Granulay")
                    .font(.title)
                    .fontWeight(.semibold)

                Text("BETA")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.orange)
                    .cornerRadius(8)
            }

            Text("Efeito granulado vintage para sua tela")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

struct ControlsSection: View {
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
        VStack(alignment: .leading, spacing: 16) {
            Text("Configurações")
                .font(.headline)

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Ativar Efeito")
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

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Intensidade")
                            .font(.subheadline)

                        Spacer()
                    }

                    HStack(spacing: 10) {
                        Button("Fraco") {
                            withLoadingDelay {
                                menuBarManager.grainIntensity = 0.1
                            }
                        }
                        .buttonStyle(
                            IntensityButtonStyle(isSelected: menuBarManager.grainIntensity <= 0.15)
                        )
                        .disabled(!menuBarManager.isGrainEnabled || isLoading)

                        Button("Médio") {
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

                        Button("Forte") {
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

                VStack(alignment: .leading, spacing: 8) {
                    Text("Estilo do Grão")
                        .font(.subheadline)

                    HStack(spacing: 10) {
                        ForEach(GrainStyle.allCases, id: \.self) { style in
                            Button(style.rawValue) {
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
                    Text("Preservar Luminosidade")
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

                Divider()

                HStack {
                    Text("Salvar Configurações Automaticamente")
                        .font(.subheadline)

                    Spacer()

                    Toggle(
                        "",
                        isOn: Binding(
                            get: { menuBarManager.saveSettingsAutomatically },
                            set: { newValue in
                                menuBarManager.saveSettingsAutomatically = newValue
                            }
                        )
                    )
                    .toggleStyle(SwitchToggleStyle())
                    .disabled(isLoading)
                }
            }
            .padding(16)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(12)
        }
    }
}

struct UpdatesSection: View {
    @EnvironmentObject var updateManager: UpdateManager
    @Binding var isLoading: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Atualizações")
                .font(.headline)

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Verificar Automaticamente")
                        .font(.subheadline)

                    Spacer()

                    Toggle("", isOn: $updateManager.automaticUpdatesEnabled)
                        .toggleStyle(SwitchToggleStyle())
                        .disabled(isLoading)
                }

                if !updateManager.automaticUpdatesEnabled {
                    Text(
                        "Verificação automática desabilitada. Use o botão abaixo para verificar manualmente."
                    )
                    .font(.caption)
                    .foregroundColor(.secondary)
                }

                Divider()

                HStack {
                    Button("Verificar Atualizações") {
                        updateManager.checkForUpdates()
                    }
                    .buttonStyle(BorderedButtonStyle())
                    .disabled(isLoading)

                    Spacer()
                }
            }
            .padding(16)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(12)
        }
    }
}

struct ActionButtons: View {
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
        VStack(spacing: 12) {
            HStack {
                Button("Salvar Configurações") {
                    menuBarManager.saveSettingsManually()
                }
                .buttonStyle(BorderedButtonStyle())
                .disabled(isLoading || menuBarManager.saveSettingsAutomatically)

                Spacer()

                Button("Restaurar Padrão") {
                    withLoadingDelay {
                        menuBarManager.resetToDefaults()
                    }
                }
                .buttonStyle(BorderedButtonStyle())
                .disabled(isLoading)
            }

            HStack(alignment: .center) {
                Text("v\(appVersion)").font(.caption).foregroundColor(.secondary)
            }

            if !menuBarManager.saveSettingsAutomatically {
                Text(
                    "Salvamento automático desabilitado. Use o botão acima para salvar manualmente."
                )
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            }
        }
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

struct FeedbackSection: View {
    @Binding var feedbackMessage: String
    @Binding var isLoading: Bool
    @Binding var showFeedbackSent: Bool
    @Binding var loadingMessage: String
    @State private var showError = false
    @State private var errorMessage = ""

    private func sendFeedback() {
        guard !feedbackMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Por favor, digite uma mensagem antes de enviar."
            showError = true
            return
        }

        loadingMessage = "Enviando feedback..."
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
            self.errorMessage = "Erro: Chave da API não encontrada. Verifique o arquivo Info.plist."
            self.showError = true
            self.isLoading = false
            self.loadingMessage = "Aplicando alterações..."
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
                        self.errorMessage = "Erro ao enviar: \(error.localizedDescription)"
                        self.showError = true
                        self.isLoading = false
                        self.loadingMessage = "Aplicando alterações..."
                        return
                    }

                    if let httpResponse = response as? HTTPURLResponse,
                        !(200...299).contains(httpResponse.statusCode)
                    {
                        self.errorMessage = "Erro no servidor: Código \(httpResponse.statusCode)"
                        self.showError = true
                        self.isLoading = false
                        self.loadingMessage = "Aplicando alterações..."
                        return
                    }

                    // Sucesso
                    self.feedbackMessage = ""
                    self.isLoading = false
                    self.showFeedbackSent = true
                    self.loadingMessage = "Aplicando alterações..."

                    // Esconde a mensagem de sucesso após 3 segundos
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.showFeedbackSent = false
                    }
                }
            }

            task.resume()
        } catch {
            print("Erro ao enviar feedback: \(error.localizedDescription)")

            self.errorMessage = "Erro ao processar dados: \(error.localizedDescription)"
            self.showError = true
            self.isLoading = false
            self.loadingMessage = "Aplicando alterações..."
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Feedback")
                .font(.headline)

            VStack(alignment: .leading, spacing: 12) {
                Text("Envie-nos suas sugestões ou reporte problemas")
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
                    Button("Enviar Feedback") {
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
                            Text("Feedback enviado!")
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
            .padding(16)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(12)
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
