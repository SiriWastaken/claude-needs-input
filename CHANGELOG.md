# Changelog

Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Versioning: [SemVer](https://semver.org/).

## [Unreleased]

### Changed
- README redesign with banner, badges and demo; deep docs moved to `docs/`.

### Added
- SECURITY.md, issue and PR templates, `.editorconfig`.

## [1.0.0] - 2026-10-13

### Added
- Desktop notifications for iTerm2, WezTerm, Windows Terminal (OSC 9) and Kitty (OSC 99), auto-detected.
- `CNI_NOTIFY_STYLE` to force the notification escape.
- README terminal support table, troubleshooting and uninstall sections.

### Fixed
- Works with macOS's default bash 3.2.
- CI shellcheck warnings in the test script.

## [0.1.0] - 2026-10-13

### Added
- Notification hook flags the terminal title, rings the bell and sends an OSC 777 notification when Claude needs input.
- Title is cleared on prompt submit / tool completion and set to `✔` on stop.
- `CNI_BELL`, `CNI_NOTIFY`, `CNI_TITLE_PREFIX` settings.
