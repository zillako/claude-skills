# Claude Code Skills Marketplace

A collection of reusable Claude Code skills and plugins by zillako.

## 📦 Installation

### Using Claude Code Plugin System

```bash
/plugin marketplace add https://github.com/zillako/claude-skills
```

This will add the claude-skills marketplace to your Claude Code and make all plugins available for installation.

### Install Individual Plugins

Once the marketplace is added, install plugins like this:

```bash
/plugin install slack-search
```

## Available Plugins

### 🔍 slack-search v2.0.0

Search and analyze Slack workspace messages directly from Claude Code.

**Features:**
- Channel list and message search
- Keyword and date filtering
- User-specific searches
- DM and thread viewing
- User OAuth Token support for full workspace access

**Setup:**
After installation, configure your Slack credentials:
```bash
/slack-setup
```

📖 **Documentation:**
- [Korean Installation Guide](./plugins/slack-search/설치가이드.md)
- [English Documentation](./plugins/slack-search/README.md)
- [Changelog](./plugins/slack-search/CHANGELOG.md)

---

## 🔧 Plugin Structure

Each plugin follows the Claude Code Plugin System specification:

```
plugins/
└── plugin-name/
    ├── .claude-plugin/
    │   └── plugin.json      # Plugin metadata
    ├── skills/
    │   └── skill-name/
    │       └── SKILL.md     # Skill specification
    ├── commands/
    │   └── command-name.md  # Slash commands
    ├── README.md            # Plugin documentation
    ├── CHANGELOG.md         # Version history
    └── LICENSE              # License information
```

## 🚀 For Plugin Developers

### Creating a New Plugin

1. Create plugin directory under `plugins/`
2. Add `.claude-plugin/plugin.json` with metadata
3. Create skills under `skills/` directory
4. Add slash commands under `commands/` directory
5. Update `.claude-plugin/marketplace.json` to register plugin

### Publishing

1. Commit your plugin to this repository
2. Submit PR to [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) for wider distribution

## 📄 License

Each plugin may have its own license. See individual plugin directories for details.

## 💬 Contact

- GitHub: [@zillako](https://github.com/zillako)
- Repository: [claude-skills](https://github.com/zillako/claude-skills)
- Issues: [Report a bug](https://github.com/zillako/claude-skills/issues)

---

**Version**: 2.0.0
**Last Updated**: 2026-01-28
