# Granulay

Vintage grain effect for macOS - Um aplicativo que adiciona efeito de grão vintage para toda a tela.

## Recursos

- 🎨 **Efeito de grão vintage** para toda a tela
- ⚙️ **Configurações personalizáveis** para intensidade e estilo  
- 🖥️ **Suporte a múltiplos monitores** com configurações individuais
- 🔧 **Integração com barra de menu** para acesso rápido
- 💡 **Opção de preservação de brilho**
- 🎯 **4 estilos de grão:** Fino, Médio, Grosso, Vintage
- 🔄 **Sistema de atualizações automáticas** via Sparkle

## Distribuição

O projeto agora usa DMG para distribuição, seguindo as melhores práticas recomendadas pelo Sparkle:

- ✅ **DMG com link simbólico /Applications** - encoraja os usuários a copiarem o app para fora do DMG
- ✅ **Atualizações automáticas** via Sparkle
- ✅ **Assinatura digital** para segurança
- ✅ **Suporte a canais beta e produção**

## Scripts de Release

### Release Principal
```bash
./release.sh 1.0.X          # Release beta
./release.sh 1.0.X --production  # Release de produção
```

### Teste do DMG
```bash
./test_dmg.sh [arquivo.dmg]  # Verifica se o DMG está correto
```

### Build de Release
```bash
./build_release.sh [versão]  # Build manual com DMG
```

O script `release.sh` agora:
1. Cria DMG em vez de ZIP
2. Adiciona link simbólico para `/Applications`
3. Valida se o DMG foi criado corretamente
4. Atualiza automaticamente o appcast.xml
5. Faz deploy para GitHub Pages

## Requisitos do Sistema

- macOS 13.0 (Ventura) ou superior
- Apple Silicon ou Intel Mac
- 4GB RAM mínimo

## Desenvolvimento

Para contribuir com o projeto, certifique-se de que:
1. As chaves do Sparkle estão configuradas (`./generate_keys`)
2. O SSH está configurado para GitHub
3. Você tem acesso aos repositórios necessários

Execute `./test_release.sh` para verificar todos os pré-requisitos antes de fazer um release.

## Licença

[Incluir informações de licença aqui]
