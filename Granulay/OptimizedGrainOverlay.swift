import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

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
}

struct GrainEffect: View {
    let intensity: Double
    let style: GrainStyle
    let screenSize: CGSize
    let preserveBrightness: Bool
    
    @State private var grainTexture: NSImage?
    
    var body: some View {
        Rectangle()
            .fill(Color.clear)
            .overlay(
                Image(nsImage: grainTexture ?? NSImage())
                    .resizable(resizingMode: .tile)
                    .opacity(intensity)
                    .blendMode(preserveBrightness ? .overlay : .multiply)
                    .allowsHitTesting(false)
            )
            .onAppear {
                generateGrainTexture()
            }
            .onChange(of: style) { _ in
                generateGrainTexture()
            }
    }
    
    private func generateGrainTexture() {
        DispatchQueue.global(qos: .userInitiated).async {
            let texture = createGrainTexture(size: CGSize(width: 512, height: 512), style: style)
            
            DispatchQueue.main.async {
                self.grainTexture = texture
            }
        }
    }
}

func createGrainTexture(size: CGSize, style: GrainStyle) -> NSImage? {
    let context = CIContext()
    
    guard let noiseFilter = CIFilter(name: "CIRandomGenerator") else { return nil }
    
    guard let noiseImage = noiseFilter.outputImage else { return nil }
    
    guard let scaleFilter = CIFilter(name: "CILanczosScaleTransform") else { return nil }
    scaleFilter.setValue(noiseImage, forKey: kCIInputImageKey)
    scaleFilter.setValue(style.noiseScale, forKey: kCIInputScaleKey)
    
    guard let scaledNoise = scaleFilter.outputImage else { return nil }
    
    guard let cropFilter = CIFilter(name: "CICrop") else { return nil }
    cropFilter.setValue(scaledNoise, forKey: kCIInputImageKey)
    cropFilter.setValue(CIVector(cgRect: CGRect(origin: .zero, size: size)), forKey: "inputRectangle")
    
    guard let croppedImage = cropFilter.outputImage else { return nil }
    
    guard let colorFilter = CIFilter(name: "CIColorMatrix") else { return nil }
    colorFilter.setValue(croppedImage, forKey: kCIInputImageKey)
    
    switch style {
    case .fine:
        colorFilter.setValue(CIVector(x: 0.2, y: 0.2, z: 0.2, w: 0), forKey: "inputRVector")
        colorFilter.setValue(CIVector(x: 0.2, y: 0.2, z: 0.2, w: 0), forKey: "inputGVector")
        colorFilter.setValue(CIVector(x: 0.2, y: 0.2, z: 0.2, w: 0), forKey: "inputBVector")
    case .medium:
        colorFilter.setValue(CIVector(x: 0.3, y: 0.3, z: 0.3, w: 0), forKey: "inputRVector")
        colorFilter.setValue(CIVector(x: 0.3, y: 0.3, z: 0.3, w: 0), forKey: "inputGVector")
        colorFilter.setValue(CIVector(x: 0.3, y: 0.3, z: 0.3, w: 0), forKey: "inputBVector")
    case .coarse:
        colorFilter.setValue(CIVector(x: 0.4, y: 0.4, z: 0.4, w: 0), forKey: "inputRVector")
        colorFilter.setValue(CIVector(x: 0.4, y: 0.4, z: 0.4, w: 0), forKey: "inputGVector")
        colorFilter.setValue(CIVector(x: 0.4, y: 0.4, z: 0.4, w: 0), forKey: "inputBVector")
    case .vintage:
        colorFilter.setValue(CIVector(x: 0.35, y: 0.25, z: 0.15, w: 0), forKey: "inputRVector")
        colorFilter.setValue(CIVector(x: 0.25, y: 0.35, z: 0.25, w: 0), forKey: "inputGVector")
        colorFilter.setValue(CIVector(x: 0.15, y: 0.25, z: 0.35, w: 0), forKey: "inputBVector")
    }
    
    guard let finalImage = colorFilter.outputImage else { return nil }
    
    guard let cgImage = context.createCGImage(finalImage, from: finalImage.extent) else { return nil }
    
    return NSImage(cgImage: cgImage, size: size)
}