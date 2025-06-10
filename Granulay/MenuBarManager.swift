import AppKit
import Combine
import SwiftUI

class MenuBarManager: ObservableObject {
    private var statusItem: NSStatusItem?
    private var overlayWindow: GrainOverlayWindow?
    private var settingsWindow: NSWindow?
    private var cancellables = Set<AnyCancellable>()
    private var intensityDebouncer = Timer()
    private let updateManager = UpdateManager.shared

    @Published var isGrainEnabled = false {
        didSet {
            updateOverlay()
            if saveSettingsAutomatically {
                saveSettings()
            }
        }
    }

    @Published var grainIntensity: Double = GrainStyle.fine.recommendedIntensity {
        didSet {
            debouncedIntensityUpdate()
        }
    }

    @Published var grainStyle: GrainStyle = .fine {
        didSet {
            overlayWindow?.updateGrainStyle(grainStyle)
            if saveSettingsAutomatically {
                saveSettings()
            }
        }
    }

    @Published var preserveBrightness = true {
        didSet {
            overlayWindow?.updatePreserveBrightness(preserveBrightness)
            if saveSettingsAutomatically {
                saveSettings()
            }
        }
    }

    @Published var saveSettingsAutomatically = true {
        didSet {
            UserDefaults.standard.set(
                saveSettingsAutomatically, forKey: "saveSettingsAutomatically")
            if saveSettingsAutomatically {
                saveSettings()
            }
        }
    }

    @Published var showInDock = false {
        didSet {
            updateDockVisibility()
            if saveSettingsAutomatically {
                saveSettings()
            }
        }
    }

    init() {
        loadSettings()
        setupMenuBar()
        setupOverlayWindow()
    }

    private func debouncedIntensityUpdate() {
        intensityDebouncer.invalidate()
        intensityDebouncer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
            self.overlayWindow?.updateGrainIntensity(self.grainIntensity)
            if self.saveSettingsAutomatically {
                self.saveSettings()
            }
        }
    }

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem?.button {
            button.image = NSImage(named: "MenuBarIcon")
            button.image?.size = NSSize(width: 16, height: 16)

            button.image?.isTemplate = true

            button.action = #selector(toggleGrain)
            button.target = self
        }

        setupMenu()
    }

    private func setupMenu() {
        let menu = NSMenu()

        let toggleItem = NSMenuItem(
            title: isGrainEnabled ? "Desativar Efeito" : "Ativar Efeito",
            action: #selector(toggleGrain),
            keyEquivalent: ""
        )
        toggleItem.target = self
        menu.addItem(toggleItem)

        menu.addItem(NSMenuItem.separator())

        let settingsItem = NSMenuItem(
            title: "Configurações...",
            action: #selector(openSettings),
            keyEquivalent: ""
        )
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(NSMenuItem.separator())

        let checkUpdatesItem = NSMenuItem(
            title: "Verificar Atualizações...",
            action: #selector(checkForUpdates),
            keyEquivalent: ""
        )
        checkUpdatesItem.target = self
        menu.addItem(checkUpdatesItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(
            title: "Sair",
            action: #selector(quit),
            keyEquivalent: ""
        )
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem?.menu = menu
    }

    private func setupOverlayWindow() {
        overlayWindow = GrainOverlayWindow()
        overlayWindow?.updateGrainIntensity(grainIntensity)
        overlayWindow?.updateGrainStyle(grainStyle)
    }

    private func updateOverlay() {
        if isGrainEnabled {
            overlayWindow?.showOverlay()
        } else {
            overlayWindow?.hideOverlay()
        }

        updateMenuTitle()
    }

    private func updateMenuTitle() {
        guard let menu = statusItem?.menu else { return }

        if let toggleItem = menu.item(at: 0) {
            toggleItem.title = isGrainEnabled ? "Desativar Efeito" : "Ativar Efeito"
        }
    }

    private func updateDockVisibility() {
        let wasSettingsWindowVisible = settingsWindow?.isVisible ?? false
        let wasSettingsWindowKey = settingsWindow?.isKeyWindow ?? false
        
        if showInDock {
            NSApp.setActivationPolicy(.regular)
        } else {
            NSApp.setActivationPolicy(.accessory)
        }
        
        // Manter a janela de configurações em foco se ela estava visível
        if wasSettingsWindowVisible {
            settingsWindow?.makeKeyAndOrderFront(nil)
            // Se a janela era a janela principal, garantir que ela continue sendo
            if wasSettingsWindowKey {
                settingsWindow?.orderFrontRegardless()
            }
        }
    }

    @objc private func toggleGrain() {
        isGrainEnabled.toggle()
    }

    @objc private func openSettings() {
        if settingsWindow == nil {
            let settingsView = SettingsView().environmentObject(self)
            let hostingView = NSHostingView(rootView: settingsView)

            settingsWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 480, height: 500),
                styleMask: [.titled, .closable, .resizable],
                backing: .buffered,
                defer: false
            )

            settingsWindow?.minSize = NSSize(width: 480, height: 500)

            settingsWindow?.title = "Configurações do Granulay"
            settingsWindow?.contentView = hostingView
            settingsWindow?.center()
            settingsWindow?.isReleasedWhenClosed = false
        }

        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }

    @objc private func checkForUpdates() {
        updateManager.checkForUpdates()
    }

    private func loadSettings() {
        saveSettingsAutomatically =
            UserDefaults.standard.object(forKey: "saveSettingsAutomatically") as? Bool ?? true

        // Carrega a configuração da Dock independentemente do salvamento automático
        showInDock = UserDefaults.standard.object(forKey: "showInDock") as? Bool ?? false

        if saveSettingsAutomatically {
            isGrainEnabled = UserDefaults.standard.bool(forKey: "isGrainEnabled")

            // Primeiro carregamos o estilo para poder usar a intensidade recomendada
            if let styleRawValue = UserDefaults.standard.string(forKey: "grainStyle"),
                let style = GrainStyle(rawValue: styleRawValue)
            {
                grainStyle = style
            } else {
                grainStyle = .fine
            }

            grainIntensity =
                UserDefaults.standard.object(forKey: "grainIntensity") as? Double
                ?? grainStyle.recommendedIntensity
            preserveBrightness =
                UserDefaults.standard.object(forKey: "preserveBrightness") as? Bool ?? true
        }
    }

    private func saveSettings() {
        UserDefaults.standard.set(isGrainEnabled, forKey: "isGrainEnabled")
        UserDefaults.standard.set(grainIntensity, forKey: "grainIntensity")
        UserDefaults.standard.set(grainStyle.rawValue, forKey: "grainStyle")
        UserDefaults.standard.set(preserveBrightness, forKey: "preserveBrightness")
        UserDefaults.standard.set(showInDock, forKey: "showInDock")
    }

    func saveSettingsManually() {
        saveSettings()
    }

    func resetToDefaults() {
        grainIntensity = GrainStyle.fine.recommendedIntensity
        grainStyle = .fine
        isGrainEnabled = false
        preserveBrightness = true
        showInDock = false

        if saveSettingsAutomatically {
            saveSettings()
        }
    }
}
