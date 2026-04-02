# Unity Orchestrator

Unity C# 게임 개발을 위한 멀티 에이전트 오케스트레이션 플러그인입니다.

GAN 아키텍처에서 영감을 받은 Planner → Implementer → Evaluator 루프로 동작합니다. 한 에이전트가 만들고, 다른 에이전트가 평가하여 "자기 작업을 스스로 칭찬하는" 문제를 방지합니다.

## 동작 방식

```
[사용자 요구사항]
       │
       ▼
  ┌─────────┐     스프린트 계획 + 기능 스펙
  │ Planner │ ──→ .unity-orc/plans/*.md
  └─────────┘
       │
       ▼
  ┌──────────────┐     C# 코드 + git 커밋
  │ Implementer  │ ──→ .unity-orc/unity-progress.md
  └──────────────┘
       │
       ▼
  ┌───────────┐     합격 → 다음 기능으로
  │ Evaluator │ ──→
  └───────────┘     불합격 → Implementer에게 피드백
```

## 설치

```bash
# GitHub에서 직접 설치
claude plugin add https://github.com/cookapps-yhkim2/unity-orchestrator
```

## 빠른 시작

1. **프로젝트 초기화**:
   > "프로젝트 초기화해줘"

2. **스프린트 계획**:
   > "스프린트 계획 세워줘" / "다음에 뭐 만들지 정하자"

3. **구현** → Implementer가 Unity 베스트 프랙티스에 따라 C# 코드 작성

4. **평가** → Evaluator가 합격 조건 기준으로 검증

5. **반복** → 피드백 반영 후 다음 기능으로

## 구성 요소

### 스킬 (Skills)

| 스킬 | 역할 | 트리거 예시 |
|------|------|------------|
| **unity-init** | 프로젝트 초기화, `.unity-orc/` 세팅 | "프로젝트 초기화해줘" |
| **unity-sprint** | 스프린트 계약 협상 및 관리 | "스프린트 계획 세워줘" |
| **unity-csharp** | Unity C# 코딩 가이드, 패턴 | "C# 코드 작성해줘" |
| **unity-gamedesign** | 게임 디자인 문서화 (밸런싱, AI) | "밸런싱 테이블 만들어줘" |

### 에이전트 (Agents)

| 에이전트 | 역할 | 모델 | 색상 |
|---------|------|------|------|
| **Planner** | 요구사항 분석 → 스프린트 계획 생성 | claude-opus-4-6 | cyan |
| **Implementer** | C# 코드 작성 → git 커밋 | inherit | green |
| **Evaluator** | 구현 검증 → 합격/불합격 리포트 | inherit | yellow |

### 훅 (Hooks)

| 이벤트 | 동작 |
|--------|------|
| **SessionStart** | 프로젝트 컨텍스트 자동 로드 (진행상황, 기능목록, git log) |
| **PreToolUse** | `.cs` 파일 작성 시 Unity 코딩 컨벤션 검사 |
| **Stop** | 진행 상황 업데이트 및 커밋 리마인더 |

## 파일 기반 상태 관리

모든 에이전트 간 통신은 `.unity-orc/` 디렉토리의 파일로 이루어집니다:

```
.unity-orc/
├── unity-progress.md       # 전체 진행 상황 추적
├── feature_list.json       # 기능 목록 + 완료 상태
├── plans/                  # 스프린트 계획서
│   └── open-questions.md   # 미결 사항
└── evaluations/            # 평가 리포트
```

## 외부 도구 연결

`CONNECTORS.md`를 통해 사용하는 도구를 연결할 수 있습니다:

| 카테고리 | 플레이스홀더 | 옵션 |
|---------|------------|------|
| 프로젝트 트래커 | `~~project tracker~~` | Jira, Linear, Asana, Trello |
| 소스 컨트롤 | `~~source control~~` | GitHub, GitLab, Bitbucket |
| 문서 | `~~docs~~` | Confluence, Notion, Obsidian |
| 채팅 | `~~chat~~` | Slack, Discord, Microsoft Teams |

## 핵심 원칙

- **GAN 영감 평가**: Evaluator는 Implementer의 자기 평가를 절대 신뢰하지 않습니다
- **파일 기반 상태**: 모든 상태는 `.unity-orc/`에 파일로 저장되어 세션 간 유지됩니다
- **스프린트 계약**: 코딩 전에 "뭘 만들지, 어떻게 검증할지" 합의합니다
- **한 번에 한 기능씩**: 작은 단위, 자주 커밋

## 워크플로우 예시: 인벤토리 시스템 만들기

```
사용자: "인벤토리 시스템 만들어줘"

1. Planner가 코드베이스를 분석하고 스프린트 계획 작성
   → feat-001: 인벤토리 데이터 모델
   → feat-002: 인벤토리 UI 그리드
   → feat-003: 아이템 드래그 앤 드롭

2. 사용자가 계획을 검토하고 승인

3. Implementer가 feat-001부터 순서대로 구현
   → InventoryData.cs, ItemData.cs (ScriptableObject) 생성
   → git commit: "[Sprint-001] feat-001: 인벤토리 데이터 모델 구현"

4. Evaluator가 합격 조건 기반으로 검증
   → ✅ 합격: feat-001 완료, feat-002로 이동
   → ❌ 불합격: 구체적 피드백 → Implementer가 수정 후 재평가
```

## 라이선스

MIT
