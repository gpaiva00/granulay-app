import SwiftUI

struct LoFiControlsView: View {
    @StateObject private var musicManager = LoFiMusicManager.shared
    @Binding var isLoading: Bool
    @State private var showCredits = false
    
    private func withLoadingDelay(_ action: @escaping () -> Void) {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isLoading = false
            }
        }
    }
    
    private var repeatIcon: String {
        switch musicManager.repeatMode {
        case .off:
            return "repeat"
        case .one:
            return "repeat.1"
        case .all:
            return "repeat"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Status da faixa atual
            HStack {
                Image(systemName: musicManager.isPlaying ? "music.note" : "music.note.list")
                    .foregroundColor(.accentColor)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(musicManager.currentTrack)
                        .font(.headline)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    
                    Text(musicManager.isPlaying ? LocalizationKeys.LoFi.playing.localized : LocalizationKeys.LoFi.stopped.localized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Botão de lista de faixas removido
            }
                
                Divider()
                
            // Controles de reprodução
            HStack(spacing: 16) {
                Button(action: {
                    withLoadingDelay {
                        musicManager.previousTrack()
                    }
                }) {
                    Image(systemName: "backward.fill")
                        .font(.title2)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(isLoading)
                
                Button(action: {
                    withLoadingDelay {
                        if musicManager.isPlaying {
                            musicManager.pause()
                        } else {
                            musicManager.play()
                        }
                    }
                }) {
                    Image(systemName: musicManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.title)
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(isLoading)
                
                Button(action: {
                    withLoadingDelay {
                        musicManager.nextTrack()
                    }
                }) {
                    Image(systemName: "forward.fill")
                        .font(.title2)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(isLoading)
                
                Spacer()
                
                // Controles de shuffle e repeat
                Button(action: {
                    musicManager.toggleShuffle()
                }) {
                    Image(systemName: "shuffle")
                        .font(.title2)
                        .foregroundColor(musicManager.isShuffled ? .accentColor : .secondary)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    musicManager.toggleRepeat()
                }) {
                    Image(systemName: repeatIcon)
                        .font(.title2)
                        .foregroundColor(musicManager.repeatMode != .off ? .accentColor : .secondary)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    withLoadingDelay {
                        musicManager.stop()
                    }
                }) {
                    Image(systemName: "stop.fill")
                        .font(.title2)
                        .foregroundColor(.red)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(isLoading)
            }
            
            Divider()
            
            // Lista de faixas removida
                
            // Controle de volume
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(LocalizationKeys.LoFi.volume.localized)
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text("\(Int(musicManager.volume * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Image(systemName: "speaker.fill")
                        .foregroundColor(.secondary)
                    
                    Slider(
                        value: Binding(
                            get: { Double(musicManager.volume) },
                            set: { newValue in
                                musicManager.setVolume(Float(newValue))
                            }
                        ),
                        in: 0...1
                    )
                    .disabled(isLoading)
                    
                    Image(systemName: "speaker.wave.3.fill")
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            // Créditos do Pixabay
            HStack {
                Button(action: {
                    showCredits.toggle()
                }) {
                    HStack {
                        Image(systemName: "info.circle")
                        Text(NSLocalizedString("lofi.credits.button", comment: "Pixabay credits button"))
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }
            
            if showCredits {
                ScrollView {
                    Text(musicManager.getPixabayCredits())
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 8)
                }
                .frame(maxHeight: 100)
            }
        }

        .padding(8)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
}
