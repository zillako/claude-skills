# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-01-28

### BREAKING CHANGE: Plugin System Migration

Migrated from manual installation to Claude Code Plugin System.

#### Changed
- **Installation Method**
  - Old: `wget` + `tar` + `./install.sh`
  - New: `/plugin marketplace add https://github.com/zillako/claude-skills` then `/plugin install slack-search`
- **Setup Method**
  - Old: `./setup.sh` interactive script
  - New: `/slack-setup` slash command
- **Directory Structure**
  - Restructured to Plugin System layout under `plugins/slack-search/`
  - SKILL.md moved to `skills/slack-search/SKILL.md`
  - Added `.claude-plugin/plugin.json` and marketplace manifest

#### Removed
- `install.sh` - Plugin system handles installation automatically
- `verify.sh` - Plugin system handles verification automatically
- `uninstall.sh` - Plugin system handles removal automatically
- `setup.sh` - Replaced by `/slack-setup` slash command

#### Added
- `.claude-plugin/plugin.json` - Plugin manifest
- `.claude-plugin/marketplace.json` - Marketplace manifest (repo root)
- `commands/slack-setup.md` - Slash command for setup
- `.gitignore` - Ignore auto-generated files

#### Migration Guide
For users upgrading from v1.x:
1. Uninstall old version: `cd ~/.claude/skills/slack-search && ./uninstall.sh`
2. Add marketplace: `/plugin marketplace add https://github.com/zillako/claude-skills`
3. Install plugin: `/plugin install slack-search`
4. Run setup: `/slack-setup`

Your existing `~/.slack/config.json` will continue to work.

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
