#!/bin/bash

# slack-search Skill Installer
# Version: 1.1.0

set -e

VERSION="1.1.0"
INSTALL_DIR="$HOME/.claude/skills/slack-search"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Command line options
UPGRADE=false
FORCE=false
SKIP_SETUP=false
CUSTOM_PATH=""

# Functions
show_help() {
    cat << EOF
slack-search Skill Installer v${VERSION}

사용법: install.sh [OPTIONS]

옵션:
  --upgrade, -u     기존 설치를 업그레이드 (설정 파일 보존)
  --force, -f       강제 재설치 (모든 것을 초기화)
  --skip-setup      토큰 설정 단계 건너뛰기
  --path PATH       사용자 정의 설치 경로
  --help, -h        이 도움말 표시
  --version, -v     버전 정보 표시

종료 코드:
  0    성공
  1    의존성 누락
  2    다운로드 실패
  3    권한 오류
  4    사용자 취소

예제:
  ./install.sh                 # 일반 설치
  ./install.sh --upgrade       # 기존 설치 업그레이드
  ./install.sh --force         # 강제 재설치
  ./install.sh --skip-setup    # 설정 없이 설치만
EOF
}

show_version() {
    echo "slack-search Skill Installer v${VERSION}"
}

check_dependencies() {
    echo "📦 의존성 확인 중..."
    echo ""

    # Check curl
    if ! command -v curl &> /dev/null; then
        echo -e "${RED}❌ curl이 설치되어 있지 않습니다${NC}"
        echo ""
        echo "설치 방법:"
        if [[ "$OSTYPE" == "darwin"* ]]; then
            echo "  macOS: curl은 기본 제공됩니다"
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            echo "  Ubuntu/Debian: sudo apt-get install curl"
            echo "  CentOS/RHEL: sudo yum install curl"
        fi
        exit 1
    fi
    echo -e "${GREEN}✅ curl 발견${NC}"

    # Check bash version
    if [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
        echo -e "${YELLOW}⚠️  Bash 버전 4.0 이상 권장 (현재: ${BASH_VERSION})${NC}"
    else
        echo -e "${GREEN}✅ Bash ${BASH_VERSION}${NC}"
    fi

    # Check jq (optional)
    if command -v jq &> /dev/null; then
        echo -e "${GREEN}✅ jq 발견 (선택사항, 권장)${NC}"
    else
        echo -e "${YELLOW}⚠️  jq 미설치 (선택사항, 권장)${NC}"
        echo "   설치하려면: brew install jq (macOS) 또는 sudo apt-get install jq (Linux)"
    fi

    echo ""
}

detect_existing() {
    if [ -d "$INSTALL_DIR" ]; then
        echo -e "${YELLOW}⚠️  기존 설치 발견: $INSTALL_DIR${NC}"
        echo ""

        # Check version if SKILL.md exists
        if [ -f "$INSTALL_DIR/SKILL.md" ]; then
            EXISTING_VERSION=$(grep "^version:" "$INSTALL_DIR/SKILL.md" | awk '{print $2}')
            if [ -n "$EXISTING_VERSION" ]; then
                echo "기존 버전: $EXISTING_VERSION"
                echo "새 버전: $VERSION"
                echo ""
            fi
        fi

        return 0
    else
        return 1
    fi
}

handle_existing_install() {
    if [ "$FORCE" = true ]; then
        echo -e "${YELLOW}🔨 강제 재설치 모드: 기존 설치 제거 중...${NC}"
        rm -rf "$INSTALL_DIR"
        echo -e "${GREEN}✅ 제거 완료${NC}"
        echo ""
        return 0
    fi

    if [ "$UPGRADE" = true ]; then
        echo -e "${BLUE}⬆️  업그레이드 모드: 설정 파일 보존${NC}"
        echo ""

        # Backup config if exists
        if [ -f "$HOME/.slack/config.json" ]; then
            echo "설정 파일 백업 중..."
            cp "$HOME/.slack/config.json" "$HOME/.slack/config.json.backup"
            echo -e "${GREEN}✅ 백업 완료: ~/.slack/config.json.backup${NC}"
        fi
        return 0
    fi

    # Interactive prompt
    echo "다음 중 하나를 선택하세요:"
    echo "  1) 업그레이드 (설정 보존)"
    echo "  2) 재설치 (모든 것 초기화)"
    echo "  3) 취소"
    echo ""
    read -p "선택 (1-3): " -n 1 -r choice
    echo ""
    echo ""

    case $choice in
        1)
            UPGRADE=true
            echo -e "${BLUE}⬆️  업그레이드 선택${NC}"
            if [ -f "$HOME/.slack/config.json" ]; then
                cp "$HOME/.slack/config.json" "$HOME/.slack/config.json.backup"
                echo -e "${GREEN}✅ 설정 백업 완료${NC}"
            fi
            echo ""
            ;;
        2)
            FORCE=true
            echo -e "${YELLOW}🔨 재설치 선택${NC}"
            rm -rf "$INSTALL_DIR"
            echo -e "${GREEN}✅ 기존 설치 제거 완료${NC}"
            echo ""
            ;;
        3)
            echo "설치가 취소되었습니다."
            exit 4
            ;;
        *)
            echo -e "${RED}잘못된 선택입니다.${NC}"
            exit 4
            ;;
    esac
}

copy_files() {
    echo "📂 파일 복사 중..."
    echo ""

    # Create install directory
    mkdir -p "$INSTALL_DIR"

    # Get current directory (where the extracted package is)
    SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)"

    # Files to copy
    FILES=(
        "SKILL.md"
        "README.md"
        "setup.sh"
        "LICENSE"
        "CHANGELOG.md"
        ".gitignore"
    )

    # Copy files
    for file in "${FILES[@]}"; do
        if [ -f "$SOURCE_DIR/$file" ]; then
            cp "$SOURCE_DIR/$file" "$INSTALL_DIR/"
            echo -e "${GREEN}✅${NC} $file"
        else
            echo -e "${YELLOW}⚠️${NC}  $file (파일 없음, 건너뜀)"
        fi
    done

    # Copy examples directory if exists
    if [ -d "$SOURCE_DIR/examples" ]; then
        cp -r "$SOURCE_DIR/examples" "$INSTALL_DIR/"
        echo -e "${GREEN}✅${NC} examples/"
    fi

    # Make setup.sh executable
    if [ -f "$INSTALL_DIR/setup.sh" ]; then
        chmod +x "$INSTALL_DIR/setup.sh"
    fi

    echo ""
    echo -e "${GREEN}✅ 파일 복사 완료${NC}"
    echo ""
}

run_setup() {
    if [ "$SKIP_SETUP" = true ]; then
        echo -e "${YELLOW}⏭️  설정 단계 건너뛰기 (--skip-setup)${NC}"
        echo ""
        echo "나중에 설정하려면 다음 명령을 실행하세요:"
        echo "  $INSTALL_DIR/setup.sh"
        echo ""
        return 0
    fi

    if [ -f "$INSTALL_DIR/setup.sh" ]; then
        echo "🔧 설정 시작..."
        echo ""

        # If upgrading and config exists, just test it
        if [ "$UPGRADE" = true ] && [ -f "$HOME/.slack/config.json" ]; then
            echo -e "${BLUE}업그레이드 모드: 기존 설정 확인 중...${NC}"
            echo ""
            "$INSTALL_DIR/setup.sh" --test-only
        else
            # Fresh setup
            "$INSTALL_DIR/setup.sh"
        fi
    else
        echo -e "${YELLOW}⚠️  setup.sh를 찾을 수 없습니다${NC}"
    fi
}

show_completion() {
    echo ""
    echo "═════════════════════════════════════════"
    echo -e "${GREEN}✨ 설치 완료!${NC}"
    echo "═════════════════════════════════════════"
    echo ""
    echo "설치 위치: $INSTALL_DIR"
    echo ""

    if [ "$SKIP_SETUP" = false ] && [ -f "$HOME/.slack/config.json" ]; then
        echo "다음 단계:"
        echo "1. Claude Code에서 사용해보세요:"
        echo "   > Slack에서 메시지 검색해줘"
        echo ""
        echo "2. 전체 문서 보기:"
        echo "   cat $INSTALL_DIR/SKILL.md"
    else
        echo "다음 단계:"
        echo "1. 설정 실행:"
        echo "   $INSTALL_DIR/setup.sh"
        echo ""
        echo "2. 사용 예제:"
        echo "   cat $INSTALL_DIR/README.md"
    fi
    echo ""
    echo "문제가 있으신가요?"
    echo "- 문서: $INSTALL_DIR/README.md"
    echo "- 변경사항: $INSTALL_DIR/CHANGELOG.md"
    echo ""
}

# Main function
main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --upgrade|-u)
                UPGRADE=true
                shift
                ;;
            --force|-f)
                FORCE=true
                shift
                ;;
            --skip-setup)
                SKIP_SETUP=true
                shift
                ;;
            --path)
                CUSTOM_PATH="$2"
                INSTALL_DIR="$CUSTOM_PATH"
                shift 2
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            --version|-v)
                show_version
                exit 0
                ;;
            *)
                echo -e "${RED}알 수 없는 옵션: $1${NC}"
                echo "도움말을 보려면: $0 --help"
                exit 1
                ;;
        esac
    done

    # Show banner
    echo ""
    echo "╔════════════════════════════════════════╗"
    echo "║   slack-search Skill Installer         ║"
    echo "║   Version: $VERSION                    ║"
    echo "╚════════════════════════════════════════╝"
    echo ""

    # 1. Check dependencies
    check_dependencies

    # 2. Detect existing installation
    if detect_existing; then
        handle_existing_install
    fi

    # 3. Copy files
    copy_files

    # 4. Run setup
    run_setup

    # 5. Show completion
    show_completion

    exit 0
}

# Run main
main "$@"
