import AppKit
import CoreGraphics
import Foundation
import QuartzCore
import SwiftUI

/// Central configuration for the grain effect rendering.
/// Defines parameters like texture size limits, animation framerates, and noise generation tuning.
struct GrainRenderTuning {
    static let atlasFrameCount = 12 // Quantidade de frames pré-gerados por textura para animação do grão.
    static let maxTextureDimension = 1600 // Limite máximo de dimensão para reduzir custo de memória/CPU em telas grandes.
    static let noiseAmplitude: Double = 85.0 // Intensidade máxima da variação de luminância aplicada ao ruído.
    static let spatialCorrelation: Double = 0.14 // Mistura entre pixel atual e vizinhos para evitar ruído totalmente aleatório.
    static let highFrequencyAmount: Double = 0.12 // Fração de micro-ruído adicionada para preservar detalhe fino.
    static let distributionClip: Double = 0.42 // Corte dos extremos da distribuição para evitar outliers visuais.
    static let temporalJitter: CGFloat = 0.003 // Pequeno deslocamento por frame para reduzir padrão estático percebido.
    static let baseAnimationInterval: TimeInterval = 1.0 / 12.0 // Cadência padrão de troca de frames da textura.
    static let minAnimationInterval: TimeInterval = 1.0 / 20.0 // Menor intervalo permitido (maior frequência).
    static let maxAnimationInterval: TimeInterval = 1.0 / 8.0 // Maior intervalo permitido (menor frequência).
    static let preserveBrightnessOpacityMultiplier: Double = 0.15 // Opacidade usada quando brilho é preservado (alpha base).
    static let standardOpacityMultiplier: Double = 0.28 // Opacidade usada no modo normal de composição (alpha base).
    static let matteOpacityMultiplier: Double = 0.24 // Matte usa alpha um pouco menor para reduzir aspecto "frosted" sem perder presença.
    static let intensityCurveExponent: Double = 0.65 // Curva não-linear para resposta mais natural do slider de intensidade.
    static let maxCachedAtlases = 6 // Limite de atlas mantidos em cache (política LRU simples).
    static let screenNumberDeviceKey = NSDeviceDescriptionKey("NSScreenNumber") // Chave de deviceDescription para identificar display.
}

/// Tuning for the frosted-film matte mode.
///
/// The matte mode is a two-layer composite that simulates real frosted emulsion film rather
/// than a flat screen haze:
///   • **Cloud diffusion layer** (≈60% of perceived density): a low-frequency, multi-pass
///     smoothed noise field rendered at low resolution and bilinearly upscaled by Core
///     Animation. Produces patchy, non-uniform density — the single strongest cue that the
///     overlay is a physical material. A slow `contentsRect` pan adds subtle "breathing"
///     without per-frame CPU cost.
///   • **Emulsion grain layer** (≈40% of perceived density): anisotropic shaped noise with
///     slight horizontal bias (fiber feel) and occasional highlight sparkles with subtle
///     warm/cool chromatic splits, approximating silver-halide scatter.
struct MatteGrainTuning {
    // 60/40 diffusion-first split of the matte opacity budget. Cloud carries the bulk of
    // perceived density so emulsion specks read *over* the frosted base rather than
    // dominating it. These must sum to 1.0.
    static let grainDensityShare: Double = 0.40
    static let cloudDensityShare: Double = 0.60

    // Emulsion micro-grain layer (~40% of density).
    static let grainHazeAlpha: Int = 52           // Base alpha for grain layer; cloud carries the bulk of density now.
    static let grainHazeAmplitude: Int = 34       // Local variation amplitude on top of the base haze.
    static let horizontalCorrelation: Double = 0.38 // Stronger lateral neighbor pull → fiber-like anisotropy.
    static let verticalCorrelation: Double = 0.16   // Weaker vertical pull so grain doesn't average into mush.
    static let distributionClip: Double = 0.40    // Clip extremes of the shaped distribution.
    static let highlightThreshold: Double = 0.9975 // Probability gate for emulsion highlight seeds.
    static let highlightCoreAlpha: Int = 210      // Core alpha of a highlight pixel.
    static let highlightNeighborAlphaBoost: Int = 38 // Neighbor bloom around highlights.
    static let highlightWarmShift: Int = 9        // Slight R bias on highlights (silver-halide warm scatter).
    static let highlightCoolShift: Int = 7        // Slight B bias on highlights (cool scatter).

    // Cloud diffusion layer (~60% of density).
    static let cloudDownsample: Int = 12          // Low-res generation factor; CA linear filter upscales smoothly.
    static let cloudBaseAlpha: Int = 82           // Mean alpha of the cloud field.
    static let cloudAmplitude: Int = 48           // Peak deviation around the mean — drives patchiness.
    static let cloudBlurPasses: Int = 3           // Box-blur iterations on noise for soft-cloud spectrum.
    static let cloudMidFrequencyMix: Double = 0.28 // Fraction of less-smoothed noise re-added for mid-frequency detail.
    static let cloudRadialBoost: Double = 0.06    // Subtle edge density gain for physical "presence."
    static let cloudPanRange: CGFloat = 0.045     // Fraction of contentsRect that drifts during animation.
    static let cloudPanDuration: CFTimeInterval = 11.0 // Full drift cycle (autoreversed) — slow breathing.
    static let cloudMinResolution: Int = 64       // Lower bound on cloud texture dimension so tiny screens still get detail.
}

struct GrainTextureKey: Hashable {
    let displayID: CGDirectDisplayID // Identificador físico/lógico da tela.
    let pixelWidth: Int // Largura da textura gerada em pixels.
    let pixelHeight: Int // Altura da textura gerada em pixels.
    let scaleBucket: Int // Bucket da escala para separar caches entre densidades diferentes.
    let isMatteMode: Bool // Se a textura foi gerada para modo matte
}

private struct GrainTextureDescriptor {
    let key: GrainTextureKey // Chave usada para lookup e invalidação no cache.
    let pixelWidth: Int // Resolução efetiva horizontal da geração.
    let pixelHeight: Int // Resolução efetiva vertical da geração.
}

struct GrainTextureAtlas {
    let key: GrainTextureKey // Chave de cache correspondente ao atlas.
    let frames: [CGImage] // Sequência de frames usada para animar o grão.
    /// Low-resolution cloud diffusion texture for matte (frosted-film) mode. `nil` for fine mode.
    /// Rendered on a sibling `CALayer` behind the grain, upscaled by Core Animation's bilinear filter.
    let cloudFrame: CGImage?
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

/// `GrainTextureCache` is a thread-safe singleton responsible for caching procedurally
/// generated noise textures (`GrainTextureAtlas`).
///
/// Generating large noise textures is computationally expensive. This cache ensures that
/// textures are only generated once per display resolution and scale factor. It uses
/// a simple Least Recently Used (LRU) policy to evict old atlases.
class GrainTextureCache {
    static let shared = GrainTextureCache() // Instância compartilhada para reutilizar atlas entre views.
    
    private let queue = DispatchQueue(label: "com.granulay.grain.texture.cache", qos: .userInitiated) // Serializa acesso ao cache.
    private var cache: [GrainTextureKey: GrainTextureAtlas] = [:] // Armazena atlas já gerados por chave.
    private var cacheOrder: [GrainTextureKey] = [] // Rastreia uso recente para remoção LRU.
    
    private init() {}
    
    func atlas(for screen: NSScreen?, isMatteMode: Bool) -> GrainTextureAtlas? {
        guard let screen,
              let descriptor = Self.makeDescriptor(for: screen, isMatteMode: isMatteMode)
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
    
    func preloadTextures(for screens: [NSScreen], isMatteMode: Bool) {
        let descriptors = screens.compactMap { Self.makeDescriptor(for: $0, isMatteMode: isMatteMode) }
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
    
    private static func makeDescriptor(for screen: NSScreen, isMatteMode: Bool) -> GrainTextureDescriptor? {
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
            scaleBucket: Int((scale * 100.0).rounded()),
            isMatteMode: isMatteMode
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
    let frameCount = descriptor.key.isMatteMode ? 1 : GrainRenderTuning.atlasFrameCount
    var frames: [CGImage] = []
    frames.reserveCapacity(frameCount) // Pré-aloca capacidade para reduzir realocações.
    
    let baseSeed =
        UInt64(descriptor.key.displayID) << 32
        ^ UInt64(descriptor.pixelWidth & 0xFFFF) << 16
        ^ UInt64(descriptor.pixelHeight & 0xFFFF)
        ^ UInt64(descriptor.key.scaleBucket & 0xFFFF) << 48
    var seedGenerator = SplitMix64(seed: baseSeed)
    
    for frameIndex in 0..<frameCount {
        let frameSeed = seedGenerator.next() ^ UInt64(frameIndex) &* 0x9E3779B185EBCA87
        
        let frame: CGImage?
        if descriptor.key.isMatteMode {
            frame = createMatteGrainFrame(pixelWidth: descriptor.pixelWidth, pixelHeight: descriptor.pixelHeight, seed: frameSeed)
        } else {
            frame = createFineGrainFrame(pixelWidth: descriptor.pixelWidth, pixelHeight: descriptor.pixelHeight, seed: frameSeed)
        }
        
        guard let validFrame = frame else {
            return nil
        }
        frames.append(validFrame)
    }
    
    let cloudFrame: CGImage? = descriptor.key.isMatteMode
        ? createCloudFrame(
            pixelWidth: descriptor.pixelWidth,
            pixelHeight: descriptor.pixelHeight,
            seed: seedGenerator.next()
        )
        : nil

    return GrainTextureAtlas(key: descriptor.key, frames: frames, cloudFrame: cloudFrame)
}

    /// Generates a frame of "Fine Grain" noise using a PRNG.
    /// The algorithm applies spatial correlation (averaging neighboring pixels) and
    /// adds high-frequency micro-noise to create a cinematic film grain aesthetic,
    /// rather than pure TV static.
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
        
        var pixels = [UInt8](repeating: 0, count: pixelCount * 4) 
        let clip = Float(GrainRenderTuning.distributionClip)
        
        for index in 0..<pixelCount {
            var sample = shapedNoise[index]
            sample = min(clip, max(-clip, sample))
            
            let normalized = sample / clip
            
            var alpha: Float = 0.0
            var color: UInt8 = 0
            
            if normalized > 0.5 {
                alpha = (normalized - 0.5) * 2.0 * 255.0
                color = 255
            } else if normalized < -0.5 {
                alpha = (-normalized - 0.5) * 2.0 * 255.0
                color = 0
            } else {
                alpha = 0.0
                color = 0
            }
            
            let alphaInt = UInt8(min(255, max(0, Int(alpha.rounded()))))
            let byteIndex = index * 4
            let premultipliedColor = (color == 255) ? alphaInt : 0
            
            pixels[byteIndex] = premultipliedColor
            pixels[byteIndex + 1] = premultipliedColor
            pixels[byteIndex + 2] = premultipliedColor
            pixels[byteIndex + 3] = alphaInt
        }
        
        return makePremultipliedRGBAImage(width: pixelWidth, height: pixelHeight, pixels: pixels)
    }

    /// Generates the emulsion micro-grain layer for matte (frosted-film) mode.
    ///
    /// Compared to the previous flat-haze matte, this pass does two things that make it read
    /// as physical emulsion rather than an overlay:
    ///   1. **Anisotropic correlation kernel** — horizontal neighbors pull harder than
    ///      vertical, giving the texture a subtle fibrous directionality (like real film
    ///      emulsion) instead of uniform isotropic noise.
    ///   2. **Chromatic highlight sparkles** — highlight seeds carry a small warm/cool RGB
    ///      split rather than pure grey, approximating silver-halide light scatter.
    ///
    /// Designed to be composited **on top of** the cloud diffusion layer; carries ~40% of the
    /// effect's perceived density (the cloud layer carries the other 60%).
    private func createMatteGrainFrame(pixelWidth: Int, pixelHeight: Int, seed: UInt64) -> CGImage? {
        let pixelCount = pixelWidth * pixelHeight
        guard pixelCount > 0 else { return nil }

        var rng = SplitMix64(seed: seed)
        var baseNoise = [Float](repeating: 0, count: pixelCount)

        for index in 0..<pixelCount {
            let centered = (rng.nextUnit() + rng.nextUnit() + rng.nextUnit()) / 3.0 - 0.5
            baseNoise[index] = Float(centered)
        }

        var shapedNoise = [Float](repeating: 0, count: pixelCount)
        let hCorr = Float(MatteGrainTuning.horizontalCorrelation)
        let vCorr = Float(MatteGrainTuning.verticalCorrelation)
        let selfWeight = 1.0 - hCorr - vCorr

        for y in 0..<pixelHeight {
            let rowStart = y * pixelWidth
            for x in 0..<pixelWidth {
                let idx = rowStart + x
                let current = baseNoise[idx]
                let left = x > 0 ? baseNoise[idx - 1] : current
                let right = x + 1 < pixelWidth ? baseNoise[idx + 1] : current
                let up = y > 0 ? baseNoise[idx - pixelWidth] : current
                let down = y + 1 < pixelHeight ? baseNoise[idx + pixelWidth] : current

                let horizontal = (left + right) * 0.5
                let vertical = (up + down) * 0.5
                shapedNoise[idx] = current * selfWeight + horizontal * hCorr + vertical * vCorr
            }
        }

        var alphas = [Int](repeating: 0, count: pixelCount)
        let clip = Float(MatteGrainTuning.distributionClip)
        let baseHaze = Float(MatteGrainTuning.grainHazeAlpha)
        let hazeAmplitude = Float(MatteGrainTuning.grainHazeAmplitude)

        for index in 0..<pixelCount {
            var sample = shapedNoise[index]
            sample = min(clip, max(-clip, sample))
            let normalized = sample / clip
            alphas[index] = Int((baseHaze + normalized * hazeAmplitude).rounded())
        }

        // Highlight pass: record which pixels received a "silver-halide" sparkle, so we can
        // apply a chromatic split on those only without tinting the neutral haze field.
        var chromaFlags = [Int8](repeating: 0, count: pixelCount) // 0 = neutral, 1 = highlight core
        let highlightThreshold = MatteGrainTuning.highlightThreshold
        let coreAlpha = MatteGrainTuning.highlightCoreAlpha
        let neighborBoost = MatteGrainTuning.highlightNeighborAlphaBoost

        for y in 0..<pixelHeight {
            let rowStart = y * pixelWidth
            for x in 0..<pixelWidth {
                if rng.nextUnit() > highlightThreshold {
                    let idx = rowStart + x
                    alphas[idx] = max(alphas[idx], coreAlpha)
                    chromaFlags[idx] = 1

                    if x > 0 { alphas[idx - 1] += neighborBoost }
                    if x + 1 < pixelWidth { alphas[idx + 1] += neighborBoost }
                    if y > 0 { alphas[idx - pixelWidth] += neighborBoost }
                    if y + 1 < pixelHeight { alphas[idx + pixelWidth] += neighborBoost }
                }
            }
        }

        let warmShift = MatteGrainTuning.highlightWarmShift
        let coolShift = MatteGrainTuning.highlightCoolShift
        var pixels = [UInt8](repeating: 0, count: pixelCount * 4)
        for index in 0..<pixelCount {
            let a = UInt8(min(255, max(0, alphas[index])))
            let byteIndex = index * 4
            // Premultiplied-white base: RGB channels equal the alpha channel.

            // Highlights gain a tiny R boost / B dip (warm shift) or vice-versa — picked by
            // the low bit of the pixel index so the two variants interleave, approximating
            // random dispersion without an extra RNG draw per pixel.
            if chromaFlags[index] == 1 {
                let luma = Int(a)
                let warm = (index & 1) == 0
                let r = warm ? min(255, luma + warmShift) : max(0, luma - warmShift)
                let b = warm ? max(0, luma - coolShift) : min(255, luma + coolShift)
                pixels[byteIndex] = UInt8(r)
                pixels[byteIndex + 1] = a
                pixels[byteIndex + 2] = UInt8(b)
            } else {
                pixels[byteIndex] = a
                pixels[byteIndex + 1] = a
                pixels[byteIndex + 2] = a
            }
            pixels[byteIndex + 3] = a
        }

        return makePremultipliedRGBAImage(width: pixelWidth, height: pixelHeight, pixels: pixels)
    }

    /// Generates the low-resolution cloud diffusion layer for matte (frosted-film) mode.
    ///
    /// This is the single biggest cue that the overlay is a physical frosted material rather
    /// than a flat digital haze: it varies density *in patches* across the frame instead of
    /// holding a constant alpha. The image is intentionally generated at a fraction of the
    /// displayed resolution (see `MatteGrainTuning.cloudDownsample`) so Core Animation's
    /// bilinear magnification filter does the smoothing for free — the low-pass is the
    /// upscale itself, which is effectively zero-cost at render time.
    ///
    /// Pipeline:
    ///   1. White noise → box-blur passes → soft low-frequency field.
    ///   2. Re-add a fraction of a less-smoothed copy for mid-frequency variation.
    ///   3. Apply a gentle radial falloff so the frame has material "presence" at edges.
    ///   4. Encode as premultiplied black-with-alpha.
    ///
    /// The CALayer hosting this frame pans `contentsRect` slowly (see
    /// `MatteGrainTuning.cloudPanRange/Duration`), which produces a slow "breathing" effect
    /// at zero CPU cost — real frosted film shifts slowly, not per-frame like grain.
    private func createCloudFrame(pixelWidth: Int, pixelHeight: Int, seed: UInt64) -> CGImage? {
        let downsample = max(1, MatteGrainTuning.cloudDownsample)
        let w = max(MatteGrainTuning.cloudMinResolution, pixelWidth / downsample)
        let h = max(MatteGrainTuning.cloudMinResolution, pixelHeight / downsample)
        let count = w * h
        guard count > 0 else { return nil }

        var rng = SplitMix64(seed: seed)
        var field = [Float](repeating: 0, count: count)
        for i in 0..<count {
            field[i] = Float(rng.nextUnit())
        }

        // Save a lightly-smoothed copy for mid-frequency re-injection after the main blur.
        var midField = field
        boxBlurInPlace(&midField, width: w, height: h, passes: 1)

        boxBlurInPlace(&field, width: w, height: h, passes: MatteGrainTuning.cloudBlurPasses)

        let midMix = Float(MatteGrainTuning.cloudMidFrequencyMix)
        for i in 0..<count {
            field[i] = field[i] * (1.0 - midMix) + midField[i] * midMix
        }

        // Normalize to [-1, 1] centered around the mean so baseAlpha + amplitude mapping is
        // symmetric regardless of how the RNG draws fell.
        var fieldMin: Float = .greatestFiniteMagnitude
        var fieldMax: Float = -.greatestFiniteMagnitude
        for v in field {
            if v < fieldMin { fieldMin = v }
            if v > fieldMax { fieldMax = v }
        }
        let range = max(0.0001, fieldMax - fieldMin)

        let baseAlpha = Float(MatteGrainTuning.cloudBaseAlpha)
        let amplitude = Float(MatteGrainTuning.cloudAmplitude)
        let radialBoost = Float(MatteGrainTuning.cloudRadialBoost)
        let cxF = Float(w) * 0.5
        let cyF = Float(h) * 0.5
        let maxR2 = cxF * cxF + cyF * cyF

        var pixels = [UInt8](repeating: 0, count: count * 4)
        for y in 0..<h {
            let rowStart = y * w
            let dy = Float(y) - cyF
            for x in 0..<w {
                let idx = rowStart + x
                let dx = Float(x) - cxF
                let r2 = (dx * dx + dy * dy) / maxR2 // 0 at center, ~1 at corner
                let radial = 1.0 + radialBoost * r2

                let normalized = ((field[idx] - fieldMin) / range) * 2.0 - 1.0 // -1..1
                var alphaF = (baseAlpha + normalized * amplitude) * radial
                alphaF = min(255, max(0, alphaF))
                let a = UInt8(alphaF.rounded())
                let byteIndex = idx * 4
                // Premultiplied-white tint: RGB channels equal alpha so Core Animation
                // composites the cloud as a soft white film rather than a dark veil.
                pixels[byteIndex] = a
                pixels[byteIndex + 1] = a
                pixels[byteIndex + 2] = a
                pixels[byteIndex + 3] = a
            }
        }

        return makePremultipliedRGBAImage(width: w, height: h, pixels: pixels)
    }

    /// In-place 3x3 box blur, separable (horizontal then vertical), repeated `passes` times.
    /// Used to soften white noise into cloud-like low-frequency density. Edge pixels clamp.
    private func boxBlurInPlace(_ field: inout [Float], width: Int, height: Int, passes: Int) {
        guard passes > 0, width > 0, height > 0 else { return }
        var scratch = [Float](repeating: 0, count: field.count)
        for _ in 0..<passes {
            // Horizontal pass: field → scratch
            for y in 0..<height {
                let rowStart = y * width
                for x in 0..<width {
                    let l = field[rowStart + max(0, x - 1)]
                    let c = field[rowStart + x]
                    let r = field[rowStart + min(width - 1, x + 1)]
                    scratch[rowStart + x] = (l + c + r) / 3.0
                }
            }
            // Vertical pass: scratch → field
            for y in 0..<height {
                let rowStart = y * width
                let upRow = max(0, y - 1) * width
                let downRow = min(height - 1, y + 1) * width
                for x in 0..<width {
                    let u = scratch[upRow + x]
                    let c = scratch[rowStart + x]
                    let d = scratch[downRow + x]
                    field[rowStart + x] = (u + c + d) / 3.0
                }
            }
        }
    }

    private func makePremultipliedRGBAImage(width: Int, height: Int, pixels: [UInt8]) -> CGImage? {
        guard let provider = CGDataProvider(data: Data(pixels) as CFData) else { return nil }
        
        return CGImage(
            width: width, height: height,
            bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
            provider: provider, decode: nil, shouldInterpolate: true, intent: .defaultIntent
        )
    }

// MARK: - Notification Extensions
extension Notification.Name {
    static let updateFrequencyChanged = Notification.Name("updateFrequencyChanged")
}

/// `GrainLayerView` is a layer-backed `NSView` responsible for actually rendering the
/// texture to the screen. 
///
/// It does not generate noise itself; instead, it receives a `GrainTextureAtlas` from the
/// cache and quickly swaps the `layer.contents` (or animates via temporal jitter) to create
/// the illusion of moving grain. It also handles opacity adjustments based on user settings
/// (like intensity and brightness preservation).
class GrainLayerView: NSView {
    
    // MARK: - Properties
    
    var intensity: Double = 1.1 { // Intensidade do efeito de grão aplicada à opacidade da camada.
        didSet {
            if oldValue != intensity {
                updateLayerProperties()
            }
        }
    }

    var matteIntensity: Double = 0.2 { // Intensidade do efeito fosco, independente do grão.
        didSet {
            if oldValue != matteIntensity && isMatteMode {
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
    
    var isGrainAnimated = true {
        didSet {
            if oldValue != isGrainAnimated {
                if isGrainAnimated {
                    applyTemporalJitter()
                } else {
                    layer?.contentsRect = CGRect(x: 0, y: 0, width: 1, height: 1)
                }
            }
        }
    }
    
    var isMatteMode: Bool = false {
        didSet {
            if oldValue != isMatteMode {
                configureForScreen(window?.screen)
                updateLayerProperties()
            }
        }
    }
    
    private var currentScale: CGFloat = 1.0 // Escala atual da tela para manter nitidez correta do conteúdo.
    private var textureAtlas: GrainTextureAtlas? // Atlas atualmente associado à tela da janela.
    private var currentFrameIndex = 0 // Índice do frame atual no atlas animado.

    /// Sublayer that renders the low-resolution cloud diffusion field for matte mode.
    /// Sits **behind** the grain (which is drawn on `layer.contents`) so grain specks
    /// composite on top of the cloud's patchy density, exactly like real emulsion over a
    /// frosted base. `nil` and removed from the tree when not in matte mode.
    private var cloudLayer: CALayer?
    private var cloudLayerAtlasKey: GrainTextureKey? // Last atlas key applied to `cloudLayer.contents`; avoids CGImage identity fragility.
    private static let cloudPanAnimationKey = "granulay.cloudPan"
    
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
        guard let atlas = GrainTextureCache.shared.atlas(for: screen, isMatteMode: isMatteMode) else {
            return
        }

        if textureAtlas?.key != atlas.key || textureAtlas == nil {
            textureAtlas = atlas
            currentFrameIndex = 0
            applyCurrentFrame()
        }

        syncCloudLayer(with: atlas)
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
        guard isGrainAnimated else { return }
        guard let textureAtlas else {
            configureForScreen(window?.screen)
            return
        }
        
        guard textureAtlas.frames.count > 1 else { return }
        
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

        if isMatteMode {
            let clampedMatte = min(1.0, max(0.0, matteIntensity))
            let curvedMatte = pow(clampedMatte, GrainRenderTuning.intensityCurveExponent)
            let matteOpacity = curvedMatte * GrainRenderTuning.matteOpacityMultiplier
            layer.opacity = Float(matteOpacity * MatteGrainTuning.grainDensityShare)
            cloudLayer?.opacity = Float(matteOpacity * MatteGrainTuning.cloudDensityShare)
        } else if preserveBrightness {
            layer.opacity = Float(curvedIntensity * GrainRenderTuning.preserveBrightnessOpacityMultiplier)
        } else {
            layer.opacity = Float(curvedIntensity * GrainRenderTuning.standardOpacityMultiplier)
        }
    }

    /// Installs or tears down the cloud diffusion sublayer in response to mode/atlas changes.
    ///
    /// When matte mode is active and the current atlas carries a cloud frame, we lazily
    /// create a sibling `CALayer` inserted at sublayer index 0 (behind the grain) and drive
    /// a slow `contentsRect` pan via Core Animation. When the mode flips off, the layer is
    /// removed so fine mode renders exactly as before.
    private func syncCloudLayer(with atlas: GrainTextureAtlas) {
        guard let hostLayer = layer else { return }

        if isMatteMode, let cloudImage = atlas.cloudFrame {
            let cl: CALayer
            if let existing = cloudLayer {
                cl = existing
            } else {
                cl = CALayer()
                cl.magnificationFilter = .linear
                cl.minificationFilter = .linear
                cl.contentsGravity = .resize
                cl.isOpaque = false
                cl.allowsEdgeAntialiasing = false
                cl.edgeAntialiasingMask = []
                cl.frame = hostLayer.bounds
                cl.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
                hostLayer.insertSublayer(cl, at: 0)
                cloudLayer = cl
            }

            if cloudLayerAtlasKey != atlas.key {
                cl.contents = cloudImage
                cl.contentsScale = currentScale
                cloudLayerAtlasKey = atlas.key
            }

            startCloudPanIfNeeded(on: cl)
        } else if let existing = cloudLayer {
            existing.removeAnimation(forKey: Self.cloudPanAnimationKey)
            existing.removeFromSuperlayer()
            cloudLayer = nil
            cloudLayerAtlasKey = nil
        }
    }

    /// Drives a slow, autoreversed `contentsRect` pan on the cloud layer. This is what gives
    /// the frosted film its subtle "breathing" without any per-frame CPU work — the grain
    /// atlas handles high-frequency motion; the cloud handles low-frequency drift.
    private func startCloudPanIfNeeded(on cloudLayer: CALayer) {
        if cloudLayer.animation(forKey: Self.cloudPanAnimationKey) != nil { return }

        let range = MatteGrainTuning.cloudPanRange
        let window = 1.0 - range
        let anim = CABasicAnimation(keyPath: "contentsRect")
        anim.fromValue = NSValue(rect: CGRect(x: 0, y: 0, width: window, height: window))
        anim.toValue = NSValue(rect: CGRect(x: range, y: range, width: window, height: window))
        anim.duration = MatteGrainTuning.cloudPanDuration
        anim.autoreverses = true
        anim.repeatCount = .infinity
        anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        anim.isRemovedOnCompletion = false
        cloudLayer.add(anim, forKey: Self.cloudPanAnimationKey)
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
        if isGrainAnimated {
            applyTemporalJitter()
        } else {
            layer.contentsRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        }
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
    let isAnimated: Bool
    let isMatteMode: Bool
    
    init(intensity: Double, preserveBrightness: Bool, isAnimated: Bool = true, isMatteMode: Bool = false) {
        self.intensity = intensity
        self.preserveBrightness = preserveBrightness
        self.isAnimated = isAnimated
        self.isMatteMode = isMatteMode
    }
    
    func makeNSView(context: Context) -> GrainLayerView {
        let view = GrainLayerView(frame: .zero)
        view.intensity = intensity
        view.preserveBrightness = preserveBrightness
        view.isGrainAnimated = isAnimated
        view.isMatteMode = isMatteMode
        
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
        nsView.isGrainAnimated = isAnimated
        nsView.isMatteMode = isMatteMode
        nsView.configureForScreen(nsView.window?.screen ?? NSScreen.main)
    }
}
