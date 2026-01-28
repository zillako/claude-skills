#!/bin/bash

# slack-search Skill Uninstaller
# Version: 1.1.0

VERSION="1.1.0"
INSTALL_DIR="$HOME/.claude/skills/slack-search"
CONFIG_FILE="$HOME/.slack/config.json"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Command line options
KEEP_CONFIG=false
FORCE=false

# Functions
show_help() {
    cat << EOF
slack-search Skill Uninstaller v${VERSION}

사용법: uninstall.sh [OPTIONS]

옵션:
  --keep-config     ~/.slack/config.json 보존
  --force, -f       확인 건너뛰기
  --help, -h        이 도움말 표시

종료 코드:
  0    성공
  1    파일을 찾을 수 없음
  2    권한 오류
  3    사용자 취소

예제:
  ./uninstall.sh                 # 일반 제거 (설정 파일 제거 여부 물어봄)
  ./uninstall.sh --keep-config   # 설정 파일 보존
  ./uninstall.sh --force         # 확인 없이 제거

EOF
    exit 0
}

confirm_removal() {
    if [ "$FORCE" = true ]; then
        return 0
    fi

    echo -e "${YELLOW}경고: slack-search 스킬을 제거하시겠습니까?${NC}"
    echo -e "제거 대상: ${BLUE}$INSTALL_DIR${NC}"
    echo ""
    read -p "계속하시겠습니까? (y/N): " -n 1 -r
    echo

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}제거가 취소되었습니다.${NC}"
        exit 3
    fi
}

remove_skill_files() {
    if [ ! -d "$INSTALL_DIR" ]; then
        echo -e "${RED}오류: 설치 디렉토리를 찾을 수 없습니다: $INSTALL_DIR${NC}"
        exit 1
    fi

    echo -e "${BLUE}스킬 파일 제거 중...${NC}"

    if ! rm -rf "$INSTALL_DIR"; then
        echo -e "${RED}오류: 파일 제거 실패 (권한 확인)${NC}"
        exit 2
    fi

    echo -e "${GREEN}✓ 스킬 파일 제거됨: $INSTALL_DIR${NC}"
}

remove_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        return 0
    fi

    if [ "$KEEP_CONFIG" = true ]; then
        echo -e "${BLUE}설정 파일 보존: $CONFIG_FILE${NC}"
        return 0
    fi

    if [ "$FORCE" = true ]; then
        rm -f "$CONFIG_FILE"
        echo -e "${GREEN}✓ 설정 파일 제거됨: $CONFIG_FILE${NC}"
        return 0
    fi

    echo ""
    echo -e "${YELLOW}Slack 설정 파일을 제거하시겠습니까?${NC}"
    echo -e "파일 위치: ${BLUE}$CONFIG_FILE${NC}"
    echo -e "${YELLOW}주의: 다시 사용하려면 토큰을 재설정해야 합니다.${NC}"
    echo ""
    read -p "설정 파일을 제거하시겠습니까? (y/N): " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -f "$CONFIG_FILE"
        echo -e "${GREEN}✓ 설정 파일 제거됨: $CONFIG_FILE${NC}"
    else
        echo -e "${BLUE}설정 파일 보존: $CONFIG_FILE${NC}"
    fi
}

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --keep-config)
                KEEP_CONFIG=true
                shift
                ;;
            --force|-f)
                FORCE=true
                shift
                ;;
            --help|-h)
                show_help
                ;;
            *)
                echo -e "${RED}알 수 없는 옵션: $1${NC}"
                echo "도움말을 보려면 --help를 사용하세요."
                exit 1
                ;;
        esac
    done

    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}slack-search Skill Uninstaller v${VERSION}${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    # Confirm removal
    confirm_removal

    # Remove skill files
    remove_skill_files

    # Handle config file
    remove_config

    # Summary
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✓ 제거 완료${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "제거된 항목:"
    echo -e "  ${GREEN}✓${NC} 스킬 디렉토리: $INSTALL_DIR"

    if [ -f "$CONFIG_FILE" ]; then
        echo -e "  ${BLUE}○${NC} 설정 파일 보존됨: $CONFIG_FILE"
    else
        echo -e "  ${GREEN}✓${NC} 설정 파일 제거됨: $CONFIG_FILE"
    fi

    echo ""
    echo -e "${BLUE}slack-search 스킬이 성공적으로 제거되었습니다.${NC}"
    echo ""

    exit 0
}

main "$@"
