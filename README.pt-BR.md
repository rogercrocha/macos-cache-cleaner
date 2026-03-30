> 🇺🇸 [Read in English](README.md)

# macOS Cache Cleaner

![Versão](https://img.shields.io/badge/versão-1.0.2-blue)

Script shell para limpar caches do macOS, dados de navegadores, arquivos temporários do OneDrive e cache do Microsoft Teams. Projetado para rodar pelo app **Atalhos (Shortcuts)** do macOS.

## Seguro por design

Este script **opera exclusivamente dentro da Biblioteca do usuário** (`~/Library`). Ele não modifica, apaga ou acessa arquivos do sistema, diretórios protegidos ou arquivos de outros usuários. Nenhum `sudo` ou privilégio de administrador é utilizado em momento algum.

Todos os dados removidos são **arquivos temporários e caches** que o macOS e os aplicativos regeneram automaticamente. A remoção não quebra nenhum aplicativo nem afeta a estabilidade do sistema — os apps simplesmente reconstroem seus caches na próxima abertura.

## Recursos

- Detecta o idioma do sistema (Português ou Inglês) e adapta todas as mensagens
- Estima o espaço a ser liberado antes de cada etapa de limpeza
- Captura os apps abertos e reabre todos ao final
- Caixas de diálogo nativas do macOS para cada opção
- Não requer sudo — totalmente compatível com o app Atalhos

## O que é limpo

| Categoria | Caminho | Detalhes |
|-----------|---------|----------|
| Cache geral | `~/Library/Caches` | Caches de apps do usuário (Mail pode ser excluído) |
| Logs | `~/Library/Logs` | Arquivos de log do usuário |
| Safari | `~/Library/Caches/com.apple.Safari` | Cache do navegador |
| Chrome | `~/Library/Caches/Google/Chrome` | Cache do navegador |
| Firefox | `~/Library/Caches/Firefox` | Cache do navegador |
| Arc | `~/Library/Caches/company.thebrowser.Browser` | Cache do navegador + App Support |
| Dia | `~/Library/Caches/company.thebrowser.Dia` | Cache do navegador + App Support |
| Microsoft Edge | `~/Library/Caches/com.microsoft.edgemac` | Cache do navegador + App Support |
| Xcode | `~/Library/Developer/Xcode/DerivedData` | Artefatos de compilação |
| npm | `~/.npm/_cacache` | Cache de pacotes |
| pip | `~/Library/Caches/pip` | Cache de pacotes |
| Homebrew | `~/Library/Caches/Homebrew` | Cache de pacotes |
| OneDrive | `~/Library/Containers/com.microsoft.OneDrive-mac/.../tmp` | Apenas arquivos `.temp` |
| Teams | `~/Library/Containers/com.microsoft.teams2/.../WV2Profile_tfw` | CacheStorage + WebStorage |
| DNS | — | Flush via `dscacheutil` |

> **Nenhum arquivo fora de `~/Library` e `~/.npm` é tocado.**

## Instalação rápida

[![Adicionar aos Atalhos](https://img.shields.io/badge/Adicionar_aos_Atalhos-blue?logo=apple&logoColor=white&style=for-the-badge)](https://www.icloud.com/shortcuts/fa7988e43e2f46ebabb1334939bf2d66)

Clique no botão acima para instalar o atalho diretamente no seu Mac.

## Instalação manual

Se preferir configurar manualmente:

1. Abra o app **Atalhos** no macOS
2. Crie um novo atalho
3. Adicione a ação **"Executar Script Shell"**
4. Cole o conteúdo do arquivo `limpar_cache_atalhos.sh`
5. Configure:
   - **Shell:** `/bin/bash`
   - **Entrada:** `Nenhuma`
6. Salve o atalho com o nome que preferir (ex: "Limpar Cache")


## Requisitos

- macOS 12 (Monterey) ou superior
- App Atalhos (Shortcuts)

## Créditos

> Idealizado por um humano. Codificado por uma máquina.
> Feito com muita curiosidade e zero habilidade em programação — e uma IA que nunca reclamou da 47ª revisão.
>
> Desenvolvido com o [Dia](https://dia.browser), o navegador com IA integrada.

## Licença

[MIT](LICENSE)
