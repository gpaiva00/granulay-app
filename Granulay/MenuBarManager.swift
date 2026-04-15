import AppKit
import Combine
import SwiftUI

/// `MenuBarManager` acts as the single source of truth for the application's state.
/// It manages the lifecycle of the menu bar icon (`NSStatusItem`), the transparent grain
/// overlay window (`GrainOverlayWindow`), and the main settings window.
///
/// It also handles persisting user preferences to `UserDefaults` and syncing state changes
/// (such as adjusting the grain intensity via sliders) to the rendering pipeline.
class MenuBarManager: ObservableObject {
    private var statusItem: NSStatusItem?
    private var overlayWindow: GrainOverlayWindow?
    private var settingsWindow: NSWindow?
    private var cancellables = Set<AnyCancellable>()
    
    // Timers used to debounce rapid updates from sliders before pushing changes to the overlay
    private var intensityDebouncer = Timer()
    private var matteIntensityDebouncer = Timer()
    
    // Prevents infinite loops when toggling mutually exclusive overlay modes
    private var isSyncingOverlayModeState = false
    
    // Prevents saving to UserDefaults while initial load is happening
    private var isLoadingSettings = false
    
    // Note: Lo-Fi music feature is currently soft-disabled due to a lost S3 bucket.
    // The manager is kept for future restoration but is not active in the UI.
    private let musicManager = LoFiMusicManager.shared

    /// Toggles the standard "Fine Grain" mode.
    /// Mutually exclusive with `isMatteModeEnabled`.
    @Published var isGrainEnabled = false {
        didSet {
            guard oldValue != isGrainEnabled else { return }
            if isLoadingSettings { return }
            if isSyncingOverlayModeState { return }

            if isGrainEnabled && isMatteModeEnabled {
                isSyncingOverlayModeState = true
                isMatteModeEnabled = false
                isSyncingOverlayModeState = false
            }
            updateOverlay()
            saveSettings()
        }
    }

    @Published var grainIntensity: Double = 0.2 {
        didSet {
            guard oldValue != grainIntensity, !isLoadingSettings else { return }
            debouncedIntensityUpdate()
        }
    }

    @Published var matteIntensity: Double = 0.2 {
        didSet {
            guard oldValue != matteIntensity, !isLoadingSettings else { return }
            debouncedMatteIntensityUpdate()
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
            guard oldValue != isMatteModeEnabled else { return }
            overlayWindow?.updateMatteMode(isMatteModeEnabled)
            if isLoadingSettings { return }
            if isSyncingOverlayModeState { return }

            if isMatteModeEnabled && isGrainEnabled {
                isSyncingOverlayModeState = true
                isGrainEnabled = false
                isSyncingOverlayModeState = false
            }
            updateOverlay()
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
        scheduleDebouncedUpdate(timer: &intensityDebouncer) {
            self.overlayWindow?.updateGrainIntensity(self.grainIntensity)
        }
    }

    private func debouncedMatteIntensityUpdate() {
        scheduleDebouncedUpdate(timer: &matteIntensityDebouncer) {
            self.overlayWindow?.updateMatteIntensity(self.matteIntensity)
        }
    }

    private func scheduleDebouncedUpdate(timer: inout Timer, _ update: @escaping () -> Void) {
        timer.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
            update()
            self.saveSettings()
        }
    }

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem?.button {
            button.image = NSImage(named: "MenuBarIcon")
            button.image?.size = NSSize(width: 16, height: 16)

            button.image?.isTemplate = true
        }

        setupMenu()
    }

    private func setupMenu() {
        let menu = NSMenu()

        let grainItem = NSMenuItem(
            title: LocalizationKeys.Settings.Appearance.grainTitle.localized,
            action: #selector(toggleGrainFromMenu),
            keyEquivalent: ""
        )
        grainItem.target = self
        grainItem.state = isGrainEnabled ? .on : .off
        menu.addItem(grainItem)

        let matteItem = NSMenuItem(
            title: LocalizationKeys.Settings.Appearance.matteTitle.localized,
            action: #selector(toggleMatteFromMenu),
            keyEquivalent: ""
        )
        matteItem.target = self
        matteItem.state = isMatteModeEnabled ? .on : .off
        menu.addItem(matteItem)

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
        if isGrainEnabled || isMatteModeEnabled {
            overlayWindow?.showOverlay()
        } else {
            overlayWindow?.hideOverlay()
        }

        updateMenuTitle()
    }

    private func updateMenuTitle() {
        guard let menu = statusItem?.menu else { return }

        if let grainItem = menu.item(at: 0) {
            grainItem.state = isGrainEnabled ? .on : .off
        }
        if let matteItem = menu.item(at: 1) {
            matteItem.state = isMatteModeEnabled ? .on : .off
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

    @objc private func toggleGrainFromMenu() {
        isGrainEnabled.toggle()
    }

    @objc private func toggleMatteFromMenu() {
        isMatteModeEnabled.toggle()
    }

    @objc private func openSettings() {
        if settingsWindow == nil {
            let settingsView = SettingsView().environmentObject(self)
            let hostingView = NSHostingView(rootView: settingsView)

            settingsWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: SettingsLayoutMetrics.windowInitialWidth, height: SettingsLayoutMetrics.windowInitialHeight),
                styleMask: [.titled, .closable, .resizable],
                backing: .buffered,
                defer: false
            )

            settingsWindow?.minSize = NSSize(width: SettingsLayoutMetrics.windowMinWidth, height: SettingsLayoutMetrics.windowMinHeight)

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
        isLoadingSettings = true
        defer { isLoadingSettings = false }

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
        isMatteModeEnabled = UserDefaults.standard.object(forKey: "isMatteModeEnabled") as? Bool ?? false
        matteIntensity = UserDefaults.standard.object(forKey: "matteIntensity") as? Double ?? 0.2
    }

    private func saveSettings() {
        UserDefaults.standard.set(isGrainEnabled, forKey: "isGrainEnabled")
        UserDefaults.standard.set(grainIntensity, forKey: "grainIntensity")
        UserDefaults.standard.set(preserveBrightness, forKey: "preserveBrightness")
        UserDefaults.standard.set(isGrainAnimated, forKey: "isGrainAnimated")
        UserDefaults.standard.set(isMatteModeEnabled, forKey: "isMatteModeEnabled")
        UserDefaults.standard.set(matteIntensity, forKey: "matteIntensity")
        UserDefaults.standard.set(showInDock, forKey: "showInDock")
    }

    func saveSettingsManually() {
        saveSettings()
    }

    func resetToDefaults() {
        grainIntensity = 0.2
        matteIntensity = 0.2
        isGrainEnabled = false
        preserveBrightness = true
        isGrainAnimated = true
        isMatteModeEnabled = false
        showInDock = false
        saveSettings()
    }
}
