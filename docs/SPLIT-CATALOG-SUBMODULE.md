# Antigravity 스킬 카탈로그 (외부 경로)

이 포트에서는 **Git submodule 대신 로컬 카탈로그**를 사용합니다.

## 카탈로그 위치

| 경로 | 내용 |
|------|------|
| `E:\workspace\skills_안티그래비티\antigravity` | ~1,300 Antigravity 스킬 (`{id}/SKILL.md`) |

환경 변수:

```powershell
$env:HARNESS_SKILL_CATALOG = "E:\workspace\skills_안티그래비티\antigravity"
```

## 하네스 repo와의 관계

- **하네스 repo** (`하네스_안티그래비티`): 메타 스킬, 스크립트, `catalog-index.yaml`(추천 ID만)
- **카탈로그 repo** (`skills_안티그래비티`): 실제 스킬 본문 — Phase 4에서 Read·선별

`install-skills.ps1` / `provision-skill.ps1`은 카탈로그에서 lock에 있는 ID만 프로젝트 `.agent/skills/`로 Junction/Copy 합니다.

## 스킬 추가·수정

1. `E:\workspace\skills_안티그래비티\antigravity\{skill-id}\` 아래에 `SKILL.md` 추가 또는 수정
2. 필요 시 `catalog-index.yaml`의 `aliases:` 또는 도메인 목록 갱신
3. 대상 프로젝트에서 `provision-skill.ps1` 또는 `install-skills.ps1` 재실행

## 이전 Cursor 포트와의 차이

| Cursor 포트 | Antigravity 포트 |
|-------------|------------------|
| `skills/catalog` submodule → cursor-skills | 외부 `skills_안티그래비티\antigravity` |
| GitHub sparse clone | 로컬 폴더 Junction |
| `.cursor/skills/` | `.agent/skills/` |

`skills/catalog/` 서브모듈은 **더 이상 사용하지 않습니다.** submodule이 남아 있다면 제거해도 됩니다.
