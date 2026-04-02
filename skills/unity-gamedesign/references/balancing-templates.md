# 밸런싱 템플릿 모음

## 1. 캐릭터 스탯 테이블

### 기본 스탯 구조
| 스탯 | 설명 | 기본값 | 레벨당 증가 | 최대값 |
|------|------|--------|-----------|--------|
| HP | 체력 | 100 | +15 | 500 |
| ATK | 공격력 | 10 | +2 | 70 |
| DEF | 방어력 | 5 | +1.5 | 45 |
| SPD | 이동속도 | 5.0 | +0 | 5.0 |
| CRIT | 크리티컬 확률(%) | 5 | +0.5 | 30 |

### 데미지 공식 (예시)
```
기본 데미지 = ATK × 스킬배율 - DEF × 0.5
최종 데미지 = Max(1, 기본 데미지) × (크리티컬 ? 1.5 : 1.0)
```

## 2. 레벨업 경험치 곡선

### 공식 유형

**선형**: `필요 경험치 = base + (level × increment)`
- 간단하지만 후반에 너무 쉬워짐

**지수형**: `필요 경험치 = base × (ratio ^ level)`
- 후반 난이도 급격히 상승

**다항식 (권장)**: `필요 경험치 = base × (level ^ exponent)`
- exponent 값으로 곡선 조절 가능

### 예시 테이블 (다항식, base=100, exponent=1.5)
| 레벨 | 필요 경험치 | 누적 경험치 |
|------|-----------|-----------|
| 1→2 | 100 | 100 |
| 2→3 | 283 | 383 |
| 3→4 | 520 | 903 |
| 4→5 | 800 | 1,703 |
| 5→6 | 1,118 | 2,821 |
| 9→10 | 2,700 | 12,513 |
| 19→20 | 8,718 | 80,264 |

### ScriptableObject 설계
```csharp
[CreateAssetMenu(menuName = "Game/Level Curve")]
public class LevelCurve : ScriptableObject
{
    public float BaseExp = 100f;
    public float Exponent = 1.5f;
    public int MaxLevel = 50;

    public int GetRequiredExp(int currentLevel)
    {
        return Mathf.RoundToInt(BaseExp * Mathf.Pow(currentLevel, Exponent));
    }

    public int GetTotalExpForLevel(int targetLevel)
    {
        int total = 0;
        for (int i = 1; i < targetLevel; i++)
            total += GetRequiredExp(i);
        return total;
    }
}
```

## 3. 드롭 테이블

### 가중치 기반 드롭
| 아이템 | 등급 | 가중치 | 확률(%) |
|--------|------|--------|---------|
| 체력 포션(소) | Common | 40 | 40% |
| 체력 포션(중) | Common | 20 | 20% |
| 마나 포션(소) | Common | 20 | 20% |
| 장비 상자 | Uncommon | 10 | 10% |
| 희귀 장비 상자 | Rare | 7 | 7% |
| 전설 장비 상자 | Legendary | 3 | 3% |
| **합계** | | **100** | **100%** |

### 등급별 확률 가이드라인
| 등급 | 색상 | 드롭 확률 범위 | 설명 |
|------|------|--------------|------|
| Common | 흰색 | 40-60% | 기본 소모품 |
| Uncommon | 초록 | 20-30% | 약간 좋은 아이템 |
| Rare | 파랑 | 10-15% | 유용한 장비 |
| Epic | 보라 | 3-8% | 강력한 장비 |
| Legendary | 주황 | 0.5-3% | 최고급 장비 |

### ScriptableObject 설계
```csharp
[CreateAssetMenu(menuName = "Game/Drop Table")]
public class DropTable : ScriptableObject
{
    [System.Serializable]
    public struct DropEntry
    {
        public GameObject ItemPrefab;
        public int Weight;
    }

    public DropEntry[] Entries;

    public GameObject Roll()
    {
        int totalWeight = 0;
        foreach (var entry in Entries)
            totalWeight += entry.Weight;

        int roll = Random.Range(0, totalWeight);
        int cumulative = 0;

        foreach (var entry in Entries)
        {
            cumulative += entry.Weight;
            if (roll < cumulative)
                return entry.ItemPrefab;
        }

        return null;
    }
}
```

## 4. 적 밸런싱 테이블

### 적 등급 시스템
| 등급 | HP 배율 | ATK 배율 | 보상 배율 | 등장 시기 |
|------|--------|---------|----------|----------|
| 졸개 (Minion) | 0.5x | 0.5x | 0.5x | 초반~ |
| 일반 (Normal) | 1.0x | 1.0x | 1.0x | 초반~ |
| 정예 (Elite) | 2.5x | 1.8x | 3.0x | 중반~ |
| 보스 (Boss) | 10x | 2.5x | 10x | 스테이지 끝 |
| 레이드 보스 | 50x | 3.0x | 30x | 엔드콘텐츠 |

### 지역별 스케일링 공식
```
적 HP = 기본HP × 등급배율 × (1 + 지역레벨 × 0.15)
적 ATK = 기본ATK × 등급배율 × (1 + 지역레벨 × 0.12)
```

## 5. 경제 밸런싱

### 골드 획득/소비 균형
| 항목 | 레벨 1 | 레벨 10 | 레벨 20 | 비고 |
|------|--------|---------|---------|------|
| 일반 몬스터 처치 | 5골드 | 25골드 | 80골드 | 주요 수입원 |
| 퀘스트 보상 | 50골드 | 300골드 | 1000골드 | 보조 수입원 |
| 체력 포션 구매 | 10골드 | 50골드 | 150골드 | 기본 소비 |
| 장비 구매 | 100골드 | 800골드 | 3000골드 | 주요 소비 |
| 강화 비용 | 50골드 | 500골드 | 2000골드 | 골드 싱크 |

### 밸런싱 원칙
- 플레이어가 **몬스터 20마리** 정도 잡으면 포션 1개 살 수 있어야 함
- **장비 구매**는 30분~1시간 파밍이 필요하도록 설정
- 레벨업 시 소비가 수입보다 약간 빠르게 증가 (인플레이션 방지)

## 사용 가이드

1. 위 템플릿을 그대로 사용하지 말고, 게임에 맞게 수정하세요.
2. 수치는 반드시 **플레이테스트**로 검증해야 합니다.
3. 공식의 파라미터는 ScriptableObject로 만들어 에디터에서 조정 가능하게 하세요.
4. 밸런싱은 반복 작업입니다 — 첫 버전에서 완벽할 필요 없습니다.
