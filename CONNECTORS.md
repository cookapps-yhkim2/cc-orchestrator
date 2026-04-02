# Connectors Configuration

이 플러그인은 외부 도구와 연결할 수 있습니다.
사용하는 도구에 맞게 `~~플레이스홀더~~`를 실제 도구명으로 교체하세요.

## 커넥터 목록

### 프로젝트 트래커 (`~~project tracker~~`)

스프린트 계획과 기능 추적을 외부 프로젝트 트래커와 동기화합니다.

| 옵션 | 설명 |
|------|------|
| Jira | Atlassian Jira — 이슈 생성, 스프린트 보드 연동 |
| Linear | Linear — 이슈 자동 생성, 상태 동기화 |
| Asana | Asana — 태스크 생성, 프로젝트 진행 추적 |
| Trello | Trello — 카드 생성, 보드 관리 |

**연결 시 동작:**
- 스프린트 계획 생성 시 → `~~project tracker~~`에 이슈/태스크 자동 생성
- 기능 완료 시 → `~~project tracker~~`의 상태를 Done으로 업데이트
- 평가 불합격 시 → `~~project tracker~~`에 버그 이슈 생성

### 소스 컨트롤 (`~~source control~~`)

코드 커밋과 브랜치 관리를 연동합니다.

| 옵션 | 설명 |
|------|------|
| GitHub | GitHub — PR 생성, 이슈 연결, Actions 연동 |
| GitLab | GitLab — MR 생성, CI/CD 파이프라인 연동 |
| Bitbucket | Bitbucket — PR 생성, Pipelines 연동 |

**연결 시 동작:**
- 스프린트 시작 시 → `~~source control~~`에 feature 브랜치 생성
- 기능 구현 완료 시 → `~~source control~~`에 PR/MR 생성
- 평가 합격 시 → PR/MR 승인 및 머지

### 문서 (`~~docs~~`)

게임 디자인 문서와 스프린트 계획을 외부 문서 도구에 동기화합니다.

| 옵션 | 설명 |
|------|------|
| Confluence | Atlassian Confluence — 페이지 생성/업데이트 |
| Notion | Notion — 데이터베이스 및 페이지 관리 |
| Obsidian | Obsidian — 로컬 마크다운 볼트 연동 |

**연결 시 동작:**
- 스프린트 계획서 → `~~docs~~`에 자동 발행
- 평가 리포트 → `~~docs~~`에 자동 발행
- 게임 디자인 문서 → `~~docs~~`에 자동 발행

### 채팅 (`~~chat~~`)

스프린트 진행 상황을 팀 채팅에 알립니다.

| 옵션 | 설명 |
|------|------|
| Slack | Slack — 채널 메시지, 스레드 |
| Discord | Discord — 채널 메시지, 웹훅 |
| Microsoft Teams | Teams — 채널 메시지, 커넥터 |

**연결 시 동작:**
- 스프린트 시작 시 → `~~chat~~`에 시작 알림
- 기능 합격/불합격 시 → `~~chat~~`에 결과 알림
- 세션 종료 시 → `~~chat~~`에 진행 요약 발송

## 설정 방법

1. 사용하고자 하는 도구의 MCP 서버를 Claude Code에 추가합니다.
2. 이 파일의 `~~플레이스홀더~~`를 실제 도구명으로 교체합니다.
3. 각 에이전트(planner, implementer, evaluator)가 해당 도구를 활용할 수 있게 됩니다.

## 예시

Jira + GitHub + Notion + Slack 조합을 사용하는 경우:

```
~~project tracker~~ → Jira
~~source control~~ → GitHub
~~docs~~ → Notion
~~chat~~ → Slack
```
