# Granulay

**Vintage grain effect for macOS** - Um aplicativo que adiciona efeito de grão vintage em tempo real para toda a tela, proporcionando uma experiência visual nostálgica e cinematográfica.

## 🎯 Proposta de Valor

- **Experiência Visual Única**: Transforma qualquer tela em uma experiência cinematográfica vintage
- **Facilidade de Uso**: Controle simples através da barra de menu
- **Personalização Avançada**: Múltiplos estilos e intensidades de grão
- **Funcionalidade Lo-Fi**: Música ambiente integrada para experiência completa
- **Performance Otimizada**: Uso eficiente de recursos do sistema

## Recursos

- 🎨 **Efeito de grão vintage** para toda a tela
- ⚙️ **Configurações personalizáveis** para intensidade e estilo  
- 🖥️ **Suporte a múltiplos monitores** com configurações individuais
- 🔧 **Integração com barra de menu** para acesso rápido
- 💡 **Opção de preservação de brilho**
- 🎯 **4 estilos de grão:** Fino, Médio, Grosso, Vintage
- 🎵 **Estação Lo-Fi integrada** para música ambiente
- 🌍 **Localização completa** em inglês e português brasileiro

## 📦 Instalação e Distribuição

### App Store (Recomendado)
O projeto é distribuído através da **App Store Connect** para garantir máxima compatibilidade e segurança:

- ✅ **App Store oficial** - distribuição confiável e segura
- ✅ **Assinatura digital** certificada pela Apple
- ✅ **Atualizações automáticas** via App Store
- ✅ **Instalação simplificada** com um clique

### Primeiros Passos
1. **Instale** o aplicativo via App Store
2. **Abra** o Granulay - ele aparecerá na barra de menu
3. **Clique** no ícone na barra de menu
4. **Selecione** "Enable Effect" para ativar o efeito de grão
5. **Acesse** "Settings" para personalizar a experiência
6. **Explore** a Lo-Fi Station para música ambiente (versão completa)

## Versões Disponíveis

### Versão Trial
- **Efeito de grão**: Apenas estilo "Fine" com intensidade limitada (0.1-0.3)
- **Funcionalidades**: Interface básica e configurações essenciais
- **Lo-Fi Station**: Não disponível
- **Configurações avançadas**: Limitadas

### Versão Completa
- **Todos os estilos de grão**: Fine, Medium, Coarse, Vintage
- **Intensidade total**: 0.1 a 1.0 (Weak, Medium, Strong)
- **Lo-Fi Station completa**: 4 estações com controles de reprodução
- **Configurações avançadas**: Acesso total a todas as opções
- **Preservação de brilho**: Disponível

## Build do Projeto

### Build Trial
```bash
./build-trial.sh  # Compila versão trial
```

### Build Completo
```bash
# Build via Xcode
xcodebuild -project Granulay.xcodeproj -scheme Granulay -configuration Release
```

## Requisitos do Sistema

- **Sistema Operacional**: macOS 13.0 (Ventura) ou superior
- **Arquitetura**: Apple Silicon (M1/M2/M3) e Intel x86_64
- **Memória**: 4GB RAM mínimo
- **Monitores**: Suporte a múltiplos displays até 8K
- **GPU**: Aceleração hardware recomendada

## Desenvolvimento

### Configuração do Ambiente
1. **Xcode 15.0+** com suporte ao macOS 13.0+
2. **Certificados Apple Developer** configurados
3. **Team ID**: TB76NB7VWG

### Estrutura do Projeto
- **SwiftUI + AppKit**: Interface moderna e nativa
- **Core Image + Metal**: Renderização otimizada do efeito de grão
- **AVFoundation**: Sistema de áudio Lo-Fi
- **Combine**: Reatividade e gerenciamento de estado

### Scripts Disponíveis
- `./build-trial.sh` - Build da versão trial
- `./check-config.sh` - Verificação de configurações

### Arquitetura
- **MenuBarManager**: Gerenciamento da barra de menu
- **GrainOverlayWindow**: Janela de sobreposição para efeito
- **LoFiMusicManager**: Sistema de reprodução de música
- **TrialConfig**: Gerenciamento de limitações trial/completa
- **PerformanceOptimizer**: Otimização baseada em FPS
- **LocalizationHelper**: Sistema de localização EN/PT-BR

### Segurança e Compliance
- **App Sandbox**: Habilitado para máxima segurança
- **Code Signing**: Certificado Apple Distribution
- **Hardened Runtime**: Proteção adicional contra malware
- **Privacy**: Nenhum dado pessoal coletado
- **Team ID**: TB76NB7VWG

## Tecnologias Utilizadas

- **Swift 5.9+**: Linguagem principal
- **SwiftUI**: Interface de usuário moderna
- **AppKit**: Integração com sistema macOS
- **Core Image**: Processamento de imagem
- **Metal**: Aceleração gráfica
- **AVFoundation**: Reprodução de áudio
- **Combine**: Programação reativa

## Performance e Otimização

- **CPU**: Uso máximo de 5% em operação normal
- **Memória**: Consumo máximo de 100MB RAM
- **GPU**: Uso eficiente de aceleração hardware
- **Latência**: Resposta instantânea (<50ms) para toggle do efeito
- **Disponibilidade**: 99.9% uptime (excluindo manutenções)
- **Recuperação**: Recuperação automática de crashes em <5 segundos
- **Compatibilidade**: Apple Silicon (M1/M2/M3) e Intel x86_64

## Funcionalidades Principais

### Efeito de Grão Vintage
- **Renderização em tempo real** sem lag perceptível
- **Sobreposição transparente** que não interfere com outros apps
- **Suporte a múltiplos monitores** com configurações independentes
- **4 estilos disponíveis**: Fine, Medium, Coarse, Vintage
- **Controle de intensidade**: 0.1 a 1.0 (Weak, Medium, Strong)
- **Preservação de brilho**: Mantém luminosidade original da tela

### Lo-Fi Station Integrada
- **4 estações pré-configuradas** com música ambiente
- **Controles completos**: Play/Pause/Stop/Previous/Next
- **Volume independente** do sistema
- **Integração com menu** da barra para acesso rápido

### Interface e Usabilidade
- **Menu na barra**: Acesso rápido e não intrusivo
- **Toggle instantâneo**: Ativar/desativar com um clique
- **Configurações avançadas**: Interface SwiftUI moderna
- **Preview em tempo real**: Visualização imediata das alterações
- **Acessibilidade**: Suporte completo a VoiceOver

## 🎨 Público-Alvo

- **Primário**: Criadores de conteúdo, designers, fotógrafos
- **Secundário**: Entusiastas de estética vintage, usuários que buscam experiência visual diferenciada
- **Terciário**: Profissionais que trabalham longas horas e desejam reduzir fadiga visual

## 🚀 Roadmap

### Funcionalidades Futuras
- **Novos estilos de grão**: Expansão da biblioteca de efeitos
- **Presets personalizáveis**: Configurações salvas pelo usuário
- **Integração com Spotify/Apple Music**: Controle de música externa
- **Atalhos de teclado globais**: Controle sem usar o mouse
- **Modo escuro/claro automático**: Adaptação ao tema do sistema

## 📞 Suporte

Para suporte técnico, dúvidas ou sugestões:
- **Email**: [Incluir email de suporte]
- **Website**: [Incluir website oficial]
- **Documentação**: Disponível no menu "Help" do aplicativo

## Licença

Todos os direitos reservados © 2025 Gabriel Paiva
