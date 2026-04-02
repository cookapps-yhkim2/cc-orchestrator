# unity-init

프로젝트를 초기화하고 에이전트 작업 환경을 세팅하는 스킬입니다.

## 트리거

- "프로젝트 초기화해줘"
- "새 Unity 프로젝트 세팅"
- "unity-orc 세팅"
- "작업 환경 만들어줘"

## 수행 작업

### 1. `.unity-orc/` 디렉토리 생성

프로젝트 루트에 다음 구조를 생성합니다:

```
.unity-orc/
├── unity-progress.md          # 전체 진행 상황 추적
├── feature_list.json          # 기능 목록 + 완료 상태
├── plans/                     # 스프린트 계획서
│   └── open-questions.md      # 미결 사항 추적
└── evaluations/               # 평가 리포트
```

### 2. unity-progress.md 초기화

`references/progress-template.md`를 참고하여 프로젝트 진행 상황 파일을 생성합니다.

사용자에게 다음을 질문하세요:
- **프로젝트 이름**: Unity 프로젝트의 이름
- **프로젝트 유형**: 2D / 3D / 2.5D
- **장르**: 액션, RPG, 퍼즐, 플랫포머 등
- **대상 플랫폼**: PC, Mobile, Console 등

### 3. feature_list.json 초기화

`references/feature-list-schema.md`를 참고하여 빈 기능 목록 파일을 생성합니다.

```json
[]
```

### 4. open-questions.md 초기화

```markdown
# 미결 사항 (Open Questions)

## 활성
(아직 없음)

## 해결됨
(아직 없음)
```

### 5. .gitignore 확인

프로젝트의 `.gitignore`에 다음이 포함되어 있는지 확인하고, 없으면 추가를 제안합니다:
- `.unity-orc/` 디렉토리는 **추적 대상**입니다 (팀원 간 공유를 위해)
- Unity 기본 gitignore 항목 확인

### 6. 기존 프로젝트 분석 (선택)

이미 코드가 있는 프로젝트라면:
- `Assets/Scripts/` 하위 폴더 구조 파악
- 기존 Scene 파일 목록 확인
- 사용 중인 패키지(Packages/manifest.json) 확인
- 분석 결과를 `unity-progress.md`에 기록

## 완료 조건

- [ ] `.unity-orc/` 디렉토리 및 하위 파일이 모두 생성됨
- [ ] `unity-progress.md`에 프로젝트 기본 정보가 기록됨
- [ ] `feature_list.json`이 유효한 JSON 배열로 존재함
- [ ] 사용자에게 초기화 완료 리포트를 보여줌

## 초기화 완료 후

사용자에게 다음 단계를 안내합니다:
> "프로젝트 초기화가 완료되었습니다. 이제 `스프린트 계획 세워줘`로 첫 번째 스프린트를 시작할 수 있어요."
