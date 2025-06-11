import Foundation
import Sparkle
import UserNotifications
import AppKit

// Classe para gerenciar a interface do usuário das atualizações
class UpdateUIDelegate: NSObject, SPUStandardUserDriverDelegate {
    
    // MARK: - Gentle Reminders Implementation
    
    // Declara suporte para gentle reminders (obrigatório)
    var supportsGentleScheduledUpdateReminders: Bool {
        return true
    }
    
    // Controla quando mostrar atualizações agendadas
    func standardUserDriverShouldHandleShowingScheduledUpdate(_ update: SUAppcastItem, andInImmediateFocus immediateFocus: Bool) -> Bool {
        // Se o app está em foco imediato, deixa o Sparkle mostrar normalmente
        if immediateFocus {
            return true
        }
        
        // Para atualizações em background, implementamos nossa própria lógica
        // Retorna false para que possamos mostrar gentle reminders
        return false
    }
    
    // Adiciona gentle reminders antes de mostrar a atualização
    func standardUserDriverWillHandleShowingUpdate(_ willShowUpdate: Bool, forUpdate update: SUAppcastItem, state: SPUUserUpdateState) {
        print("Preparando para mostrar atualização: \(update.versionString)")
        
        // Se não vamos mostrar a atualização imediatamente, criamos gentle reminders
        if !willShowUpdate {
            showGentleReminder(for: update)
        }
    }
    
    // Notifica quando o usuário deu atenção à atualização
    func standardUserDriverDidReceiveUserAttention(forUpdate update: SUAppcastItem) {
        print("Usuário deu atenção à atualização: \(update.versionString)")
        // Remove notificações ou badges se necessário
        clearGentleReminders()
    }
    
    // Notifica quando a sessão de atualização terminar
    func standardUserDriverWillFinishUpdateSession() {
        print("Sessão de atualização finalizada")
        clearGentleReminders()
    }
    
    func standardUserDriverWillShowModalAlert() {
        print("Mostrando alerta modal de atualização")
    }
    
    // MARK: - Gentle Reminders Implementation
    
    private func showGentleReminder(for update: SUAppcastItem) {
        // Opção 1: Badge no ícone do Dock
        DispatchQueue.main.async {
            NSApp.dockTile.badgeLabel = "!"
        }
        
        // Opção 2: Notificação do sistema (requer permissão)
        requestNotificationPermissionAndShow(for: update)
        
        print("Gentle reminder criado para atualização \(update.versionString)")
    }
    
    private func clearGentleReminders() {
        DispatchQueue.main.async {
            NSApp.dockTile.badgeLabel = ""
        }
        
        // Remove notificações pendentes
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    private func requestNotificationPermissionAndShow(for update: SUAppcastItem) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                self.postUpdateNotification(for: update)
            }
        }
    }
    
    private func postUpdateNotification(for update: SUAppcastItem) {
        let content = UNMutableNotificationContent()
        content.title = "Atualização Disponível"
        content.body = "Granulay \(update.versionString) está disponível"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "granulay-update-\(update.versionString)",
            content: content,
            trigger: nil // Mostra imediatamente
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Erro ao postar notificação: \(error)")
            }
        }
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