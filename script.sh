#!/bin/bash

# =============================================================
# macOS Cache Cleaner
# Version: 1.0
# https://github.com/rogercrocha/macos-cache-cleaner
#
# Como usar no Atalhos / How to use in Shortcuts:
#   1. Abra o app Atalhos / Open the Shortcuts app
#   2. Crie um novo atalho / Create a new shortcut
#   3. Adicione "Executar Script Shell" / Add "Run Shell Script"
#   4. Cole este script / Paste this script
#   5. Shell: /bin/bash | Input: Nothing
# =============================================================

REPORT=""
CLEANED=0
SKIPPED=0

# ============================================================
# DETECT SYSTEM LANGUAGE
# ============================================================

SYS_LANG=$(defaults read -g AppleLanguages 2>/dev/null | sed -n 's/.*"\(.*\)".*/\1/p' | head -1)

if echo "$SYS_LANG" | grep -qi "^pt"; then
    LANG_PT=true
else
    LANG_PT=false
fi

# Localized strings
if [ "$LANG_PT" = true ]; then
    BTN_YES="Sim"
    BTN_NO="Não"
    DLG_TITLE="Limpeza de Cache"
    DLG_NOTICE="Este Atalho funciona silenciosamente. Você verá pouca ou nenhuma atividade na sua tela, mas o script estará rodando. Note o indicador de atividade do atalho na barra de menus. Você será notificado a cada novo passo e receberá um relatório ao final do processo."
    DLG_QUIT="Encerrar todos os aplicativos abertos antes da limpeza?"
    DLG_MAIL="Limpar também o cache do Mail?"
    DLG_ONEDRIVE="Limpar arquivos temporários do OneDrive?"
    DLG_TEAMS="Limpar cache do Microsoft Teams?"
    LBL_ESTIMATE="Estimativa total de limpeza"
    LBL_SPACE="Espaço estimado"
    LBL_FILES_FOUND="arquivos .temp encontrados"
    RPT_TITLE="LIMPEZA DE CACHE DO MACOS"
    RPT_DATE="Data"
    RPT_GENERAL="CACHE GERAL"
    RPT_USER_CACHE="Cache do usuário"
    RPT_MAIL_INCL="Mail incluído"
    RPT_MAIL_PRES="Mail preservado"
    RPT_LOGS="Logs do usuário"
    RPT_DNS="Cache DNS — limpo"
    RPT_BROWSERS="NAVEGADORES"
    RPT_DEVTOOLS="FERRAMENTAS DE DESENVOLVIMENTO"
    RPT_FREED="liberados"
    RPT_CLEANED="limpo"
    RPT_NOT_FOUND="não encontrado"
    RPT_ONEDRIVE_FILES="arquivos .temp removidos"
    RPT_ONEDRIVE_NONE="nenhum arquivo .temp encontrado"
    RPT_ONEDRIVE_NO_DIR="pasta tmp não encontrada"
    RPT_TEAMS_NOT_FOUND="pastas de cache não encontradas"
    RPT_SUMMARY="RESUMO"
    RPT_CLEANED_COUNT="Limpos"
    RPT_SKIPPED_COUNT="Ignorados"
    RPT_RESTART="Reinicie o Mac para concluir a limpeza."
else
    BTN_YES="Yes"
    BTN_NO="No"
    DLG_TITLE="Cache Cleaner"
    DLG_NOTICE="This Shortcut runs silently. You will see little or no activity on your screen, but the script will be running. Look for the shortcut activity indicator in the menu bar. You will be notified at each new step and will receive a report at the end of the process."
    DLG_QUIT="Quit all open apps before cleaning?"
    DLG_MAIL="Also clean Mail cache?"
    DLG_ONEDRIVE="Also clean OneDrive .temp files?"
    DLG_TEAMS="Also clean Microsoft Teams cache?"
    LBL_ESTIMATE="Estimated total cleanup"
    LBL_SPACE="Estimated space"
    LBL_FILES_FOUND=".temp files found"
    RPT_TITLE="MACOS CACHE CLEANER"
    RPT_DATE="Date"
    RPT_GENERAL="GENERAL CACHE"
    RPT_USER_CACHE="User cache"
    RPT_MAIL_INCL="Mail included"
    RPT_MAIL_PRES="Mail preserved"
    RPT_LOGS="User logs"
    RPT_DNS="DNS cache — flushed"
    RPT_BROWSERS="BROWSERS"
    RPT_DEVTOOLS="DEV TOOLS"
    RPT_FREED="freed"
    RPT_CLEANED="cleaned"
    RPT_NOT_FOUND="not found"
    RPT_ONEDRIVE_FILES=".temp files removed"
    RPT_ONEDRIVE_NONE="no .temp files found"
    RPT_ONEDRIVE_NO_DIR="tmp folder not found"
    RPT_TEAMS_NOT_FOUND="cache folders not found"
    RPT_SUMMARY="SUMMARY"
    RPT_CLEANED_COUNT="Cleaned"
    RPT_SKIPPED_COUNT="Skipped"
    RPT_RESTART="Restart your Mac to complete the cleanup."
fi

# ============================================================
# HELPER FUNCTIONS
# ============================================================

log_entry() {
    REPORT="$REPORT
$1"
}

get_size() {
    du -sh "$1" 2>/dev/null | awk '{print $1}' || echo "0B"
}

format_size_kb() {
    local kb="$1"
    if [ "$kb" -ge 1048576 ]; then
        awk "BEGIN {printf \"%.1f GB\", $kb/1048576}"
    elif [ "$kb" -ge 1024 ]; then
        awk "BEGIN {printf \"%.1f MB\", $kb/1024}"
    else
        echo "${kb} KB"
    fi
}

clean_directory() {
    local name="$1"
    local path="$2"
    if [ -d "$path" ]; then
        local size
        size=$(get_size "$path")
        rm -rf "$path" 2>/dev/null || true
        log_entry "OK $name — $size $RPT_FREED"
        CLEANED=$((CLEANED + 1))
    else
        log_entry "SKIP $name — $RPT_NOT_FOUND"
        SKIPPED=$((SKIPPED + 1))
    fi
}

clean_contents() {
    local name="$1"
    local path="$2"
    if [ -d "$path" ]; then
        local size
        size=$(get_size "$path")
        find "$path" -mindepth 1 -exec rm -rf {} + 2>/dev/null || true
        log_entry "OK $name — $size $RPT_FREED"
        CLEANED=$((CLEANED + 1))
    else
        log_entry "SKIP $name — $RPT_NOT_FOUND"
        SKIPPED=$((SKIPPED + 1))
    fi
}

clean_browser_cache() {
    local name="$1"
    local cache_path="$2"
    local app_support_path="$3"
    local found=false

    if [ -d "$cache_path" ]; then
        local size
        size=$(get_size "$cache_path")
        rm -rf "$cache_path" 2>/dev/null || true
        log_entry "OK $name (Caches) — $size $RPT_FREED"
        found=true
    fi

    if [ -d "$app_support_path" ]; then
        find "$app_support_path" -type d -name "Cache" -exec rm -rf {} + 2>/dev/null || true
        find "$app_support_path" -type d -name "Code Cache" -exec rm -rf {} + 2>/dev/null || true
        find "$app_support_path" -type d -name "GPUCache" -exec rm -rf {} + 2>/dev/null || true
        find "$app_support_path" -type d -name "CacheStorage" -exec rm -rf {} + 2>/dev/null || true
        log_entry "OK $name (App Support) — $RPT_CLEANED"
        found=true
    fi

    if [ "$found" = false ]; then
        log_entry "SKIP $name — $RPT_NOT_FOUND"
        SKIPPED=$((SKIPPED + 1))
    else
        CLEANED=$((CLEANED + 1))
    fi
}

# ============================================================
# CAPTURE RUNNING APPS
# ============================================================

RUNNING_APPS=$(osascript -e '
    tell application "System Events"
        set appList to name of every application process whose background only is false
    end tell
    set AppleScript'\''s text item delimiters to linefeed
    return appList as text
' 2>/dev/null || echo "")

# ============================================================
# ESTIMATE SIZES
# ============================================================

GENERAL_CACHE_KB=0
if [ -d "$HOME/Library/Caches" ]; then
    FULL_KB=$(du -sk "$HOME/Library/Caches" 2>/dev/null | awk '{print $1}')
    M_KB=0; [ -d "$HOME/Library/Caches/com.apple.mail" ] && M_KB=$(du -sk "$HOME/Library/Caches/com.apple.mail" 2>/dev/null | awk '{print $1}')
    MB_KB=0; [ -d "$HOME/Library/Caches/com.apple.mbuseragent" ] && MB_KB=$(du -sk "$HOME/Library/Caches/com.apple.mbuseragent" 2>/dev/null | awk '{print $1}')
    GENERAL_CACHE_KB=$((FULL_KB - M_KB - MB_KB))
fi

LOGS_KB=0; [ -d "$HOME/Library/Logs" ] && LOGS_KB=$(du -sk "$HOME/Library/Logs" 2>/dev/null | awk '{print $1}')
SAFARI_KB=0; [ -d "$HOME/Library/Caches/com.apple.Safari" ] && SAFARI_KB=$(du -sk "$HOME/Library/Caches/com.apple.Safari" 2>/dev/null | awk '{print $1}')
CHROME_KB=0; [ -d "$HOME/Library/Caches/Google/Chrome" ] && CHROME_KB=$(du -sk "$HOME/Library/Caches/Google/Chrome" 2>/dev/null | awk '{print $1}')
FIREFOX_KB=0; [ -d "$HOME/Library/Caches/Firefox" ] && FIREFOX_KB=$(du -sk "$HOME/Library/Caches/Firefox" 2>/dev/null | awk '{print $1}')
ARC_KB=0; [ -d "$HOME/Library/Caches/company.thebrowser.Browser" ] && ARC_KB=$(du -sk "$HOME/Library/Caches/company.thebrowser.Browser" 2>/dev/null | awk '{print $1}')
DIA_KB=0; [ -d "$HOME/Library/Caches/company.thebrowser.Dia" ] && DIA_KB=$(du -sk "$HOME/Library/Caches/company.thebrowser.Dia" 2>/dev/null | awk '{print $1}')
EDGE_KB=0; [ -d "$HOME/Library/Caches/com.microsoft.edgemac" ] && EDGE_KB=$(du -sk "$HOME/Library/Caches/com.microsoft.edgemac" 2>/dev/null | awk '{print $1}')
XCODE_KB=0; [ -d "$HOME/Library/Developer/Xcode/DerivedData" ] && XCODE_KB=$(du -sk "$HOME/Library/Developer/Xcode/DerivedData" 2>/dev/null | awk '{print $1}')
NPM_KB=0; [ -d "$HOME/.npm/_cacache" ] && NPM_KB=$(du -sk "$HOME/.npm/_cacache" 2>/dev/null | awk '{print $1}')
PIP_KB=0; [ -d "$HOME/Library/Caches/pip" ] && PIP_KB=$(du -sk "$HOME/Library/Caches/pip" 2>/dev/null | awk '{print $1}')
BREW_KB=0; [ -d "$HOME/Library/Caches/Homebrew" ] && BREW_KB=$(du -sk "$HOME/Library/Caches/Homebrew" 2>/dev/null | awk '{print $1}')

TOTAL_BASE_KB=$((GENERAL_CACHE_KB + LOGS_KB + SAFARI_KB + CHROME_KB + FIREFOX_KB + ARC_KB + DIA_KB + EDGE_KB + XCODE_KB + NPM_KB + PIP_KB + BREW_KB))
TOTAL_BASE_HR=$(format_size_kb $TOTAL_BASE_KB)

# Mail
MAIL_CACHE_KB=0
[ -d "$HOME/Library/Caches/com.apple.mail" ] && MAIL_CACHE_KB=$(du -sk "$HOME/Library/Caches/com.apple.mail" 2>/dev/null | awk '{print $1}')
[ -d "$HOME/Library/Caches/com.apple.mbuseragent" ] && MAIL_CACHE_KB=$((MAIL_CACHE_KB + $(du -sk "$HOME/Library/Caches/com.apple.mbuseragent" 2>/dev/null | awk '{print $1}')))
MAIL_CACHE_HR=$(format_size_kb $MAIL_CACHE_KB)

# OneDrive
ONEDRIVE_TMP="$HOME/Library/Containers/com.microsoft.OneDrive-mac/Data/Library/Application Support/OneDrive/tmp"
ONEDRIVE_TEMP_KB=0
ONEDRIVE_TEMP_COUNT=0
if [ -d "$ONEDRIVE_TMP" ]; then
    ONEDRIVE_TEMP_KB=$(find "$ONEDRIVE_TMP" -type f -name "*.temp" -exec du -sk {} + 2>/dev/null | awk '{s+=$1} END {printf "%d", s+0}')
    ONEDRIVE_TEMP_COUNT=$(find "$ONEDRIVE_TMP" -type f -name "*.temp" 2>/dev/null | wc -l | tr -d ' ')
fi
ONEDRIVE_TEMP_HR=$(format_size_kb $ONEDRIVE_TEMP_KB)

# Teams
TEAMS_BASE="$HOME/Library/Containers/com.microsoft.teams2/Data/Library/Application Support/Microsoft/MSTeams/EBWebView/WV2Profile_tfw"
TEAMS_CACHE_STORAGE="${TEAMS_BASE}/Service Worker/CacheStorage"
TEAMS_WEBSTORAGE="${TEAMS_BASE}/WebStorage"
TEAMS_CACHE_KB=0; [ -d "$TEAMS_CACHE_STORAGE" ] && TEAMS_CACHE_KB=$(du -sk "$TEAMS_CACHE_STORAGE" 2>/dev/null | awk '{print $1}')
TEAMS_WEB_KB=0; [ -d "$TEAMS_WEBSTORAGE" ] && TEAMS_WEB_KB=$(du -sk "$TEAMS_WEBSTORAGE" 2>/dev/null | awk '{print $1}')
TEAMS_TOTAL_KB=$((TEAMS_CACHE_KB + TEAMS_WEB_KB))
TEAMS_TOTAL_HR=$(format_size_kb $TEAMS_TOTAL_KB)

# ============================================================
# DIALOG BOXES
# ============================================================

# Dialog 1: Quit apps (with notice about silent operation)
QUIT_APPS=$(osascript -e 'display dialog "'"$DLG_NOTICE"'\n\n'"$DLG_QUIT"'\n\n'"$LBL_ESTIMATE"': '"$TOTAL_BASE_HR"'" buttons {"'"$BTN_NO"'", "'"$BTN_YES"'"} default button "'"$BTN_NO"'" with title "'"$DLG_TITLE"'" with icon caution' -e 'button returned of result' 2>/dev/null || echo "$BTN_NO")

if [ "$QUIT_APPS" = "$BTN_YES" ]; then
    osascript -e '
        set keepOpen to {"Finder", "Shortcuts", "SystemUIServer", "Control Center", "Notification Center", "Dock", "Spotlight", "WindowManager", "Window Manager", "AirPlayUIAgent", "TextInputMenuAgent", "universalAccessAuthWarn", "CoreServicesUIAgent", "loginwindow", "Bartender 4", "iStat Menus", "Alfred", "Raycast", "1Password", "Logi Options", "Logi Options+", "Karabiner-Elements", "Magnet", "Rectangle", "BetterTouchTool"}
        tell application "System Events"
            set appList to name of every application process whose background only is false
        end tell
        repeat with appName in appList
            if appName is not in keepOpen then
                try
                    tell application (appName as text) to quit
                end try
            end if
        end repeat
    ' 2>/dev/null || true
    sleep 5
fi

# Dialog 2: Mail
CLEAN_MAIL=$(osascript -e 'display dialog "'"$DLG_MAIL"'\n\n'"$LBL_SPACE"': '"$MAIL_CACHE_HR"'" buttons {"'"$BTN_NO"'", "'"$BTN_YES"'"} default button "'"$BTN_NO"'" with title "'"$DLG_TITLE"'" with icon caution' -e 'button returned of result' 2>/dev/null || echo "$BTN_NO")

# Dialog 3: OneDrive
CLEAN_ONEDRIVE=$(osascript -e 'display dialog "'"$DLG_ONEDRIVE"'\n\n'"$ONEDRIVE_TEMP_COUNT"' '"$LBL_FILES_FOUND"' — '"$LBL_SPACE"': '"$ONEDRIVE_TEMP_HR"'" buttons {"'"$BTN_NO"'", "'"$BTN_YES"'"} default button "'"$BTN_NO"'" with title "'"$DLG_TITLE"'" with icon caution' -e 'button returned of result' 2>/dev/null || echo "$BTN_NO")

# Dialog 4: Teams
CLEAN_TEAMS=$(osascript -e 'display dialog "'"$DLG_TEAMS"'\n\n'"$LBL_SPACE"': '"$TEAMS_TOTAL_HR"'" buttons {"'"$BTN_NO"'", "'"$BTN_YES"'"} default button "'"$BTN_NO"'" with title "'"$DLG_TITLE"'" with icon caution' -e 'button returned of result' 2>/dev/null || echo "$BTN_NO")

# ============================================================
# START CLEANUP
# ============================================================

log_entry "$RPT_TITLE"
log_entry "$RPT_DATE: $(date '+%d/%m/%Y %H:%M')"
log_entry "————————————————————————"

# 1. User cache
log_entry ""
log_entry "$RPT_GENERAL"
if [ -d "$HOME/Library/Caches" ]; then
    size_before=$(get_size "$HOME/Library/Caches")
    if [ "$CLEAN_MAIL" = "$BTN_YES" ]; then
        find "$HOME/Library/Caches" -mindepth 1 -maxdepth 1 \
            -exec rm -rf {} + 2>/dev/null || true
        log_entry "OK $RPT_USER_CACHE — $size_before ($RPT_MAIL_INCL)"
    else
        find "$HOME/Library/Caches" -mindepth 1 -maxdepth 1 \
            ! -iname "com.apple.mail" \
            ! -iname "com.apple.mbuseragent" \
            -exec rm -rf {} + 2>/dev/null || true
        log_entry "OK $RPT_USER_CACHE — $size_before ($RPT_MAIL_PRES)"
    fi
    CLEANED=$((CLEANED + 1))
fi

# 2. Logs
clean_contents "$RPT_LOGS" "$HOME/Library/Logs"

# 3. DNS
log_entry ""
log_entry "DNS"
dscacheutil -flushcache 2>/dev/null || true
killall -HUP mDNSResponder 2>/dev/null || true
log_entry "OK $RPT_DNS"
CLEANED=$((CLEANED + 1))

# 4. Browsers
log_entry ""
log_entry "$RPT_BROWSERS"

clean_directory "Safari" "$HOME/Library/Caches/com.apple.Safari"
clean_directory "Chrome" "$HOME/Library/Caches/Google/Chrome"
clean_directory "Firefox" "$HOME/Library/Caches/Firefox"

clean_browser_cache "Arc" \
    "$HOME/Library/Caches/company.thebrowser.Browser" \
    "$HOME/Library/Application Support/Arc"

clean_browser_cache "Dia" \
    "$HOME/Library/Caches/company.thebrowser.Dia" \
    "$HOME/Library/Application Support/Dia"

clean_browser_cache "Microsoft Edge" \
    "$HOME/Library/Caches/com.microsoft.edgemac" \
    "$HOME/Library/Application Support/Microsoft Edge"

# 5. Dev tools
log_entry ""
log_entry "$RPT_DEVTOOLS"

clean_contents "Xcode DerivedData" "$HOME/Library/Developer/Xcode/DerivedData"
clean_directory "npm" "$HOME/.npm/_cacache"
clean_directory "pip" "$HOME/Library/Caches/pip"
clean_contents "Homebrew" "$HOME/Library/Caches/Homebrew"

# 6. OneDrive
if [ "$CLEAN_ONEDRIVE" = "$BTN_YES" ]; then
    log_entry ""
    log_entry "ONEDRIVE"

    if [ -d "$ONEDRIVE_TMP" ]; then
        osascript -e 'tell application "OneDrive" to quit' >/dev/null 2>&1 || true
        pkill -x OneDrive >/dev/null 2>&1 || true
        sleep 5

        SIZE_BEFORE_KB=$(du -sk "$ONEDRIVE_TMP" 2>/dev/null | awk '{print $1}')
        TEMP_COUNT=$(find "$ONEDRIVE_TMP" -type f -name "*.temp" 2>/dev/null | wc -l | tr -d ' ')

        if [ "$TEMP_COUNT" -gt 0 ]; then
            find "$ONEDRIVE_TMP" -type f -name "*.temp" -delete 2>/dev/null || true
            SIZE_AFTER_KB=$(du -sk "$ONEDRIVE_TMP" 2>/dev/null | awk '{print $1}')
            FREED_KB=$((SIZE_BEFORE_KB - SIZE_AFTER_KB))
            FREED_MB=$(awk "BEGIN {printf \"%.1f\", $FREED_KB/1024}")
            log_entry "OK OneDrive — $TEMP_COUNT $RPT_ONEDRIVE_FILES (${FREED_MB} MB $RPT_FREED)"
            CLEANED=$((CLEANED + 1))
        else
            log_entry "SKIP OneDrive — $RPT_ONEDRIVE_NONE"
            SKIPPED=$((SKIPPED + 1))
        fi
    else
        log_entry "SKIP OneDrive — $RPT_ONEDRIVE_NO_DIR"
        SKIPPED=$((SKIPPED + 1))
    fi
fi

# 7. Teams
if [ "$CLEAN_TEAMS" = "$BTN_YES" ]; then
    log_entry ""
    log_entry "MICROSOFT TEAMS"

    teams_found=false

    osascript -e 'tell application "Microsoft Teams" to quit' >/dev/null 2>&1 || true
    pkill -x "Microsoft Teams" >/dev/null 2>&1 || true
    sleep 3

    if [ -d "$TEAMS_CACHE_STORAGE" ]; then
        size=$(get_size "$TEAMS_CACHE_STORAGE")
        find "$TEAMS_CACHE_STORAGE" -mindepth 1 -exec rm -rf {} + 2>/dev/null || true
        log_entry "OK Teams CacheStorage — $size $RPT_FREED"
        teams_found=true
    fi

    if [ -d "$TEAMS_WEBSTORAGE" ]; then
        size=$(get_size "$TEAMS_WEBSTORAGE")
        find "$TEAMS_WEBSTORAGE" -mindepth 1 -exec rm -rf {} + 2>/dev/null || true
        log_entry "OK Teams WebStorage — $size $RPT_FREED"
        teams_found=true
    fi

    if [ "$teams_found" = true ]; then
        CLEANED=$((CLEANED + 1))
    else
        log_entry "SKIP Teams — $RPT_TEAMS_NOT_FOUND"
        SKIPPED=$((SKIPPED + 1))
    fi
fi

# ============================================================
# REPORT
# ============================================================

log_entry ""
log_entry "————————————————————————"
log_entry "$RPT_SUMMARY"
log_entry "   $RPT_CLEANED_COUNT: $CLEANED"
log_entry "   $RPT_SKIPPED_COUNT: $SKIPPED"
log_entry ""
log_entry "$RPT_RESTART"

echo "$REPORT"

# ============================================================
# REOPEN APPS
# ============================================================

if [ -n "$RUNNING_APPS" ]; then
    SKIP_REOPEN="Finder Shortcuts SystemUIServer Control Center Notification Center Dock Spotlight WindowManager Window Manager AirPlayUIAgent TextInputMenuAgent universalAccessAuthWarn CoreServicesUIAgent loginwindow"

    while IFS= read -r app; do
        [ -z "$app" ] && continue
        skip=false
        for s in $SKIP_REOPEN; do
            if [ "$app" = "$s" ]; then
                skip=true
                break
            fi
        done
        if [ "$skip" = false ]; then
            open -a "$app" 2>/dev/null || true
        fi
    done <<< "$RUNNING_APPS"
fi
