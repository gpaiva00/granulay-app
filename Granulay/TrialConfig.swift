//
//  TrialConfig.swift
//  Granulay
//
//  Created by Assistant on 2025-01-16.
//

import Foundation

struct TrialConfig {
    
    // MARK: - Trial Version Detection
    
    static var isTrialVersion: Bool {
        #if TRIAL_VERSION
        return true
        #else
        return false
        #endif
    }
    
    // MARK: - Grain Effect Limitations
    
    static var allowedGrainStyles: [GrainStyle] {
        if isTrialVersion {
            return [.fine] // Apenas estilo "fino" na versão trial
        } else {
            return GrainStyle.allCases
        }
    }
    
    static var allowedIntensityRange: ClosedRange<Double> {
        if isTrialVersion {
            return 0.1...0.3 // Apenas intensidade "fraca" na versão trial
        } else {
            return 0.1...1.0
        }
    }
    
    static var canPreserveBrightness: Bool {
        return !isTrialVersion // Preservar brilho desativado na versão trial
    }
    
    // MARK: - Feature Availability
    
    static var isLoFiEnabled: Bool {
        return !isTrialVersion // Lo-Fi desativado na versão trial
    }
    
    static var isBehaviorSectionEnabled: Bool {
        return !isTrialVersion // Seção Comportamento desativada na versão trial
    }
    
    // MARK: - Purchase Information
    
    static let purchaseURL = "https://gabrielpaiva5.gumroad.com/l/granulay"
    
    static var appDisplayName: String {
        if isTrialVersion {
            return "Granulay Trial"
        } else {
            return "Granulay"
        }
    }
    
    static var appVersion: String {
        if isTrialVersion {
            return "1.0.0-trial"
        } else {
            return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        }
    }
}