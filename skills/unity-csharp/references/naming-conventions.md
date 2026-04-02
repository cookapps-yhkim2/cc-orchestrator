# 네이밍 컨벤션 & 코드 스타일

## C# 네이밍 규칙

| 대상 | 규칙 | 예시 |
|------|------|------|
| 클래스 / 구조체 | PascalCase | `PlayerController`, `InventorySlot` |
| 인터페이스 | I + PascalCase | `IDamageable`, `IInteractable` |
| public 필드 | PascalCase | `public float MoveSpeed` |
| public 프로퍼티 | PascalCase | `public int CurrentHp { get; private set; }` |
| private 필드 | _ + camelCase | `private float _moveSpeed` |
| [SerializeField] private | _ + camelCase | `[SerializeField] private float _moveSpeed` |
| 로컬 변수 | camelCase | `float currentSpeed = 0f` |
| 파라미터 | camelCase | `void TakeDamage(int damage)` |
| 상수 | UPPER_SNAKE_CASE | `const float MAX_SPEED = 10f` |
| static readonly | PascalCase | `static readonly Vector3 SpawnOffset` |
| 메서드 | PascalCase | `void HandleInput()` |
| enum | PascalCase | `enum PlayerState { Idle, Moving }` |
| 이벤트 | On + PascalCase | `public event Action OnDeath` |
| 콜백 파라미터 | on + PascalCase | `void Subscribe(Action onComplete)` |

## 파일 / 폴더 네이밍

### 스크립트 파일
- 파일명 = 클래스명 (1파일 1클래스)
- `PlayerController.cs`, `InventoryUI.cs`

### 폴더 구조 (권장)
```
Assets/
├── Scripts/
│   ├── Core/              # 핵심 시스템 (GameManager, SceneLoader)
│   ├── Player/            # 플레이어 관련
│   ├── Enemy/             # 적 관련
│   ├── UI/                # UI 스크립트
│   ├── Systems/           # 게임 시스템 (인벤토리, 퀘스트, 저장)
│   ├── Data/              # ScriptableObject 클래스 정의
│   ├── Utilities/         # 헬퍼, 확장 메서드
│   └── Interfaces/        # 인터페이스 정의
├── ScriptableObjects/     # SO 에셋 (인스턴스)
│   ├── Weapons/
│   ├── Items/
│   └── Settings/
├── Prefabs/
│   ├── Characters/
│   ├── UI/
│   └── Effects/
├── Scenes/
├── Art/
│   ├── Sprites/ (2D)
│   ├── Models/ (3D)
│   ├── Materials/
│   └── Animations/
├── Audio/
│   ├── BGM/
│   └── SFX/
└── Resources/             # Resources.Load()로 접근할 에셋만
```

## 코드 스타일

### 중괄호
Allman 스타일 (새 줄에서 시작):
```csharp
// ✅ 좋은 예
if (isAlive)
{
    TakeDamage(10);
}

// ❌ 나쁜 예 (K&R 스타일)
if (isAlive) {
    TakeDamage(10);
}
```

### SerializeField 정리
`[Header]`로 그룹을 나누고, `[Tooltip]`으로 설명을 추가합니다:
```csharp
[Header("Movement")]
[Tooltip("초당 이동 속도 (단위: m/s)")]
[SerializeField] private float _moveSpeed = 5f;

[Tooltip("점프 힘")]
[SerializeField] private float _jumpForce = 8f;

[Header("References")]
[SerializeField] private Rigidbody _rb;
[SerializeField] private Animator _animator;

[Header("Ground Check")]
[SerializeField] private Transform _groundCheckPoint;
[SerializeField] private float _groundCheckRadius = 0.2f;
[SerializeField] private LayerMask _groundLayer;
```

### 메서드 순서 (권장)
```csharp
public class Example : MonoBehaviour
{
    // 1. 상수
    private const float MAX_SPEED = 10f;

    // 2. static 필드
    public static Example Instance;

    // 3. SerializeField (Inspector 노출)
    [SerializeField] private float _speed;

    // 4. public 필드/프로퍼티
    public int Score { get; private set; }

    // 5. private 필드
    private Rigidbody _rb;

    // 6. 이벤트
    public event Action OnScoreChanged;

    // 7. Unity 콜백 (라이프사이클 순서대로)
    private void Awake() { }
    private void OnEnable() { }
    private void Start() { }
    private void Update() { }
    private void FixedUpdate() { }
    private void LateUpdate() { }
    private void OnDisable() { }
    private void OnDestroy() { }

    // 8. public 메서드
    public void TakeDamage(int damage) { }

    // 9. private 메서드
    private void HandleInput() { }

    // 10. 코루틴
    private IEnumerator DashRoutine() { yield break; }
}
```

### 리전 사용 (선택)
코드가 길어질 경우 `#region`으로 구분할 수 있습니다:
```csharp
#region Unity Callbacks
private void Awake() { }
private void Update() { }
#endregion

#region Public Methods
public void TakeDamage(int damage) { }
#endregion
```

## 자주 하는 실수

### 1. public 필드 남용
```csharp
// ❌ 아무 데서나 수정 가능
public int hp = 100;

// ✅ 프로퍼티로 보호
public int Hp { get; private set; } = 100;

// ✅ 또는 Inspector 전용으로
[SerializeField] private int _hp = 100;
```

### 2. 매직 넘버
```csharp
// ❌ 10이 뭔지 알 수 없음
if (distance < 10f) { }

// ✅ 의미가 명확
[SerializeField] private float _detectRange = 10f;
if (distance < _detectRange) { }
```

### 3. 불분명한 이름
```csharp
// ❌
float t;
int n;
void DoStuff() { }

// ✅
float elapsedTime;
int enemyCount;
void SpawnEnemyWave() { }
```
