---
name: slack-search
description: "Slack 워크스페이스에서 메시지를 조회하고 검색하는 skill. 채널 목록, 메시지 히스토리, DM 조회, 키워드 검색, 스레드 조회, 날짜 필터링을 지원합니다."
license: MIT
allowed-tools: Bash Read Write TodoWrite
metadata:
  version: "2.0.0"
  complexity: 0.5
  agentic_patterns:
    - plan-then-execute
    - dynamic-context-injection
    - llm-friendly-api-design
  examples:
    - trigger: "Slack에서 'OneApp' 키워드로 메시지 검색해줘"
    - trigger: "Slack #general 채널의 최근 메시지 보여줘"
    - trigger: "Slack에서 종오님이 보낸 메시지 찾아줘"
    - trigger: "민규님과의 DM에서 1월 23일 대화 찾아줘"
    - trigger: "서민규님과 주고받은 DM 메시지 검색해줘"
    - trigger: "오늘 Slack에서 내가 보낸 메시지 찾아줘"
    - trigger: "2026-01-27 Slack 활동 검색해줘"
---

# Slack Search

Slack API를 활용하여 워크스페이스의 메시지를 조회하고 검색하는 skill입니다.

## Installation

For complete installation instructions, see [설치가이드.md](./설치가이드.md).

**Installation**:
```bash
# Add claude-skills marketplace
/plugin marketplace add https://github.com/zillako/claude-skills

# Install slack-search plugin
/plugin install slack-search

# Configure with your Slack credentials
/slack-setup
```

## Core Capabilities

1. **채널 관리**
   - 워크스페이스 채널 목록 조회
   - 채널 정보 확인

2. **메시지 조회**
   - 특정 채널의 메시지 히스토리 조회
   - DM(Direct Message) 메시지 조회
   - 그룹 DM 메시지 조회
   - 시간 범위 기반 필터링
   - 최신 N개 메시지 조회

3. **메시지 검색**
   - 키워드 기반 전체 검색
   - 채널 필터링
   - DM 검색 지원
   - 사용자 필터링

4. **스레드 조회**
   - 특정 메시지의 스레드 답글 조회
   - 스레드 컨텍스트 확인

5. **사용자 정보**
   - 사용자 프로필 조회
   - Display name 및 real name 확인

## Setup Requirements

### 1. Slack App 생성

1. https://api.slack.com/apps 에서 새 앱 생성
2. OAuth & Permissions 페이지에서 **User Token Scopes** 섹션에 다음 scopes 추가:
   ```
   channels:history
   channels:read
   groups:history
   groups:read
   im:history
   im:read
   mpim:history
   mpim:read
   search:read
   users:read
   users:read.email
   ```
3. Install App to Workspace
4. User OAuth Token 복사 (xoxp-로 시작)

### 2. Token 설정

Token을 안전하게 저장:

```bash
# ~/.slack/config.json 생성
mkdir -p ~/.slack
cat > ~/.slack/config.json << 'EOF'
{
  "token": "xoxp-your-token-here",
  "workspace": "your-workspace-name"
}
EOF

# 권한 설정 (본인만 읽기 가능)
chmod 600 ~/.slack/config.json
```

## Workflow

### Phase 1: Planning (Plan-Then-Execute Pattern)

사용자 요청을 분석하여 실행 계획 수립:

```yaml
request_analysis:
  - 작업 유형 식별 (list, history, search, thread)
  - 필요한 파라미터 추출 (channel, keyword, user, timerange)
  - API 엔드포인트 결정

execution_plan:
  step_1: "Token 설정 확인"
  step_2: "필요시 채널 ID 조회"
  step_3: "API 호출 실행"
  step_4: "결과 파싱 및 포맷팅"
```

### Phase 2: Execution

TodoWrite로 작업 추적하며 순차적으로 실행:

```typescript
workflow {
  // Step 1: Token 로드
  config = Read("~/.slack/config.json")
  token = config.token

  // Step 2: API 호출
  response = Bash(curl_command_with_token)

  // Step 3: 결과 변환 (LLM-Friendly API Design)
  formatted_result = parseAndFormat(response)

  // Step 4: 출력
  return formatted_result
}
```

## Pattern Implementation

### 1. Plan-Then-Execute

**Planning Phase**:
- 사용자 요청 분석 및 의도 파악
- 필요한 API 엔드포인트 결정
- 파라미터 수집 및 검증

**Execution Phase**:
- TodoWrite로 진행상황 추적
- API 호출 실행
- 에러 핸들링 및 재시도

### 2. Dynamic Context Injection

**On-Demand API Documentation**:
- 필요시 Slack API 문서 참조
- 특정 엔드포인트의 상세 파라미터 조회
- 에러 코드 해석 및 해결 방법 검색

```typescript
// 에러 발생시 API 문서 동적 조회
if (error.code === 'channel_not_found') {
  docs = WebFetch("https://api.slack.com/methods/conversations.list")
  // docs를 참조하여 문제 해결
}
```

### 3. LLM-Friendly API Design

**API 응답 변환**:
- Slack API의 JSON 응답을 읽기 쉬운 형식으로 변환
- 중요 정보 우선 표시
- 타임스탬프를 사람이 읽기 쉬운 형식으로 변환

```typescript
// 원본 Slack API 응답
{
  "ok": true,
  "messages": [{
    "type": "message",
    "user": "U1234",
    "text": "Hello",
    "ts": "1641234567.123456"
  }]
}

// LLM-Friendly 변환
[채널: general]
- 2024-01-03 15:30 | 홍길동: Hello
  Link: https://workspace.slack.com/archives/C1234/p1641234567123456
```

## API Reference

### 1. 채널 목록 조회

```bash
curl -X GET "https://slack.com/api/conversations.list" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json"
```

### 2. 메시지 히스토리

```bash
curl -X GET "https://slack.com/api/conversations.history" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "channel=$CHANNEL_ID&limit=100"
```

### 3. 메시지 검색

```bash
curl -X GET "https://slack.com/api/search.messages" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "query=$SEARCH_QUERY"
```

**날짜 검색 필터**:
```bash
# 특정 날짜 검색 (정확히 그 날)
query="from:me on:2026-01-27"

# 특정 날짜 이후
query="from:me after:2026-01-26"

# 특정 날짜 이전
query="from:me before:2026-01-28"

# 날짜 범위 검색
query="from:me after:2026-01-20 before:2026-01-28"
```

**중요**:
- 특정 날짜로 검색할 때는 반드시 `on:YYYY-MM-DD` 형식을 사용해야 합니다.
- `after:` 또는 `before:`는 범위 검색에 사용됩니다.
- 날짜 형식은 `YYYY-MM-DD` (ISO 8601)를 따릅니다.

### 4. 스레드 조회

```bash
curl -X GET "https://slack.com/api/conversations.replies" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "channel=$CHANNEL_ID&ts=$THREAD_TS"
```

### 5. 사용자 정보

```bash
curl -X GET "https://slack.com/api/users.info" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "user=$USER_ID"
```

## Usage Examples

### Example 1: 채널 목록 조회

**요청**: "Slack 채널 목록 보여줘"

**Workflow**:
```
1. Planning: conversations.list API 사용 결정
2. Execution:
   - Token 로드
   - API 호출
   - 채널 목록 파싱
3. Output:
   [Slack Channels]
   • general (C01234ABC)
   • random (C01234DEF)
   • engineering (C01234GHI)
```

### Example 2: 메시지 검색

**요청**: "Slack에서 'OneApp' 키워드로 메시지 검색해줘"

**Workflow**:
```
1. Planning:
   - search.messages API 사용
   - query="OneApp" 파라미터 설정

2. Execution:
   - Token 로드
   - 검색 API 호출
   - 결과 최대 20개 제한

3. Output:
   [검색 결과: OneApp]

   1. #product-team | 2026-01-12 14:30 | 신제경
      "OneApp 스냅 기능 M1 완료 목표로 진행 중"
      Link: https://workspace.slack.com/archives/C1234/p1234567890

   2. #engineering | 2026-01-12 10:15 | 고진영
      "OneApp VND 통화 오픈스펙 TT 미팅에서 리뷰 예정"
      Link: https://workspace.slack.com/archives/C5678/p9876543210
```

### Example 3: 특정 채널 히스토리

**요청**: "Slack #general 채널의 최근 메시지 10개 보여줘"

**Workflow**:
```
1. Planning:
   - conversations.history API 사용
   - limit=10 설정

2. Execution:
   - 채널 이름으로 채널 ID 조회
   - 히스토리 API 호출
   - 시간 역순 정렬

3. Output:
   [#general - 최근 10개 메시지]

   2026-01-12 16:45 | 홍길동
   "회의실 예약 완료했습니다"

   2026-01-12 16:30 | 김영희
   "내일 점심 뭐 먹을까요?"

   [...]
```

### Example 4: 사용자 필터링 검색

**요청**: "Slack에서 종오님이 보낸 메시지 찾아줘"

**Workflow**:
```
1. Planning:
   - 사용자 이름 "종오"로 User ID 조회 필요
   - search.messages API에 from: 필터 적용

2. Execution:
   - users.list로 "종오" 검색
   - User ID 확인 (예: U9876)
   - search.messages with query="from:<@U9876>"

3. Output:
   [종오님의 메시지]

   1. #tech-team | 2026-01-12 11:00
      "TT 미팅 목요일로 일정 잡았습니다"
      Link: https://workspace.slack.com/...
```

### Example 5: 날짜 검색

**요청**: "Slack에서 오늘(2026-01-27) 내가 보낸 메시지 찾아줘"

**Workflow**:
```
1. Planning:
   - search.messages API 사용
   - 날짜 필터: on:2026-01-27
   - 사용자 필터: from:me

2. Execution:
   - Token 로드
   - query="from:me on:2026-01-27" 검색
   - DM, 채널 메시지 모두 포함

3. Output:
   [2026-01-27 내가 보낸 메시지 - 총 228건]

   1. #mss_ai_champion_group | 23:53:46
      "클로드 개발자 피셜"

   2. #tech-ai-hub | 20:12:34
      "claude한테 시켜서 로컬에 mcp 서버 띄우고..."

   3. #fe-global-store | 17:24:32
      "Anthropic CEO, Node.js 창시자도 더이상..."
```

**날짜 검색 팁**:
- **특정 날짜**: `on:YYYY-MM-DD` (정확히 그 날만)
- **날짜 범위**: `after:YYYY-MM-DD before:YYYY-MM-DD`
- **상대 날짜**: `after:today`, `after:yesterday`
- **조합 검색**: `from:me on:2026-01-27 in:#engineering`

## Error Handling

### Common Errors

1. **Token Invalid (invalid_auth)**
   ```
   → Token 확인: ~/.slack/config.json
   → Token 재발급 필요
   ```

2. **Channel Not Found (channel_not_found)**
   ```
   → conversations.list로 채널 ID 확인
   → 채널 이름 vs ID 구분
   ```

3. **Rate Limit (rate_limited)**
   ```
   → Retry-After 헤더 확인
   → 지수 백오프 적용
   ```

4. **Permission Denied (missing_scope)**
   ```
   → 필요한 OAuth scope 확인
   → App 권한 재설정
   ```

### Error Recovery Strategy

```typescript
try {
  response = callSlackAPI()
} catch (error) {
  if (error.code === 'rate_limited') {
    wait(error.retry_after)
    response = callSlackAPI() // 재시도
  } else if (error.code === 'channel_not_found') {
    // 채널 ID 검색 시도
    channel_id = findChannelByName(channel_name)
    response = callSlackAPI(channel_id)
  } else {
    // Dynamic Context Injection: API 문서 조회
    docs = WebFetch(api_docs_url)
    // 문서 기반 해결 시도
  }
}
```

## Quality Gates

✅ **Setup Validation**
- Token 파일 존재 확인 (`~/.slack/config.json`)
- Token 형식 검증 (`xoxp-` prefix)
- API 연결 테스트 (`auth.test` 호출)

✅ **Request Validation**
- 필수 파라미터 존재 확인
- 파라미터 타입 검증
- API 엔드포인트 유효성

✅ **Response Validation**
- API 응답 `ok` 필드 확인
- 에러 코드 처리
- 데이터 무결성 검증

✅ **Output Quality**
- 타임스탬프 변환 정확성
- 링크 URL 유효성
- 사용자 이름 매핑 정확성

## Performance Considerations

**Token Usage**:
- Simple query: ~5K tokens
- Complex search: ~10K tokens
- Thread analysis: ~15K tokens

**Execution Time**:
- Channel list: ~2s
- Message search: ~3-5s
- Thread retrieval: ~2-3s
- Rate limit 고려: Tier 3 (50+ requests/min)

**Optimization**:
- 결과 제한 (default 20개)
- 채널 ID 캐싱 (세션 내)
- User ID 매핑 캐싱
- 병렬 API 호출 (독립적인 요청)

## Security Considerations

**Token Management**:
- ✅ Token을 환경변수나 설정 파일에 저장
- ✅ 파일 권한 제한 (chmod 600)
- ❌ Token을 코드나 로그에 노출하지 않음
- ❌ Git에 Token 커밋하지 않음 (.gitignore 추가)

**Data Privacy**:
- 민감한 메시지 내용 필터링 옵션 제공
- 검색 결과 저장시 주의
- 개인정보 포함 여부 확인

## Future Enhancements

1. **MCP Server Integration**
   - Slack MCP 서버 개발
   - Native tool integration
   - Real-time message streaming

2. **Advanced Features**
   - 메시지 전송 기능
   - 파일 다운로드
   - 채널 생성/관리
   - Workflow automation

3. **Analytics**
   - 메시지 빈도 분석
   - 사용자 활동 통계
   - 키워드 트렌드 분석

4. **UI Integration**
   - 웹 인터페이스
   - 결과 시각화
   - 인터랙티브 필터링

---

**Version**: 2.0.0
**Last Updated**: 2026-01-28
**Complexity**: 0.5 (Moderate)
**Patterns Applied**: plan-then-execute, dynamic-context-injection, llm-friendly-api-design

**Changelog**:
- v2.0.0 (2026-01-28): Plugin System migration (breaking changes)
- v1.1.0 (2026-01-27): 날짜 검색 필터 설명 추가 (`on:`, `after:`, `before:`)
- v1.0.0 (2026-01-12): 초기 버전
