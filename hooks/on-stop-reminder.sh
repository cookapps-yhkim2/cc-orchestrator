#!/bin/bash
# Stop Hook
# 세션 종료 시 unity-progress.md 업데이트를 리마인드합니다.

ORC_DIR=".unity-orc"

# .unity-orc 디렉토리가 없으면 무시
if [ ! -d "$ORC_DIR" ]; then
    exit 0
fi

echo ""
echo "🔔 세션 종료 전 확인사항:"
echo ""

# 1. unity-progress.md 업데이트 리마인드
if [ -f "$ORC_DIR/unity-progress.md" ]; then
    echo "📋 unity-progress.md가 최신 상태인지 확인하세요."
    echo "   - 현재 작업 중인 항목의 진행률이 갱신되었나요?"
    echo "   - 완료된 작업이 '최근 완료' 섹션에 추가되었나요?"
    echo "   - 새로 발견된 이슈가 기록되었나요?"
fi

# 2. feature_list.json 상태 확인
if [ -f "$ORC_DIR/feature_list.json" ]; then
    PENDING=$(grep -c '"passes": null' "$ORC_DIR/feature_list.json" 2>/dev/null || echo "0")
    FAILED=$(grep -c '"passes": false' "$ORC_DIR/feature_list.json" 2>/dev/null || echo "0")

    if [ "$PENDING" -gt 0 ]; then
        echo "📦 미평가 기능이 ${PENDING}개 있습니다."
    fi
    if [ "$FAILED" -gt 0 ]; then
        echo "❌ 불합격 기능이 ${FAILED}개 있습니다."
    fi
fi

# 3. 커밋되지 않은 변경사항 확인
if git rev-parse --git-dir > /dev/null 2>&1; then
    UNCOMMITTED=$(git status --porcelain 2>/dev/null | wc -l)
    if [ "$UNCOMMITTED" -gt 0 ]; then
        echo "⚠️ 커밋되지 않은 변경사항이 ${UNCOMMITTED}개 있습니다. 커밋을 잊지 마세요!"
    fi
fi

echo ""
echo "👋 다음 세션에서 이어서 작업하세요!"
