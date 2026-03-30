# Changelog

## [1.0.2] — 2026-03-30

### Fixed
- Mail cache size estimate now uses case-insensitive matching (`find -iname`) to correctly detect `com.apple.Mail` regardless of capitalization
- OneDrive and Microsoft Teams now reopen after cleanup (menu bar apps are detected separately via `pgrep`)

### Added
- Report now opens automatically in TextEdit at the end of the cleanup (no extra Shortcuts action needed)
## [1.0] — 2026-03-29

### Added
- General cache cleanup (`~/Library/Caches`, `~/Library/Logs`)
- Browser cache cleanup: Safari, Chrome, Firefox, Arc, Dia, Microsoft Edge
- Dev tools cache cleanup: Xcode DerivedData, npm, pip, Homebrew
- DNS cache flush
- OneDrive `.temp` file cleanup
- Microsoft Teams cache cleanup (CacheStorage + WebStorage)
- Optional Mail cache cleanup via dialog
- Automatic system language detection (Portuguese / English)
- Space estimation displayed in each dialog box
- Capture and reopen all running apps after cleanup
- Native macOS dialog boxes for each step
- Silent operation notice in first dialog
