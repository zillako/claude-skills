# Claude Code Skills

A collection of reusable Claude Code skills for enhanced productivity.

## Available Skills

### 🔍 [slack-search](./slack-search/)
Search and analyze Slack workspace messages directly from Claude Code.

**Features:**
- Channel list and message search
- Keyword and date filtering
- User-specific searches
- DM and thread viewing

**Installation:**
```bash
wget https://github.com/zillako/claude-skills/releases/download/slack-search-v1.1.0/slack-search-v1.1.0.tar.gz
tar -xzf slack-search-v1.1.0.tar.gz
cd slack-search-v1.1.0
./install.sh
```

📖 **[Korean Guide](./slack-search/설치가이드.md)** | **[English Docs](./slack-search/README.md)**

---

## Contributing

Each skill follows this structure:
```
skill-name/
├── SKILL.md          # Claude Code skill specification
├── README.md         # User documentation
├── install.sh        # Installation script
├── setup.sh          # Configuration script
├── verify.sh         # Health check
└── examples/         # Usage examples
```

## License

Each skill may have its own license. See individual skill directories for details.

## Contact

- GitHub: [@zillako](https://github.com/zillako)
- Repository: [claude-skills](https://github.com/zillako/claude-skills)
