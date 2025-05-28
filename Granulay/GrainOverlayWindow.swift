import SwiftUI
import AppKit

class GrainOverlayWindow: NSObject {
    private var overlayWindows: [NSWindow] = []
    private var hostingViews: [NSHostingView<GrainEffect>] = []
    private var currentIntensity: Double = 0.3
    private var currentStyle: GrainStyle = .fine
    private var currentPreserveBrightness: Bool = true
    
    override init() {
        super.init()
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
        
        let grainEffect = GrainEffect(
            intensity: currentIntensity,
            style: currentStyle,
            screenSize: screen.frame.size,
            preserveBrightness: currentPreserveBrightness
        )
        
        let hostingView = NSHostingView(rootView: grainEffect)
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
        for window in overlayWindows {
            window.orderFrontRegardless()
        }
    }
    
    func hideOverlay() {
        for window in overlayWindows {
            window.orderOut(nil)
        }
    }
    
    func updateGrainIntensity(_ intensity: Double) {
        currentIntensity = intensity
        updateAllViews()
    }
    
    func updateGrainStyle(_ style: GrainStyle) {
        currentStyle = style
        updateAllViews()
    }
    
    func updatePreserveBrightness(_ preserve: Bool) {
        currentPreserveBrightness = preserve
        updateAllViews()
    }
    
    private func updateAllViews() {
        for (index, window) in overlayWindows.enumerated() {
            guard index < NSScreen.screens.count else { continue }
            
            let screen = NSScreen.screens[index]
            let grainEffect = GrainEffect(
                intensity: currentIntensity,
                style: currentStyle,
                screenSize: screen.frame.size,
                preserveBrightness: currentPreserveBrightness
            )
            
            let hostingView = NSHostingView(rootView: grainEffect)
            window.contentView = hostingView
        }
    }
}