> 🇧🇷 [Leia em Português](README.pt-BR.md)

# macOS Cache Cleaner

![Version](https://img.shields.io/badge/version-1.0.2-blue)

Shell script to clean macOS caches, browser data, OneDrive temp files, and Microsoft Teams cache. Designed to run via the macOS **Shortcuts** app.

## Safe by design

This script **only touches files inside your user Library** (`~/Library`). It does not modify, delete, or access any system files, protected directories, or files belonging to other users. No `sudo` or administrator privileges are used at any point.

All cleaned data consists of **temporary files and caches** that macOS and applications regenerate automatically. Removing them does not break any application or affect system stability — apps simply rebuild their caches on next launch.

## Features

- Detects system language (Portuguese or English) and adapts all messages
- Estimates space to be freed before each cleanup step
- Captures running apps and reopens them all at the end
- Native macOS dialog boxes for each option
- No sudo required — fully compatible with the Shortcuts app

## What gets cleaned

| Category | Path | Details |
|----------|------|---------|
| General cache | `~/Library/Caches` | User app caches (Mail can be excluded) |
| Logs | `~/Library/Logs` | User log files |
| Safari | `~/Library/Caches/com.apple.Safari` | Browser cache |
| Chrome | `~/Library/Caches/Google/Chrome` | Browser cache |
| Firefox | `~/Library/Caches/Firefox` | Browser cache |
| Arc | `~/Library/Caches/company.thebrowser.Browser` | Browser + App Support caches |
| Dia | `~/Library/Caches/company.thebrowser.Dia` | Browser + App Support caches |
| Microsoft Edge | `~/Library/Caches/com.microsoft.edgemac` | Browser + App Support caches |
| Xcode | `~/Library/Developer/Xcode/DerivedData` | Build artifacts |
| npm | `~/.npm/_cacache` | Package cache |
| pip | `~/Library/Caches/pip` | Package cache |
| Homebrew | `~/Library/Caches/Homebrew` | Package cache |
| OneDrive | `~/Library/Containers/com.microsoft.OneDrive-mac/.../tmp` | `.temp` files only |
| Teams | `~/Library/Containers/com.microsoft.teams2/.../WV2Profile_tfw` | CacheStorage + WebStorage |
| DNS | — | Flush via `dscacheutil` |

> **Nothing outside `~/Library` and `~/.npm` is ever touched.**

## Quick install

[![Add to Shortcuts](https://img.shields.io/badge/Add_to_Shortcuts-blue?logo=apple&logoColor=white&style=for-the-badge)](https://www.icloud.com/shortcuts/fa7988e43e2f46ebabb1334939bf2d66)

Click the button above to install the shortcut directly on your Mac.

## Manual install

If you prefer to set it up manually:

1. Open the **Shortcuts** app on macOS
2. Create a new shortcut
3. Add the **"Run Shell Script"** action
4. Paste the contents of `limpar_cache_atalhos.sh`
5. Configure:
   - **Shell:** `/bin/bash`
   - **Input:** `Nothing`
6. Save the shortcut with any name you like (e.g. "Clean Cache")

## Requirements

- macOS 12 (Monterey) or later
- Shortcuts app

## Credits

> Conceived by a human. Coded by a machine.
> Built with a lot of curiosity and zero programming skills — and an AI that never complained about the 47th revision.
>
> Powered by [Dia](https://dia.browser), the browser with a built-in AI.

## License

[MIT](LICENSE)
