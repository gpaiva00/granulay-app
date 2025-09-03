#!/bin/bash

# Script para verificar configuração do projeto Granulay
# Uso: ./check-config.sh

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Verificando configuração do projeto Granulay${NC}"
echo "================================================"

# Verificar se estamos na pasta correta
if [ ! -f "Granulay.xcodeproj/project.pbxproj" ]; then
    echo -e "${RED}❌ Erro: Arquivo de projeto não encontrado${NC}"
    echo "Execute este script na pasta raiz do projeto"
    exit 1
fi

echo -e "${GREEN}✅ Projeto encontrado${NC}"

# Verificar certificados de assinatura
echo -e "\n${YELLOW}🔐 Verificando certificados de assinatura...${NC}"
echo "Certificados disponíveis:"
security find-identity -v -p codesigning

# Verificar se tem certificado de distribuição
if security find-identity -v -p codesigning | grep -q "Apple Distribution"; then
    echo -e "${GREEN}✅ Certificado Apple Distribution encontrado${NC}"
else
    echo -e "${RED}❌ Certificado Apple Distribution não encontrado${NC}"
    echo "   Você precisa instalar o certificado de distribuição"
fi

# Verificar se tem certificado de desenvolvimento
if security find-identity -v -p codesigning | grep -q "Apple Development"; then
    echo -e "${GREEN}✅ Certificado Apple Development encontrado${NC}"
else
    echo -e "${YELLOW}⚠️  Certificado Apple Development não encontrado${NC}"
fi

# Verificar configurações do Info.plist
echo -e "\n${YELLOW}📄 Verificando Info.plist...${NC}"
if [ -f "Granulay/Info.plist" ]; then
    echo -e "${GREEN}✅ Info.plist encontrado${NC}"
    
    # Verificar versão
    VERSION=$(plutil -extract CFBundleShortVersionString raw Granulay/Info.plist 2>/dev/null || echo "N/A")
    BUILD=$(plutil -extract CFBundleVersion raw Granulay/Info.plist 2>/dev/null || echo "N/A")
    BUNDLE_ID=$(plutil -extract CFBundleIdentifier raw Granulay/Info.plist 2>/dev/null || echo "N/A")
    
    echo "   Versão: $VERSION"
    echo "   Build: $BUILD"
    echo "   Bundle ID: $BUNDLE_ID"
    
    # Verificar se não é versão trial
    if [[ "$VERSION" == *"trial"* ]] || [[ "$VERSION" == *"beta"* ]] || [[ "$BUILD" == *"-"* ]]; then
        echo -e "${RED}❌ Versão parece ser trial/beta${NC}"
        echo "   Atualize para versão de produção (ex: 1.0.0)"
    else
        echo -e "${GREEN}✅ Versão parece estar correta para App Store${NC}"
    fi
else
    echo -e "${RED}❌ Info.plist não encontrado${NC}"
fi

# Verificar entitlements
echo -e "\n${YELLOW}🛡️  Verificando entitlements...${NC}"
if [ -f "Granulay/Granulay.entitlements" ]; then
    echo -e "${GREEN}✅ Arquivo de entitlements encontrado${NC}"
    
    # Verificar sandbox
    if plutil -p Granulay/Granulay.entitlements 2>/dev/null | grep -q '"com.apple.security.app-sandbox" => true'; then
        echo -e "${GREEN}✅ App Sandbox habilitado${NC}"
    else
        echo -e "${RED}❌ App Sandbox não habilitado${NC}"
    fi
    
    # Verificar permissões potencialmente problemáticas
    if plutil -extract "com.apple.security.cs.allow-jit" raw Granulay/Granulay.entitlements 2>/dev/null | grep -q "true"; then
        echo -e "${YELLOW}⚠️  JIT habilitado - pode precisar de justificativa${NC}"
    fi
    
    if plutil -extract "com.apple.security.cs.disable-library-validation" raw Granulay/Granulay.entitlements 2>/dev/null | grep -q "true"; then
        echo -e "${YELLOW}⚠️  Library validation desabilitada - pode precisar de justificativa${NC}"
    fi
else
    echo -e "${RED}❌ Arquivo de entitlements não encontrado${NC}"
fi

# Verificar configurações do projeto
echo -e "\n${YELLOW}⚙️  Verificando configurações do projeto...${NC}"

# Verificar team ID
if grep -q "DEVELOPMENT_TEAM = TB76NB7VWG" Granulay.xcodeproj/project.pbxproj; then
    echo -e "${GREEN}✅ Development Team configurado (TB76NB7VWG)${NC}"
else
    echo -e "${RED}❌ Development Team não configurado corretamente${NC}"
fi

# Verificar assinatura de código
if grep -q '"CODE_SIGN_IDENTITY\[sdk=macosx\*\]" = "Apple Distribution"' Granulay.xcodeproj/project.pbxproj; then
    echo -e "${GREEN}✅ Assinatura configurada para Apple Distribution${NC}"
else
    echo -e "${YELLOW}⚠️  Assinatura não configurada para Apple Distribution${NC}"
    echo "   Verifique se está usando Apple Distribution para Release"
fi

# Verificar bundle identifier
if grep -q "com.granulay.app" Granulay.xcodeproj/project.pbxproj; then
    echo -e "${GREEN}✅ Bundle identifier configurado (com.granulay.app)${NC}"
else
    echo -e "${RED}❌ Bundle identifier não encontrado${NC}"
fi

# Verificar arquivos necessários
echo -e "\n${YELLOW}📁 Verificando arquivos necessários...${NC}"

files_to_check=(
    "ExportOptions.plist"
    "build-appstore.sh"
    "APP_STORE_GUIDE.md"
)

for file in "${files_to_check[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✅ $file${NC}"
    else
        echo -e "${RED}❌ $file não encontrado${NC}"
    fi
done

# Verificar Xcode
echo -e "\n${YELLOW}🛠️  Verificando Xcode...${NC}"
if command -v xcodebuild &> /dev/null; then
    XCODE_VERSION=$(xcodebuild -version | head -n 1)
    echo -e "${GREEN}✅ $XCODE_VERSION${NC}"
else
    echo -e "${RED}❌ Xcode não encontrado${NC}"
fi

# Resumo
echo -e "\n${BLUE}📋 Resumo da Verificação${NC}"
echo "================================================"
echo -e "${GREEN}✅${NC} = Configurado corretamente"
echo -e "${YELLOW}⚠️${NC}  = Atenção necessária"
echo -e "${RED}❌${NC} = Problema que precisa ser corrigido"

echo -e "\n${BLUE}💡 Próximos passos:${NC}"
echo "1. Corrija os problemas marcados com ❌"
echo "2. Revise os itens marcados com ⚠️"
echo "3. Execute ./build-appstore.sh para criar o build"
echo "4. Consulte APP_STORE_GUIDE.md para instruções detalhadas"