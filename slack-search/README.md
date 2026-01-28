# Slack Search Skill

Slack API를 활용하여 워크스페이스의 메시지를 조회하고 검색하는 Claude Code skill입니다.

## Installation

### Download and Install

```bash
# Download and install
wget https://github.com/zillako/slack-search-skill/releases/download/v1.1.0/slack-search-v1.1.0.tar.gz
tar -xzf slack-search-v1.1.0.tar.gz
cd slack-search-v1.1.0
./install.sh
```

See [설치가이드.md](./설치가이드.md) for detailed Korean installation guide.

### Manual Configuration

If you prefer to configure manually:

1. https://api.slack.com/apps 에서 앱 생성
2. User Token Scopes 추가:
   - `channels:history`
   - `channels:read`
   - `groups:history`
   - `groups:read`
   - `im:history` (DM 메시지 읽기)
   - `im:read` (DM 채널 목록)
   - `mpim:history` (그룹 DM 메시지 읽기, 선택사항)
   - `mpim:read` (그룹 DM 채널 목록, 선택사항)
   - `search:read`
   - `users:read`
3. Install to Workspace
4. User OAuth Token 복사

### Token Configuration

```bash
# 설정 디렉토리 생성
mkdir -p ~/.slack

# Token 설정
cat > ~/.slack/config.json << 'EOF'
{
  "token": "xoxp-your-token-here",
  "workspace": "your-workspace-name"
}
EOF

# 권한 설정
chmod 600 ~/.slack/config.json
```

### Usage in Claude Code

Once configured, use the skill in Claude Code like this:

```
> Slack에서 'OneApp' 키워드로 메시지 검색해줘
> Slack #general 채널의 최근 메시지 보여줘
> Slack에서 종오님이 보낸 메시지 찾아줘
> 민규님과의 DM에서 1월 23일 대화 찾아줘
```

## Features

- ✅ 채널 목록 조회
- ✅ 메시지 히스토리 조회
- ✅ DM(Direct Message) 조회
- ✅ 그룹 DM 조회
- ✅ 키워드 기반 검색
- ✅ 스레드 조회
- ✅ 사용자 정보 조회
- ✅ 시간 범위 필터링
- ✅ 사용자 필터링

## Requirements

- Slack workspace 접근 권한
- Slack Bot User OAuth Token
- curl (API 호출용)
- jq (JSON 파싱용, 선택사항)

## Documentation

Complete documentation is available in:

- **[설치가이드.md](./설치가이드.md)** - Detailed Korean installation guide with troubleshooting
- **[SKILL.md](./SKILL.md)** - Comprehensive API reference and usage examples
- **[examples/](./examples/)** - Sample scripts and usage patterns

## Architecture

```
┌─────────────────┐
│  User Request   │
└────────┬────────┘
         │
    ┌────▼────┐
    │ Planning │ (요청 분석)
    └────┬────┘
         │
    ┌────▼────────┐
    │  Execution  │ (API 호출)
    └────┬────────┘
         │
    ┌────▼─────────┐
    │  Formatting  │ (결과 변환)
    └────┬─────────┘
         │
    ┌────▼────┐
    │  Output │
    └─────────┘
```

## Examples

### 채널 목록 조회
```
> Slack 채널 목록 보여줘

[Slack Channels]
• general (C01234ABC)
• random (C01234DEF)
• engineering (C01234GHI)
```

### 메시지 검색
```
> Slack에서 'budget' 검색해줘

[검색 결과: budget]

1. #finance | 2026-01-10 14:30 | 김철수
   "Q1 budget 승인 완료했습니다"
   Link: https://workspace.slack.com/...

2. #product | 2026-01-08 10:15 | 박영희
   "budget 관련 미팅 내일 3시에 잡혔습니다"
   Link: https://workspace.slack.com/...
```

## Security

- ✅ Token은 로컬 파일에 안전하게 저장 (chmod 600)
- ✅ Token을 코드나 로그에 노출하지 않음
- ✅ Git에 Token 커밋 방지 (.gitignore)
- ✅ API rate limit 준수

## Troubleshooting

### Token 오류
```bash
# Token 유효성 확인
curl -X POST https://slack.com/api/auth.test \
  -H "Authorization: Bearer $(jq -r .token ~/.slack/config.json)"
```

### 채널을 찾을 수 없음
```bash
# 채널 목록 확인
curl -X GET https://slack.com/api/conversations.list \
  -H "Authorization: Bearer $(jq -r .token ~/.slack/config.json)"
```

## Performance

- Simple query: ~5K tokens, ~2s
- Search query: ~10K tokens, ~3-5s
- Thread analysis: ~15K tokens, ~2-3s

## Future Enhancements

- [ ] Slack MCP 서버 개발
- [ ] 메시지 전송 기능
- [ ] 파일 다운로드
- [ ] 메시지 분석 및 통계
- [ ] Real-time streaming

## Version

- **Current**: 1.1.0
- **Last Updated**: 2026-01-12
- **Complexity**: 0.5 (Moderate)

## License

MIT

## Support

Issues and questions: [GitHub Issues](https://github.com/your-repo/slack-search/issues)
