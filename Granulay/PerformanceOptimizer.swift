import Foundation
import AppKit

class PerformanceOptimizer: ObservableObject {
    static let shared = PerformanceOptimizer()
    
    private var frameRateMonitor: Timer?
    private var lastFrameTime: CFTimeInterval = 0
    private var frameCount = 0
    private var averageFPS: Double = 60.0
    private let targetFPS: Double = 60.0
    
    private init() {
        setupFrameRateMonitor()
        setupDisplayNotifications()
    }
    
    deinit {
        frameRateMonitor?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupFrameRateMonitor() {
        frameRateMonitor = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { _ in
            self.frameCallback()
        }
    }
    
    private func setupDisplayNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(displayConfigurationChanged),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }
    
    @objc private func frameCallback() {
        let currentTime = CFAbsoluteTimeGetCurrent()
        
        if lastFrameTime > 0 {
            let deltaTime = currentTime - lastFrameTime
            let currentFPS = 1.0 / deltaTime
            
            // Média móvel simples para suavizar variações
            averageFPS = (averageFPS * 0.9) + (currentFPS * 0.1)
            frameCount += 1
            
            // Verifica performance a cada 60 frames
            if frameCount >= 60 {
                optimizeBasedOnPerformance()
                frameCount = 0
            }
        }
        
        lastFrameTime = currentTime
    }
    
    private func optimizeBasedOnPerformance() {
        let performanceRatio = averageFPS / targetFPS
        
        if performanceRatio < 0.8 { // Performance abaixo de 80%
            applyPerformanceOptimizations()
        } else if performanceRatio > 0.95 { // Performance boa
            removePerformanceOptimizations()
        }
    }
    
    private func applyPerformanceOptimizations() {
        DispatchQueue.main.async {
            // Reduz qualidade da textura temporariamente
            self.optimizeTextureQuality(reduce: true)
            
            // Reduz frequência de atualizações
            self.optimizeUpdateFrequency(reduce: true)
        }
    }
    
    private func removePerformanceOptimizations() {
        DispatchQueue.main.async {
            // Restaura qualidade normal
            self.optimizeTextureQuality(reduce: false)
            
            // Restaura frequência normal
            self.optimizeUpdateFrequency(reduce: false)
        }
    }
    
    private func optimizeTextureQuality(reduce: Bool) {
        let newSize = reduce ? CGSize(width: 256, height: 256) : CGSize(width: 512, height: 512)
        
        // Notifica o cache para ajustar qualidade
        NotificationCenter.default.post(
            name: .textureQualityChanged,
            object: newSize
        )
    }
    
    private func optimizeUpdateFrequency(reduce: Bool) {
        let interval = reduce ? 0.1 : 0.05
        
        // Notifica o overlay para ajustar frequência
        NotificationCenter.default.post(
            name: .updateFrequencyChanged,
            object: interval
        )
    }
    
    @objc private func displayConfigurationChanged() {
        // Reset performance monitoring quando configuração da tela muda
        averageFPS = 60.0
        frameCount = 0
        lastFrameTime = 0
    }
    
    func getCurrentPerformanceMetrics() -> (fps: Double, quality: String) {
        let quality: String
        if averageFPS >= 55 {
            quality = "Excelente"
        } else if averageFPS >= 45 {
            quality = "Boa"
        } else if averageFPS >= 30 {
            quality = "Média"
        } else {
            quality = "Baixa"
        }
        
        return (averageFPS, quality)
    }
} 