# Granulay

Um aplicativo nativo para Mac que adiciona um efeito granulado vintage sobre toda a tela, criando uma textura nostálgica sem interferir na interação do usuário.

## Características

- **Overlay Transparente**: Efeito aplicado sobre todas as telas sem bloquear interações
- **Ícone na Barra de Menu**: Controle rápido para ativar/desativar o efeito
- **Configurações Avançadas**: Ajuste de intensidade e estilo do grão
- **Preview em Tempo Real**: Visualize as mudanças antes de aplicar
- **Performance Otimizada**: Efeito estático que não consome recursos desnecessários
- **Multi-Monitor**: Suporte completo para múltiplas telas

## Estilos de Grão

- **Fino**: Grão sutil e delicado
- **Médio**: Textura equilibrada
- **Grosso**: Efeito mais pronunciado
- **Vintage**: Tom sépia nostálgico

## Requisitos

- macOS 13.0 ou superior
- Xcode 15.0 ou superior
- Swift 5.9 ou superior

## Compilação

1. Abra o projeto no Xcode:

   ```bash
   open Granulay.xcodeproj
   ```

2. Selecione o esquema "Granulay" e o destino "My Mac"

3. Compile e execute o projeto (⌘+R)

## Uso

1. **Ativação**: Clique no ícone na barra de menu ou use o atalho ⌘+G
2. **Configurações**: Acesse através do menu ou atalho ⌘+,
3. **Ajustes**: Modifique intensidade (10-100%) e estilo do grão
4. **Preview**: Visualize as mudanças na área de preview
5. **Reset**: Use "Restaurar Padrão" para voltar às configurações iniciais

## Arquitetura

### Componentes Principais

- **GranulayApp**: Ponto de entrada do aplicativo
- **MenuBarManager**: Gerencia o ícone da barra de menu e estados
- **GrainOverlayWindow**: Cria janelas overlay transparentes
- **GrainEffect**: Renderiza o efeito granulado usando Core Image
- **SettingsView**: Interface de configurações com preview

### Otimizações de Performance

- Textura de grão gerada uma única vez por estilo
- Renderização assíncrona em background
- Overlay estático sem atualizações desnecessárias
- Gerenciamento eficiente de memória

## Tecnologias

- **SwiftUI**: Interface do usuário moderna e declarativa
- **AppKit**: Integração nativa com macOS
- **Core Image**: Geração de texturas granuladas
- **Combine**: Gerenciamento reativo de estados

## Licença

Este projeto é fornecido como exemplo educacional.
