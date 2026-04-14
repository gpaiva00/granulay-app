import AppKit
import CoreGraphics

let app = NSApplication.shared
app.setActivationPolicy(.regular)

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
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
        
        // Generate test texture (black/white dots with alpha)
        let w = 400
        let h = 400
        var pixels = [UInt8](repeating: 0, count: w * h * 4)
        for i in 0..<(w*h) {
            let rnd = Float.random(in: -1...1)
            let alpha: Float
            let color: UInt8
            if rnd > 0.5 {
                alpha = (rnd - 0.5) * 2.0 * 255.0
                color = 255
            } else if rnd < -0.5 {
                alpha = (-rnd - 0.5) * 2.0 * 255.0
                color = 0
            } else {
                alpha = 0
                color = 0
            }
            let alphaInt = UInt8(alpha)
            let premul = (color == 255) ? alphaInt : 0
            pixels[i*4] = premul
            pixels[i*4+1] = premul
            pixels[i*4+2] = premul
            pixels[i*4+3] = alphaInt
        }
        let provider = CGDataProvider(data: Data(pixels) as CFData)!
        let cgImage = CGImage(width: w, height: h, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: w*4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue), provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)
        
        view.layer?.contents = cgImage
        view.layer?.opacity = 0.8
        
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
