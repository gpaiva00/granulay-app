# PRD - Product Requirements Document
# Granulay - Vintage Grain Effect for macOS

## 📋 Visão Geral do Produto

### Descrição
Granulay é um aplicativo macOS que adiciona efeito de grão vintage em tempo real para toda a tela, proporcionando uma experiência visual nostálgica e cinematográfica. O aplicativo opera como uma sobreposição transparente que pode ser ativada/desativada facilmente através da barra de menu.

### Proposta de Valor
- **Experiência Visual Única**: Transforma qualquer tela em uma experiência cinematográfica vintage
- **Facilidade de Uso**: Controle simples através da barra de menu
- **Personalização Avançada**: Múltiplos estilos e intensidades de grão
- **Funcionalidade Lo-Fi**: Música ambiente integrada para experiência completa
- **Performance Otimizada**: Uso eficiente de recursos do sistema

### Público-Alvo
- **Primário**: Criadores de conteúdo, designers, fotógrafos
- **Secundário**: Entusiastas de estética vintage, usuários que buscam experiência visual diferenciada
- **Terciário**: Profissionais que trabalham longas horas e desejam reduzir fadiga visual

---

## 🎯 Objetivos do Produto

### Objetivos Primários
1. Fornecer efeito de grão vintage de alta qualidade em tempo real
2. Manter performance otimizada sem impacto significativo no sistema
3. Oferecer interface intuitiva e não intrusiva
4. Garantir compatibilidade com múltiplos monitores

### Objetivos Secundários
1. Integrar funcionalidade de música Lo-Fi ambiente
2. Implementar sistema de atualizações automáticas
3. Suporte completo para localização (EN/PT-BR)
4. Estratégia de monetização através de versão trial

---

## ⚙️ Requisitos Funcionais

### RF001 - Efeito de Grão
**Descrição**: Aplicar efeito de grão vintage em tempo real sobre toda a tela

**Critérios de Aceitação**:
- ✅ Sobreposição transparente que não interfere na interação com outros apps
- ✅ Renderização em tempo real sem lag perceptível
- ✅ Suporte a múltiplos monitores com configurações independentes
- ✅ 4 estilos de grão disponíveis: Fine, Medium, Coarse, Vintage
- ✅ Controle de intensidade de 0.1 a 1.0
- ✅ Opção de preservar brilho da tela

### RF002 - Interface de Controle
**Descrição**: Interface acessível através da barra de menu

**Critérios de Aceitação**:
- ✅ Ícone na barra de menu sempre visível
- ✅ Menu contextual com opções principais
- ✅ Toggle rápido para ativar/desativar efeito
- ✅ Acesso direto às configurações
- ✅ Indicação visual do status (ativo/inativo)

### RF003 - Configurações Avançadas
**Descrição**: Painel de configurações completo

**Critérios de Aceitação**:
- ✅ Interface SwiftUI moderna e responsiva
- ✅ Organização por categorias (Aparência, Comportamento, Lo-Fi, Atualizações)
- ✅ Preview em tempo real das alterações
- ✅ Salvamento automático de configurações
- ✅ Opção de reset para configurações padrão

### RF004 - Sistema Lo-Fi
**Descrição**: Reprodução de música Lo-Fi ambiente integrada

**Critérios de Aceitação**:
- ✅ 4 estações Lo-Fi pré-configuradas
- ✅ Controles de reprodução (Play/Pause/Stop)
- ✅ Navegação entre estações (Anterior/Próxima)
- ✅ Controle de volume independente
- ✅ Integração com menu da barra

### RF005 - Sistema de Atualizações
**Descrição**: Verificação e instalação automática de atualizações

**Critérios de Aceitação**:
- ✅ Verificação automática de atualizações
- ✅ Notificações de novas versões disponíveis
- ✅ Download e instalação automática (opcional)
- ✅ Changelog integrado
- ✅ Rollback em caso de problemas

### RF006 - Localização
**Descrição**: Suporte completo para múltiplos idiomas

**Critérios de Aceitação**:
- ✅ Inglês (EN) como idioma padrão
- ✅ Português Brasileiro (PT-BR)
- ✅ Detecção automática do idioma do sistema
- ✅ Todas as strings da interface localizadas
- ✅ Formatação adequada para cada idioma

---

## 🚫 Requisitos Não Funcionais

### RNF001 - Performance
- **CPU**: Uso máximo de 5% em operação normal
- **Memória**: Consumo máximo de 100MB RAM
- **GPU**: Uso eficiente de aceleração hardware quando disponível
- **Latência**: Resposta instantânea (<50ms) para toggle do efeito

### RNF002 - Compatibilidade
- **Sistema**: macOS 13.0 (Ventura) ou superior
- **Arquitetura**: Apple Silicon (M1/M2/M3) e Intel x86_64
- **Monitores**: Suporte a múltiplos displays até 8K
- **Memória**: Mínimo 4GB RAM

### RNF003 - Segurança
- **Sandbox**: App Sandbox habilitado
- **Permissões**: Apenas permissões essenciais solicitadas
- **Criptografia**: Comunicação HTTPS para atualizações
- **Assinatura**: Code signing com certificado Apple Developer

### RNF004 - Usabilidade
- **Tempo de Aprendizado**: Usuário deve conseguir usar funcionalidades básicas em <2 minutos
- **Acessibilidade**: Suporte a VoiceOver e navegação por teclado
- **Feedback Visual**: Indicações claras de status e ações
- **Consistência**: Interface seguindo Human Interface Guidelines da Apple

### RNF005 - Confiabilidade
- **Disponibilidade**: 99.9% uptime (excluindo manutenções programadas)
- **Recuperação**: Recuperação automática de crashes em <5 segundos
- **Backup**: Configurações salvas automaticamente
- **Logs**: Sistema de logging para diagnóstico

---

## 🔄 Fluxos de Usuário Principais

### Fluxo 1: Primeiro Uso
```
1. Usuário instala e abre o aplicativo
2. Sistema solicita permissões necessárias
3. Aplicativo aparece na barra de menu
4. Usuário clica no ícone da barra de menu
5. Menu contextual é exibido
6. Usuário seleciona "Enable Effect"
7. Efeito de grão é aplicado imediatamente
8. Usuário pode ajustar configurações via "Settings"
```

### Fluxo 2: Uso Diário
```
1. Usuário clica no ícone na barra de menu
2. Toggle rápido para ativar/desativar efeito
3. Ajuste rápido de intensidade (se necessário)
4. Acesso a estações Lo-Fi (se habilitado)
5. Configurações persistem entre sessões
```

### Fluxo 3: Configuração Avançada
```
1. Usuário acessa "Settings" no menu
2. Janela de configurações abre
3. Navegação por abas: Aparência, Comportamento, Lo-Fi, Atualizações
4. Alterações aplicadas em tempo real
5. Configurações salvas automaticamente
6. Usuário fecha janela, configurações persistem
```

### Fluxo 4: Sistema Lo-Fi
```
1. Usuário acessa submenu "Lo-Fi Station"
2. Seleciona estação desejada
3. Clica em "Play" para iniciar reprodução
4. Controla volume através do submenu
5. Navega entre estações com Previous/Next
6. Para reprodução com "Stop"
```

---

## 🎭 Especificações da Versão Trial

### Estratégia de Monetização
A versão trial serve como demonstração das capacidades do produto, incentivando a compra da versão completa através de limitações estratégicas que não comprometem a experiência básica.

### Limitações Implementadas

#### L001 - Efeito de Grão
- **Estilo**: Apenas "Fine" disponível
- **Intensidade**: Limitada de 0.1 a 0.3 (apenas "Weak")
- **Preservar Brilho**: Sempre desativado
- **Justificativa**: Permite experiência básica mantendo incentivo para upgrade

#### L002 - Funcionalidades
- **Lo-Fi Station**: Completamente desabilitado (menu oculto)
- **Seção Comportamento**: Desabilitada nas configurações
- **Configurações Avançadas**: Acesso limitado
- **Justificativa**: Funcionalidades premium reservadas para versão paga

#### L003 - Interface
- **Nome do App**: "Granulay Trial" (diferenciação clara)
- **Bundle ID**: `com.granulay.trial` (separação técnica)
- **Botão de Compra**: Prominente nas configurações
- **Versão**: "1.0.0-trial" (identificação clara)

### Configuração Técnica

#### Build Configurations
- **Trial Debug**: Para desenvolvimento e testes da versão trial
- **Debug**: Versão completa para desenvolvimento
- **Release**: Versão completa para produção

#### Compilação
```bash
# Versão Trial
./build-trial.sh
xcodebuild -project Granulay.xcodeproj -target Granulay -configuration "Trial Debug"

# Versão Completa
xcodebuild -project Granulay.xcodeproj -target Granulay -configuration Release
```

#### Detecção de Versão
```swift
static var isTrialVersion: Bool {
    #if TRIAL_VERSION
    return true
    #else
    return false
    #endif
}
```

### Experiência do Usuário Trial

#### Onboarding
1. Instalação simples via download direto
2. Primeira execução mostra limitações claramente
3. Experiência básica funcional imediatamente
4. Call-to-action para upgrade bem posicionado

#### Limitações Visíveis
- Interface clara sobre status trial
- Seções desabilitadas com explicação
- Botão de compra sempre acessível
- Comparação trial vs completa na tela de compra

#### Conversão
- **URL de Compra**: `https://gabrielpaiva5.gumroad.com/l/granulay`
- **Preço**: Acesso vitalício
- **Proposta**: "💎 Acesso completo e vitalício"

---

## 🚀 Especificações da Versão Completa

### Funcionalidades Desbloqueadas

#### F001 - Efeito de Grão Completo
- **Todos os Estilos**: Fine, Medium, Coarse, Vintage
- **Intensidade Total**: 0.1 a 1.0 (Weak, Medium, Strong)
- **Preservar Brilho**: Opção disponível
- **Configurações Avançadas**: Acesso total

#### F002 - Sistema Lo-Fi Completo
- **4 Estações**: Chill Lo-Fi, Jazz Lo-Fi, Study Beats, Sleep Lo-Fi
- **Controles Completos**: Play/Pause/Stop/Previous/Next
- **Controle de Volume**: 0-100%
- **Integração Menu**: Submenu completo na barra

#### F003 - Configurações Avançadas
- **Seção Comportamento**: Totalmente acessível
- **Configurações de Performance**: Otimizações disponíveis
- **Múltiplos Monitores**: Configuração independente
- **Atalhos de Teclado**: Personalizáveis

#### F004 - Atualizações Premium
- **Atualizações Automáticas**: Sem limitações
- **Acesso Beta**: Versões de teste antecipadas
- **Suporte Prioritário**: Canal direto com desenvolvedor

### Diferenciação Técnica

#### Bundle Configuration
- **Bundle ID**: `com.granulay.app`
- **Nome**: "Granulay"
- **Versão**: Obtida do Bundle (`CFBundleShortVersionString`)

#### Detecção de Recursos
```swift
// Estilos permitidos
static var allowedGrainStyles: [GrainStyle] {
    return GrainStyle.allCases // Todos os estilos
}

// Range de intensidade
static var allowedIntensityRange: ClosedRange<Double> {
    return 0.1...1.0 // Intensidade completa
}

// Funcionalidades
static var isLoFiEnabled: Bool {
    return true // Lo-Fi habilitado
}
```

---

## 🏗️ Arquitetura Técnica

### Stack Tecnológico
- **Framework**: SwiftUI + AppKit
- **Linguagem**: Swift 5.9+
- **Minimum Deployment**: macOS 13.0
- **Graphics**: Core Image + Metal
- **Audio**: AVFoundation
- **Networking**: URLSession
- **Storage**: UserDefaults

### Componentes Principais

#### MenuBarManager
- **Responsabilidade**: Gerenciamento da interface da barra de menu
- **Funcionalidades**: Toggle de efeito, menu contextual, integração Lo-Fi
- **Estado**: Published properties para reatividade

#### GrainOverlayWindow
- **Responsabilidade**: Janela de sobreposição para efeito de grão
- **Funcionalidades**: Renderização em tempo real, múltiplos monitores
- **Performance**: Otimizada com Metal e Core Image

#### GrainEffect
- **Responsabilidade**: Geração e aplicação do efeito de grão
- **Funcionalidades**: 4 estilos, cache de texturas, blend modes
- **Otimização**: Texture cache e performance monitoring

#### TrialConfig
- **Responsabilidade**: Gerenciamento de limitações trial vs completa
- **Funcionalidades**: Feature flags, validação de recursos
- **Compilação**: Conditional compilation com #if TRIAL_VERSION

#### LoFiMusicManager
- **Responsabilidade**: Reprodução de música Lo-Fi
- **Funcionalidades**: Streaming, controle de volume, estações
- **Estado**: Published properties para UI reativa

#### UpdateManager
- **Responsabilidade**: Sistema de atualizações automáticas
- **Funcionalidades**: Verificação, download, instalação
- **Segurança**: Verificação de assinatura digital

### Padrões de Design
- **MVVM**: Model-View-ViewModel com SwiftUI
- **Singleton**: Para managers globais (LoFiMusicManager, UpdateManager)
- **Observer**: Combine framework para reatividade
- **Strategy**: Diferentes estilos de grão
- **Factory**: Criação de texturas de grão

---

## 📊 Métricas e KPIs

### Métricas de Produto
- **Taxa de Conversão Trial→Pago**: Meta 15-25%
- **Tempo de Uso Diário**: Meta 2-4 horas
- **Retenção D7**: Meta 60%
- **Retenção D30**: Meta 40%
- **NPS (Net Promoter Score)**: Meta >50

### Métricas Técnicas
- **Crash Rate**: <0.1%
- **Tempo de Inicialização**: <2 segundos
- **Uso de CPU**: <5% em operação normal
- **Uso de Memória**: <100MB
- **Tempo de Resposta UI**: <50ms

### Métricas de Negócio
- **Downloads Trial**: Tracking via analytics
- **Conversões**: Via Gumroad analytics
- **Revenue**: Receita mensal recorrente
- **CAC (Customer Acquisition Cost)**: Custo por conversão
- **LTV (Lifetime Value)**: Valor vitalício do cliente

---

## 🚀 Roadmap de Desenvolvimento

### Fase 1: MVP (Concluída) ✅
- [x] Efeito de grão básico
- [x] Interface barra de menu
- [x] Configurações básicas
- [x] Sistema trial/completo

### Fase 2: Funcionalidades Avançadas (Concluída) ✅
- [x] Sistema Lo-Fi
- [x] Múltiplos estilos de grão
- [x] Configurações avançadas
- [x] Sistema de atualizações
- [x] Localização PT-BR

### Fase 3: Polimento e Lançamento (Em Andamento) 🔄
- [x] Otimizações de performance
- [x] Testes extensivos
- [x] Preparação App Store
- [ ] Marketing e lançamento
- [ ] Coleta de feedback inicial

### Fase 4: Expansão (Planejada) 📋
- [ ] Novos estilos de grão
- [ ] Presets personalizáveis
- [ ] Integração com Spotify/Apple Music
- [ ] Atalhos de teclado globais
- [ ] Modo escuro/claro automático

---

## 🎨 Especificações de Design

### Identidade Visual
- **Cores Primárias**: Sistema (adapta ao tema do macOS)
- **Ícone**: Minimalista, representa grão/textura
- **Tipografia**: SF Pro (sistema macOS)
- **Estilo**: Moderno, limpo, não intrusivo

### Interface Guidelines
- **Princípio**: Seguir Human Interface Guidelines da Apple
- **Acessibilidade**: Suporte completo a VoiceOver
- **Responsividade**: Adaptação a diferentes tamanhos de tela
- **Consistência**: Padrões visuais consistentes em toda a app

### Componentes UI
- **Menu Bar**: Ícone discreto, menu contextual intuitivo
- **Settings Window**: Layout em abas, controles nativos
- **Sliders**: Feedback visual em tempo real
- **Buttons**: Estados claros (normal, hover, pressed, disabled)

---

## 🔒 Considerações de Segurança

### App Sandbox
- **Status**: Habilitado para App Store
- **Permissões**: Apenas essenciais
- **Network**: Apenas HTTPS para atualizações e Lo-Fi
- **File System**: Acesso limitado a configurações

### Code Signing
- **Certificado**: Apple Distribution Certificate
- **Team ID**: TB76NB7VWG
- **Notarization**: Obrigatória para distribuição
- **Hardened Runtime**: Habilitado

### Privacy
- **Dados Coletados**: Nenhum dado pessoal
- **Analytics**: Apenas métricas técnicas anônimas
- **Permissões**: Transparência total sobre uso
- **GDPR**: Compliance total

---

## 📈 Estratégia de Go-to-Market

### Canais de Distribuição
1. **App Store** (Principal)
   - Descoberta orgânica
   - Credibilidade da plataforma
   - Sistema de pagamento integrado

2. **Website Próprio** (Secundário)
   - Download direto da versão trial
   - Controle total da experiência
   - Métricas detalhadas

3. **Gumroad** (Monetização)
   - Processamento de pagamentos
   - Entrega automática
   - Analytics de vendas

### Estratégia de Preços
- **Modelo**: Pagamento único (lifetime)
- **Preço**: Competitivo no mercado de utilities macOS
- **Trial**: Funcionalidades limitadas, sem tempo limite
- **Valor**: Foco na proposta de valor única

### Marketing
- **Target**: Criadores de conteúdo, designers
- **Canais**: Redes sociais, communities de design
- **Conteúdo**: Demos visuais, before/after
- **Influencers**: Parcerias com criadores de conteúdo

---

## 📋 Critérios de Aceitação Final

### Funcionalidade
- [ ] Todos os requisitos funcionais implementados
- [ ] Versão trial com limitações corretas
- [ ] Versão completa com todas as funcionalidades
- [ ] Sistema de atualizações funcionando
- [ ] Localização completa EN/PT-BR

### Performance
- [ ] Uso de CPU <5% em operação normal
- [ ] Uso de memória <100MB
- [ ] Tempo de resposta <50ms
- [ ] Sem vazamentos de memória
- [ ] Estabilidade em uso prolongado

### Qualidade
- [ ] Zero crashes em testes extensivos
- [ ] Interface responsiva e intuitiva
- [ ] Compatibilidade com múltiplos monitores
- [ ] Suporte a diferentes resoluções
- [ ] Acessibilidade completa

### Distribuição
- [ ] Build App Store aprovado
- [ ] Certificados e assinaturas válidos
- [ ] Metadata e screenshots preparados
- [ ] Sistema de analytics implementado
- [ ] Documentação completa

---

## 📞 Contatos e Responsabilidades

### Desenvolvimento
- **Lead Developer**: Gabriel Paiva
- **Responsabilidades**: Arquitetura, implementação, testes
- **Contato**: Via GitHub Issues

### Design
- **UI/UX**: Gabriel Paiva
- **Responsabilidades**: Interface, experiência do usuário
- **Guidelines**: Apple Human Interface Guidelines

### Produto
- **Product Owner**: Gabriel Paiva
- **Responsabilidades**: Roadmap, requisitos, priorização
- **Decisões**: Baseadas em feedback e métricas

---

## 📚 Documentação Relacionada

- `README.md` - Visão geral e instruções básicas
- `README-TRIAL.md` - Especificações da versão trial
- `APP_STORE_GUIDE.md` - Guia para publicação na App Store
- `CERTIFICADO_DISTRIBUICAO.md` - Configuração de certificados
- `RESUMO_PUBLICACAO.md` - Status da publicação
- `CHANGELOG` - Histórico de versões

---

**Versão do Documento**: 1.0  
**Data**: Janeiro 2025  
**Autor**: Gabriel Paiva  
**Status**: Aprovado para Desenvolvimento