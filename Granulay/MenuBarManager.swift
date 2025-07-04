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
    private let musicManager = LoFiMusicManager.shared

    @Published var isGrainEnabled = false {
        didSet {
            updateOverlay()
            saveSettings()
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
            saveSettings()
        }
    }

    @Published var preserveBrightness = true {
        didSet {
            overlayWindow?.updatePreserveBrightness(preserveBrightness)
            saveSettings()
        }
    }



    @Published var showInDock = false {
        didSet {
            updateDockVisibility()
            saveSettings()
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
            self.saveSettings()
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
            title: isGrainEnabled ? LocalizationKeys.Menu.disableEffect.localized : LocalizationKeys.Menu.enableEffect.localized,
            action: #selector(toggleGrain),
            keyEquivalent: ""
        )
        toggleItem.target = self
        menu.addItem(toggleItem)

        menu.addItem(NSMenuItem.separator())

        // Lo-Fi Station submenu
        let lofiItem = NSMenuItem(
            title: LocalizationKeys.Menu.lofiStation.localized,
            action: nil,
            keyEquivalent: ""
        )
        let lofiSubmenu = createLoFiSubmenu()
        lofiItem.submenu = lofiSubmenu
        menu.addItem(lofiItem)

        menu.addItem(NSMenuItem.separator())

        let settingsItem = NSMenuItem(
            title: LocalizationKeys.Menu.settings.localized,
            action: #selector(openSettings),
            keyEquivalent: ""
        )
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(NSMenuItem.separator())

        let checkUpdatesItem = NSMenuItem(
            title: LocalizationKeys.Menu.checkUpdates.localized,
            action: #selector(checkForUpdates),
            keyEquivalent: ""
        )
        checkUpdatesItem.target = self
        menu.addItem(checkUpdatesItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(
            title: LocalizationKeys.Menu.quit.localized,
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
            toggleItem.title = isGrainEnabled ? LocalizationKeys.Menu.disableEffect.localized : LocalizationKeys.Menu.enableEffect.localized
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

            settingsWindow?.title = LocalizationKeys.Settings.windowTitle.localized
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
    
    private func createLoFiSubmenu() -> NSMenu {
        let submenu = NSMenu()
        
        // Play/Pause
        let playPauseTitle = musicManager.isPlaying ? "Pause" : "Play"
        let playPauseItem = NSMenuItem(
            title: playPauseTitle,
            action: #selector(toggleLoFiPlayback),
            keyEquivalent: ""
        )
        playPauseItem.target = self
        submenu.addItem(playPauseItem)
        
        // Stop
        let stopItem = NSMenuItem(
            title: "Stop",
            action: #selector(stopLoFi),
            keyEquivalent: ""
        )
        stopItem.target = self
        submenu.addItem(stopItem)
        
        submenu.addItem(NSMenuItem.separator())
        
        // Previous Station
        let previousItem = NSMenuItem(
            title: "Previous Station",
            action: #selector(previousStation),
            keyEquivalent: ""
        )
        previousItem.target = self
        submenu.addItem(previousItem)
        
        // Next Station
        let nextItem = NSMenuItem(
            title: "Next Station",
            action: #selector(nextStation),
            keyEquivalent: ""
        )
        nextItem.target = self
        submenu.addItem(nextItem)
        
        submenu.addItem(NSMenuItem.separator())
        
        // Current Station Info
        let stationInfo = NSMenuItem(
            title: "\(LocalizationKeys.LoFi.station.localized): \(musicManager.currentStation)",
            action: nil,
            keyEquivalent: ""
        )
        stationInfo.isEnabled = false
        submenu.addItem(stationInfo)
        
        return submenu
    }
    
    @objc private func toggleLoFiPlayback() {
        if musicManager.isPlaying {
            musicManager.pause()
        } else {
            musicManager.play()
        }
        updateMenuTitle()
    }
    
    @objc private func stopLoFi() {
        musicManager.stop()
        updateMenuTitle()
    }
    
    @objc private func previousStation() {
        musicManager.previousStation()
        updateMenuTitle()
    }
    
    @objc private func nextStation() {
        musicManager.nextStation()
        updateMenuTitle()
    }

    private func loadSettings() {
        // Carrega todas as configurações salvas
        showInDock = UserDefaults.standard.object(forKey: "showInDock") as? Bool ?? false
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
        saveSettings()
    }
}
