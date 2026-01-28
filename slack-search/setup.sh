#!/bin/bash

# Slack Search Skill - Setup Script
# Version: 1.1.0

set -e

# Parse command line arguments
TEST_ONLY=false
NON_INTERACTIVE_TOKEN=""
NON_INTERACTIVE_WORKSPACE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --test-only)
            TEST_ONLY=true
            shift
            ;;
        --token)
            NON_INTERACTIVE_TOKEN="$2"
            shift 2
            ;;
        --workspace)
            NON_INTERACTIVE_WORKSPACE="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--test-only] [--token TOKEN] [--workspace NAME]"
            exit 1
            ;;
    esac
done

echo "🚀 Slack Search Skill Setup"
echo "================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to mask token for display
mask_token() {
    local token="$1"
    if [ ${#token} -le 10 ]; then
        echo "***"
    else
        echo "${token:0:10}..."
    fi
}

# Check dependencies
echo "📦 Checking dependencies..."

if ! command -v curl &> /dev/null; then
    echo -e "${RED}❌ curl is not installed${NC}"
    exit 1
fi
echo -e "${GREEN}✅ curl found${NC}"

if command -v jq &> /dev/null; then
    echo -e "${GREEN}✅ jq found (optional but recommended)${NC}"
    HAS_JQ=true
else
    echo -e "${YELLOW}⚠️  jq not found (optional but recommended for JSON parsing)${NC}"
    HAS_JQ=false
fi

echo ""

# Create config directory
CONFIG_DIR="$HOME/.slack"

# Test-only mode: verify existing config
if [ "$TEST_ONLY" = true ]; then
    echo "🔍 Test-only mode: Verifying existing configuration..."
    echo ""

    if [ ! -f "$CONFIG_DIR/config.json" ]; then
        echo -e "${RED}❌ Config file not found: $CONFIG_DIR/config.json${NC}"
        exit 1
    fi

    # Read token from existing config
    if [ "$HAS_JQ" = true ]; then
        SLACK_TOKEN=$(jq -r '.token' "$CONFIG_DIR/config.json")
        WORKSPACE_NAME=$(jq -r '.workspace' "$CONFIG_DIR/config.json")
    else
        echo -e "${RED}❌ jq is required for test-only mode${NC}"
        exit 1
    fi

    echo "Existing configuration:"
    echo "  Workspace: $WORKSPACE_NAME"
    echo "  Token: $(mask_token "$SLACK_TOKEN")"
    echo ""

    # Skip to connection test
else
    # Normal setup mode
    echo "📁 Creating config directory..."
    mkdir -p "$CONFIG_DIR"
    echo -e "${GREEN}✅ Directory created: $CONFIG_DIR${NC}"
    echo ""

    # Check if config already exists
    if [ -f "$CONFIG_DIR/config.json" ]; then
        echo -e "${YELLOW}⚠️  Config file already exists${NC}"
        read -p "Do you want to overwrite it? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Setup cancelled."
            exit 0
        fi
    fi
fi

# Get Slack token (skip in test-only mode)
if [ "$TEST_ONLY" = false ]; then
    # Check if non-interactive mode
    if [ -n "$NON_INTERACTIVE_TOKEN" ] && [ -n "$NON_INTERACTIVE_WORKSPACE" ]; then
        # Non-interactive mode: use provided values
        SLACK_TOKEN="$NON_INTERACTIVE_TOKEN"
        WORKSPACE_NAME="$NON_INTERACTIVE_WORKSPACE"

        echo "🔑 Non-interactive mode"
        echo "================================"
        echo ""
        echo "Using provided configuration:"
        echo "  Workspace: $WORKSPACE_NAME"
        echo "  Token: $(mask_token "$SLACK_TOKEN")"
        echo ""

        # Validate token format
        if [[ ! $SLACK_TOKEN =~ ^xoxp- ]]; then
            echo -e "${RED}❌ Invalid token format. Token should start with 'xoxp-'${NC}"
            exit 1
        fi
    else
        # Interactive mode: prompt for values
        echo "🔑 Slack Token Setup"
        echo "================================"
        echo ""
        echo "To get your Slack User OAuth Token:"
        echo "1. Go to https://api.slack.com/apps"
        echo "2. Create a new app or select existing one"
        echo "3. Go to 'OAuth & Permissions'"
        echo "4. Add these scopes under 'User Token Scopes':"
        echo "   - channels:history"
        echo "   - channels:read"
        echo "   - groups:history"
        echo "   - groups:read"
        echo "   - search:read"
        echo "   - users:read"
        echo "5. Install app to workspace"
        echo "6. Copy 'User OAuth Token' (starts with xoxp-)"
        echo ""

        # Prompt for token
        read -p "Enter your Slack User OAuth Token (xoxp-...): " SLACK_TOKEN

        # Validate token format
        if [[ ! $SLACK_TOKEN =~ ^xoxp- ]]; then
            echo -e "${RED}❌ Invalid token format. Token should start with 'xoxp-'${NC}"
            exit 1
        fi

        # Prompt for workspace name
        read -p "Enter your Slack workspace name (e.g., mycompany): " WORKSPACE_NAME
    fi

    # Create config file
    echo ""
    echo "💾 Creating config file..."

    cat > "$CONFIG_DIR/config.json" << EOF
{
  "token": "$SLACK_TOKEN",
  "workspace": "$WORKSPACE_NAME"
}
EOF

    # Set permissions
    chmod 600 "$CONFIG_DIR/config.json"
    echo -e "${GREEN}✅ Config file created with secure permissions (600)${NC}"
    echo ""
fi

# Test connection
echo "🔍 Testing Slack API connection..."
echo "   Token: $(mask_token "$SLACK_TOKEN")"
echo ""

if [ "$HAS_JQ" = true ]; then
    RESPONSE=$(curl -s -X POST https://slack.com/api/auth.test \
        -H "Authorization: Bearer $SLACK_TOKEN")

    OK=$(echo "$RESPONSE" | jq -r '.ok')

    if [ "$OK" = "true" ]; then
        TEAM=$(echo "$RESPONSE" | jq -r '.team')
        USER=$(echo "$RESPONSE" | jq -r '.user')
        echo -e "${GREEN}✅ Connection successful!${NC}"
        echo "   Team: $TEAM"
        echo "   Bot User: $USER"
    else
        ERROR=$(echo "$RESPONSE" | jq -r '.error')
        echo -e "${RED}❌ Connection failed: $ERROR${NC}"
        echo "Please check your token and try again."
        exit 1
    fi
else
    # Without jq, just check HTTP status
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST https://slack.com/api/auth.test \
        -H "Authorization: Bearer $SLACK_TOKEN")

    if [ "$HTTP_CODE" = "200" ]; then
        echo -e "${GREEN}✅ Connection successful! (HTTP 200)${NC}"
        echo "   Note: Install jq for more detailed verification"
    else
        echo -e "${RED}❌ Connection failed (HTTP $HTTP_CODE)${NC}"
        echo "Please check your token and try again."
        exit 1
    fi
fi

echo ""

# Different completion messages based on mode
if [ "$TEST_ONLY" = true ]; then
    echo "✨ Test complete!"
    echo ""
    echo "Configuration verified successfully."
else
    echo "✨ Setup complete!"
    echo ""
    echo "Next steps:"
    echo "1. Try the skill in Claude Code:"
    echo "   > Slack에서 메시지 검색해줘"
    echo ""
    echo "2. View full documentation:"
    echo "   cat ~/.claude/skills/slack-search/SKILL.md"
    echo ""
    echo "Security reminder:"
    echo "- Your token is stored in: $CONFIG_DIR/config.json"
    echo "- File permissions are set to 600 (only you can read)"
    echo "- Do NOT commit this file to git"
    echo ""
fi
