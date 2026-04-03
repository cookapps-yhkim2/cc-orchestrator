# Changelog

## [0.3.0] - 2026-04-03

### Fixed
- marketplace.json에 `metadata.version` 및 플러그인별 `version` 필드 추가
- 플러그인 업데이트 시 캐시 삭제 없이 정상 업데이트 가능하도록 수정
- hooks.json 포맷을 3-level nested object 형식으로 수정
- agents 필드를 배열 형식으로 수정, frontmatter에 name/description 추가

### Changed
- plugin.json agents 필드: 디렉토리 → 파일 경로 배열
- hooks.json: flat array → event-keyed object 구조

## [0.2.0] - 2026-04-03

### Fixed
- hooks.json 포맷 오류 수정 (expected record, received array)
- Agent frontmatter에 필수 필드(name, description) 추가

## [0.1.0] - 2026-04-02

### Added
- Initial release
- **Skills**: unity-init, unity-sprint, unity-csharp, unity-gamedesign
- **Agents**: Planner (opus), Implementer, Evaluator — GAN-inspired loop
- **Hooks**: SessionStart (context loading), PreToolUse (C# convention check), Stop (progress reminder)
- File-based state management via `.unity-orc/` directory
- Sprint contract pattern with acceptance criteria
- External tool connectors (CONNECTORS.md)
- Korean README (README.ko.md)
