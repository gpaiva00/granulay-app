import SwiftUI
import AppKit
import Combine

class GrainOverlayWindow: NSObject, ObservableObject {
    private var overlayWindows: [NSWindow] = []
    private var hostingViews: [NSHostingView<GrainEffect>] = []
    private var currentIntensity: Double = 0.3
    private var currentStyle: GrainStyle = .medium
    private var currentPreserveBrightness: Bool = true
    private var updateTimer: Timer?
    private var pendingUpdate = false
    private var updateInterval: TimeInterval = 0.05
    
    override init() {
        super.init()
        
        // Preload texturas para melhor performance
        GrainTextureCache.shared.preloadTextures()
        
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
        NotificationCenter.default.removeObserver(self)
        updateTimer?.invalidate()
    }
    
    private func setupPerformanceOptimizations() {
        NotificationCenter.default.addObserver(
            forName: .updateFrequencyChanged,
            object: nil,
            queue: .main
        ) { notification in
            if let newInterval = notification.object as? TimeInterval {
                self.updateInterval = newInterval
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
        
        let grainEffect = GrainEffect(
            intensity: currentIntensity,
            style: currentStyle,
            screenSize: screen.frame.size,
            preserveBrightness: currentPreserveBrightness
        )
        
        let hostingView = NSHostingView(rootView: grainEffect)
        hostingView.frame = screen.frame
        hostingViews.append(hostingView)
        
        window.contentView = hostingView
        
        return window
    }
    
    private func clearOverlayWindows() {
        for window in overlayWindows {
            window.orderOut(nil)
        }
        overlayWindows.removeAll()
        hostingViews.removeAll()
    }
    
    @objc private func screenConfigurationChanged() {
        DispatchQueue.main.async {
            let wasVisible = !self.overlayWindows.isEmpty && self.overlayWindows.first?.isVisible == true
            
            self.setupOverlayWindows()
            
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
        for (_, window) in overlayWindows.enumerated() {

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
    }
    
    func hideOverlay() {
        for window in overlayWindows {
            window.orderOut(nil)
        }
    }
    
    func updateGrainIntensity(_ intensity: Double) {
        currentIntensity = intensity
        scheduleUpdate()
    }
    
    func updateGrainStyle(_ style: GrainStyle) {
        currentStyle = style
        scheduleUpdate()
    }
    
    func updatePreserveBrightness(_ preserve: Bool) {
        currentPreserveBrightness = preserve
        scheduleUpdate()
    }
    
    // Implementa debouncing para evitar atualizações excessivas
    private func scheduleUpdate() {
        guard !pendingUpdate else { return }
        
        pendingUpdate = true
        updateTimer?.invalidate()
        
        updateTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: false) { _ in
            self.performUpdate()
            self.pendingUpdate = false
        }
    }
    
    private func performUpdate() {
        for (index, hostingView) in hostingViews.enumerated() {
            guard index < NSScreen.screens.count else { continue }
            
            let screen = NSScreen.screens[index]
            let grainEffect = GrainEffect(
                intensity: currentIntensity,
                style: currentStyle,
                screenSize: screen.frame.size,
                preserveBrightness: currentPreserveBrightness
            )
            
            // Atualiza a view existente ao invés de recriar
            hostingView.rootView = grainEffect
            
            // Forçar redesenho
            hostingView.needsDisplay = true
            if index < overlayWindows.count {
                overlayWindows[index].display()
            }
        }
        
        // Força refresh das janelas para garantir aplicação uniforme
        refreshAllWindows()
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
