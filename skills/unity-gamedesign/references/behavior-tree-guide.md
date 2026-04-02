# AI 행동트리 가이드

## 행동트리란?

AI의 의사결정을 트리 구조로 표현하는 패턴입니다.
각 노드는 `Success`, `Failure`, `Running` 중 하나를 반환합니다.

### 상태 머신 vs 행동트리
| 항목 | 상태 머신 (FSM) | 행동트리 (BT) |
|------|:---:|:---:|
| 단순한 AI | ✅ 적합 | △ 과도할 수 있음 |
| 복잡한 AI | ❌ 상태 폭발 | ✅ 적합 |
| 확장성 | 어려움 | 좋음 |
| 디버깅 | 쉬움 | 보통 |
| 추천 대상 | 2-4개 상태 | 5개+ 상태 |

## 노드 타입

### 1. Composite (복합 노드) — 자식 노드들을 관리

#### Sequence (순차 실행) →
모든 자식이 Success면 Success. 하나라도 Failure면 즉시 Failure.
```
[Sequence] →
  ├── 적이 사거리 안에 있는가? (조건)
  ├── 공격 쿨다운이 끝났는가? (조건)
  └── 공격 실행 (행동)
```
**비유**: AND 연산. "A 그리고 B 그리고 C 모두 해라"

#### Selector (선택 실행) ?
자식을 순서대로 시도. 하나라도 Success면 즉시 Success.
```
[Selector] ?
  ├── HP < 30%면 도주 (우선순위 1)
  ├── 적이 사거리 안이면 공격 (우선순위 2)
  └── 순찰 (우선순위 3 — 기본 행동)
```
**비유**: OR 연산. "A를 해보고, 안 되면 B, 그래도 안 되면 C"

#### Parallel (병렬 실행) ⇉
모든 자식을 동시에 실행.
```
[Parallel] ⇉
  ├── 목표 지점으로 이동
  └── 주변 위협 감지
```

### 2. Decorator (데코레이터) — 자식 하나를 감싸서 동작 변경

| 데코레이터 | 동작 | 예시 |
|-----------|------|------|
| Inverter | 결과를 반전 (Success↔Failure) | "적이 없으면" |
| Repeater | N회 또는 무한 반복 | "3번 공격 반복" |
| UntilFail | Failure 나올 때까지 반복 | "적이 죽을 때까지 공격" |
| Cooldown | 쿨다운 시간 동안 실행 차단 | "스킬 3초 쿨다운" |
| TimeLimit | 시간 초과 시 Failure | "5초 안에 도달 못하면 포기" |

### 3. Leaf (리프 노드) — 실제 동작 수행

#### Condition (조건)
```
IsPlayerInRange(float range)     → 플레이어가 범위 안에 있는가?
IsHealthBelow(float percent)     → HP가 N% 이하인가?
HasLineOfSight()                 → 시야가 확보되어 있는가?
IsTargetAlive()                  → 대상이 살아있는가?
```

#### Action (행동)
```
MoveTo(Transform target)         → 대상 위치로 이동
Attack(Transform target)         → 대상 공격
Flee(float distance)             → 반대 방향으로 도주
Patrol(Transform[] waypoints)    → 웨이포인트 순찰
Wait(float seconds)              → 대기
PlayAnimation(string name)       → 애니메이션 재생
```

## 예시: 기본 적 AI

```
[Selector] Root
  │
  ├── [Sequence] 도주 행동
  │     ├── [Condition] HP < 20%?
  │     └── [Action] 도주
  │
  ├── [Sequence] 공격 행동
  │     ├── [Condition] 플레이어가 공격 사거리 안?
  │     ├── [Condition] 쿨다운 완료?
  │     └── [Action] 공격
  │
  ├── [Sequence] 추적 행동
  │     ├── [Condition] 플레이어가 감지 범위 안?
  │     ├── [Condition] 시야 확보?
  │     └── [Action] 플레이어에게 이동
  │
  └── [Action] 순찰 (기본 행동)
```

## 예시: 보스 AI (페이즈 전환)

```
[Selector] Boss Root
  │
  ├── [Sequence] 페이즈 3 (HP < 30%)
  │     ├── [Condition] HP < 30%?
  │     ├── [Action] 분노 버프 활성화
  │     └── [Selector] 분노 패턴
  │           ├── [Sequence] 광역 공격
  │           │     ├── [Cooldown: 5초]
  │           │     └── [Action] 광역 공격
  │           └── [Action] 난사 공격
  │
  ├── [Sequence] 페이즈 2 (HP < 60%)
  │     ├── [Condition] HP < 60%?
  │     └── [Selector] 강화 패턴
  │           ├── [Sequence] 소환
  │           │     ├── [Cooldown: 10초]
  │           │     └── [Action] 부하 소환
  │           ├── [Action] 돌진 공격
  │           └── [Action] 기본 공격
  │
  └── [Selector] 페이즈 1 (기본)
        ├── [Sequence] 원거리 공격
        │     ├── [Condition] 거리 > 5m?
        │     └── [Action] 투사체 발사
        ├── [Action] 기본 근접 공격
        └── [Action] 대기
```

## Unity 구현 패턴

### 간단한 구현 (인터페이스 기반)

```csharp
// 노드 인터페이스
public enum NodeState { Success, Failure, Running }

public interface IBTNode
{
    NodeState Evaluate();
}

// Sequence 노드
public class Sequence : IBTNode
{
    private readonly List<IBTNode> _children;

    public Sequence(List<IBTNode> children)
    {
        _children = children;
    }

    public NodeState Evaluate()
    {
        foreach (var child in _children)
        {
            var state = child.Evaluate();
            if (state != NodeState.Success)
                return state; // Failure 또는 Running이면 즉시 반환
        }
        return NodeState.Success;
    }
}

// Selector 노드
public class Selector : IBTNode
{
    private readonly List<IBTNode> _children;

    public Selector(List<IBTNode> children)
    {
        _children = children;
    }

    public NodeState Evaluate()
    {
        foreach (var child in _children)
        {
            var state = child.Evaluate();
            if (state != NodeState.Failure)
                return state; // Success 또는 Running이면 즉시 반환
        }
        return NodeState.Failure;
    }
}

// 조건 노드 예시
public class IsPlayerInRange : IBTNode
{
    private readonly Transform _self;
    private readonly float _range;

    public IsPlayerInRange(Transform self, float range)
    {
        _self = self;
        _range = range;
    }

    public NodeState Evaluate()
    {
        var player = GameObject.FindWithTag("Player");
        if (player == null) return NodeState.Failure;

        float distance = Vector3.Distance(_self.position, player.transform.position);
        return distance <= _range ? NodeState.Success : NodeState.Failure;
    }
}
```

### 트리 조립 예시
```csharp
public class EnemyAI : MonoBehaviour
{
    [SerializeField] private float _detectRange = 10f;
    [SerializeField] private float _attackRange = 2f;

    private IBTNode _root;

    private void Start()
    {
        _root = new Selector(new List<IBTNode>
        {
            // 공격
            new Sequence(new List<IBTNode>
            {
                new IsPlayerInRange(transform, _attackRange),
                new AttackAction(this)
            }),
            // 추적
            new Sequence(new List<IBTNode>
            {
                new IsPlayerInRange(transform, _detectRange),
                new ChaseAction(this)
            }),
            // 순찰
            new PatrolAction(this)
        });
    }

    private void Update()
    {
        _root.Evaluate();
    }
}
```

## 설계 팁

1. **Selector의 자식은 우선순위 순으로 배치**: 위에 있을수록 먼저 시도됨
2. **기본 행동을 항상 마지막에**: 순찰이나 대기를 Selector 맨 아래에 둠
3. **쿨다운은 Decorator로**: 행동 자체에 넣지 말고 Decorator로 감싸기
4. **Running 상태 주의**: 이동처럼 여러 프레임에 걸치는 행동은 Running 반환
5. **복잡해지면 서브트리로 분리**: 한 트리가 너무 깊으면 서브트리로 나누기
