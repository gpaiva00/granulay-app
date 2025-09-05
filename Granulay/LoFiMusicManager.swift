import Foundation
import AVFoundation
import Combine

class LoFiMusicManager: ObservableObject {
    static let shared = LoFiMusicManager()
    
    @Published var isPlaying = false
    @Published var currentStation = "Chill Lo-Fi"
    @Published var volume: Float = 0.5
    @Published var currentTrack = "Loading..."
    
    private var audioPlayer: AVPlayer?
    private var cancellables = Set<AnyCancellable>()
    
    // Estações lo-fi disponíveis com streams reais
    private let stations = [
        "Chill Lo-Fi": "https://streams.ilovemusic.de/iloveradio17.mp3",
        "Jazz Lo-Fi": "https://streams.ilovemusic.de/iloveradio36.mp3", 
        "Study Beats": "https://radio.streemlion.com:2199/tunein/chillhop.pls",
        "Sleep Lo-Fi": "https://streams.ilovemusic.de/iloveradio17.mp3"
    ]
    
    private init() {
        loadSettings()
    }
    
    func play() {
        guard let urlString = stations[currentStation],
              let url = URL(string: urlString) else { 

            return 
        }
        
        // Para URLs .pls, precisamos extrair a URL real
        if urlString.hasSuffix(".pls") {
            loadPlaylistURL(url) { [weak self] realURL in
                guard let realURL = realURL else { return }
                self?.playStream(url: realURL)
            }
        } else {
            playStream(url: url)
        }
    }
    
    private func loadPlaylistURL(_ playlistURL: URL, completion: @escaping (URL?) -> Void) {
        URLSession.shared.dataTask(with: playlistURL) { data, response, error in
            guard let data = data,
                  let content = String(data: data, encoding: .utf8) else {
                completion(nil)
                return
            }
            
            // Extrair URL do arquivo .pls
            let lines = content.components(separatedBy: .newlines)
            for line in lines {
                if line.hasPrefix("File1=") {
                    let urlString = String(line.dropFirst(6))
                    completion(URL(string: urlString))
                    return
                }
            }
            completion(nil)
        }.resume()
    }
    
    private func playStream(url: URL) {
        DispatchQueue.main.async {
            self.audioPlayer = AVPlayer(url: url)
            self.audioPlayer?.volume = self.volume
            self.audioPlayer?.play()
            self.isPlaying = true
            self.currentTrack = self.currentStation
            self.saveSettings()
        }
    }
    
    func pause() {
        audioPlayer?.pause()
        isPlaying = false
        saveSettings()
    }
    
    func stop() {
        audioPlayer?.pause()
        audioPlayer = nil
        isPlaying = false
        currentTrack = "Stopped"
        saveSettings()
    }
    
    func nextStation() {
        let stationKeys = Array(stations.keys)
        if let currentIndex = stationKeys.firstIndex(of: currentStation) {
            let nextIndex = (currentIndex + 1) % stationKeys.count
            currentStation = stationKeys[nextIndex]
            if isPlaying {
                stop()
                play()
            }
            saveSettings()
        }
    }
    
    func previousStation() {
        let stationKeys = Array(stations.keys)
        if let currentIndex = stationKeys.firstIndex(of: currentStation) {
            let previousIndex = currentIndex > 0 ? currentIndex - 1 : stationKeys.count - 1
            currentStation = stationKeys[previousIndex]
            if isPlaying {
                stop()
                play()
            }
            saveSettings()
        }
    }
    
    func setVolume(_ newVolume: Float) {
        volume = max(0.0, min(1.0, newVolume))
        audioPlayer?.volume = volume
        saveSettings()
    }
    
    private func saveSettings() {
        UserDefaults.standard.set(currentStation, forKey: "LoFiCurrentStation")
        UserDefaults.standard.set(volume, forKey: "LoFiVolume")
        UserDefaults.standard.set(isPlaying, forKey: "LoFiIsPlaying")
    }
    
    private func loadSettings() {
        currentStation = UserDefaults.standard.string(forKey: "LoFiCurrentStation") ?? "Chill Lo-Fi"
        volume = UserDefaults.standard.float(forKey: "LoFiVolume")
        if volume == 0 {
            volume = 0.5
        }
    }
}