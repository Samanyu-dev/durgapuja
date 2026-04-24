# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added
- AI-powered Durga idol design generation via Krea AI
- Voice-to-text finance ledger with Bengali speech recognition
- Firebase Phone Auth with OTP verification
- Bilingual UI support (English + Bengali)
- Order management with client directory and WhatsApp integration
- Material tracking and expense analytics dashboard

### Changed
- Improved README with full documentation
- Fixed `analysis_options.yaml` to enforce proper lints (`avoid_print`, `use_build_context_synchronously`)
- Updated Android app label to "Durga Idol Maker"
- Replaced broken counter-app widget test with actual app smoke tests
- Moved development test scripts from project root to `scripts/`
- Added `.env.example` for easier onboarding

### Fixed
- Auth bypass in router now uses a configurable `demoMode` flag (default: `false`)
- Removed debug `print()` statements from `router.dart`
- Added warning comments for hardcoded mock users in `auth_service.dart`

## [1.0.0+1] - 2025-XX-XX

### Added
- Initial release with core modules: Design, Finance, Orders, Reports
- go_router navigation with ShellRoute for module-level layouts
- Provider state management
- sqflite local database with Firebase sync
