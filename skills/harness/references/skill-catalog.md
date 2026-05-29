# Skill Catalog (부품 창고)

Harness는 스킬을 항상 처음부터 쓰지 않는다. **공유 카탈로그**에서 도메인에 맞는 스킬을 찾아 프로젝트에 연결한 뒤, 없을 때만 신규 작성한다.

## 카탈로그 위치 (필수)

추가 스킬 카탈로그는 **반드시** 아래 경로를 사용한다:

```
E:\workspace\skills\antigravity
```

환경 변수로 재정의 가능:

```powershell
$env:HARNESS_SKILL_CATALOG = "E:\workspace\skills\antigravity"
```

## 팀원은 카탈로그 전체를 받을 필요 없음

| 방식 | 용도 |
|------|------|
| **`scripts/install-skills.ps1` + `.harness/skills.lock.yaml`** | 일반 개발자 — lock에 있는 스킬만 Junction/Copy (권장) |
| 로컬 카탈로그 직접 탐색 | 설계자가 Phase 4에서 스킬 선별할 때 |
| 프로젝트 `.agent/skills/` Git 커밋 | lock + install 결과를 repo에 고정 |

## Phase 4 절차 (카탈로그 연동)

1. `catalog-index.yaml`(있으면) 또는 `HARNESS_SKILL_CATALOG` 경로에서 `Glob`으로 후보 수집 (3~8개)
2. `{catalog}/{id}/SKILL.md` frontmatter `description`을 Read해 채택/제외
3. 채택 스킬 설치 — **우선 `install-skills.ps1` 사용**:
   ```powershell
   # 대상 프로젝트 루트에서
   & "$env:HARNESS_HOME\scripts\install-skills.ps1" -Skills id1,id2,id3 -TargetDir .agent\skills
   ```
4. 프로젝트 `.harness/skills.lock.yaml` 생성·커밋 (팀 온보딩용)
5. 없거나 전용이면 `프로젝트/.agent/skills/{name}/SKILL.md` 신규 작성
6. 오케스트레이터·에이전트 정의에 Read 경로 및 `@skill-name` 호출 명시

### skills.lock.yaml 예

```yaml
domain: code-review
skills:
  - vibers-code-review
  - vulnerability-scanner
```

템플릿: `.harness/skills.lock.yaml.example`

## catalog-index.yaml

하네스 루트 `skills/catalog-index.yaml` — 도메인별 **추천 ID** (전체 목록 아님).

## 금지

- 카탈로그 전체(~1,300개)를 `~/.gemini/antigravity/skills/`에 복사
- 모든 팀원에게 전체 카탈로그 clone 필수로 강제 (lock + install-skills로 대체)
