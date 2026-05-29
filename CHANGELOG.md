# Changelog

## [1.1.0-cursor] — 2026-05-27

### Added

- `skills/catalog/` — shared Cursor skills library (team Git, vendored in harness_v2)
- `skills/catalog-index.yaml` — domain → recommended skill IDs
- `skills/harness/references/skill-catalog.md` — Phase 4 catalog integration rules
- `docs/SPLIT-CATALOG-SUBMODULE.md` — optional split to `namkibok/cursor-skills` submodule

### Changed

- Harness Phase 4: prefer catalog pick + project junction over writing from scratch
- README: team install with `HARNESS_SKILL_CATALOG`

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
