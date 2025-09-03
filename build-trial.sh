#!/bin/bash

# Script para compilar a versão trial do Granulay
# Este script compila o projeto usando a configuração 'Trial Debug'

echo "🔨 Compilando versão trial do Granulay..."

# Limpar build anterior
echo "🧹 Limpando builds anteriores..."
rm -rf build/

# Compilar com configuração Trial Debug
echo "⚙️ Compilando com configuração Trial Debug..."
xcodebuild -project Granulay.xcodeproj -target Granulay -configuration "Trial Debug" build

if [ $? -eq 0 ]; then
    echo "✅ Compilação da versão trial concluída com sucesso!"
    echo "📱 App disponível em: build/Trial Debug/Granulay.app"
    echo "🚀 Para executar: open 'build/Trial Debug/Granulay.app'"
else
    echo "❌ Erro na compilação da versão trial"
    exit 1
fi