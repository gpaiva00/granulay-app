import Foundation
import Sparkle

// Classe para gerenciar a interface do usuário das atualizações
class UpdateUIDelegate: NSObject, SPUStandardUserDriverDelegate {
    func standardUserDriverWillHandleShowingUpdate(_ willShowUpdate: Bool, forUpdate update: SUAppcastItem, state: SPUUserUpdateState) {
        print("Preparando para mostrar atualização: \(update.versionString)")
    }
    
    func standardUserDriverWillShowModalAlert() {
        print("Mostrando alerta modal de atualização")
    }
}

class UpdateManager: NSObject, ObservableObject, SPUUpdaterDelegate {
    static let shared = UpdateManager()
    
    @Published var automaticUpdatesEnabled: Bool {
        didSet {
            UserDefaults.standard.set(automaticUpdatesEnabled, forKey: "AutomaticUpdatesEnabled")
            updaterController.updater.automaticallyChecksForUpdates = automaticUpdatesEnabled
        }
    }
    
    private var updaterController: SPUStandardUpdaterController!
    private let uiDelegate = UpdateUIDelegate()
    
    private override init() {
        // Carrega a preferência salva
        self.automaticUpdatesEnabled = UserDefaults.standard.bool(forKey: "AutomaticUpdatesEnabled")
        
        super.init()
        
        // Inicializa o updater com o delegate após super.init()
        self.updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: self,
            userDriverDelegate: uiDelegate
        )
        
        // Configura baseado na preferência do usuário
        updaterController.updater.automaticallyChecksForUpdates = automaticUpdatesEnabled
        
        // Log para debug
        print("UpdateManager inicializado")
        print("Feed URL: \(updaterController.updater.feedURL?.absoluteString ?? "nil")")
        print("Updates automáticos: \(automaticUpdatesEnabled)")
    }
    
    func checkForUpdates() {
        print("Verificando atualizações manualmente...")
        updaterController.checkForUpdates(nil)
    }
    
    func enableAutomaticUpdates(_ enabled: Bool) {
        automaticUpdatesEnabled = enabled
    }
    
    // MARK: - SPUUpdaterDelegate
    
    // Fornece URL do appcast como fallback se não estiver no Info.plist
    func feedURLString(for updater: SPUUpdater) -> String? {
        let feedURL = "https://gpaiva00.github.io/granulay-releases/appcast.xml"
        print("Fornecendo URL do appcast via delegate: \(feedURL)")
        return feedURL
    }
    
    // Permite canal beta
    func allowedChannels(for updater: SPUUpdater) -> Set<String> {
        let channels: Set<String> = ["beta"]
        print("Canais permitidos: \(channels)")
        return channels
    }
    
    // Log quando não encontrar atualizações
    func updaterDidNotFindUpdate(_ updater: SPUUpdater, error: Error) {
        print("Nenhuma atualização encontrada: \(error.localizedDescription)")
        
        // Debug adicional
        let userInfo = (error as NSError).userInfo
        if let latestItem = userInfo[SPULatestAppcastItemFoundKey] as? SUAppcastItem {
            print("Último item encontrado: versão \(latestItem.versionString)")
        }
    }
    
    // Log quando encontrar atualização
    func updater(_ updater: SPUUpdater, didFindValidUpdate item: SUAppcastItem) {
        print("Atualização encontrada: \(item.versionString)")
    }
    
    // Log quando o appcast for carregado - usando nome correto do método
    func updater(_ updater: SPUUpdater, didFinishLoading appcast: SUAppcast) {
        print("Appcast carregado com \(appcast.items.count) itens")
        for item in appcast.items {
            print("- Item: \(item.versionString) (canal: \(item.channel ?? "default"))")
        }
    }
} 