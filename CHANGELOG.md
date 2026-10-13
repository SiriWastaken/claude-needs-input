# Changelog

Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Versioning: [SemVer](https://semver.org/).

## [Unreleased]

## [0.1.0] - 2026-10-13

### Added
- Notification hook flags the terminal title, rings the bell and sends an OSC 777 notification when Claude needs input.
- Title is cleared on prompt submit / tool completion and set to `✔` on stop.
- `CNI_BELL`, `CNI_NOTIFY`, `CNI_TITLE_PREFIX` settings.
