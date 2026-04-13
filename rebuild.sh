#!/bin/bash
echo "Parando instância atual..."
killall Granulay 2>/dev/null || echo "Nenhuma instância em execução"

echo "Compilando..."
xcodebuild -project Granulay.xcodeproj -scheme Granulay -configuration Release

if [ $? -eq 0 ]; then
    echo "Build sucesso! Abrindo app..."
    open Granulay.app
else
    echo "Build falhou!"
    exit 1
fi
