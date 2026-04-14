import AppKit

let app = NSApplication.shared
app.setActivationPolicy(.regular)

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let screen = NSScreen.main!
        window = NSWindow(contentRect: NSRect(x: 100, y: 100, width: 400, height: 400),
                          styleMask: [.borderless],
                          backing: .buffered,
                          defer: false)
        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .floating
        window.hasShadow = false
        
        let view = NSView(frame: window.contentRect(forFrameRect: window.frame))
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.gray.cgColor
        view.layer?.compositingFilter = CIFilter(name: "CIOverlayBlendMode")
        
        window.contentView = view
        window.makeKeyAndOrderFront(nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            NSApp.terminate(nil)
        }
    }
}

let delegate = AppDelegate()
app.delegate = delegate
app.run()
