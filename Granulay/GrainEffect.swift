import AppKit
import CoreGraphics
import Foundation
import QuartzCore
import SwiftUI

struct GrainParams {
    let blockSize: Int
    let contrast: Double
    let meanShift: Int
    let tint: (r: Double, g: Double, b: Double)
}

class GrainTextureCache {
    static let shared = GrainTextureCache()
    private var cache: [String: CGImage] = [:]
    
    // Default params that act as the only grain base style now
    private let defaultParams = GrainParams(blockSize: 2, contrast: 0.50, meanShift: 0, tint: (1, 1, 1))
    
    // We target ~2048x2048 to cover a 1024pt display at @2x natively.
    private let targetPhysicalPixels = 2048
    
    private init() {}
    
    func cgImage() -> CGImage? {
        if let cached = cache["default"] {
            return cached
        }
        guard let texture = createGrainTexture(physicalPixels: targetPhysicalPixels, params: defaultParams) else {
            return nil
        }
        cache["default"] = texture
        return texture
    }

    func preloadTextures() {
        DispatchQueue.global(qos: .userInitiated).async {
            if self.cache["default"] == nil,
               let texture = createGrainTexture(physicalPixels: self.targetPhysicalPixels, params: self.defaultParams) {
                DispatchQueue.main.async {
                    self.cache["default"] = texture
                }
            }
        }
    }
}

func createGrainTexture(physicalPixels: Int, params: GrainParams) -> CGImage? {
    let size = physicalPixels
    let blockSize = params.blockSize
    let contrast = params.contrast
    let meanShift = params.meanShift
    
    let isRGB = params.tint.r != 1.0 || params.tint.g != 1.0 || params.tint.b != 1.0
    let bytesPerPixel = isRGB ? 4 : 1
    let totalBytes = size * size * bytesPerPixel
    
    let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: totalBytes)
    defer { buffer.deallocate() }
    
    // Create random noise at actual size / blockSize
    let blockGridSize = (size + blockSize - 1) / blockSize
    let noiseBytes = blockGridSize * blockGridSize
    var randomBuffer = [UInt8](repeating: 0, count: noiseBytes)
    arc4random_buf(&randomBuffer, noiseBytes)
    
    if isRGB {
        let rMult = params.tint.r
        let gMult = params.tint.g
        let bMult = params.tint.b
        
        for y in 0..<size {
            for x in 0..<size {
                let bx = x / blockSize
                let by = y / blockSize
                let noiseVal = randomBuffer[by * blockGridSize + bx]
                
                // noise: 0-255 -> -127 to 127
                let centered = Double(noiseVal) - 127.0
                let scaled = centered * contrast + Double(meanShift) + 127.0
                
                var r = scaled * rMult
                var g = scaled * gMult
                var b = scaled * bMult
                
                r = max(0, min(255, r))
                g = max(0, min(255, g))
                b = max(0, min(255, b))
                
                let idx = (y * size + x) * 4
                // RGBA or RGBX layout
                buffer[idx] = UInt8(r)
                buffer[idx + 1] = UInt8(g)
                buffer[idx + 2] = UInt8(b)
                buffer[idx + 3] = 255 // Alpha ignored but needed for padding usually
            }
        }
    } else {
        for y in 0..<size {
            for x in 0..<size {
                let bx = x / blockSize
                let by = y / blockSize
                let noiseVal = randomBuffer[by * blockGridSize + bx]
                
                let centered = Double(noiseVal) - 127.0
                let scaled = centered * contrast + Double(meanShift) + 127.0
                let val = max(0, min(255, scaled))
                
                buffer[y * size + x] = UInt8(val)
            }
        }
    }
    
    let data = Data(bytes: buffer, count: totalBytes)
    guard let provider = CGDataProvider(data: data as CFData) else { return nil }
    
    let colorSpace: CGColorSpace
    let bitmapInfo: CGBitmapInfo
    
    if isRGB {
        colorSpace = CGColorSpaceCreateDeviceRGB()
        bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue)
    } else {
        colorSpace = CGColorSpaceCreateDeviceGray()
        bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
    }
    
    return CGImage(
        width: size,
        height: size,
        bitsPerComponent: 8,
        bitsPerPixel: bytesPerPixel * 8,
        bytesPerRow: size * bytesPerPixel,
        space: colorSpace,
        bitmapInfo: bitmapInfo,
        provider: provider,
        decode: nil,
        shouldInterpolate: false,
        intent: .defaultIntent
    )
}

// MARK: - Notification Extensions
extension Notification.Name {
    static let updateFrequencyChanged = Notification.Name("updateFrequencyChanged")
}

class GrainLayerView: NSView {
    
    // MARK: - Properties
    
    var intensity: Double = 1.0 {
        didSet {
            if oldValue != intensity {
                updateLayerProperties()
            }
        }
    }
    
    var preserveBrightness: Bool = false {
        didSet {
            if oldValue != preserveBrightness {
                updateLayerProperties()
            }
        }
    }
    
    private var currentScale: CGFloat = 1.0
    
    // MARK: - Initialization
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupLayer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayer()
    }
    
    private func setupLayer() {
        self.wantsLayer = true
        self.layerContentsRedrawPolicy = .never
        self.layerContentsPlacement = .topLeft
        
        guard let layer = self.layer else { return }
        
        layer.magnificationFilter = .nearest
        layer.minificationFilter = .nearest
        layer.contentsGravity = .resize
        layer.isOpaque = false
        layer.needsDisplayOnBoundsChange = false
        layer.shouldRasterize = false
        layer.drawsAsynchronously = false
        layer.allowsEdgeAntialiasing = false
        layer.edgeAntialiasingMask = []
    }
    
    // MARK: - Public API
    
    func applyScale(_ scale: CGFloat) {
        if currentScale != scale {
            currentScale = scale
            self.layer?.contentsScale = scale
            updateTexture()
        }
    }
    
    // MARK: - Private Updates
    
    private func updateTexture() {
        guard let layer = self.layer else { return }
        layer.contents = GrainTextureCache.shared.cgImage()
    }
    
    private func updateLayerProperties() {
        guard let layer = self.layer else { return }
        
        if preserveBrightness {
            layer.opacity = Float(intensity * 0.35)
            layer.compositingFilter = CIFilter(name: "CIOverlayBlendMode")
        } else {
            layer.opacity = Float(intensity * 0.55)
            layer.compositingFilter = nil
        }
    }
}

// MARK: - SwiftUI Support
struct GrainEffect: NSViewRepresentable {
    let intensity: Double
    let preserveBrightness: Bool
    
    func makeNSView(context: Context) -> GrainLayerView {
        let view = GrainLayerView(frame: .zero)
        view.intensity = intensity
        view.preserveBrightness = preserveBrightness
        
        // Use the main screen scale for the preview
        if let screen = NSScreen.main {
            view.applyScale(screen.backingScaleFactor)
        }
        
        return view
    }
    
    func updateNSView(_ nsView: GrainLayerView, context: Context) {
        nsView.intensity = intensity
        nsView.preserveBrightness = preserveBrightness
    }
}
