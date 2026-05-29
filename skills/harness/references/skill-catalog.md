# Skill Catalog (부품 창고)

Harness는 스킬을 항상 처음부터 쓰지 않는다. **공유 카탈로그**에서 도메인에 맞는 스킬을 찾아 프로젝트에 연결한 뒤, 없을 때만 신규 작성한다.

## 카탈로그 경로 해석 (우선순위)

1. 환경 변수 `HARNESS_SKILL_CATALOG` (절대 경로)
2. **harness_v2 저장소 루트**의 `skills/catalog/` (submodule → [cursor-skills](https://github.com/namkibok/cursor-skills))
3. 대상 프로젝트의 `skills/catalog/` (서브모듈로 둔 경우)

메타 스킬만 `~/.cursor/skills/harness`에 복사한 경우, 카탈로그는 없다. 반드시 harness_v2를 clone하거나 `HARNESS_SKILL_CATALOG`를 설정한다.

```powershell
$env:HARNESS_SKILL_CATALOG = "C:\dev\harness_v2\skills\catalog"
```

## Phase 4 절차 (카탈로그 연동)

1. `catalog-index.yaml`(있으면) 또는 `Glob`/`Grep`으로 후보 스킬 이름 수집
2. 각 후보의 `{catalog}/{name}/SKILL.md` frontmatter `description`을 Read해 적합성 판단
3. **채택 시** (전역 설치 금지):
   - 프로젝트 `.cursor/skills/{name}`에 **디렉터리 정션 링크** 또는 복사
   - 에이전트 정의·오케스트레이터에 `Read {catalog}/{name}/SKILL.md` 지시 추가
4. 카탈로그에 없거나 도메인 전용이면 `프로젝트/.cursor/skills/{name}/SKILL.md` 신규 작성
5. 팀원 수(3~8개)를 넘기지 않는다 — 트리거 충돌 방지

### Windows 정션 링크 예

```powershell
New-Item -ItemType Junction -Path ".cursor\skills\typescript-expert" `
  -Target "$env:HARNESS_SKILL_CATALOG\typescript-expert"
```

## catalog-index.yaml

`skills/catalog-index.yaml`에 도메인별 **추천 스킬 ID**만 둔다. 전체 1,300개를 나열하지 않는다.

## 서브모듈 분리 (선택)

카탈로그만 별도 repo로 쪼개려면 `docs/SPLIT-CATALOG-SUBMODULE.md`를 따른다. 팀 온보딩은 **harness_v2 단일 clone**으로 동일하다 (`skills/catalog` 포함).

## 금지

- `skills/catalog` 전체를 `~/.cursor/skills/`에 복사
- 카탈로그 스킬 description을 프로젝트 스킬과 중복 작성 (링크·Read로 충분)
