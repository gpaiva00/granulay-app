# Guia para Publicação na App Store - Granulay

## 1. Configuração da Assinatura de Código

### Pré-requisitos
- ✅ Conta Apple Developer ativa
- ✅ Team ID: TB76NB7VWG (já configurado)
- ✅ Xcode instalado

### Configurações Necessárias no Xcode

1. **Abra o projeto no Xcode**:
   ```bash
   open Granulay.xcodeproj
   ```

2. **Configure a assinatura para distribuição**:
   - Selecione o projeto "Granulay" no navegador
   - Vá para a aba "Signing & Capabilities"
   - Para a configuração **Release**:
     - Mude `CODE_SIGN_IDENTITY` de "Apple Development" para "Apple Distribution"
     - Mantenha `CODE_SIGN_STYLE = Automatic`
     - Verifique se `DEVELOPMENT_TEAM = TB76NB7VWG`

## 2. Preparação do Bundle Identifier

### Configuração Atual
- **Debug/Release**: `com.granulay.app`
- **Trial**: `com.granulay.trial`

### Para App Store
O bundle identifier `com.granulay.app` está correto para a versão da App Store.

## 3. Configurações do Info.plist

### Atualizações Necessárias

1. **Versão do App**:
   - Altere `CFBundleShortVersionString` de "--trial-beta" para "1.0.0"
   - Altere `CFBundleVersion` de "-1002003" para "1"

2. **Remover configurações de trial**:
   - Remover ou comentar `ResendApiKey` (não necessário para App Store)
   - Verificar se todas as URLs apontam para produção

## 4. Configurações de Build

### Archive Configuration

1. **Selecione o esquema correto**:
   - Use o esquema "Release" (não "Trial Debug")
   - Product → Scheme → Edit Scheme
   - Archive → Build Configuration → Release

2. **Configurações de otimização**:
   - `SWIFT_COMPILATION_MODE = wholemodule`
   - `SWIFT_OPTIMIZATION_LEVEL = "-O"`
   - `DEAD_CODE_STRIPPING = YES`

## 5. Entitlements para App Store

### Verificar Permissões
O arquivo `Granulay.entitlements` contém:
- ✅ App Sandbox habilitado
- ✅ Permissões de rede
- ✅ Acesso a arquivos do usuário
- ⚠️ Algumas permissões podem precisar de justificativa:
  - `com.apple.security.cs.allow-jit`
  - `com.apple.security.cs.allow-unsigned-executable-memory`
  - `com.apple.security.cs.disable-library-validation`

## 6. Processo de Build e Upload

### Passo a Passo

1. **Limpar o projeto**:
   ```bash
   # No terminal, na pasta do projeto
   xcodebuild clean -project Granulay.xcodeproj -scheme Granulay
   ```

2. **Criar Archive**:
   - Product → Archive
   - Ou via linha de comando:
   ```bash
   xcodebuild archive -project Granulay.xcodeproj -scheme Granulay -archivePath ./build/Granulay.xcarchive
   ```

3. **Validar o Archive**:
   - Window → Organizer
   - Selecione o archive
   - Clique em "Validate App"

4. **Upload para App Store Connect**:
   - No Organizer, clique em "Distribute App"
   - Selecione "App Store Connect"
   - Siga o assistente

## 7. App Store Connect

### Configurações Necessárias

1. **Criar o App**:
   - Acesse [App Store Connect](https://appstoreconnect.apple.com)
   - My Apps → "+" → New App
   - Bundle ID: `com.granulay.app`
   - Nome: "Granulay"
   - Categoria: "Utilities"

2. **Informações do App**:
   - Descrição
   - Screenshots (obrigatório)
   - Ícone do app (1024x1024px)
   - Palavras-chave
   - URL de suporte
   - Política de privacidade

3. **Preços e Disponibilidade**:
   - Definir preço (gratuito ou pago)
   - Territórios de disponibilidade

## 8. Screenshots Necessários

### Tamanhos Obrigatórios para macOS
- 1280 x 800 pixels
- 1440 x 900 pixels
- 2560 x 1600 pixels
- 2880 x 1800 pixels

### Dicas para Screenshots
- Mostre as principais funcionalidades
- Use o app em diferentes cenários
- Capture em alta resolução

## 9. Checklist Final

### Antes do Upload
- [ ] Bundle identifier correto (`com.granulay.app`)
- [ ] Versão atualizada no Info.plist
- [ ] Certificado de distribuição configurado
- [ ] Archive validado sem erros
- [ ] Entitlements revisados
- [ ] Funcionalidades testadas

### App Store Connect
- [ ] App criado no App Store Connect
- [ ] Screenshots adicionados
- [ ] Descrição e metadados preenchidos
- [ ] Política de privacidade configurada
- [ ] Preço definido
- [ ] Build enviado e processado

## 10. Comandos Úteis

### Verificar certificados
```bash
security find-identity -v -p codesigning
```

### Verificar assinatura do app
```bash
codesign -dv --verbose=4 /path/to/Granulay.app
```

### Build via linha de comando
```bash
# Archive
xcodebuild archive -project Granulay.xcodeproj -scheme Granulay -configuration Release -archivePath ./build/Granulay.xcarchive

# Export para App Store
xcodebuild -exportArchive -archivePath ./build/Granulay.xcarchive -exportPath ./build -exportOptionsPlist ExportOptions.plist
```

## Próximos Passos

1. **Imediato**: Atualizar configurações do projeto
2. **Teste**: Criar archive e validar
3. **Upload**: Enviar para App Store Connect
4. **Review**: Aguardar aprovação da Apple (1-7 dias)
5. **Lançamento**: Publicar na App Store

---

**Nota**: Este guia assume que você já tem acesso ao Apple Developer Program. Algumas etapas podem variar dependendo da configuração específica da sua conta.