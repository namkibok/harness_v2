# Changelog

## [2.1.0-antigravity] — 2026-05-29

### Changed

- Skill catalog: [namkibok/ant-skills](https://github.com/namkibok/ant-skills) (GitHub) + local `E:\workspace\skills\antigravity`
- `install-skills.ps1`: local catalog first, then sparse clone from ant-skills
- `provision-skill.ps1`: local + GitHub API fallback for ant-skills

## [2.0.0-antigravity] — 2026-05-29

### Changed

- **Google Antigravity** 런타임 포트: `.cursor/*` → `.agent/*`, 전역 `~/.gemini/antigravity/skills/`
- 스킬 카탈로그: GitHub `cursor-skills` → 로컬 `E:\workspace\skills\antigravity`
- `HARNESS_V2_HOME` → `HARNESS_HOME`, `install-skills.ps1` / `provision-skill.ps1` 로컬 카탈로그 Junction
- `cursor-runtime-mapping.md` → `antigravity-runtime-mapping.md`
- `docs/quickstart-cursor.md` → `docs/quickstart-antigravity.md`
- `.gitmodules` (cursor-skills submodule) 제거 — 외부 카탈로그 경로 사용

## [1.4.0-cursor] — 2026-05-27

### Added

- `skills/provision-skill/` — natural-language skill install (triggers on "hwpx 스킬 구성" etc.)
- `scripts/provision-skill.ps1` — resolve IDs via GitHub API + aliases, update lock, call install-skills
- `catalog-index.yaml` `aliases:` section for keyword → skill ID mapping

## [1.3.0-cursor] — 2026-05-27

### Added

- `scripts/install-skills.ps1` — sparse fetch from cursor-skills using `skills.lock.yaml`
- `.harness/skills.lock.yaml.example` — project lock template
- `docs/TEAM-WORKFLOW.md` — harness designer vs developer onboarding

### Changed

- README: submodule optional; developers use lock + install-skills only
- Harness Phase 4: generate `.harness/skills.lock.yaml` and run install-skills

## [1.2.0-cursor] — 2026-05-27

### Changed

- `skills/catalog` → Git submodule [namkibok/cursor-skills](https://github.com/namkibok/cursor-skills)
- Team clone: `git clone --recurse-submodules`

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
