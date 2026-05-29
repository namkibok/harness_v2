# Skill Catalog (부품 창고)

Harness는 스킬을 항상 처음부터 쓰지 않는다. **공유 카탈로그**에서 도메인에 맞는 스킬을 찾아 프로젝트에 연결한 뒤, 없을 때만 신규 작성한다.

## 팀원은 카탈로그 전체를 받을 필요 없음

| 방식 | 용도 |
|------|------|
| **`scripts/install-skills.ps1` + `.harness/skills.lock.yaml`** | 일반 개발자 — lock에 있는 스킬만 sparse fetch (권장) |
| `skills/catalog` submodule | 설계자가 카탈로그 전체를 로컬에서 탐색할 때만 (선택) |
| 프로젝트 `.cursor/skills/` Git 커밋 | lock + install 결과를 repo에 고정 |

## 카탈로그 경로 해석 (설계자 · Harness Phase 4)

1. 환경 변수 `HARNESS_SKILL_CATALOG`
2. sparse cache: `%LOCALAPPDATA%\harness\cursor-skills-sparse` (`install-skills.ps1` 사용 시)
3. harness_v2의 `skills/catalog/` (submodule, **선택**)

설계자만 submodule init:

```powershell
git submodule update --init skills/catalog
$env:HARNESS_SKILL_CATALOG = "$PWD\skills\catalog"
```

## Phase 4 절차 (카탈로그 연동)

1. `catalog-index.yaml`(있으면) 또는 sparse cache / submodule `Glob`으로 후보 수집 (3~8개)
2. `{catalog}/{id}/SKILL.md` frontmatter `description`을 Read해 채택/제외
3. 채택 스킬 설치 — **우선 `install-skills.ps1` 사용**:
   ```powershell
   # 대상 프로젝트 루트에서
   ..\harness_v2\scripts\install-skills.ps1 -Skills id1,id2,id3 -TargetDir .cursor\skills
   ```
4. 프로젝트 `.harness/skills.lock.yaml` 생성·커밋 (팀 온보딩용)
5. 없거나 전용이면 `프로젝트/.cursor/skills/{name}/SKILL.md` 신규 작성
6. 오케스트레이터·에이전트 정의에 Read 경로 명시

### skills.lock.yaml 예

```yaml
domain: code-review
skills:
  - vibers-code-review
  - vulnerability-scanner
```

템플릿: harness_v2 `.harness/skills.lock.yaml.example`

## catalog-index.yaml

harness_v2 `skills/catalog-index.yaml` — 도메인별 **추천 ID** (전체 목록 아님).

## 금지

- 카탈로그 전체를 `~/.cursor/skills/`에 복사
- 모든 팀원에게 `git clone --recurse-submodules` 필수로 강제 (lock + install-skills로 대체)
