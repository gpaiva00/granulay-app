import Foundation
import AVFoundation
import Combine
import Network

struct LoFiTrack {
    let id: String
    let title: String
    let artist: String
    let url: String
    let pixabayId: String
}

class LoFiMusicManager: ObservableObject {
    static let shared = LoFiMusicManager()
    
    @Published var isPlaying = false
    @Published var currentTrackIndex = 0
    @Published var volume: Float = 0.5
    @Published var currentTrack = NSLocalizedString("lofi.loading", comment: "Loading status")
    @Published var isShuffled = false
    @Published var repeatMode: RepeatMode = .off
    
    private var audioPlayer: AVPlayer?
    private var cancellables = Set<AnyCancellable>()
    private var shuffledIndices: [Int] = []
    
    enum RepeatMode: Int, CaseIterable {
        case off = 0
        case one = 1
        case all = 2
    }
    
    // Faixas lo-fi do Pixabay hospedadas no S3
    private let tracks: [LoFiTrack] = [
        LoFiTrack(id: "cutie-japan", title: "Cutie Japan Lo-Fi", artist: "FASSounds", url: "https://granulay-lo-fi-tracks.s3.sa-east-1.amazonaws.com/cutie-japan-lofi-402355.mp3", pixabayId: "402355"),
        LoFiTrack(id: "good-night", title: "Good Night Cozy Chill", artist: "FASSounds", url: "https://granulay-lo-fi-tracks.s3.sa-east-1.amazonaws.com/good-night-lofi-cozy-chill-music-160166.mp3", pixabayId: "160166"),
        LoFiTrack(id: "background-2", title: "Lo-Fi Background Music 2", artist: "DELOSound", url: "https://granulay-lo-fi-tracks.s3.sa-east-1.amazonaws.com/lofi-background-music-2-337568.mp3", pixabayId: "337568"),
        LoFiTrack(id: "background-314199", title: "Lo-Fi Background Music", artist: "Andrii Poradovskyi", url: "https://granulay-lo-fi-tracks.s3.sa-east-1.amazonaws.com/lofi-background-music-314199.mp3", pixabayId: "314199"),
        LoFiTrack(id: "background-326931", title: "Lo-Fi Background Music", artist: "kaveesha Senanayake", url: "https://granulay-lo-fi-tracks.s3.sa-east-1.amazonaws.com/lofi-background-music-326931.mp3", pixabayId: "326931"),
        LoFiTrack(id: "background-336230", title: "Lo-Fi Background Music", artist: "kaveesha Senanayake", url: "https://granulay-lo-fi-tracks.s3.sa-east-1.amazonaws.com/lofi-background-music-336230.mp3", pixabayId: "336230"),
        LoFiTrack(id: "background-388291", title: "Lo-Fi Background Music", artist: "Mikhail Smusev", url: "https://granulay-lo-fi-tracks.s3.sa-east-1.amazonaws.com/lofi-background-music-388291.mp3", pixabayId: "388291"),
        LoFiTrack(id: "background-398281", title: "Lo-Fi Background Music", artist: "DELOSound", url: "https://granulay-lo-fi-tracks.s3.sa-east-1.amazonaws.com/lofi-background-music-398281.mp3", pixabayId: "398281"),
        LoFiTrack(id: "background-401916", title: "Lo-Fi Background Music", artist: "FreeMusicForVideo", url: "https://granulay-lo-fi-tracks.s3.sa-east-1.amazonaws.com/lofi-background-music-401916.mp3", pixabayId: "401916"),
        LoFiTrack(id: "jazz", title: "Lo-Fi Jazz", artist: "DELOSound", url: "https://granulay-lo-fi-tracks.s3.sa-east-1.amazonaws.com/lofi-jazz-398289.mp3", pixabayId: "398289"),
        LoFiTrack(id: "background-398421", title: "Lo-Fi Background Music", artist: "Ievgen Poltavskyi", url: "https://granulay-lo-fi-tracks.s3.sa-east-1.amazonaws.com/lofi-lofi-background-music-398421.mp3", pixabayId: "398421"),
        LoFiTrack(id: "chill", title: "Lo-Fi Chill", artist: "DELOSound", url: "https://granulay-lo-fi-tracks.s3.sa-east-1.amazonaws.com/lofi-lofi-chill-398290.mp3", pixabayId: "398290"),
        LoFiTrack(id: "hiphop", title: "Lo-Fi Hip Hop", artist: "FreeMusicForVideo", url: "https://granulay-lo-fi-tracks.s3.sa-east-1.amazonaws.com/lofi-lofi-hiphop-401921.mp3", pixabayId: "401921"),
        LoFiTrack(id: "music", title: "Lo-Fi Music", artist: "FreeMusicForVideo", url: "https://granulay-lo-fi-tracks.s3.sa-east-1.amazonaws.com/lofi-lofi-music-401926.mp3", pixabayId: "401926"),
        LoFiTrack(id: "song", title: "Lo-Fi Song", artist: "FreeMusicForVideo", url: "https://granulay-lo-fi-tracks.s3.sa-east-1.amazonaws.com/lofi-lofi-song-401920.mp3", pixabayId: "401920"),
        LoFiTrack(id: "song-music", title: "Lo-Fi Song Music", artist: "DELOSound", url: "https://granulay-lo-fi-tracks.s3.sa-east-1.amazonaws.com/lofi-lofi-song-music-398288.mp3", pixabayId: "398288"),
        LoFiTrack(id: "study-calm", title: "Study Calm Peaceful Chill Hop", artist: "FASSounds", url: "https://granulay-lo-fi-tracks.s3.sa-east-1.amazonaws.com/lofi-study-calm-peaceful-chill-hop-112191.mp3", pixabayId: "112191"),
        LoFiTrack(id: "rainy-city", title: "Rainy Lo-Fi City", artist: "kaveesha Senanayake", url: "https://granulay-lo-fi-tracks.s3.sa-east-1.amazonaws.com/rainy-lofi-city-lofi-music-332746.mp3", pixabayId: "332746"),
        LoFiTrack(id: "spring-vibes", title: "Spring Lo-Fi Vibes", artist: "kaveesha Senanayake", url: "https://granulay-lo-fi-tracks.s3.sa-east-1.amazonaws.com/spring-lofi-vibes-lofi-music-340019.mp3", pixabayId: "340019"),
        LoFiTrack(id: "youtube-background", title: "YouTube Background Music Lo-Fi", artist: "DELOSound", url: "https://granulay-lo-fi-tracks.s3.sa-east-1.amazonaws.com/youtube-background-music-lofi-398315.mp3", pixabayId: "398315")
    ]
    
    var currentTrackInfo: LoFiTrack? {
        guard currentTrackIndex < tracks.count else { return nil }
        let index = isShuffled ? shuffledIndices[currentTrackIndex] : currentTrackIndex
        return tracks[index]
    }
    
    private init() {
        setupShuffledIndices()
        loadSettings()
    }
    
    private func setupShuffledIndices() {
        shuffledIndices = Array(0..<tracks.count).shuffled()
    }
    
    func play() {
        guard let track = currentTrackInfo,
              let url = URL(string: track.url) else {
            return
        }
        
        playTrackInternal(url: url, trackInfo: track)
    }
    
    func playTrack(at index: Int) {
        guard index >= 0 && index < tracks.count else {
            return
        }
        
        // Verificar conectividade de rede
        if !isNetworkAvailable() {
            return
        }
        
        currentTrackIndex = index
        let track = tracks[index]
        guard let url = URL(string: track.url) else {
            return
        }
        
        playTrackInternal(url: url, trackInfo: track)
    }
    
    private func playTrackInternal(url: URL, trackInfo: LoFiTrack) {
        DispatchQueue.main.async { [self] in
            // Limpar player anterior e observadores
            removeObservers()
            audioPlayer?.pause()
            audioPlayer = nil
            
            // Configurar sessão de rede para HTTPS
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = 30.0
            config.timeoutIntervalForResource = 60.0
            config.allowsCellularAccess = true
            config.waitsForConnectivity = true
            
            // Criar asset com configurações de rede otimizadas
            let asset = AVURLAsset(url: url, options: [
                AVURLAssetPreferPreciseDurationAndTimingKey: false,
                AVURLAssetHTTPCookiesKey: [],
                "AVURLAssetHTTPHeaderFieldsKey": [
                    "User-Agent": "Granulay/1.0",
                    "Accept": "audio/*"
                ]
            ])
            
            // Criar player item com asset configurado
            let playerItem = AVPlayerItem(asset: asset)
            
            // Configurações otimizadas para streaming
            playerItem.preferredForwardBufferDuration = 3.0
            playerItem.preferredPeakBitRate = 128000 // 128 kbps
            playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = false
            
            // Configurar player
            audioPlayer = AVPlayer(playerItem: playerItem)
            audioPlayer?.automaticallyWaitsToMinimizeStalling = true
            audioPlayer?.volume = volume
            
            // Observadores com tratamento robusto
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(playerItemFailedToPlay(_:)),
                name: .AVPlayerItemFailedToPlayToEndTime,
                object: playerItem
            )
            
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(playerItemDidPlayToEndTime(_:)),
                name: .AVPlayerItemDidPlayToEndTime,
                object: playerItem
            )
            
            // Observar mudanças de status para debug
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(playerItemStatusChanged(_:)),
                name: .AVPlayerItemNewAccessLogEntry,
                object: playerItem
            )
            
            // Aguardar carregamento antes de reproduzir
              DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                  if playerItem.status == .readyToPlay {
                      audioPlayer?.play()
                      isPlaying = true
                      retryCount = 0 // Reset contador em caso de sucesso
                  } else {
                      audioPlayer?.play()
                      isPlaying = true
                  }
              }
            
            currentTrack = "\(trackInfo.title) - \(trackInfo.artist)"
            saveSettings()
        }
    }
    
    private func handleTrackEnded() {
        switch repeatMode {
        case .one:
            // Repetir a faixa atual
            play()
        case .all:
            // Ir para próxima faixa
            nextTrack()
        case .off:
            // Parar reprodução
            stop()
        }
    }
    
    func pause() {
        audioPlayer?.pause()
        isPlaying = false
        saveSettings()
    }
    
    func stop() {
        removeObservers()
        audioPlayer?.pause()
        audioPlayer = nil
        isPlaying = false
        currentTrack = NSLocalizedString("lofi.stopped", comment: "Stopped status")
        saveSettings()
    }
    
    @objc private func playerItemFailedToPlay(_ notification: Notification) {
        if let error = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error {
            let errorCode = (error as NSError).code
            
            // Tratar erros específicos de rede
            switch errorCode {
            case -12540, -12660, -12939: // Erros de streaming/rede
                retryCurrentTrack()
            default:
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.nextTrack()
                }
            }
        }
    }
    
    @objc private func playerItemDidPlayToEndTime(_ notification: Notification) {
        handleTrackEnded()
    }
    
    @objc private func playerItemStatusChanged(_ notification: Notification) {
        // Status monitoring without debug output
    }
    
    private var retryCount = 0
    private let maxRetries = 2
    private let networkMonitor = NWPathMonitor()
    private let networkQueue = DispatchQueue(label: "NetworkMonitor")
    
    private func retryCurrentTrack() {
        guard retryCount < maxRetries else {
            retryCount = 0
            nextTrack()
            return
        }
        
        retryCount += 1
        
        // Verificar conectividade de rede antes de tentar novamente
        guard isNetworkAvailable() else {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
             let currentIndex = self.isShuffled ? self.shuffledIndices[self.currentTrackIndex] : self.currentTrackIndex
             self.playTrack(at: currentIndex)
         }
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemFailedToPlayToEndTime, object: nil)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemNewAccessLogEntry, object: nil)
    }
    
    func nextTrack() {
        let maxIndex = tracks.count - 1
        
        if currentTrackIndex < maxIndex {
            currentTrackIndex += 1
        } else {
            currentTrackIndex = 0
        }
        
        if isPlaying {
            stop()
            play()
        } else {
            updateCurrentTrackDisplay()
        }
        saveSettings()
    }
    
    func previousTrack() {
        if currentTrackIndex > 0 {
            currentTrackIndex -= 1
        } else {
            currentTrackIndex = tracks.count - 1
        }
        
        if isPlaying {
            stop()
            play()
        } else {
            updateCurrentTrackDisplay()
        }
        saveSettings()
    }
    
    func toggleShuffle() {
        isShuffled.toggle()
        if isShuffled {
            setupShuffledIndices()
        }
        saveSettings()
    }
    
    func toggleRepeat() {
        switch repeatMode {
        case .off:
            repeatMode = .one
        case .one:
            repeatMode = .all
        case .all:
            repeatMode = .off
        }
        saveSettings()
    }
    
    func selectTrack(at index: Int) {
        guard index >= 0 && index < tracks.count else { return }
        currentTrackIndex = index
        
        if isPlaying {
            stop()
            play()
        } else {
            updateCurrentTrackDisplay()
        }
        saveSettings()
    }
    
    private func updateCurrentTrackDisplay() {
        if let track = currentTrackInfo {
            currentTrack = "\(track.title) - \(track.artist)"
        }
    }
    
    func getAllTracks() -> [LoFiTrack] {
        return tracks
    }
    
    func getPixabayCredits() -> String {
        let credits = tracks.map { track in
            String(format: NSLocalizedString("lofi.credits.format", comment: "Credit format"), track.artist, track.pixabayId)
        }.joined(separator: "\n")
        
        return credits + "\n\n" + NSLocalizedString("lofi.credits", comment: "Credits footer")
    }
    
    func setVolume(_ newVolume: Float) {
        volume = max(0.0, min(1.0, newVolume))
        audioPlayer?.volume = volume
        saveSettings()
    }
    
    private func saveSettings() {
        UserDefaults.standard.set(currentTrackIndex, forKey: "currentTrackIndex")
        UserDefaults.standard.set(volume, forKey: "lofiVolume")
        UserDefaults.standard.set(isShuffled, forKey: "isShuffled")
        UserDefaults.standard.set(repeatMode.rawValue, forKey: "repeatMode")
    }
    
    private func isNetworkAvailable() -> Bool {
        let monitor = NWPathMonitor()
        var isConnected = false
        let semaphore = DispatchSemaphore(value: 0)
        
        monitor.pathUpdateHandler = { path in
            isConnected = path.status == .satisfied
            semaphore.signal()
        }
        
        let queue = DispatchQueue(label: "NetworkCheck")
        monitor.start(queue: queue)
        
        _ = semaphore.wait(timeout: .now() + 1.0)
        monitor.cancel()
        
        return isConnected
    }
    
    private func loadSettings() {
        currentTrackIndex = UserDefaults.standard.integer(forKey: "currentTrackIndex")
        volume = UserDefaults.standard.float(forKey: "lofiVolume")
        if volume == 0 {
            volume = 0.5
        }
        isShuffled = UserDefaults.standard.bool(forKey: "isShuffled")
        let repeatRawValue = UserDefaults.standard.integer(forKey: "repeatMode")
         repeatMode = RepeatMode(rawValue: repeatRawValue) ?? .off
        
        // Garantir que o índice está dentro dos limites
        if currentTrackIndex >= tracks.count {
            currentTrackIndex = 0
        }
        
        updateCurrentTrackDisplay()
    }
}