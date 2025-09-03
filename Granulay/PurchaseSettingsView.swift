//
//  PurchaseSettingsView.swift
//  Granulay
//
//  Created by Granulay on 2024.
//

import SwiftUI

struct PurchaseSettingsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Versão Trial")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Você está usando a versão trial do Granulay com funcionalidades limitadas:")
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Efeito de grão básico (estilo Fine, intensidade Fraca)")
                    }
                    
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                        Text("Todos os estilos e intensidades de grão")
                    }
                    
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                        Text("Funcionalidade Lo-Fi")
                    }
                    
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                        Text("Configurações de comportamento")
                    }
                    
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                        Text("Preservar brilho")
                    }
                }
                .font(.system(size: 13))
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Desbloqueie todas as funcionalidades:")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Todos os estilos de grão (Fine, Medium, Coarse)")
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Todas as intensidades (Fraca, Média, Forte)")
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Funcionalidade Lo-Fi completa")
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Configurações avançadas de comportamento")
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Opção de preservar brilho")
                    }
                }
                .font(.system(size: 13))
            }
            
            Spacer()
            
            VStack(spacing: 16) {
                // Botão de compra com destaque especial
                Button(action: {
                    if let url = URL(string: TrialConfig.purchaseURL) {
                        NSWorkspace.shared.open(url)
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "cart.fill")
                            .font(.title3)
                        Text("Comprar Versão Completa")
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
                
                Text("💎 Acesso completo e vitalício")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

#Preview {
    PurchaseSettingsView()
        .frame(width: 400, height: 500)
}