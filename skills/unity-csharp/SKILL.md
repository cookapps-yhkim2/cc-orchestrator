# unity-csharp

Unity C# 코딩 가이드 스킬입니다.
MonoBehaviour 패턴, ScriptableObject, 네이밍 컨벤션, 성능 베스트 프랙티스를 제공합니다.

## 트리거

- "C# 코드 작성해줘"
- "MonoBehaviour 어떻게 써?"
- "ScriptableObject 사용법"
- "Unity 코딩 컨벤션"
- "성능 최적화 어떻게?"

## 참조 문서

이 스킬은 3개의 레퍼런스 문서를 포함합니다. 코드를 작성할 때 반드시 참고하세요:

1. **`references/monobehaviour-patterns.md`** — MonoBehaviour 라이프사이클, 자주 쓰는 패턴, 안티패턴
2. **`references/scriptableobject-guide.md`** — ScriptableObject 활용법, 데이터 컨테이너, 이벤트 시스템
3. **`references/naming-conventions.md`** — 네이밍 규칙, 폴더 구조, 코드 스타일

## 코드 작성 원칙

### 1. 읽기 쉬운 코드 우선
- 주니어 개발자도 이해할 수 있는 코드를 작성합니다.
- 복잡한 로직에는 주석을 추가합니다.
- 한 메서드는 하나의 역할만 합니다.

### 2. Unity 생태계 존중
- Unity의 컴포넌트 기반 아키텍처를 따릅니다.
- Inspector에서 설정할 수 있는 것은 `[SerializeField]`로 노출합니다.
- `[Header]`, `[Tooltip]`, `[Range]` 어트리뷰트로 Inspector를 정리합니다.

### 3. 방어적 프로그래밍
- null 체크를 습관화합니다.
- `TryGetComponent<T>()`를 `GetComponent<T>()` 대신 사용합니다 (Unity 2019.2+).
- public API에는 파라미터 유효성 검사를 추가합니다.

### 4. 성능 의식
- `Update()`에서 할당(new)을 최소화합니다.
- `GetComponent<T>()`는 `Awake()`에서 캐싱합니다.
- 문자열 비교 대신 `CompareTag()`를 사용합니다.
- 매 프레임 실행되지 않아도 되는 로직은 코루틴이나 이벤트로 분리합니다.

## 코드 작성 시 체크리스트

코드를 작성하거나 리뷰할 때 아래 항목을 확인하세요:

- [ ] 네이밍 컨벤션을 따르는가? (`references/naming-conventions.md`)
- [ ] MonoBehaviour 라이프사이클 순서가 올바른가? (Awake → OnEnable → Start → Update)
- [ ] `[SerializeField]`로 Inspector 노출이 적절한가?
- [ ] `Update()`에 불필요한 할당이 없는가?
- [ ] null 체크가 필요한 곳에 있는가?
- [ ] 매직 넘버 대신 상수나 `[SerializeField]` 필드를 사용하는가?
- [ ] 에디터 전용 코드는 `#if UNITY_EDITOR`로 감쌌는가?

## 자주 사용하는 코드 패턴

### 싱글톤 (간단 버전)
```csharp
public class GameManager : MonoBehaviour
{
    public static GameManager Instance { get; private set; }

    private void Awake()
    {
        if (Instance != null && Instance != this)
        {
            Destroy(gameObject);
            return;
        }
        Instance = this;
        DontDestroyOnLoad(gameObject);
    }
}
```

### 오브젝트 풀링 (기본)
```csharp
public class ObjectPool : MonoBehaviour
{
    [SerializeField] private GameObject _prefab;
    [SerializeField] private int _initialSize = 10;

    private Queue<GameObject> _pool = new Queue<GameObject>();

    private void Awake()
    {
        for (int i = 0; i < _initialSize; i++)
        {
            var obj = Instantiate(_prefab);
            obj.SetActive(false);
            _pool.Enqueue(obj);
        }
    }

    public GameObject Get()
    {
        var obj = _pool.Count > 0 ? _pool.Dequeue() : Instantiate(_prefab);
        obj.SetActive(true);
        return obj;
    }

    public void Return(GameObject obj)
    {
        obj.SetActive(false);
        _pool.Enqueue(obj);
    }
}
```

### 이벤트 기반 통신
```csharp
// UnityEvent 방식 (Inspector에서 연결 가능)
public class Health : MonoBehaviour
{
    [SerializeField] private int _maxHp = 100;
    private int _currentHp;

    public UnityEvent<int, int> OnHpChanged; // current, max
    public UnityEvent OnDeath;

    public void TakeDamage(int damage)
    {
        _currentHp = Mathf.Max(0, _currentHp - damage);
        OnHpChanged?.Invoke(_currentHp, _maxHp);

        if (_currentHp <= 0)
            OnDeath?.Invoke();
    }
}
```
