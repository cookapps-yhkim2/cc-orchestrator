#!/bin/bash
# PreToolUse Hook (Write|Edit on *.cs)
# C# 파일 작성/수정 시 Unity 코딩 컨벤션 기본 검사를 수행합니다.
#
# 이 훅은 에이전트에게 리마인더를 제공하는 역할입니다.
# 실제 컴파일 검증은 Unity Editor에서 수행해야 합니다.

FILE_PATH="$1"

# .cs 파일이 아니면 무시
if [[ "$FILE_PATH" != *.cs ]]; then
    exit 0
fi

echo "🔍 Unity C# 컨벤션 체크: $FILE_PATH"
echo ""

WARNINGS=0

# 1. Update()에서 GetComponent 호출 검사
if grep -n "void Update\|void FixedUpdate\|void LateUpdate" "$FILE_PATH" > /dev/null 2>&1; then
    # Update 메서드 내부에서 GetComponent 호출 패턴 감지 (간이 검사)
    if grep -n "GetComponent" "$FILE_PATH" > /dev/null 2>&1; then
        echo "⚠️ GetComponent 호출이 감지되었습니다. Update() 내부에서 사용 중이라면 Awake()에서 캐싱하세요."
        WARNINGS=$((WARNINGS + 1))
    fi
fi

# 2. Find / FindObjectOfType 사용 검사
if grep -n "GameObject\.Find\|FindObjectOfType\|FindObjectsOfType" "$FILE_PATH" > /dev/null 2>&1; then
    echo "⚠️ Find/FindObjectOfType 호출이 감지되었습니다. Inspector 참조 또는 의존성 주입을 권장합니다."
    WARNINGS=$((WARNINGS + 1))
fi

# 3. public 필드 (프로퍼티가 아닌) 검사
if grep -n "^[[:space:]]*public [a-zA-Z<>\[\]]*[[:space:]][a-z]" "$FILE_PATH" > /dev/null 2>&1; then
    echo "⚠️ public 필드가 소문자로 시작합니다. PascalCase를 사용하거나, [SerializeField] private으로 변경하세요."
    WARNINGS=$((WARNINGS + 1))
fi

# 4. 빈 Unity 콜백 검사
if grep -Pzo "void (Update|Start|Awake|FixedUpdate|LateUpdate)\(\)[^{]*\{[[:space:]]*\}" "$FILE_PATH" > /dev/null 2>&1; then
    echo "⚠️ 빈 Unity 콜백이 감지되었습니다. 사용하지 않는 콜백은 삭제하세요."
    WARNINGS=$((WARNINGS + 1))
fi

# 5. 문자열 태그 비교 검사
if grep -n '\.tag ==' "$FILE_PATH" > /dev/null 2>&1; then
    echo "⚠️ .tag == 문자열 비교가 감지되었습니다. CompareTag()를 사용하세요."
    WARNINGS=$((WARNINGS + 1))
fi

if [ $WARNINGS -eq 0 ]; then
    echo "✅ 기본 컨벤션 검사를 통과했습니다."
else
    echo ""
    echo "📌 총 $WARNINGS개의 경고가 있습니다. 확인 후 수정해 주세요."
fi
