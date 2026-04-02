# ScriptableObject 가이드

## ScriptableObject란?

MonoBehaviour와 달리 씬에 붙이지 않는 데이터 컨테이너입니다.
에디터에서 에셋으로 생성하고, 여러 오브젝트가 공유할 수 있습니다.

## 언제 사용하는가?

| 상황 | MonoBehaviour | ScriptableObject |
|------|:---:|:---:|
| 씬에 존재하는 오브젝트 | ✅ | ❌ |
| 게임 설정 데이터 (스탯, 밸런스) | ❌ | ✅ |
| 여러 오브젝트가 공유하는 데이터 | △ | ✅ |
| 이벤트 채널 | ❌ | ✅ |
| 인벤토리 아이템 정의 | ❌ | ✅ |
| 런타임에 생성/파괴되는 오브젝트 | ✅ | ❌ |

## 패턴 1: 데이터 컨테이너

가장 기본적인 사용법. 게임 데이터를 에셋으로 관리합니다.

```csharp
[CreateAssetMenu(fileName = "NewWeaponData", menuName = "Game/Weapon Data")]
public class WeaponData : ScriptableObject
{
    [Header("기본 정보")]
    public string WeaponName;
    [TextArea] public string Description;
    public Sprite Icon;

    [Header("스탯")]
    public int Damage;
    public float AttackSpeed;
    public float Range;

    [Header("효과")]
    public GameObject HitEffect;
    public AudioClip HitSound;
}
```

사용하는 쪽:
```csharp
public class Weapon : MonoBehaviour
{
    [SerializeField] private WeaponData _data;

    public void Attack(IDamageable target)
    {
        target.TakeDamage(_data.Damage);
        // _data.HitEffect, _data.HitSound 등 사용
    }
}
```

### 장점
- Inspector에서 쉽게 편집
- 여러 무기 프리팹이 같은 WeaponData를 공유 가능 (메모리 절약)
- 기획자가 코드 수정 없이 밸런싱 가능

## 패턴 2: 이벤트 채널

ScriptableObject를 이벤트 중개자로 사용합니다.
오브젝트 간 직접 참조 없이 통신할 수 있습니다.

```csharp
[CreateAssetMenu(fileName = "NewGameEvent", menuName = "Game/Event Channel")]
public class GameEvent : ScriptableObject
{
    private readonly List<GameEventListener> _listeners = new List<GameEventListener>();

    public void Raise()
    {
        // 역순으로 호출 (리스너가 자신을 제거해도 안전)
        for (int i = _listeners.Count - 1; i >= 0; i--)
        {
            _listeners[i].OnEventRaised();
        }
    }

    public void RegisterListener(GameEventListener listener)
    {
        if (!_listeners.Contains(listener))
            _listeners.Add(listener);
    }

    public void UnregisterListener(GameEventListener listener)
    {
        _listeners.Remove(listener);
    }
}
```

```csharp
public class GameEventListener : MonoBehaviour
{
    [SerializeField] private GameEvent _event;
    [SerializeField] private UnityEvent _response;

    private void OnEnable() => _event.RegisterListener(this);
    private void OnDisable() => _event.UnregisterListener(this);

    public void OnEventRaised() => _response.Invoke();
}
```

### 사용 예시
- `OnPlayerDeath` 이벤트 → UI, 사운드, 카메라 흔들림이 각각 반응
- `OnScoreChanged` 이벤트 → HUD, 리더보드가 각각 반응
- 씬 간 이벤트 전달에도 유용

## 패턴 3: 런타임 데이터 세트

런타임에 변하는 데이터를 ScriptableObject로 관리합니다.

```csharp
[CreateAssetMenu(fileName = "NewRuntimeSet", menuName = "Game/Runtime Set")]
public class RuntimeSet<T> : ScriptableObject
{
    private readonly List<T> _items = new List<T>();

    public IReadOnlyList<T> Items => _items;
    public int Count => _items.Count;

    public void Add(T item)
    {
        if (!_items.Contains(item))
            _items.Add(item);
    }

    public void Remove(T item)
    {
        _items.Remove(item);
    }

    // 에디터에서 Play 종료 시 자동 초기화
    private void OnDisable()
    {
        _items.Clear();
    }
}
```

```csharp
// 적 목록 관리 예시
[CreateAssetMenu(fileName = "EnemyRuntimeSet", menuName = "Game/Enemy Runtime Set")]
public class EnemyRuntimeSet : RuntimeSet<Enemy> { }
```

### 사용 예시
- 씬의 모든 적 추적 (미니맵, AI 관리자)
- 활성 퀘스트 목록
- 현재 파티 멤버 목록

## 패턴 4: 설정 / 난이도 테이블

```csharp
[CreateAssetMenu(fileName = "DifficultySettings", menuName = "Game/Difficulty Settings")]
public class DifficultySettings : ScriptableObject
{
    [System.Serializable]
    public struct DifficultyLevel
    {
        public string Name;
        public float EnemyHealthMultiplier;
        public float EnemyDamageMultiplier;
        public float PlayerDamageMultiplier;
        public int MaxEnemyCount;
    }

    [SerializeField] private DifficultyLevel[] _levels;

    public DifficultyLevel GetLevel(int index)
    {
        return _levels[Mathf.Clamp(index, 0, _levels.Length - 1)];
    }
}
```

## 주의사항

1. **런타임 수정 주의**: ScriptableObject의 값을 런타임에 변경하면, 에디터에서는 Play 종료 후에도 변경이 유지됩니다. 빌드에서는 유지되지 않습니다.

2. **Instantiate로 복사**: 런타임에 값을 변경해야 한다면, `Instantiate()`로 복사본을 만들어 사용하세요.
```csharp
private WeaponData _runtimeData;

private void Awake()
{
    _runtimeData = Instantiate(_data); // 복사본 사용
}
```

3. **에셋 정리**: ScriptableObject 에셋은 `Assets/Data/` 또는 `Assets/ScriptableObjects/` 폴더에 정리하세요.
