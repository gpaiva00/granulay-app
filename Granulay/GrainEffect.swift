import AppKit
import CoreGraphics
import Foundation
import QuartzCore
import SwiftUI

struct GrainRenderTuning {
    static let atlasFrameCount = 12 // Quantidade de frames pré-gerados por textura para animação do grão.
    static let maxTextureDimension = 1600 // Limite máximo de dimensão para reduzir custo de memória/CPU em telas grandes.
    static let noiseAmplitude: Double = 46.0 // Intensidade máxima da variação de luminância aplicada ao ruído.
    static let spatialCorrelation: Double = 0.14 // Mistura entre pixel atual e vizinhos para evitar ruído totalmente aleatório.
    static let highFrequencyAmount: Double = 0.12 // Fração de micro-ruído adicionada para preservar detalhe fino.
    static let distributionClip: Double = 0.42 // Corte dos extremos da distribuição para evitar outliers visuais.
    static let temporalJitter: CGFloat = 0.003 // Pequeno deslocamento por frame para reduzir padrão estático percebido.
    static let baseAnimationInterval: TimeInterval = 1.0 / 12.0 // Cadência padrão de troca de frames da textura.
    static let minAnimationInterval: TimeInterval = 1.0 / 20.0 // Menor intervalo permitido (maior frequência).
    static let maxAnimationInterval: TimeInterval = 1.0 / 8.0 // Maior intervalo permitido (menor frequência).
    static let preserveBrightnessOpacityMultiplier: Double = 0.28 // Opacidade usada quando brilho é preservado.
    static let standardOpacityMultiplier: Double = 0.42 // Opacidade usada no modo normal de composição.
    static let intensityCurveExponent: Double = 0.92 // Curva não-linear para resposta mais natural do slider de intensidade.
    static let maxCachedAtlases = 6 // Limite de atlas mantidos em cache (política LRU simples).
    static let screenNumberDeviceKey = NSDeviceDescriptionKey("NSScreenNumber") // Chave de deviceDescription para identificar display.
}

struct GrainTextureKey: Hashable {
    let displayID: CGDirectDisplayID // Identificador físico/lógico da tela.
    let pixelWidth: Int // Largura da textura gerada em pixels.
    let pixelHeight: Int // Altura da textura gerada em pixels.
    let scaleBucket: Int // Bucket da escala para separar caches entre densidades diferentes.
}

private struct GrainTextureDescriptor {
    let key: GrainTextureKey // Chave usada para lookup e invalidação no cache.
    let pixelWidth: Int // Resolução efetiva horizontal da geração.
    let pixelHeight: Int // Resolução efetiva vertical da geração.
}

struct GrainTextureAtlas {
    let key: GrainTextureKey // Chave de cache correspondente ao atlas.
    let frames: [CGImage] // Sequência de frames usada para animar o grão.
}

private struct SplitMix64 {
    private var state: UInt64 // Estado interno do PRNG.
    
    init(seed: UInt64) {
        state = seed != 0 ? seed : 0x9E3779B97F4A7C15
    }
    
    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
    
    mutating func nextUnit() -> Double {
        let bits = next() >> 11
        return Double(bits) * (1.0 / Double(1 << 53))
    }
}

class GrainTextureCache {
    static let shared = GrainTextureCache() // Instância compartilhada para reutilizar atlas entre views.
    
    private let queue = DispatchQueue(label: "com.granulay.grain.texture.cache", qos: .userInitiated) // Serializa acesso ao cache.
    private var cache: [GrainTextureKey: GrainTextureAtlas] = [:] // Armazena atlas já gerados por chave.
    private var cacheOrder: [GrainTextureKey] = [] // Rastreia uso recente para remoção LRU.
    
    private init() {}
    
    func atlas(for screen: NSScreen?) -> GrainTextureAtlas? {
        guard let screen,
              let descriptor = Self.makeDescriptor(for: screen)
        else {
            return nil
        }
        
        return queue.sync {
            if let cachedAtlas = cache[descriptor.key] {
                touchCacheEntry(for: descriptor.key)
                return cachedAtlas
            }
            
            guard let atlas = createGrainAtlas(descriptor: descriptor) else {
                return nil
            }
            
            insertIntoCache(atlas)
            return atlas
        }
    }
    
    func preloadTextures(for screens: [NSScreen]) {
        let descriptors = screens.compactMap(Self.makeDescriptor)
        guard !descriptors.isEmpty else { return }
        
        queue.async {
            for descriptor in descriptors {
                if self.cache[descriptor.key] != nil {
                    continue
                }
                
                guard let atlas = createGrainAtlas(descriptor: descriptor) else {
                    continue
                }
                
                self.insertIntoCache(atlas)
            }
        }
    }
    
    private static func makeDescriptor(for screen: NSScreen) -> GrainTextureDescriptor? {
        let scale = max(1.0, screen.backingScaleFactor) // Garante escala válida para cálculo em pixels.
        let rawWidth = Int((screen.frame.width * scale).rounded())
        let rawHeight = Int((screen.frame.height * scale).rounded())
        
        guard rawWidth > 0, rawHeight > 0 else {
            return nil
        }
        
        let longestEdge = max(rawWidth, rawHeight) // Define referência para eventual downscale.
        let scaleDownRatio: CGFloat
        if longestEdge > GrainRenderTuning.maxTextureDimension {
            scaleDownRatio = CGFloat(GrainRenderTuning.maxTextureDimension) / CGFloat(longestEdge)
        } else {
            scaleDownRatio = 1.0
        }
        
        let pixelWidth = max(256, Int((CGFloat(rawWidth) * scaleDownRatio).rounded())) // Evita texturas pequenas demais.
        let pixelHeight = max(256, Int((CGFloat(rawHeight) * scaleDownRatio).rounded())) // Evita texturas pequenas demais.
        
        let displayID = (screen.deviceDescription[GrainRenderTuning.screenNumberDeviceKey] as? NSNumber)?
            .uint32Value ?? 0
        let key = GrainTextureKey(
            displayID: displayID,
            pixelWidth: pixelWidth,
            pixelHeight: pixelHeight,
            scaleBucket: Int((scale * 100.0).rounded())
        )
        
        return GrainTextureDescriptor(key: key, pixelWidth: pixelWidth, pixelHeight: pixelHeight)
    }
    
    private func insertIntoCache(_ atlas: GrainTextureAtlas) {
        cache[atlas.key] = atlas
        touchCacheEntry(for: atlas.key)
        trimCacheIfNeeded()
    }
    
    private func touchCacheEntry(for key: GrainTextureKey) {
        cacheOrder.removeAll { $0 == key }
        cacheOrder.append(key)
    }
    
    private func trimCacheIfNeeded() {
        while cacheOrder.count > GrainRenderTuning.maxCachedAtlases {
            let keyToRemove = cacheOrder.removeFirst()
            cache.removeValue(forKey: keyToRemove)
        }
    }
}

private func createGrainAtlas(descriptor: GrainTextureDescriptor) -> GrainTextureAtlas? {
    var frames: [CGImage] = []
    frames.reserveCapacity(GrainRenderTuning.atlasFrameCount) // Pré-aloca capacidade para reduzir realocações.
    
    let baseSeed =
        UInt64(descriptor.key.displayID) << 32
        ^ UInt64(descriptor.pixelWidth & 0xFFFF) << 16
        ^ UInt64(descriptor.pixelHeight & 0xFFFF)
        ^ UInt64(descriptor.key.scaleBucket & 0xFFFF) << 48
    var seedGenerator = SplitMix64(seed: baseSeed)
    
    for frameIndex in 0..<GrainRenderTuning.atlasFrameCount {
        let frameSeed = seedGenerator.next() ^ UInt64(frameIndex) &* 0x9E3779B185EBCA87
        guard let frame = createFineGrainFrame(
            pixelWidth: descriptor.pixelWidth,
            pixelHeight: descriptor.pixelHeight,
            seed: frameSeed
        ) else {
            return nil
        }
        frames.append(frame)
    }
    
    return GrainTextureAtlas(key: descriptor.key, frames: frames)
}

private func createFineGrainFrame(pixelWidth: Int, pixelHeight: Int, seed: UInt64) -> CGImage? {
    let pixelCount = pixelWidth * pixelHeight
    guard pixelCount > 0 else { return nil }
    
    var rng = SplitMix64(seed: seed)
    var baseNoise = [Float](repeating: 0, count: pixelCount) // Ruído base antes da modelagem espacial.
    
    for index in 0..<pixelCount {
        let centered = (rng.nextUnit() + rng.nextUnit() + rng.nextUnit()) / 3.0 - 0.5
        baseNoise[index] = Float(centered)
    }
    
    var shapedNoise = [Float](repeating: 0, count: pixelCount) // Ruído final após correlação e micro-detalhe.
    let correlation = Float(GrainRenderTuning.spatialCorrelation) // Peso da média de vizinhança.
    let highFrequency = Float(GrainRenderTuning.highFrequencyAmount) // Peso do ruído fino adicional.
    
    for y in 0..<pixelHeight {
        let rowStart = y * pixelWidth
        for x in 0..<pixelWidth {
            let idx = rowStart + x
            let current = baseNoise[idx]
            let left = x > 0 ? baseNoise[idx - 1] : current
            let right = x + 1 < pixelWidth ? baseNoise[idx + 1] : current
            let up = y > 0 ? baseNoise[idx - pixelWidth] : current
            let down = y + 1 < pixelHeight ? baseNoise[idx + pixelWidth] : current
            
            let neighborhood = (left + right + up + down) * 0.25
            let microNoise = Float(rng.nextUnit() - 0.5) * highFrequency
            shapedNoise[idx] = (current * (1.0 - correlation) + neighborhood * correlation) + microNoise
        }
    }
    
    var pixels = [UInt8](repeating: 0, count: pixelCount) // Buffer grayscale final em 8 bits.
    let clip = Float(GrainRenderTuning.distributionClip) // Limite da distribuição antes da conversão para luma.
    let amplitude = Float(GrainRenderTuning.noiseAmplitude) // Escala de contraste na conversão para luma.
    
    for index in 0..<pixelCount {
        var sample = shapedNoise[index]
        sample = min(clip, max(-clip, sample))
        
        let luma = 127.0 + sample * amplitude
        let rounded = Int(luma.rounded())
        pixels[index] = UInt8(min(255, max(0, rounded)))
    }
    
    guard let provider = CGDataProvider(data: Data(pixels) as CFData) else {
        return nil
    }
    
    return CGImage(
        width: pixelWidth, // Largura da textura.
        height: pixelHeight, // Altura da textura.
        bitsPerComponent: 8, // Precisão por canal.
        bitsPerPixel: 8, // Um único canal (grayscale).
        bytesPerRow: pixelWidth, // 1 byte por pixel.
        space: CGColorSpaceCreateDeviceGray(), // Espaço de cor cinza para textura de luminância.
        bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue), // Sem canal alpha.
        provider: provider, // Fonte dos bytes de pixel.
        decode: nil, // Sem remapeamento de faixa.
        shouldInterpolate: true, // Permite interpolação suave em escalas fracionárias.
        intent: .defaultIntent // Intent padrão de renderização.
    )
}

// MARK: - Notification Extensions
extension Notification.Name {
    static let updateFrequencyChanged = Notification.Name("updateFrequencyChanged")
}

class GrainLayerView: NSView {
    
    // MARK: - Properties
    
    var intensity: Double = 1.0 { // Intensidade do efeito de grão aplicada à opacidade da camada.
        didSet {
            if oldValue != intensity {
                updateLayerProperties()
            }
        }
    }
    
    var preserveBrightness: Bool = false { // Ativa modo de blend que preserva melhor brilho percebido.
        didSet {
            if oldValue != preserveBrightness {
                updateLayerProperties()
            }
        }
    }
    
    private var currentScale: CGFloat = 1.0 // Escala atual da tela para manter nitidez correta do conteúdo.
    private var textureAtlas: GrainTextureAtlas? // Atlas atualmente associado à tela da janela.
    private var currentFrameIndex = 0 // Índice do frame atual no atlas animado.
    private let softLightBlendFilter = CIFilter(name: "CISoftLightBlendMode") // Filtro reutilizado no modo preserveBrightness.
    
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
        wantsLayer = true
        layerContentsRedrawPolicy = .never // Evita redraw implícito; atualização é controlada manualmente.
        layerContentsPlacement = .topLeft // Mantém origem previsível para conteúdo e jitter.
        
        guard let layer else { return }
        
        layer.magnificationFilter = .linear // Suaviza ampliação da textura em escalas altas.
        layer.minificationFilter = .linear // Suaviza redução para evitar aliasing perceptível.
        layer.contentsGravity = .resize // Faz o conteúdo acompanhar o tamanho da view.
        layer.isOpaque = false // Mantém transparência para overlay.
        layer.needsDisplayOnBoundsChange = false // Evita redraw automático em toda mudança de bounds.
        layer.shouldRasterize = false // Evita raster extra desnecessário para conteúdo já texturizado.
        layer.drawsAsynchronously = true // Permite pipeline de desenho mais fluido.
        layer.allowsEdgeAntialiasing = false // Desliga AA de borda para evitar halo.
        layer.edgeAntialiasingMask = [] // Sem mascaramento de AA em bordas.
        
        updateLayerProperties()
    }
    
    // MARK: - Public API
    
    func configureForScreen(_ screen: NSScreen?) {
        guard let atlas = GrainTextureCache.shared.atlas(for: screen) else {
            return
        }
        
        if textureAtlas?.key != atlas.key || textureAtlas == nil {
            textureAtlas = atlas
            currentFrameIndex = 0
            applyCurrentFrame()
        }
    }
    
    func applyScale(_ scale: CGFloat) {
        if currentScale != scale {
            currentScale = scale
            layer?.contentsScale = scale
            configureForScreen(window?.screen)
            updateTexture()
        }
    }
    
    func advanceAnimationFrame() {
        guard let textureAtlas else {
            configureForScreen(window?.screen)
            return
        }
        
        guard !textureAtlas.frames.isEmpty else { return }
        
        currentFrameIndex = (currentFrameIndex + 1) % textureAtlas.frames.count
        applyCurrentFrame()
    }
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        configureForScreen(window?.screen)
        if let screen = window?.screen {
            applyScale(screen.backingScaleFactor)
        }
    }
    
    // MARK: - Private Updates
    
    private func updateTexture() {
        guard textureAtlas != nil else {
            configureForScreen(window?.screen)
            return
        }
        applyCurrentFrame()
    }
    
    private func updateLayerProperties() {
        guard let layer else { return }
        
        let clampedIntensity = min(1.0, max(0.0, intensity)) // Limita entrada ao intervalo esperado.
        let curvedIntensity = pow(clampedIntensity, GrainRenderTuning.intensityCurveExponent) // Aplica curva perceptual.
        
        if preserveBrightness {
            layer.opacity = Float(curvedIntensity * GrainRenderTuning.preserveBrightnessOpacityMultiplier)
            if layer.compositingFilter == nil {
                layer.compositingFilter = softLightBlendFilter
            }
        } else {
            layer.opacity = Float(curvedIntensity * GrainRenderTuning.standardOpacityMultiplier)
            if layer.compositingFilter != nil {
                layer.compositingFilter = nil
            }
        }
    }
    
    private func applyCurrentFrame() {
        guard let layer,
              let textureAtlas,
              !textureAtlas.frames.isEmpty
        else {
            return
        }
        
        let clampedIndex = max(0, min(currentFrameIndex, textureAtlas.frames.count - 1))
        layer.contents = textureAtlas.frames[clampedIndex]
        applyTemporalJitter()
    }
    
    private func applyTemporalJitter() {
        guard let layer else { return }
        
        let jitter = GrainRenderTuning.temporalJitter
        guard jitter > 0 else {
            layer.contentsRect = CGRect(x: 0, y: 0, width: 1, height: 1)
            return
        }
        
        let offsetX = CGFloat.random(in: -jitter...jitter)
        let offsetY = CGFloat.random(in: -jitter...jitter)
        
        layer.contentsRect = CGRect(
            x: max(0, offsetX),
            y: max(0, offsetY),
            width: 1.0 - abs(offsetX),
            height: 1.0 - abs(offsetY)
        )
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
            view.configureForScreen(screen)
            view.applyScale(screen.backingScaleFactor)
        }
        
        return view
    }
    
    func updateNSView(_ nsView: GrainLayerView, context: Context) {
        nsView.intensity = intensity
        nsView.preserveBrightness = preserveBrightness
        nsView.configureForScreen(nsView.window?.screen ?? NSScreen.main)
    }
}
