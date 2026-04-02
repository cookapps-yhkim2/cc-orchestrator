#!/bin/bash
# SessionStart Hook
# 세션 시작 시 프로젝트 컨텍스트를 자동으로 로드하여 에이전트에게 전달합니다.

ORC_DIR=".unity-orc"

# .unity-orc 디렉토리 존재 확인
if [ ! -d "$ORC_DIR" ]; then
    echo "⚠️ .unity-orc/ 디렉토리가 없습니다. 'unity-init' 스킬로 프로젝트를 초기화하세요."
    exit 0
fi

echo "🎮 Unity Orchestrator 컨텍스트 로딩 중..."
echo ""

# 1. unity-progress.md 로드
if [ -f "$ORC_DIR/unity-progress.md" ]; then
    echo "📋 === 프로젝트 진행 상황 ==="
    cat "$ORC_DIR/unity-progress.md"
    echo ""
else
    echo "⚠️ unity-progress.md가 없습니다."
fi

# 2. feature_list.json 로드
if [ -f "$ORC_DIR/feature_list.json" ]; then
    echo "📦 === 기능 목록 ==="
    cat "$ORC_DIR/feature_list.json"
    echo ""
else
    echo "⚠️ feature_list.json이 없습니다."
fi

# 3. 최근 git 로그
if git rev-parse --git-dir > /dev/null 2>&1; then
    echo "📝 === 최근 Git 커밋 (20개) ==="
    git log --oneline -20
    echo ""
else
    echo "⚠️ Git 저장소가 아닙니다."
fi

echo "✅ 컨텍스트 로딩 완료. 작업을 시작하세요!"
