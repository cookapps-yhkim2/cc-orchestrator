# feature_list.json 스키마

## 구조

`feature_list.json`은 JSON 배열로, 각 요소는 하나의 기능을 나타냅니다.

## 필드 정의

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `id` | string | ✅ | 고유 ID. `feat-001` 형식. 순번은 전체에서 유일해야 함 |
| `category` | string | ✅ | 기능 카테고리 (아래 목록 참조) |
| `description` | string | ✅ | 기능 설명 (한 줄) |
| `sprint` | number | ✅ | 해당 기능이 속한 스프린트 번호 |
| `steps` | string[] | ✅ | 구현 단계 목록 |
| `passes` | boolean \| null | ✅ | 평가 결과. `true`=합격, `false`=불합격, `null`=미평가 |

## 카테고리 목록

| 카테고리 | 설명 | 예시 |
|---------|------|------|
| `core` | 핵심 게임플레이 | 캐릭터 이동, 점프, 공격 |
| `ui` | 사용자 인터페이스 | 인벤토리 UI, HUD, 메뉴 |
| `system` | 게임 시스템 | 저장/로드, 씬 전환, 오브젝트 풀링 |
| `ai` | AI / NPC 행동 | 적 AI, NPC 대화, 패스파인딩 |
| `audio` | 사운드 | BGM, 효과음, 볼륨 설정 |
| `vfx` | 시각 효과 | 파티클, 셰이더, 포스트프로세싱 |
| `level` | 레벨 / 맵 | 맵 생성, 타일맵, 스폰 시스템 |
| `network` | 네트워크 / 멀티플레이 | 동기화, 매치메이킹 |
| `tool` | 에디터 도구 | 커스텀 인스펙터, 레벨 에디터 |

## 예시

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
    "passes": null
  }
]
```

## 규칙

1. `id`는 절대 중복되면 안 됩니다.
2. `steps`는 Implementer가 순서대로 따라갈 수 있도록 구체적으로 작성합니다.
3. `passes`는 Evaluator만 변경할 수 있습니다. Implementer가 임의로 `true`로 바꾸면 안 됩니다.
4. 새 기능 추가 시 `id` 번호는 항상 증가합니다 (삭제된 번호 재사용 금지).
