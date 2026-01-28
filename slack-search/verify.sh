#!/bin/bash
# slack-search Skill Health Check
# Version: 1.1.0

set -e

INSTALL_DIR="$HOME/.claude/skills/slack-search"
CONFIG_FILE="$HOME/.slack/config.json"
EXPECTED_VERSION="1.1.0"

# Output modes
QUIET_MODE=false
JSON_MODE=false

# Check results
INSTALLED=false
VERSION_MATCH=false
CONFIG_EXISTS=false
CONFIG_PERMS_OK=false
TOKEN_FORMAT_VALID=false
API_CONNECTED=false
WORKSPACE_NAME=""

# Exit codes
EXIT_OK=0
EXIT_INSTALL_ERROR=1
EXIT_CONFIG_ERROR=2
EXIT_CONNECTION_ERROR=3

# Colors for human output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
show_help() {
  cat <<EOF
slack-search Skill Health Check

Usage: verify.sh [OPTIONS]

OPTIONS:
  --quiet, -q       Only output errors
  --json            Output as JSON
  --help, -h        Show help

EXIT CODES:
  0    All checks passed
  1    Installation issues
  2    Configuration issues
  3    Connection issues
EOF
}

log_info() {
  if [[ "$QUIET_MODE" == false && "$JSON_MODE" == false ]]; then
    echo -e "${BLUE}[INFO]${NC} $1"
  fi
}

log_success() {
  if [[ "$QUIET_MODE" == false && "$JSON_MODE" == false ]]; then
    echo -e "${GREEN}[PASS]${NC} $1"
  fi
}

log_error() {
  if [[ "$JSON_MODE" == false ]]; then
    echo -e "${RED}[FAIL]${NC} $1" >&2
  fi
}

log_warn() {
  if [[ "$QUIET_MODE" == false && "$JSON_MODE" == false ]]; then
    echo -e "${YELLOW}[WARN]${NC} $1"
  fi
}

check_installation() {
  log_info "Checking installation..."

  if [[ -d "$INSTALL_DIR" ]]; then
    if [[ -f "$INSTALL_DIR/SKILL.md" && -f "$INSTALL_DIR/setup.sh" && -f "$INSTALL_DIR/install.sh" ]]; then
      INSTALLED=true
      log_success "Skill files exist in $INSTALL_DIR"
    else
      log_error "Skill directory exists but required files are missing"
      return 1
    fi
  else
    log_error "Skill directory not found: $INSTALL_DIR"
    return 1
  fi
}

check_version() {
  log_info "Checking version..."

  if [[ ! -f "$INSTALL_DIR/SKILL.md" ]]; then
    log_error "SKILL.md not found"
    return 1
  fi

  # Extract version from line 12: "version: 1.1.0"
  local version=$(sed -n '12p' "$INSTALL_DIR/SKILL.md" | sed 's/version: //' | tr -d ' ')

  if [[ "$version" == "$EXPECTED_VERSION" ]]; then
    VERSION_MATCH=true
    log_success "Version matches: $version"
  else
    log_error "Version mismatch: expected $EXPECTED_VERSION, found $version"
    return 1
  fi
}

check_config() {
  log_info "Checking configuration..."

  if [[ -f "$CONFIG_FILE" ]]; then
    CONFIG_EXISTS=true
    log_success "Configuration file exists: $CONFIG_FILE"
  else
    log_error "Configuration file not found: $CONFIG_FILE"
    log_error "Run setup.sh to configure Slack token"
    return 1
  fi
}

check_permissions() {
  log_info "Checking file permissions..."

  if [[ ! -f "$CONFIG_FILE" ]]; then
    return 1
  fi

  local perms=$(stat -f "%Lp" "$CONFIG_FILE" 2>/dev/null || stat -c "%a" "$CONFIG_FILE" 2>/dev/null)

  if [[ "$perms" == "600" ]]; then
    CONFIG_PERMS_OK=true
    log_success "Configuration permissions are secure (600)"
  else
    log_warn "Configuration permissions are $perms (should be 600)"
    log_warn "Fix with: chmod 600 $CONFIG_FILE"
    CONFIG_PERMS_OK=false
  fi
}

check_token_format() {
  log_info "Checking token format..."

  if [[ ! -f "$CONFIG_FILE" ]]; then
    return 1
  fi

  # Check if jq is available
  if ! command -v jq &> /dev/null; then
    log_warn "jq not found, skipping token format validation"
    TOKEN_FORMAT_VALID=true
    return 0
  fi

  local token=$(jq -r '.token // empty' "$CONFIG_FILE" 2>/dev/null)

  if [[ -z "$token" ]]; then
    log_error "Token not found in configuration"
    return 1
  fi

  if [[ "$token" =~ ^xoxb- ]]; then
    TOKEN_FORMAT_VALID=true
    log_success "Token format is valid (xoxb-*)"
  else
    log_error "Invalid token format (expected xoxb-*)"
    return 1
  fi
}

check_api_connection() {
  log_info "Checking API connection..."

  if [[ ! -f "$CONFIG_FILE" ]]; then
    return 1
  fi

  # Check if jq is available
  if ! command -v jq &> /dev/null; then
    log_warn "jq not found, skipping API connection test"
    API_CONNECTED=true
    return 0
  fi

  local token=$(jq -r '.token // empty' "$CONFIG_FILE" 2>/dev/null)

  if [[ -z "$token" ]]; then
    log_error "Cannot test API connection without token"
    return 1
  fi

  local response=$(curl -s -X POST "https://slack.com/api/auth.test" \
    -H "Authorization: Bearer $token" \
    -H "Content-Type: application/json")

  local ok=$(echo "$response" | jq -r '.ok // false' 2>/dev/null)

  if [[ "$ok" == "true" ]]; then
    API_CONNECTED=true
    WORKSPACE_NAME=$(echo "$response" | jq -r '.team // "unknown"' 2>/dev/null)
    log_success "API connection successful"
    log_success "Workspace: $WORKSPACE_NAME"
  else
    local error=$(echo "$response" | jq -r '.error // "unknown error"' 2>/dev/null)
    log_error "API connection failed: $error"
    return 1
  fi
}

output_json() {
  # Check if jq is available
  if command -v jq &> /dev/null; then
    cat <<EOF | jq
{
  "installed": $INSTALLED,
  "version": "$EXPECTED_VERSION",
  "config_exists": $CONFIG_EXISTS,
  "token_valid": $TOKEN_FORMAT_VALID,
  "api_connected": $API_CONNECTED,
  "workspace": "$WORKSPACE_NAME"
}
EOF
  else
    # Fallback to plain JSON without jq
    cat <<EOF
{
  "installed": $INSTALLED,
  "version": "$EXPECTED_VERSION",
  "config_exists": $CONFIG_EXISTS,
  "token_valid": $TOKEN_FORMAT_VALID,
  "api_connected": $API_CONNECTED,
  "workspace": "$WORKSPACE_NAME"
}
EOF
  fi
}

output_human() {
  echo ""
  echo -e "${BLUE}=====================================${NC}"
  echo -e "${BLUE}  slack-search Skill Health Check${NC}"
  echo -e "${BLUE}=====================================${NC}"
  echo ""
  echo -e "Installed:       $([ "$INSTALLED" == true ] && echo -e "${GREEN}✓${NC}" || echo -e "${RED}✗${NC}")"
  echo -e "Version:         $([ "$VERSION_MATCH" == true ] && echo -e "${GREEN}$EXPECTED_VERSION${NC}" || echo -e "${RED}mismatch${NC}")"
  echo -e "Config exists:   $([ "$CONFIG_EXISTS" == true ] && echo -e "${GREEN}✓${NC}" || echo -e "${RED}✗${NC}")"
  echo -e "Token valid:     $([ "$TOKEN_FORMAT_VALID" == true ] && echo -e "${GREEN}✓${NC}" || echo -e "${RED}✗${NC}")"
  echo -e "API connected:   $([ "$API_CONNECTED" == true ] && echo -e "${GREEN}✓${NC}" || echo -e "${RED}✗${NC}")"
  if [[ -n "$WORKSPACE_NAME" ]]; then
    echo -e "Workspace:       ${GREEN}$WORKSPACE_NAME${NC}"
  fi
  echo ""

  if [[ "$INSTALLED" == true && "$VERSION_MATCH" == true && "$CONFIG_EXISTS" == true && "$TOKEN_FORMAT_VALID" == true && "$API_CONNECTED" == true ]]; then
    echo -e "${GREEN}All checks passed!${NC}"
  else
    echo -e "${RED}Some checks failed. See errors above.${NC}"
  fi
  echo ""
}

# Main execution
main() {
  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
      --quiet|-q)
        QUIET_MODE=true
        shift
        ;;
      --json)
        JSON_MODE=true
        shift
        ;;
      --help|-h)
        show_help
        exit 0
        ;;
      *)
        echo "Unknown option: $1"
        show_help
        exit 1
        ;;
    esac
  done

  # Run checks (in order)
  local exit_code=$EXIT_OK

  if ! check_installation; then
    exit_code=$EXIT_INSTALL_ERROR
  elif ! check_version; then
    exit_code=$EXIT_INSTALL_ERROR
  elif ! check_config; then
    exit_code=$EXIT_CONFIG_ERROR
  else
    check_permissions
    if ! check_token_format; then
      exit_code=$EXIT_CONFIG_ERROR
    elif ! check_api_connection; then
      exit_code=$EXIT_CONNECTION_ERROR
    fi
  fi

  # Output results
  if [[ "$JSON_MODE" == true ]]; then
    output_json
  elif [[ "$QUIET_MODE" == false ]]; then
    output_human
  fi

  exit $exit_code
}

main "$@"
