# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2026-01-28
### Fixed
- **CRITICAL**: Changed from Bot Token (xoxb-) to User Token (xoxp-)
- `search.messages` API requires User Token, not Bot Token
- User Token provides access to all user's channels, DMs, and private channels
- Bot Token only works with channels where bot is explicitly added

### Changed
- Updated all documentation from Bot User OAuth Token to User OAuth Token
- Changed token validation in setup.sh from xoxb- to xoxp-
- Changed token validation in verify.sh from xoxb- to xoxp-
- Updated OAuth scope instructions to use "User Token Scopes" section
- Revised Korean installation guide (설치가이드.md) with corrected token type
- Updated FAQ Q8 to reflect correct token type

## [1.1.0] - 2026-01-27
### Added
- Date search filters (on:, after:, before:)
- DM search support
- User filtering in search
- Distribution package with installer scripts
- Comprehensive documentation

### Changed
- Improved error messages in setup.sh
- Enhanced README with installation instructions

## [1.0.0] - 2026-01-12
### Added
- Initial release
- Channel list, message history, search functionality
- Interactive setup script
- Comprehensive SKILL.md documentation
