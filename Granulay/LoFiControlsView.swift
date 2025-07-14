import SwiftUI

struct LoFiControlsView: View {
    @StateObject private var musicManager = LoFiMusicManager.shared
    @Binding var isLoading: Bool
    
    private func withLoadingDelay(_ action: @escaping () -> Void) {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isLoading = false
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
//            Text(LocalizationKeys.LoFi.title.localized)
//                .font(.headline)
//            
            VStack(alignment: .leading, spacing: 16) {
                // Status da música
                HStack {
                    Image(systemName: musicManager.isPlaying ? "music.note" : "music.note.list")
                        .foregroundColor(.accentColor)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(musicManager.currentStation)
                            .font(.headline)
                            .fontWeight(.medium)
                        
                        Text(musicManager.isPlaying ? LocalizationKeys.LoFi.playing.localized : LocalizationKeys.LoFi.stopped.localized)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                Divider()
                
                // Controles de reprodução
                HStack(spacing: 16) {
                    Button(action: {
                        withLoadingDelay {
                            musicManager.previousStation()
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
                            musicManager.nextStation()
                        }
                    }) {
                        Image(systemName: "forward.fill")
                            .font(.title2)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(isLoading)
                    
                    Spacer()
                    
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
            }
            .padding(8)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(12)
        }
    }
}
