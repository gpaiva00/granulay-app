# Granulay - Versão Trial

Este documento explica como trabalhar com a versão trial do Granulay durante o desenvolvimento.

## Configurações de Build

O projeto possui três configurações de build:

- **Debug**: Versão completa para desenvolvimento
- **Release**: Versão completa para produção
- **Trial Debug**: Versão trial para testes

## Como Compilar

### Versão Completa (Debug)
```bash
xcodebuild -project Granulay.xcodeproj -target Granulay -configuration Debug
```

### Versão Completa (Release)
```bash
xcodebuild -project Granulay.xcodeproj -target Granulay -configuration Release
```

### Versão Trial
```bash
# Usando o script automatizado
./build-trial.sh

# Ou manualmente
xcodebuild -project Granulay.xcodeproj -target Granulay -configuration "Trial Debug"
```

## Limitações da Versão Trial

A versão trial possui as seguintes limitações implementadas:

### Efeito de Grão
- ✅ **Estilo**: Apenas "Fine" (Fino)
- ✅ **Intensidade**: Limitada de 0.1 a 0.3 (apenas "Weak")
- ✅ **Preservar Brilho**: Sempre desativado

### Funcionalidades
- ✅ **Lo-Fi Station**: Completamente desabilitado (menu oculto)
- ✅ **Seção Comportamento**: Desabilitada nas configurações
- ✅ **Botão de Compra**: Aparece nas configurações

### Interface
- ✅ **Nome do App**: Muda para "Granulay Trial"
- ✅ **Bundle ID**: `com.granulay.trial` (diferente da versão completa)

## Arquivos Relacionados

### Configuração Trial
- `TrialConfig.swift`: Contém toda a lógica de detecção e limitações da versão trial
- `PurchaseSettingsView.swift`: Interface do botão de compra

### Implementação das Limitações
- `MenuBarManager.swift`: Aplica limitações de grão e oculta menu Lo-Fi
- `SettingsView.swift`: Oculta seções não disponíveis na trial

### Scripts
- `build-trial.sh`: Script automatizado para compilar a versão trial

## Como Funciona

A detecção da versão trial é feita através da flag de compilação `TRIAL_VERSION`:

```swift
static var isTrialVersion: Bool {
    #if TRIAL_VERSION
    return true
    #else
    return false
    #endif
}
```

Esta flag é definida automaticamente na configuração "Trial Debug" através da configuração:
```
SWIFT_ACTIVE_COMPILATION_CONDITIONS = "DEBUG TRIAL_VERSION"
```

## Testando a Versão Trial

1. Compile usando `./build-trial.sh`
2. Execute o app: `open 'build/Trial Debug/Granulay.app'`
3. Verifique:
   - Nome do app na barra de menu: "Granulay Trial"
   - Menu Lo-Fi não aparece
   - Configurações limitadas (apenas Fine, intensidade baixa)
   - Botão "Comprar Versão Completa" nas configurações

## Alternando Entre Versões

### Durante Desenvolvimento
- Use Xcode normalmente para a versão completa (configuração Debug)
- Use `./build-trial.sh` quando precisar testar a versão trial

### Para Distribuição
- **Versão Completa**: Use configuração Release
- **Versão Trial**: Use configuração Trial Debug

## Notas Importantes

- As duas versões podem coexistir no sistema (Bundle IDs diferentes)
- A versão trial sempre força as limitações, mesmo se o usuário tentar modificar
- O botão de compra direciona para: https://granulay.gumroad.com/l/granulay
- Todas as strings da interface estão localizadas em `Localizable.strings`