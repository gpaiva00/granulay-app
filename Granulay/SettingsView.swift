import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var menuBarManager: MenuBarManager
    @StateObject private var updateManager = UpdateManager.shared
    @State private var isLoading = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HeaderView()
                
                ControlsSection(isLoading: $isLoading)
                    .environmentObject(menuBarManager)
                
                UpdatesSection(isLoading: $isLoading)
                    .environmentObject(updateManager)
                
                ActionButtons(isLoading: $isLoading)
                    .environmentObject(menuBarManager)
            }
            .padding(24)
        }
        .frame(width: 480, height: 550)
        .overlay(
            Group {
                if isLoading {
                    LoadingOverlay()
                }
            }
        )
    }
}

struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 12) {
                ProgressView()
                    .scaleEffect(1.2)
                
                Text("Aplicando alterações...")
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
                    
                    Toggle("", isOn: Binding(
                        get: { menuBarManager.isGrainEnabled },
                        set: { newValue in
                            withLoadingDelay {
                                menuBarManager.isGrainEnabled = newValue
                            }
                        }
                    ))
                    .toggleStyle(SwitchToggleStyle())
                    .disabled(isLoading)
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Intensidade")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Text("\(Int(menuBarManager.grainIntensity * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(
                        value: Binding(
                            get: { menuBarManager.grainIntensity },
                            set: { newValue in
                                withLoadingDelay {
                                    menuBarManager.grainIntensity = newValue
                                }
                            }
                        ),
                        in: 0.1...1.0,
                        step: 0.05
                    )
                    .disabled(!menuBarManager.isGrainEnabled || isLoading)
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Estilo do Grão")
                        .font(.subheadline)
                    
                    Picker("Estilo", selection: Binding(
                        get: { menuBarManager.grainStyle },
                        set: { newValue in
                            withLoadingDelay {
                                menuBarManager.grainStyle = newValue
                            }
                        }
                    )) {
                        ForEach(GrainStyle.allCases, id: \.self) { style in
                            Text(style.rawValue).tag(style)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .disabled(!menuBarManager.isGrainEnabled || isLoading)
                }
                
                Divider()
                
                HStack {
                    Text("Preservar Luminosidade")
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Toggle("", isOn: Binding(
                        get: { menuBarManager.preserveBrightness },
                        set: { newValue in
                            withLoadingDelay {
                                menuBarManager.preserveBrightness = newValue
                            }
                        }
                    ))
                    .toggleStyle(SwitchToggleStyle())
                    .disabled(!menuBarManager.isGrainEnabled || isLoading)
                }
                
                Divider()
                
                HStack {
                    Text("Salvar Configurações Automaticamente")
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Toggle("", isOn: Binding(
                        get: { menuBarManager.saveSettingsAutomatically },
                        set: { newValue in
                            menuBarManager.saveSettingsAutomatically = newValue
                        }
                    ))
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
                    Text("Verificação automática desabilitada. Use o botão abaixo para verificar manualmente.")
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
                Text("Salvamento automático desabilitado. Use o botão acima para salvar manualmente.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
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
