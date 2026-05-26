# Changelog

## [1.0.0-cursor] — 2026-05-27

### Added

- Cursor 포트: `skills/harness/` 및 `references/cursor-runtime-mapping.md`
- README, `docs/quickstart-cursor.md`

### Changed (from revfactory/harness)

- `.claude/*` → `.cursor/*`
- `CLAUDE.md` → `AGENTS.md` / `.cursor/rules/`
- Agent Teams API → 병렬 `Task` + `_workspace/` handoff
- Claude Code 플러그인 설치 → `~/.cursor/skills/harness` 복사

### Unchanged

- 6 Phase 워크플로, 6가지 아키텍처 패턴, Progressive Disclosure, 검증·진화 루프
