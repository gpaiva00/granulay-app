import SwiftUI
import AppKit
import Combine

class GrainOverlayWindow: NSObject, ObservableObject {
    private var overlayWindows: [NSWindow] = []
    private var grainViews: [GrainLayerView] = []
    private var currentIntensity: Double = 0.2
    private var currentPreserveBrightness: Bool = true
    private var currentGrainAnimated: Bool = true
    private var currentMatteMode: Bool = false
    private var settingsUpdateTimer: Timer?
    private var pendingSettingsUpdate = false
    private var animationTimer: Timer?
    private let settingsDebounceInterval: TimeInterval = 0.05
    private var animationInterval: TimeInterval = GrainRenderTuning.baseAnimationInterval
    private var updateFrequencyObserver: NSObjectProtocol?
    
    override init() {
        super.init()
        
        GrainTextureCache.shared.preloadTextures(for: NSScreen.screens, isMatteMode: false)
        
        setupPerformanceOptimizations()
        setupOverlayWindows()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenConfigurationChanged),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }
    
    deinit {
        if let updateFrequencyObserver {
            NotificationCenter.default.removeObserver(updateFrequencyObserver)
        }
        NotificationCenter.default.removeObserver(self)
        settingsUpdateTimer?.invalidate()
        animationTimer?.invalidate()
    }
    
    private func setupPerformanceOptimizations() {
        updateFrequencyObserver = NotificationCenter.default.addObserver(
            forName: .updateFrequencyChanged,
            object: nil,
            queue: .main
        ) { notification in
            if let newInterval = notification.object as? TimeInterval {
                self.animationInterval = min(
                    GrainRenderTuning.maxAnimationInterval,
                    max(GrainRenderTuning.minAnimationInterval, newInterval)
                )
                self.restartAnimationLoopIfVisible()
            }
        }
    }
    
    private func setupOverlayWindows() {
        clearOverlayWindows()
        
        for screen in NSScreen.screens {
            let window = createOverlayWindow(for: screen)
            overlayWindows.append(window)
        }
    }
    
    private func createOverlayWindow(for screen: NSScreen) -> NSWindow {
        let window = NSWindow(
            contentRect: screen.frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false,
            screen: screen
        )
        
        window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.maximumWindow)) + 1)
        window.backgroundColor = NSColor.clear
        window.isOpaque = false
        window.hasShadow = false
        window.ignoresMouseEvents = true
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenAuxiliary]
        window.isReleasedWhenClosed = false
        
        // Garante que a janela cubra toda a tela de forma consistente
        window.setFrame(screen.frame, display: true, animate: false)
        
        let grainView = GrainLayerView(frame: screen.frame)
        grainView.intensity = currentIntensity
        grainView.preserveBrightness = currentPreserveBrightness
        grainView.isAnimated = currentGrainAnimated
        grainView.isMatteMode = currentMatteMode
        grainView.configureForScreen(screen)
        grainView.applyScale(screen.backingScaleFactor)
        
        grainViews.append(grainView)
        window.contentView = grainView
        
        return window
    }
    
    private func clearOverlayWindows() {
        for window in overlayWindows {
            window.orderOut(nil)
        }
        stopAnimationLoop()
        overlayWindows.removeAll()
        grainViews.removeAll()
    }
    
    @objc private func screenConfigurationChanged() {
        DispatchQueue.main.async {
            let wasVisible = !self.overlayWindows.isEmpty && self.overlayWindows.first?.isVisible == true

            self.setupOverlayWindows()
            GrainTextureCache.shared.preloadTextures(for: NSScreen.screens, isMatteMode: self.currentMatteMode)
            
            if wasVisible {
                self.showOverlay()
            }
        }
    }
    
    func showOverlay() {

        // Garantir que as janelas estão configuradas
        if overlayWindows.isEmpty {
            setupOverlayWindows()
        }
        

        
        // Garantir configuração correta das janelas
        for window in overlayWindows {

            window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.screenSaverWindow)) + 1)
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]
            window.isOpaque = false
            window.hasShadow = false
            window.ignoresMouseEvents = true
            
            // Garantir que a janela está configurada corretamente
            if let screen = window.screen {
                window.setFrame(screen.frame, display: true, animate: false)
            }
            
            // Mostrar a janela

            window.orderFrontRegardless()
            window.display()
            
            // Forçar atualização visual
            if let contentView = window.contentView {
                contentView.needsDisplay = true
            }
        }
        
        // Forçar uma atualização imediata

        performUpdate()
        startAnimationLoop()
    }
    
    func hideOverlay() {
        for window in overlayWindows {
            window.orderOut(nil)
        }
        stopAnimationLoop()
    }
    
    func updateGrainIntensity(_ intensity: Double) {
        guard currentIntensity != intensity else { return }
        currentIntensity = intensity
        scheduleSettingsUpdate()
    }
    
    func updatePreserveBrightness(_ preserve: Bool) {
        guard currentPreserveBrightness != preserve else { return }
        currentPreserveBrightness = preserve
        scheduleSettingsUpdate()
    }
    
    func updateGrainAnimated(_ animated: Bool) {
        guard currentGrainAnimated != animated else { return }
        currentGrainAnimated = animated
        for grainView in grainViews {
            grainView.isAnimated = animated
        }
        if animated {
            restartAnimationLoopIfVisible()
        } else {
            stopAnimationLoop()
        }
    }
    
    func updateMatteMode(_ matteMode: Bool) {
        guard currentMatteMode != matteMode else { return }
        currentMatteMode = matteMode
        scheduleSettingsUpdate()
    }
    
    // Implementa debouncing para evitar atualizações excessivas
    private func scheduleSettingsUpdate() {
        guard !pendingSettingsUpdate else { return }
        
        pendingSettingsUpdate = true
        settingsUpdateTimer?.invalidate()
        
        settingsUpdateTimer = Timer.scheduledTimer(withTimeInterval: settingsDebounceInterval, repeats: false) { _ in
            self.performUpdate()
            self.pendingSettingsUpdate = false
        }
    }
    
    private func performUpdate() {
        for (index, window) in overlayWindows.enumerated() {
            guard index < grainViews.count else { continue }
            let grainView = grainViews[index]
            
            grainView.intensity = currentIntensity
            grainView.preserveBrightness = currentPreserveBrightness
            grainView.isAnimated = currentGrainAnimated
            grainView.isMatteMode = currentMatteMode
            if let screen = window.screen ?? NSScreen.main {
                grainView.configureForScreen(screen)
                grainView.applyScale(screen.backingScaleFactor)
            }
            
            // Forçar redesenho
            grainView.needsDisplay = true
            window.display()
        }
        
        // Força refresh das janelas para garantir aplicação uniforme
        refreshAllWindows()
    }
    
    private func startAnimationLoop() {
        stopAnimationLoop()
        
        let timer = Timer(timeInterval: animationInterval, repeats: true) { [weak self] _ in
            self?.advanceAnimationFrame()
        }
        timer.tolerance = animationInterval * 0.25
        RunLoop.main.add(timer, forMode: .common)
        animationTimer = timer
    }
    
    private func stopAnimationLoop() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    private func restartAnimationLoopIfVisible() {
        if overlayWindows.contains(where: { $0.isVisible }) {
            startAnimationLoop()
        }
    }
    
    private func advanceAnimationFrame() {
        for grainView in grainViews {
            grainView.advanceAnimationFrame()
        }
    }
    
    private func refreshAllWindows() {
        for window in overlayWindows {
            if window.isVisible {
                window.invalidateShadow()
                window.viewsNeedDisplay = true
                if let contentView = window.contentView {
                    contentView.needsDisplay = true
                }
            }
        }
    }
}
