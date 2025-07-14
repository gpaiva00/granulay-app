#!/bin/bash

# 🚀 SCRIPT MASTER DE RELEASE DO GRANULAY
# Automatiza todo o fluxo: build → assinatura → upload → appcast → deploy
# Uso: ./release.sh <versao> [--production|--channel beta]

set -e

# Diretório do script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Configurações
REPO_OWNER="gpaiva00"
APP_REPO="granulay-app" 
RELEASES_REPO="granulay-releases"
RELEASES_REPO_URL="git@github.com:$REPO_OWNER/$RELEASES_REPO.git"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para logs
log() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

# Verificar argumentos
if [ $# -eq 0 ]; then
    error "Uso: $0 <versao> [--production|--channel beta]
    
Exemplos:
  ./release.sh 1.0.1               # Release beta (padrão)
  ./release.sh 1.0.1 --channel beta   # Release beta (explícito)
  ./release.sh 1.0.1 --production     # Release de produção"
fi

VERSION="$1"
IS_PRODUCTION="false"
CHANNEL="beta"
VERSION_STRING="$VERSION-beta"

# Processar segundo argumento se fornecido
if [ $# -gt 1 ]; then
    if [ "${2:-}" = "--production" ]; then
        IS_PRODUCTION="true"
        CHANNEL="stable"
        VERSION_STRING="$VERSION"
    elif [ "${2:-}" = "--channel" ] && [ "${3:-}" = "beta" ]; then
        # Explicitamente definindo como beta (já é o padrão, mas deixamos claro)
        IS_PRODUCTION="false"
        CHANNEL="beta"
        VERSION_STRING="$VERSION-beta"
    elif [ "${2:-}" = "--channel" ]; then
        error "Canal inválido. Use: --channel beta ou --production"
    else
        error "Parâmetro inválido: ${2:-}. Use --production ou --channel beta"
    fi
fi

echo "
🚀 =====================================
   GRANULAY RELEASE AUTOMÁTICO v$VERSION
   Canal: $CHANNEL
=====================================
"

# STEP 1: Verificações iniciais
log "📋 Verificando pré-requisitos..."

# Verificar se git está limpo
if [[ $(git status --porcelain) ]]; then
    warning "Há mudanças não commitadas. Commit ou stash primeiro."
    git status --short
    read -p "Continuar mesmo assim? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Verificar se as chaves existem
if [ ! -f "sparkle_private_key.pem" ]; then
    error "Chaves do Sparkle não encontradas. Execute ./generate_keys primeiro."
fi

# Verificar se o comando generate_appcast existe
if [ ! -f "./bin/generate_appcast" ]; then
    error "Comando generate_appcast não encontrado em ./bin/"
fi

# Verificar se o ssh está configurado para GitHub
if ! ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    warning "SSH para GitHub não configurado. Certifique-se de ter acesso ao repositório $RELEASES_REPO"
fi

success "Pré-requisitos OK"

# STEP 2: Atualizar versão no Info.plist
log "📝 Atualizando versão no Info.plist..."

# Gerar número sequencial para CFBundleVersion baseado na versão completa
# Converte versão como 1.1.2 para um número sequencial (ex: 1001002)
MAJOR=$(echo "$VERSION" | cut -d'.' -f1)
MINOR=$(echo "$VERSION" | cut -d'.' -f2)
PATCH=$(echo "$VERSION" | cut -d'.' -f3)
VERSION_NUMBER=$((MAJOR * 1000000 + MINOR * 1000 + PATCH))

# Atualizar CFBundleShortVersionString (procurar pela linha seguinte após a key)
sed -i.bak '/CFBundleShortVersionString/{n;s/<string>.*<\/string>/<string>'$VERSION_STRING'<\/string>/;}' Granulay/Info.plist

# Atualizar CFBundleVersion (procurar pela linha seguinte após a key)
sed -i.bak2 '/CFBundleVersion/{n;s/<string>.*<\/string>/<string>'$VERSION_NUMBER'<\/string>/;}' Granulay/Info.plist

# Remover arquivos backup
rm Granulay/Info.plist.bak Granulay/Info.plist.bak2

success "Versões atualizadas:"
success "  CFBundleShortVersionString: $VERSION_STRING"
success "  CFBundleVersion: $VERSION_NUMBER"

# STEP 3: Build do app
log "🔨 Fazendo build do projeto..."
rm -rf build/ dist/
mkdir -p build dist

xcodebuild -project Granulay.xcodeproj \
           -scheme Granulay \
           -configuration Release \
           -derivedDataPath build/DerivedData \
           -destination "platform=macOS" \
           -allowProvisioningUpdates \
           build

# Copiar app para dist
cp -R build/DerivedData/Build/Products/Release/Granulay.app dist/
success "Build completo"

# # STEP 4: Criar ZIP
# log "📦 Criando ZIP..."
# cd dist
# zip -r "Granulay-$VERSION.zip" Granulay.app
# cd ..
# success "ZIP criado: dist/Granulay-$VERSION.zip"

# STEP 4: Criar DMG com atalho para Applications
log "💿 Criando DMG instalador..."

# Verificar se create-dmg está instalado
if ! command -v create-dmg &> /dev/null; then
    error "create-dmg não encontrado. Instale com: brew install create-dmg"
fi

create-dmg \
    --volname "Granulay Installer" \
    --volicon "Granulay/Assets.xcassets/AppIcon.appiconset/icon_512x512.png" \
    --window-pos 200 120 \
    --window-size 800 400 \
    --background "assets/background.png" \
    --icon-size 100 \
    --icon "Granulay.app" 200 190 \
    --hide-extension "Granulay.app" \
    --app-drop-link 600 185 \
    --text-size 12 \
    "dist/Granulay-$VERSION.dmg" \
    "dist/Granulay.app/"

success "DMG criado: dist/Granulay-$VERSION.dmg"

# STEP 5: Usar release notes HTML existente
log "📄 Usando arquivo de release notes existente..."
RELEASE_NOTES_FILE="dist/Granulay-$VERSION.html"

# Verificar se o arquivo release-notes.html existe
if [ ! -f "release-notes.html" ]; then
    error "Arquivo release-notes.html não encontrado. Crie o arquivo primeiro."
fi

# Copiar o arquivo release-notes.html para o diretório dist
cp "release-notes.html" "$RELEASE_NOTES_FILE"

success "Release notes copiadas de release-notes.html para: $RELEASE_NOTES_FILE"

# STEP 6: Upload automatizado para GitHub Releases usando GitHub CLI
log "📤 Criando release no GitHub e fazendo upload..."

# Verificar se o GitHub CLI está configurado
if ! gh auth status >/dev/null 2>&1; then
    error "GitHub CLI não está autenticado. Execute: gh auth login"
fi

# Determinar se é pre-release baseado no canal
if [ "$IS_PRODUCTION" = "true" ]; then
    PRERELEASE_FLAG=""
    RELEASE_TITLE="Granulay $VERSION_STRING"
else
    PRERELEASE_FLAG="--prerelease"
    RELEASE_TITLE="Granulay $VERSION_STRING Beta"
fi

# Criar release e fazer upload dos arquivos
log "Criando release v$VERSION_STRING..."
gh release create "v$VERSION_STRING" \
    "./dist/Granulay-$VERSION.dmg" \
    --title "$RELEASE_TITLE" \
    --notes-file "./dist/Granulay-$VERSION.html" \
    $PRERELEASE_FLAG \
    --repo "$REPO_OWNER/$APP_REPO"

if [ $? -ne 0 ]; then
    error "Falha ao criar release no GitHub"
fi

success "Release v$VERSION_STRING criado e arquivos DMG enviados com sucesso!"

# STEP 7: Gerar appcast usando o comando do Sparkle
log "📡 Gerando appcast.xml com Sparkle..."

# Fazer backup do appcast atual
if [ -f "appcast.xml" ]; then
    cp appcast.xml appcast.xml.backup
fi

# Definir parâmetros do canal baseado no tipo de release
if [ "$IS_PRODUCTION" = "true" ]; then
    CHANNEL_PARAM=""
    DOWNLOAD_URL_PREFIX="https://github.com/$REPO_OWNER/$APP_REPO/releases/download/v$VERSION_STRING/"
    log "Gerando appcast para canal padrão (produção)"
else
    CHANNEL_PARAM="--channel beta"
    DOWNLOAD_URL_PREFIX="https://github.com/$REPO_OWNER/$APP_REPO/releases/download/v$VERSION_STRING/"
    log "Gerando appcast para canal beta"
fi

# Criar diretório temporário para o appcast
log "Preparando arquivos para o appcast..."
APPCAST_TMP_DIR="./dist/appcast_tmp"
mkdir -p "$APPCAST_TMP_DIR"

# Copiar apenas o DMG para o diretório temporário
cp "./dist/Granulay-$VERSION.dmg" "$APPCAST_TMP_DIR/"

# Gerar novo appcast com ou sem canal beta usando apenas o DMG
./bin/generate_appcast $CHANNEL_PARAM --download-url-prefix "$DOWNLOAD_URL_PREFIX" "$APPCAST_TMP_DIR/"

# Verificar se o appcast foi gerado
if [ ! -f "$APPCAST_TMP_DIR/appcast.xml" ]; then
    error "Falha ao gerar appcast.xml"
fi

# Mover o appcast para o diretório dist
cp "$APPCAST_TMP_DIR/appcast.xml" "./dist/"

success "appcast.xml gerado automaticamente pelo Sparkle"

# STEP 8: Commit das mudanças no repositório principal
log "💾 Commitando mudanças no repositório principal..."
git add Granulay/Info.plist ./dist/appcast.xml -f
git commit -m "Release v$VERSION_STRING" || true
success "Mudanças commitadas"

# STEP 9: Deploy do appcast.xml para GitHub Pages
log "🌐 Fazendo deploy para GitHub Pages..."

# Criar diretório temporário para o repositório releases
TEMP_RELEASES_DIR="/tmp/granulay-releases-$$"
rm -rf "$TEMP_RELEASES_DIR"

# Clonar ou atualizar o repositório releases
if [ -d "../$RELEASES_REPO" ]; then
    log "Usando repositório existente em ../$RELEASES_REPO"
    cd "../$RELEASES_REPO"
    git pull origin main
    cd -
    RELEASES_DIR="../$RELEASES_REPO"
else
    log "Clonando repositório $RELEASES_REPO..."
    git clone "$RELEASES_REPO_URL" "$TEMP_RELEASES_DIR"
    RELEASES_DIR="$TEMP_RELEASES_DIR"
fi

# Copiar appcast.xml para o repositório releases
log "📋 Copiando appcast.xml para o repositório releases..."
cp ./dist/appcast.xml "$RELEASES_DIR/"

# Fazer commit e push do appcast
cd "$RELEASES_DIR"
git add appcast.xml

if git diff --staged --quiet; then
    warning "Nenhuma mudança detectada no appcast.xml"
else
    git commit -m "Atualizar appcast para v$VERSION_STRING"
    git push origin main
    success "appcast.xml publicado no GitHub Pages"
fi

cd - > /dev/null

# Limpar diretório temporário se foi criado
if [ -d "$TEMP_RELEASES_DIR" ]; then
    rm -rf "$TEMP_RELEASES_DIR"
fi

# STEP 11: Limpeza
log "🧹 Limpando arquivos temporários..."
rm -rf build/DerivedData
rm -rf "$APPCAST_TMP_DIR"
success "Limpeza completa"

echo "
🎉 =====================================
   RELEASE $VERSION_STRING COMPLETO!
=====================================

📁 Arquivos gerados:
   - dist/Granulay-$VERSION.dmg (instalador com atalho para Applications)
   - dist/Granulay-$VERSION.html (release notes)
   - appcast.xml (gerado e publicado automaticamente)
   - appcast.xml.backup (backup)

🔗 Links importantes:
   - Release: https://github.com/$REPO_OWNER/$APP_REPO/releases/tag/v$VERSION_STRING
   - Appcast: https://gpaiva00.github.io/granulay-releases/appcast.xml

🧪 Para testar:
   - Aguarde 1-2 minutos para o GitHub Pages atualizar
   - Execute o Granulay atual
   - Menu → Verificar Atualizações
   - Deve mostrar a nova versão

✅ Release publicado com sucesso!
"