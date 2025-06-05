import Combine
import CoreImage
import CoreImage.CIFilterBuiltins
import QuartzCore
import SwiftUI

enum GrainStyle: String, CaseIterable {
    case fine = "Fino"
    case medium = "Médio"
    case coarse = "Grosso"
    case vintage = "Vintage"

    var noiseScale: Float {
        switch self {
        case .fine: return 0.5
        case .medium: return 1.0
        case .coarse: return 2.0
        case .vintage: return 1.5
        }
    }

    var grainSize: CGFloat {
        switch self {
        case .fine: return 1.0
        case .medium: return 2.0
        case .coarse: return 3.0
        case .vintage: return 2.5
        }
    }

    var recommendedIntensity: Double {
        switch self {
        case .fine: return 0.1
        case .medium: return 0.2
        case .coarse: return 0.3
        case .vintage: return 0.25
        }
    }
}

class GrainTextureCache {
    static let shared = GrainTextureCache()
    private var cache: [String: NSImage] = [:]
    private let queue = DispatchQueue(label: "grain.texture.cache", qos: .userInitiated)
    private var currentTextureSize = CGSize(width: 512, height: 512)
    internal let ciContext: CIContext

    private init() {
        self.ciContext = CIContext(options: [
            .workingColorSpace: NSNull(),
            .outputColorSpace: NSNull(),
            .useSoftwareRenderer: false,
        ])
        setupPerformanceOptimizations()
    }

    func getTexture(for style: GrainStyle, completion: @escaping (NSImage?) -> Void) {
        let key =
            "\(style.rawValue)_\(Int(currentTextureSize.width))x\(Int(currentTextureSize.height))"

        queue.async {
            if let cachedTexture = self.cache[key] {
                DispatchQueue.main.async {
                    completion(cachedTexture)
                }
                return
            }

            let texture = createGrainTexture(size: self.currentTextureSize, style: style)

            if let texture = texture {
                self.cache[key] = texture
            }

            DispatchQueue.main.async {
                completion(texture)
            }
        }
    }

    func preloadTextures() {
        queue.async {
            for style in GrainStyle.allCases {
                let key =
                    "\(style.rawValue)_\(Int(self.currentTextureSize.width))x\(Int(self.currentTextureSize.height))"
                if self.cache[key] == nil {
                    let texture = createGrainTexture(size: self.currentTextureSize, style: style)
                    if let texture = texture {
                        self.cache[key] = texture
                    }
                }
            }
        }
    }

    private func setupPerformanceOptimizations() {
        NotificationCenter.default.addObserver(
            forName: .textureQualityChanged,
            object: nil,
            queue: .main
        ) { notification in
            if let newSize = notification.object as? CGSize {
                self.adjustTextureQuality(size: newSize)
            }
        }
    }

    private func adjustTextureQuality(size: CGSize) {
        currentTextureSize = size

        queue.async {
            // Limpa cache antigo
            self.cache.removeAll()

            // Regenera texturas com nova qualidade
            for style in GrainStyle.allCases {
                let key = "\(style.rawValue)_\(Int(size.width))x\(Int(size.height))"
                let texture = createGrainTexture(size: size, style: style)
                if let texture = texture {
                    self.cache[key] = texture
                }
            }
        }
    }
}

struct GrainEffect: View {
    let intensity: Double
    let style: GrainStyle
    let screenSize: CGSize
    let preserveBrightness: Bool

    @State private var grainTexture: NSImage?
    @State private var isTextureLoading = false

    var body: some View {
        if #available(macOS 14.0, *) {
            Rectangle()
                .fill(Color.clear)
                .overlay(
                    Group {
                        if let texture = grainTexture {
                            Image(nsImage: texture)
                                .resizable(resizingMode: .tile)
                                .opacity(intensity)
                                .blendMode(preserveBrightness ? .overlay : .multiply)
                                .allowsHitTesting(false)
                                .drawingGroup(opaque: false, colorMode: .nonLinear)
                                .animation(.easeInOut(duration: 0.1), value: intensity)
                        } else {
                            Color.clear
                        }
                    }
                )
                .onAppear {
                    loadTextureIfNeeded()
                }
                .onChange(of: style) { oldValue, newValue in
                    loadTextureIfNeeded()
                }
        } else {
            // Fallback on earlier versions
        }
    }

    private func loadTextureIfNeeded() {
        guard !isTextureLoading else { return }

        isTextureLoading = true
        GrainTextureCache.shared.getTexture(for: style) { texture in
            self.grainTexture = texture
            self.isTextureLoading = false
        }
    }
}

func createGrainTexture(size: CGSize, style: GrainStyle) -> NSImage? {
    // Usa o ciContext compartilhado da classe GrainTextureCache
    let context = GrainTextureCache.shared.ciContext

    guard let noiseFilter = CIFilter(name: "CIRandomGenerator") else { return nil }

    guard let noiseImage = noiseFilter.outputImage else { return nil }

    guard let scaleFilter = CIFilter(name: "CILanczosScaleTransform") else { return nil }
    scaleFilter.setValue(noiseImage, forKey: kCIInputImageKey)
    scaleFilter.setValue(style.noiseScale, forKey: kCIInputScaleKey)

    guard let scaledNoise = scaleFilter.outputImage else { return nil }

    guard let cropFilter = CIFilter(name: "CICrop") else { return nil }
    cropFilter.setValue(scaledNoise, forKey: kCIInputImageKey)
    cropFilter.setValue(
        CIVector(cgRect: CGRect(origin: .zero, size: size)), forKey: "inputRectangle")

    guard let croppedImage = cropFilter.outputImage else { return nil }

    guard let colorFilter = CIFilter(name: "CIColorMatrix") else { return nil }
    colorFilter.setValue(croppedImage, forKey: kCIInputImageKey)

    switch style {
    case .fine:
        colorFilter.setValue(CIVector(x: 0.08, y: 0.08, z: 0.08, w: 0), forKey: "inputRVector")
        colorFilter.setValue(CIVector(x: 0.08, y: 0.08, z: 0.08, w: 0), forKey: "inputGVector")
        colorFilter.setValue(CIVector(x: 0.08, y: 0.08, z: 0.08, w: 0), forKey: "inputBVector")
    case .medium:
        colorFilter.setValue(CIVector(x: 0.2, y: 0.2, z: 0.2, w: 0), forKey: "inputRVector")
        colorFilter.setValue(CIVector(x: 0.2, y: 0.2, z: 0.2, w: 0), forKey: "inputGVector")
        colorFilter.setValue(CIVector(x: 0.2, y: 0.2, z: 0.2, w: 0), forKey: "inputBVector")
    case .coarse:
        colorFilter.setValue(CIVector(x: 0.25, y: 0.25, z: 0.25, w: 0), forKey: "inputRVector")
        colorFilter.setValue(CIVector(x: 0.25, y: 0.25, z: 0.25, w: 0), forKey: "inputGVector")
        colorFilter.setValue(CIVector(x: 0.25, y: 0.25, z: 0.25, w: 0), forKey: "inputBVector")
    case .vintage:
        colorFilter.setValue(CIVector(x: 0.35, y: 0.25, z: 0.15, w: 0), forKey: "inputRVector")
        colorFilter.setValue(CIVector(x: 0.25, y: 0.35, z: 0.25, w: 0), forKey: "inputGVector")
        colorFilter.setValue(CIVector(x: 0.15, y: 0.25, z: 0.35, w: 0), forKey: "inputBVector")
    }

    guard let finalImage = colorFilter.outputImage else { return nil }

    guard let cgImage = context.createCGImage(finalImage, from: finalImage.extent) else {
        return nil
    }

    return NSImage(cgImage: cgImage, size: size)
}

// MARK: - GrainStyle Extension for Hybrid Implementation
extension GrainStyle {
    var colorComponents: (CGFloat, CGFloat, CGFloat) {
        switch self {
        case .fine: return (0.2, 0.2, 0.2)
        case .medium: return (0.3, 0.3, 0.3)
        case .coarse: return (0.4, 0.4, 0.4)
        case .vintage: return (0.35, 0.25, 0.15)
        }
    }
}

// MARK: - Notification Extensions
extension Notification.Name {
    static let textureQualityChanged = Notification.Name("textureQualityChanged")
    static let updateFrequencyChanged = Notification.Name("updateFrequencyChanged")
}
