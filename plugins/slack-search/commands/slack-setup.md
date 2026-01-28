---
name: slack-setup
description: Slack Search skill의 초기 설정을 수행합니다 (User OAuth Token 설정)
---

# Slack Setup Command

Slack Search skill을 사용하기 위한 초기 설정을 안내합니다.

## Prerequisites Check

먼저 다음 사항을 확인하세요:

1. **Slack App 생성 완료 여부**
   - https://api.slack.com/apps 에서 Slack App 생성
   - User Token Scopes 권한 추가 완료
   - 사용자에게: "Slack App을 생성하고 User Token Scopes 권한을 추가하셨나요? (예/아니오)"

2. **User OAuth Token 준비**
   - Slack App 설정 > OAuth & Permissions
   - "User OAuth Token" 섹션에서 xoxp-로 시작하는 token 복사
   - 사용자에게: "User OAuth Token을 준비하셨나요? (예/아니오)"

만약 위 단계를 완료하지 않았다면, 먼저 설치가이드를 읽어보시기 바랍니다:
- Read tool로 plugin 디렉토리의 `설치가이드.md` 읽기 (경로는 Claude가 자동으로 해결)

## Setup Steps

### Step 1: Dependency Check

1. Bash tool로 curl 설치 확인:
```bash
command -v curl
```

- curl이 없으면 사용자에게 curl 설치 안내
- curl이 있으면 다음 단계로 진행

2. jq 설치 확인 (optional):
```bash
command -v jq
```

- jq가 없어도 진행 가능하지만, 있으면 더 편리함을 사용자에게 알림

### Step 2: Collect Configuration

1. **User OAuth Token 요청**
   - AskUserQuestion tool 사용: "Slack User OAuth Token을 입력해주세요 (xoxp-로 시작)"
   - Token 형식 검증: xoxp-로 시작하는지 확인
   - 형식이 올바르지 않으면 다시 요청

2. **Workspace 이름 요청**
   - AskUserQuestion tool 사용: "Slack Workspace 이름을 입력해주세요"

### Step 3: Create Config Directory

Bash tool로 config 디렉토리 생성:
```bash
mkdir -p ~/.slack
chmod 700 ~/.slack
```

### Step 4: Write Config File

Write tool로 ~/.slack/config.json 생성:
```json
{
  "token": "{{USER_TOKEN}}",
  "workspace": "{{WORKSPACE_NAME}}"
}
```

Bash tool로 권한 설정:
```bash
chmod 600 ~/.slack/config.json
```

사용자에게 알림: "✅ Config 파일이 생성되었습니다: ~/.slack/config.json"

### Step 5: Verify Token

Bash tool로 token 유효성 검증:
```bash
curl -X POST https://slack.com/api/auth.test \
  -H "Authorization: Bearer {{USER_TOKEN}}" \
  -H "Content-Type: application/json"
```

응답 확인:
- `ok: true` → token이 유효함을 사용자에게 알림
- `ok: false` → 에러 메시지를 사용자에게 보여주고 token 재확인 요청

### Step 6: Verify Permissions

Bash tool로 권한 확인:
```bash
curl -X GET "https://slack.com/api/conversations.list?types=public_channel,private_channel,im,mpim&limit=5" \
  -H "Authorization: Bearer {{USER_TOKEN}}"
```

응답 확인:
- `ok: true` → 권한이 올바르게 설정됨을 사용자에게 알림
- `ok: false` → 에러 메시지 확인:
  - `missing_scope` → 필요한 권한(scope)이 누락되었음을 알리고 설치가이드 참조 안내
  - 기타 에러 → 에러 메시지를 사용자에게 보여줌

### Step 7: Completion

모든 단계가 성공하면:

✅ **Slack Search Skill 설정이 완료되었습니다!**

이제 다음과 같이 skill을 사용할 수 있습니다:
- "Slack 채널 목록 보여줘"
- "Slack에서 'keyword' 검색해줘"
- "#channel-name 채널의 최근 메시지 보여줘"

## Error Handling

각 단계에서 에러가 발생하면:
1. 명확한 에러 메시지를 사용자에게 보여줌
2. 해결 방법 안내
3. 필요시 설치가이드 참조 안내

## Security Note

- Token은 로컬 파일(~/.slack/config.json)에 안전하게 저장됨
- 파일 권한은 600 (사용자만 읽기/쓰기)
- Token을 절대 공개 저장소에 commit하지 않도록 주의

## Troubleshooting

문제가 발생하면 설치가이드의 FAQ 섹션을 참조하세요:
- Read tool로 plugin 디렉토리의 `설치가이드.md` 읽기 (경로는 Claude가 자동으로 해결)
