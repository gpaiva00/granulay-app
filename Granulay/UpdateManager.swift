import Foundation
import Sparkle

class UpdateManager: ObservableObject {
    static let shared = UpdateManager()
    
    @Published var automaticUpdatesEnabled: Bool {
        didSet {
            UserDefaults.standard.set(automaticUpdatesEnabled, forKey: "AutomaticUpdatesEnabled")
            updaterController.updater.automaticallyChecksForUpdates = automaticUpdatesEnabled
        }
    }
    
    private let updaterController: SPUStandardUpdaterController
    
    private init() {
        // Carrega a preferência salva
        self.automaticUpdatesEnabled = UserDefaults.standard.bool(forKey: "AutomaticUpdatesEnabled")
        
        // Inicializa o updater
        self.updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
        
        // Configura baseado na preferência do usuário
        updaterController.updater.automaticallyChecksForUpdates = automaticUpdatesEnabled
    }
    
    func checkForUpdates() {
        updaterController.checkForUpdates(nil)
    }
    
    func enableAutomaticUpdates(_ enabled: Bool) {
        automaticUpdatesEnabled = enabled
    }
} 