# Como Obter e Instalar o Certificado Apple Distribution

## Problema Identificado
❌ **Certificado Apple Distribution não encontrado**

Para publicar na App Store, você precisa do certificado "Apple Distribution" além do "Apple Development" que já possui.

## Passo a Passo para Obter o Certificado

### 1. Acesse o Apple Developer Portal
1. Vá para [developer.apple.com](https://developer.apple.com)
2. Faça login com sua conta Apple Developer
3. Vá para "Certificates, Identifiers & Profiles"

### 2. Criar o Certificado de Distribuição
1. Clique em "Certificates" no menu lateral
2. Clique no botão "+" (Create a Certificate)
3. Selecione "Apple Distribution" em "Software"
4. Clique "Continue"

### 3. Gerar Certificate Signing Request (CSR)
1. Abra o "Keychain Access" no seu Mac
2. Menu "Keychain Access" → "Certificate Assistant" → "Request a Certificate From a Certificate Authority"
3. Preencha:
   - **User Email Address**: gabrielalvesdepaiva@icloud.com
   - **Common Name**: Gabriel Alves de Paiva (ou seu nome)
   - **CA Email Address**: deixe em branco
   - Selecione "Saved to disk"
   - Marque "Let me specify key pair information"
4. Clique "Continue"
5. Escolha:
   - **Key Size**: 2048 bits
   - **Algorithm**: RSA
6. Salve o arquivo .certSigningRequest

### 4. Upload do CSR
1. No Apple Developer Portal, faça upload do arquivo .certSigningRequest
2. Clique "Continue"
3. Clique "Download" para baixar o certificado

### 5. Instalar o Certificado
1. Dê duplo clique no arquivo .cer baixado
2. Ele será automaticamente adicionado ao Keychain
3. Verifique no Keychain Access se aparece "Apple Distribution: [Seu Nome] ([Team ID])"

## Verificar Instalação

Após instalar, execute no terminal:
```bash
security find-identity -v -p codesigning
```

Você deve ver algo como:
```
1) [ID] "Apple Development: gabrielalvesdepaiva@icloud.com (C5AAKU89NP)"
2) [ID] "Apple Distribution: Gabriel Alves de Paiva (TB76NB7VWG)"
```

## Troubleshooting

### Certificado não aparece após instalação
1. Verifique se está no keychain correto (login ou System)
2. Tente arrastar o .cer para o Keychain Access
3. Reinicie o Xcode

### Erro "Certificate not trusted"
1. No Keychain Access, encontre o certificado
2. Clique duplo → "Trust" → "Always Trust"
3. Digite sua senha do Mac

### Múltiplos certificados
Se você tem múltiplos certificados Apple Distribution:
1. Use apenas o mais recente
2. Revogue os antigos no Developer Portal se necessário

## Próximos Passos

Após instalar o certificado:
1. Execute `./check-config.sh` novamente
2. Deve mostrar ✅ para "Certificado Apple Distribution encontrado"
3. Execute `./build-appstore.sh` para criar o build

## Notas Importantes

- O certificado Apple Distribution é válido por 1 ano
- Você precisará renová-lo anualmente
- Mantenha o arquivo .p12 (export) como backup
- Nunca compartilhe sua chave privada

## Backup do Certificado

Para fazer backup:
1. No Keychain Access, encontre o certificado
2. Clique com botão direito → "Export"
3. Salve como .p12 com senha segura
4. Guarde em local seguro (não no repositório!)