//
//  PurchaseSettingsView.swift
//  Granulay
//
//  Created by Granulay on 2024.
//

import SwiftUI

struct PurchaseSettingsView: View {
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(NSLocalizedString("purchase.trial.title", comment: "Trial version title"))
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 12) {
                Text(NSLocalizedString("purchase.trial.description", comment: "Trial version description"))
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(NSLocalizedString("purchase.trial.basic_grain", comment: "Basic grain effect"))
                    }
                    
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                        Text(NSLocalizedString("purchase.trial.all_grain_styles", comment: "All grain styles"))
                    }
                    
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                        Text(NSLocalizedString("purchase.trial.lofi_functionality", comment: "Lo-Fi functionality"))
                    }
                    
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                        Text(NSLocalizedString("purchase.trial.behavior_settings", comment: "Behavior settings"))
                    }
                    
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                        Text(NSLocalizedString("purchase.trial.preserve_brightness", comment: "Preserve brightness"))
                    }
                }
                .font(.system(size: 13))
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 12) {
                Text(NSLocalizedString("purchase.unlock.title", comment: "Unlock all features"))
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(NSLocalizedString("purchase.unlock.all_grain_styles", comment: "All grain styles"))
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(NSLocalizedString("purchase.unlock.all_intensities", comment: "All intensities"))
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(NSLocalizedString("purchase.unlock.complete_lofi", comment: "Complete Lo-Fi functionality"))
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(NSLocalizedString("purchase.unlock.advanced_settings", comment: "Advanced behavior settings"))
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(NSLocalizedString("purchase.unlock.preserve_brightness", comment: "Preserve brightness option"))
                    }
                }
                .font(.system(size: 13))
            }
            
            Spacer()
            
            VStack(spacing: 16) {
                // Botão de compra com destaque especial
                Button(action: {
                    openPurchaseStore()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "cart.fill")
                            .font(.title3)
                        Text(NSLocalizedString("purchase.button.title", comment: "Buy full version button"))
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(PlainButtonStyle())
                .scaleEffect(1.0)
                .animation(.easeInOut(duration: 0.1), value: false)
                
                Text(NSLocalizedString("purchase.lifetime_access", comment: "Lifetime access message"))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .alert(NSLocalizedString("purchase.error.title", comment: "Error title"), isPresented: $showingAlert) {
            Button(NSLocalizedString("purchase.error.ok", comment: "OK button")) {
                showingAlert = false
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func openPurchaseStore() {
        // Tenta abrir a App Store primeiro
        if let appStoreURL = URL(string: TrialConfig.purchaseURL) {
            NSWorkspace.shared.open(appStoreURL, configuration: NSWorkspace.OpenConfiguration()) { (app, error) in
                if error != nil {
                    // Se falhar, mostra alerta informativo
                    DispatchQueue.main.async {
                        alertMessage = NSLocalizedString("purchase.error.message", comment: "Purchase error message")
                        showingAlert = true
                    }
                }
            }
        }
    }
}

#Preview {
    PurchaseSettingsView()
        .frame(width: 400, height: 500)
}
