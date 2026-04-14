import AppKit
import Combine
import SwiftUI

class MenuBarManager: ObservableObject {
    private var statusItem: NSStatusItem?
    private var overlayWindow: GrainOverlayWindow?
    private var settingsWindow: NSWindow?
    private var cancellables = Set<AnyCancellable>()
    private var intensityDebouncer = Timer()
    private let musicManager = LoFiMusicManager.shared

    @Published var isGrainEnabled = false {
        didSet {
            updateOverlay()
            saveSettings()
        }
    }

    @Published var grainIntensity: Double = 0.2 {
        didSet {
            debouncedIntensityUpdate()
        }
    }

    @Published var preserveBrightness = true {
        didSet {
            overlayWindow?.updatePreserveBrightness(preserveBrightness)
            saveSettings()
        }
    }

    @Published var isGrainAnimated = true {
        didSet {
            overlayWindow?.updateGrainAnimated(isGrainAnimated)
            saveSettings()
        }
    }
    
    @Published var isMatteModeEnabled = false {
        didSet {
            overlayWindow?.updateMatteMode(isMatteModeEnabled)
            saveSettings()
        }
    }

    @Published var showInDock = true {
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
        overlayWindow?.updatePreserveBrightness(preserveBrightness)
        overlayWindow?.updateGrainAnimated(isGrainAnimated)
        overlayWindow?.updateMatteMode(isMatteModeEnabled)
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


    
    private func createLoFiSubmenu() -> NSMenu {
        let submenu = NSMenu()
        
        // Play/Pause
        let playPauseTitle = musicManager.isPlaying ? LocalizationKeys.LoFi.pause.localized : LocalizationKeys.LoFi.play.localized
        let playPauseItem = NSMenuItem(
            title: playPauseTitle,
            action: #selector(toggleLoFiPlayback),
            keyEquivalent: ""
        )
        playPauseItem.target = self
        submenu.addItem(playPauseItem)
        
        // Stop
        let stopItem = NSMenuItem(
            title: LocalizationKeys.LoFi.stop.localized,
            action: #selector(stopLoFi),
            keyEquivalent: ""
        )
        stopItem.target = self
        submenu.addItem(stopItem)
        
        submenu.addItem(NSMenuItem.separator())
        
        // Previous Track
        let previousItem = NSMenuItem(
            title: NSLocalizedString("lofi.previous_track", comment: "Previous track menu item"),
            action: #selector(previousTrack),
            keyEquivalent: ""
        )
        previousItem.target = self
        submenu.addItem(previousItem)
        
        // Next Track
        let nextItem = NSMenuItem(
            title: NSLocalizedString("lofi.next_track", comment: "Next track menu item"),
            action: #selector(nextTrack),
            keyEquivalent: ""
        )
        nextItem.target = self
        submenu.addItem(nextItem)
        
        submenu.addItem(NSMenuItem.separator())
        
        // Current Track Info
        let trackInfo = NSMenuItem(
            title: String(format: NSLocalizedString("lofi.current_track", comment: "Current track info"), musicManager.currentTrack),
            action: nil,
            keyEquivalent: ""
        )
        trackInfo.isEnabled = false
        submenu.addItem(trackInfo)
        
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
    
    @objc private func previousTrack() {
        musicManager.previousTrack()
        updateMenuTitle()
    }
    
    @objc private func nextTrack() {
        musicManager.nextTrack()
        updateMenuTitle()
    }

    private func loadSettings() {
        // Carrega todas as configurações salvas
        showInDock = UserDefaults.standard.object(forKey: "showInDock") as? Bool ?? true
        isGrainEnabled = UserDefaults.standard.bool(forKey: "isGrainEnabled")

        let savedIntensity = UserDefaults.standard.object(forKey: "grainIntensity") as? Double

        // Migrate old grainStyle key to intensity; prefer any explicitly saved intensity value
        if let styleRawValue = UserDefaults.standard.string(forKey: "grainStyle") {
            let mappedIntensity: Double
            switch styleRawValue {
            case "fine": mappedIntensity = 0.1
            case "coarse", "vintage": mappedIntensity = 0.3
            default: mappedIntensity = 0.2
            }
            grainIntensity = savedIntensity ?? mappedIntensity
            UserDefaults.standard.removeObject(forKey: "grainStyle")
        } else {
            grainIntensity = savedIntensity ?? 0.2
        }

        preserveBrightness =
            UserDefaults.standard.object(forKey: "preserveBrightness") as? Bool ?? true
        isGrainAnimated = UserDefaults.standard.object(forKey: "isGrainAnimated") as? Bool ?? true
        isMatteModeEnabled = UserDefaults.standard.bool(forKey: "isMatteModeEnabled")
    }

    private func saveSettings() {
        UserDefaults.standard.set(isGrainEnabled, forKey: "isGrainEnabled")
        UserDefaults.standard.set(grainIntensity, forKey: "grainIntensity")
        UserDefaults.standard.set(preserveBrightness, forKey: "preserveBrightness")
        UserDefaults.standard.set(isGrainAnimated, forKey: "isGrainAnimated")
        UserDefaults.standard.set(isMatteModeEnabled, forKey: "isMatteModeEnabled")
        UserDefaults.standard.set(showInDock, forKey: "showInDock")
    }

    func saveSettingsManually() {
        saveSettings()
    }

    func resetToDefaults() {
        grainIntensity = 0.2
        isGrainEnabled = false
        preserveBrightness = true
        isGrainAnimated = true
        isMatteModeEnabled = false
        showInDock = false
        saveSettings()
    }
}
