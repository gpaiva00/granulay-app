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
            return [.fine, .medium, .coarse] // Apenas estilo "fino" na versão trial
        } else {
            return GrainStyle.allCases
        }
    }
    
    static var allowedIntensityRange: ClosedRange<Double> {
        return 0.1...1.0
//        if isTrialVersion {
//            return 0.1...0.3 // Apenas intensidade "fraca" na versão trial
//        } else {
//            return 0.1...1.0
//        }
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
    
    static let appStoreURL = "https://apps.apple.com/br/app/granulay/id6751862804?mt=12Granulay"
    
    static var purchaseURL: String {
        return appStoreURL // Prioriza App Store
    }
    
    static var appDisplayName: String {
        if isTrialVersion {
            return "Granulay Trial"
        } else {
            return "Granulay"
        }
    }
    
    static var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
}
