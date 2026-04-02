# MonoBehaviour 패턴 가이드

## 라이프사이클 순서

```
Awake()          → 스크립트 인스턴스 로드 시 (1회)
OnEnable()       → 오브젝트 활성화 시
Start()          → 첫 프레임 Update 전 (1회)
  │
  ├── FixedUpdate()   → 물리 연산 (고정 간격, 기본 0.02초)
  ├── Update()        → 매 프레임
  ├── LateUpdate()    → 모든 Update 후
  │
OnDisable()      → 오브젝트 비활성화 시
OnDestroy()      → 오브젝트 파괴 시
```

## 각 메서드의 올바른 사용

### Awake()
- 자기 자신의 컴포넌트 캐싱
- 자기 자신의 초기 상태 설정
- 다른 오브젝트에 의존하지 않는 초기화

```csharp
private Rigidbody _rb;
private Animator _animator;

private void Awake()
{
    _rb = GetComponent<Rigidbody>();
    _animator = GetComponent<Animator>();
}
```

### Start()
- 다른 오브젝트의 참조가 필요한 초기화
- Awake에서 세팅된 값에 의존하는 로직

```csharp
private void Start()
{
    // 다른 오브젝트의 Awake()가 완료된 후 실행
    var gameManager = GameManager.Instance;
    gameManager.RegisterPlayer(this);
}
```

### Update()
- 입력 처리
- 비물리 이동
- 타이머, 쿨다운
- 애니메이션 파라미터 설정

```csharp
private void Update()
{
    HandleInput();
    UpdateCooldowns();
    UpdateAnimator();
}
```

### FixedUpdate()
- Rigidbody를 사용하는 물리 연산만
- AddForce, velocity 변경

```csharp
private void FixedUpdate()
{
    _rb.AddForce(_moveDirection * _moveSpeed);
}
```

### LateUpdate()
- 카메라 팔로우
- 다른 오브젝트의 Update 결과에 의존하는 로직

```csharp
private void LateUpdate()
{
    // 플레이어의 Update 이동 후 카메라 위치 조정
    transform.position = _target.position + _offset;
}
```

## 자주 쓰는 패턴

### 1. 캐싱 패턴
```csharp
// ❌ 나쁜 예: 매 프레임 GetComponent 호출
private void Update()
{
    GetComponent<Rigidbody>().velocity = Vector3.zero;
}

// ✅ 좋은 예: Awake에서 캐싱
private Rigidbody _rb;

private void Awake()
{
    _rb = GetComponent<Rigidbody>();
}

private void Update()
{
    _rb.velocity = Vector3.zero;
}
```

### 2. 입력 분리 패턴
```csharp
// 입력 → 데이터 → 실행 분리
private Vector2 _inputDirection;

private void Update()
{
    // 입력 수집만
    _inputDirection = new Vector2(
        Input.GetAxisRaw("Horizontal"),
        Input.GetAxisRaw("Vertical")
    ).normalized;
}

private void FixedUpdate()
{
    // 물리 이동 실행
    _rb.MovePosition(_rb.position + (Vector3)_inputDirection * _moveSpeed * Time.fixedDeltaTime);
}
```

### 3. 상태 머신 패턴
```csharp
public enum PlayerState { Idle, Moving, Jumping, Attacking }

private PlayerState _currentState = PlayerState.Idle;

private void Update()
{
    switch (_currentState)
    {
        case PlayerState.Idle:
            HandleIdleState();
            break;
        case PlayerState.Moving:
            HandleMovingState();
            break;
        case PlayerState.Jumping:
            HandleJumpingState();
            break;
        case PlayerState.Attacking:
            HandleAttackingState();
            break;
    }
}

private void ChangeState(PlayerState newState)
{
    if (_currentState == newState) return;

    // 이전 상태 종료 처리
    ExitState(_currentState);
    _currentState = newState;
    // 새 상태 진입 처리
    EnterState(_currentState);
}
```

### 4. 코루틴 패턴
```csharp
// WaitForSeconds 캐싱
private WaitForSeconds _waitHalf = new WaitForSeconds(0.5f);

private IEnumerator DamageFlash()
{
    _spriteRenderer.color = Color.red;
    yield return _waitHalf;
    _spriteRenderer.color = Color.white;
}

// 코루틴 관리
private Coroutine _flashCoroutine;

public void TakeDamage()
{
    if (_flashCoroutine != null)
        StopCoroutine(_flashCoroutine);
    _flashCoroutine = StartCoroutine(DamageFlash());
}
```

## 안티패턴 (하지 말아야 할 것)

### ❌ Update에서 Find 호출
```csharp
// 매 프레임 씬 전체를 검색 → 성능 재앙
private void Update()
{
    var player = GameObject.Find("Player");
}
```

### ❌ 문자열 태그 비교
```csharp
// GC 할당 발생
if (other.gameObject.tag == "Player") { }

// ✅ CompareTag 사용
if (other.gameObject.CompareTag("Player")) { }
```

### ❌ Update에서 매 프레임 new
```csharp
// 매 프레임 GC 할당
private void Update()
{
    List<Enemy> enemies = new List<Enemy>();
}

// ✅ 필드로 선언하고 재사용
private List<Enemy> _enemies = new List<Enemy>();

private void Update()
{
    _enemies.Clear();
    // ...
}
```

### ❌ 빈 Unity 콜백 남겨두기
```csharp
// 빈 메서드도 Unity가 호출함 → 불필요한 오버헤드
private void Update() { }  // 삭제하세요!
```
