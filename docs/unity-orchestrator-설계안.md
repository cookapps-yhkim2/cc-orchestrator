# Unity Multi-Agent Orchestrator Plugin 설계안

## 설계 원칙 (Anthropic 블로그 기반)

### 1. Planner → Implementer → Evaluator (GAN 영감 루프)
에이전트가 자기 작업을 스스로 평가하면 "자신의 작업을 자신있게 칭찬하는" 경향이 있음.
반드시 **별도의 평가자(Evaluator)**가 검증해야 함.

### 2. 파일 기반 상태 관리
에이전트 간 통신은 파일로 수행. `.unity-orc/` 디렉토리 하위에 plans, progress, feature list 등을 저장.
> "이전 시프트를 기억 못하는 엔지니어가 교대근무하는 상황"을 해결하는 핵심

### 3. 스프린트 계약 패턴
구현 전에 "무엇을 만들지, 어떻게 검증할지"를 협상.
모호한 요구사항 → 구체적인 체크리스트로 변환.

---

## 컴포넌트 구성

### Skills (4개)

| 스킬 | 역할 | 트리거 예시 |
|------|------|------------|
| **unity-init** | 프로젝트 초기화. `.unity-orc/` 디렉토리, feature_list.json, unity-progress.md 생성. 에이전트 작업 환경 세팅 | "프로젝트 초기화해줘", "새 Unity 프로젝트 세팅" |
| **unity-sprint** | 스프린트 계약 협상. Planner↔Implementer 간 "뭐 만들지, 어떻게 검증할지" 합의. `.unity-orc/plans/*.md`에 저장 | "스프린트 계획 세워줘", "다음에 뭐 만들지 정하자" |
| **unity-csharp** | Unity C# 코딩 가이드. MonoBehaviour 패턴, ScriptableObject, 네이밍 컨벤션, 성능 베스트 프랙티스 | "C# 코드 작성해줘", "MonoBehaviour 어떻게 써?" |
| **unity-gamedesign** | 게임 디자인 문서화. 밸런싱 테이블, 시스템 설계, AI 행동트리 템플릿 | "밸런싱 테이블 만들어줘", "AI 행동트리 설계해줘" |

### Agents (3개 - GAN 영감 루프)

| 에이전트 | 역할 | 모델 | 색상 | 입력 → 출력 |
|---------|------|------|------|------------|
| **planner** | 요구사항 분석 → 상세 스펙/스프린트 계획 생성. 코드베이스 팩트는 직접 조사 (유저에게 묻지 않음) | claude-opus-4-6 | cyan | 사용자 요구사항 → `.unity-orc/plans/*.md` + `feature_list.json` |
| **implementer** | C# 코드 작성. 한 번에 한 기능씩, git 커밋으로 진행 추적 | inherit | green | 스프린트 계약 → C# 코드 + git 커밋 + `unity-progress.md` 업데이트 |
| **evaluator** | 구현된 기능 검증. 스프린트 계약 기준으로 합격/불합격 판정. 자체 변호 금지 | inherit | yellow | 구현 결과 + 스프린트 계약 → 합격/불합격 리포트 |

### Hooks

| 이벤트 | 동작 |
|--------|------|
| **SessionStart** | `.unity-orc/unity-progress.md` + `feature_list.json` + `git log --oneline -20` 자동 로드하여 컨텍스트 제공 |
| **PreToolUse** (Write\|Edit) | Unity C# 코딩 컨벤션 준수 여부 검사 (`.cs` 파일 대상) |
| **Stop** | `unity-progress.md` 자동 업데이트 리마인더 |

### MCP Servers: 0개
필요시 나중에 추가 가능

### CONNECTORS.md (외부 배포용)
GitHub 레포로 배포하므로, 사용자마다 다른 외부 도구를 `~~` 플레이스홀더로 추상화

| 카테고리 | 플레이스홀더 | 옵션 |
|---------|------------|------|
| 프로젝트 트래커 | `~~project tracker` | Jira, Linear, Asana, Trello |
| 소스 컨트롤 | `~~source control` | GitHub, GitLab, Bitbucket |
| 문서 | `~~docs` | Confluence, Notion, Obsidian |
| 채팅 | `~~chat` | Slack, Discord, Microsoft Teams |

---

## 워크플로우 다이어그램

```
[사용자 요구사항]
       │
       ▼
  ┌─────────┐     .unity-orc/plans/*.md
  │ Planner │ ──→ + feature_list.json
  └─────────┘
       │
       ▼
  ┌──────────────┐     C# 코드 + git 커밋
  │ Implementer  │ ──→ + unity-progress.md 업데이트
  └──────────────┘
       │
       ▼
  ┌───────────┐     합격 → 다음 기능으로
  │ Evaluator │ ──→
  └───────────┘     불합격 → Implementer에게 피드백
       │
       ▼ (불합격 시)
  ┌──────────────┐
  │ Implementer  │  ← 피드백 반영 후 재구현
  └──────────────┘
```

---

## 파일 기반 상태 관리

### 프로젝트 내 `.unity-orc/` 디렉토리 구조
```
.unity-orc/
├── unity-progress.md          # 전체 진행 상황 추적
├── feature_list.json          # 기능 목록 + 완료 상태
├── plans/                     # 스프린트 계획서
│   ├── sprint-001.md
│   ├── sprint-002.md
│   └── open-questions.md      # 미결 사항 추적
└── evaluations/               # 평가 리포트
    ├── sprint-001-eval.md
    └── sprint-002-eval.md
```

### unity-progress.md (예시)
```markdown
# Unity Project Progress

## 현재 스프린트: Sprint 3 - 인벤토리 시스템

### 최근 완료
- [Sprint 2] 캐릭터 이동 시스템 구현 완료
- [Sprint 2] 카메라 팔로우 시스템 구현 완료

### 현재 작업 중
- 인벤토리 UI 레이아웃 (진행률: 60%)

### 다음 작업
- 아이템 드래그 앤 드롭
- 인벤토리 저장/로드

### 알려진 이슈
- 카메라가 벽을 관통하는 버그 (Sprint 4에서 수정 예정)
```

### feature_list.json (예시)
```json
[
  {
    "id": "feat-001",
    "category": "core",
    "description": "캐릭터 WASD 이동 + 점프",
    "sprint": 1,
    "steps": [
      "PlayerController.cs 생성",
      "Rigidbody 기반 이동 구현",
      "Space 키 점프 구현",
      "지면 감지 레이캐스트 추가"
    ],
    "passes": true
  },
  {
    "id": "feat-002",
    "category": "ui",
    "description": "인벤토리 UI 그리드 표시",
    "sprint": 3,
    "steps": [
      "InventoryUI.cs 생성",
      "그리드 레이아웃 구현",
      "아이템 아이콘 표시",
      "슬롯 하이라이트 구현"
    ],
    "passes": false
  }
]
```

---

## GitHub 레포지토리 배포 계획

### 레포지토리 구조 (oh-my-claudecode 패턴 참고)
```
unity-orchestrator/
├── .claude-plugin/
│   └── plugin.json              # 플러그인 매니페스트
├── skills/
│   ├── unity-init/
│   │   ├── SKILL.md
│   │   └── references/
│   │       ├── feature-list-schema.md
│   │       └── progress-template.md
│   ├── unity-sprint/
│   │   ├── SKILL.md
│   │   └── references/
│   │       └── sprint-contract-template.md
│   ├── unity-csharp/
│   │   ├── SKILL.md
│   │   └── references/
│   │       ├── monobehaviour-patterns.md
│   │       ├── scriptableobject-guide.md
│   │       └── naming-conventions.md
│   └── unity-gamedesign/
│       ├── SKILL.md
│       └── references/
│           ├── balancing-templates.md
│           └── behavior-tree-guide.md
├── agents/
│   ├── planner.md
│   ├── implementer.md
│   └── evaluator.md
├── hooks/
│   └── hooks.json
├── CONNECTORS.md
├── CLAUDE.md                    # Claude에게 프로젝트 컨텍스트 제공
├── README.md
├── README.ko.md                 # 한국어 README
├── CHANGELOG.md
└── LICENSE                      # MIT
```

### plugin.json
```json
{
  "name": "unity-orchestrator",
  "version": "0.1.0",
  "description": "Multi-agent orchestration system for Unity C# projects — Planner/Implementer/Evaluator loop with sprint contracts and file-based state management",
  "author": {
    "name": "Tora"
  },
  "repository": "https://github.com/<your-username>/unity-orchestrator",
  "license": "MIT",
  "keywords": [
    "claude-code",
    "plugin",
    "unity",
    "csharp",
    "multi-agent",
    "orchestration",
    "game-development"
  ],
  "skills": "./skills/",
  "agents": "./agents/"
}
```

### 설치 방법 (사용자 관점)
```bash
# 방법 1: 마켓플레이스에서 설치
claude plugin marketplace add https://github.com/<your-username>/unity-orchestrator
claude plugin install unity-orchestrator

# 방법 2: GitHub에서 직접 설치
claude plugin add https://github.com/<your-username>/unity-orchestrator
```

### README.md에 포함할 내용
1. **개요**: 플러그인이 하는 일, 대상 사용자 (Unity C# 개발자, 소규모 팀)
2. **설치 방법**: `claude plugin add` 또는 마켓플레이스 설치
3. **빠른 시작**: 프로젝트 초기화 → 스프린트 계획 → 구현 → 평가 사이클
4. **컴포넌트 설명**: 각 Skill, Agent, Hook의 역할과 트리거
5. **커스터마이즈**: CONNECTORS.md를 통한 외부 도구 연결
6. **워크플로우 예시**: 실제 사용 시나리오 (예: "인벤토리 시스템 만들기")
7. **기여 가이드**: PR, 이슈 작성 가이드라인
