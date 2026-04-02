# Unity Orchestrator — Claude 컨텍스트

이 프로젝트는 Unity C# 게임 개발을 위한 Multi-Agent Orchestrator 플러그인입니다.

## 아키텍처 개요

Planner → Implementer → Evaluator의 GAN 영감 루프로 동작합니다.

- **Planner** (claude-opus-4-6): 요구사항 분석 → 스프린트 계획 생성
- **Implementer** (inherit): C# 코드 작성 → git 커밋
- **Evaluator** (inherit): 합격 조건 기반 검증 → 합격/불합격 판정

## 파일 기반 상태 관리

에이전트 간 통신은 `.unity-orc/` 디렉토리의 파일로 수행됩니다.

```
.unity-orc/
├── unity-progress.md       # 전체 진행 상황
├── feature_list.json       # 기능 목록 + 완료 상태
├── plans/                  # 스프린트 계획서
│   └── open-questions.md   # 미결 사항
└── evaluations/            # 평가 리포트
```

## 워크플로우

1. 사용자가 요구사항을 전달
2. Planner가 코드베이스를 분석하고 스프린트 계획 작성
3. 사용자 승인 후 Implementer가 C# 코드 구현
4. Evaluator가 합격 조건 기준으로 검증
5. 불합격 시 → Implementer가 피드백 반영 후 재구현
6. 합격 시 → 다음 기능 또는 스프린트로 진행

## 핵심 규칙

- **Evaluator는 구현자의 자기 평가를 신뢰하지 않음** (GAN 원칙)
- **모든 상태는 파일로 기록** (세션 간 컨텍스트 유지)
- **스프린트 계약 = 구현 전 합의** (모호함 → 체크리스트)
- **한 번에 한 기능씩 구현** (작은 단위, 자주 커밋)

## 스킬 목록

| 스킬 | 역할 |
|------|------|
| unity-init | 프로젝트 초기화, .unity-orc/ 환경 세팅 |
| unity-sprint | 스프린트 계약 협상 및 관리 |
| unity-csharp | Unity C# 코딩 가이드 및 패턴 |
| unity-gamedesign | 게임 디자인 문서화 (밸런싱, AI) |

## Unity C# 코딩 컨벤션 요약

- 클래스: PascalCase / private 필드: _camelCase
- MonoBehaviour 라이프사이클 순서 준수
- Update()에서 GetComponent 금지 → Awake()에서 캐싱
- [SerializeField]로 Inspector 노출, [Header]로 정리
- CompareTag() 사용, Find() 최소화
