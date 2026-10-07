# Changelog

All notable changes to this project will be documented in this file.

## [2.1.0] - 2026-10-07

### Added
- Support for Debian 14+ releases with auto-detection
- Enhanced error handling for modern package managers
- Additional security hardening in SSH configuration
- Updated compatibility matrix for 2026

### Improved
- Documentation updated for October 2026 compatibility
- Script robustness enhancements for newer Debian releases
- Better detection of VNC server status
- Improved locale handling for edge cases

### Fixed
- Corrected package version references for 2026 Debian repositories
- Enhanced compatibility checks for newer Android Terminal versions
- Improved error messages for better troubleshooting

## [2.0.0] - 2026-06-10

### Added
- Full bilingual (Chinese/English) support throughout UI
- sshd_config.d drop-in configuration system (replacing direct sed edits)
- Display button awareness for Android 16 QPR2 / Android 17
- Automatic OS detection (bookworm vs trixie)
- smart configuration step skipping

### Changed
- Moved SSH configuration to `/etc/ssh/sshd_config.d/` for cleaner management
- Improved system preparation with robust locale detection
- Enhanced VNC configuration handling

### Security
- Updated SSH hardening practices
- Better password authentication prompts

## [1.0.0] - Initial Release

### Features
- Basic Debian 12 support
- One-click GUI setup via VNC
- SSH server configuration
- Desktop environment installation via tasksel
- Windows PowerShell automation helper

---

## Version Format

This project follows [Semantic Versioning](https://semver.org/). Version numbers are formatted as `MAJOR.MINOR.PATCH`.
