---
name: provision-skill
description: "스킬 자동 분석·설치. 사용자가 'hwpx 스킬 구성해줘', 'typescript-expert 설치', '스킬 적용해줘', 'install skill', '카탈로그에서 스킬 받아줘' 등 특정 스킬 이름·도메인만 언급할 때 반드시 사용. 하네스 전체 팀 설계가 아닌 단일/복수 스킬 프로비저닝. cursor-skills에서 sparse download 후 프로젝트 .cursor/skills/에 연결하고 .harness/skills.lock.yaml 갱신."
---

# Provision Skill — 말만 하면 스킬 분석·설치

사용자가 **스킬 이름·도메인만** 말했을 때(전체 하네스 구성이 아닐 때) 이 스킬을 실행한다.  
`harness` 메타 스킬(팀 설계)과 구분: "하네스 구성해줘" → `harness`, "hwpx 스킬 구성해줘" → **이 스킬**.

## 사전 조건

1. [harness_v2](https://github.com/namkibok/harness_v2) clone 및 환경 변수 (최초 1회):

```powershell
git clone https://github.com/namkibok/harness_v2.git C:\dev\harness_v2
$env:HARNESS_V2_HOME = "C:\dev\harness_v2"
Copy-Item -Recurse -Force "$env:HARNESS_V2_HOME\skills\provision-skill" "$env:USERPROFILE\.cursor\skills\provision-skill"
Copy-Item -Recurse -Force "$env:HARNESS_V2_HOME\skills\harness" "$env:USERPROFILE\.cursor\skills\harness"
```

2. 작업 디렉터리 = **대상 프로젝트 루트** (`.cursor/skills/`가 생길 위치)

3. **터미널 실행 권한** (git sparse + 스크립트)

## 워크플로 (매 요청 시)

### Step 1: 사용자 발화에서 스킬 의도 추출

- 예: `hwpx 스킬 구성해줘` → 후보 `hwpx`
- 예: `typescript랑 webapp-testing 스킬 설치` → `typescript-expert`, `webapp-testing` (카탈로그 ID는 하이픈 형식)
- `catalog-index.yaml`의 `aliases:` 확인 (예: `한글: hwpx`)

### Step 2: 스크립트 실행 (필수)

프로젝트 루트에서 **반드시** Shell로 실행:

```powershell
& "$env:HARNESS_V2_HOME\scripts\provision-skill.ps1" -Query "<사용자 원문 그대로 또는 핵심 키워드>"
```

ID를 이미 알면:

```powershell
& "$env:HARNESS_V2_HOME\scripts\provision-skill.ps1" -SkillIds hwpx,typescript-expert
```

스크립트가 자동으로:

1. [cursor-skills](https://github.com/namkibok/cursor-skills)에 스킬 존재 여부 확인 (GitHub API)
2. `.harness/skills.lock.yaml` 병합 갱신
3. `install-skills.ps1`로 **해당 스킬만** sparse download → `.cursor/skills/{id}/`

### Step 3: 결과 보고

- 설치된 스킬 ID 목록
- 생성/갱신된 경로: `.cursor/skills/`, `.harness/skills.lock.yaml`
- 실패 시: 카탈로그에 없음 → Step 4

### Step 4: 카탈로그에 없을 때

1. 사용자에게 "cursor-skills에 `{id}` 없음" 명시
2. 프로젝트 전용 스킬이 필요하면 `.cursor/skills/{id}/SKILL.md` **신규 작성** (최소 frontmatter + 절차)
3. lock에 ID 추가
4. (선택) 팀에 cursor-skills repo에 PR 권장

## 금지

- `~/.cursor/skills/`에 카탈로그 전체 복사
- 스크립트 없이 "설치했다"고만 보고
- 전체 하네스(에이전트 팀·오케스트레이터)를 이 스킬만으로 대체

## 참고

- 카탈로그 alias: harness_v2 `skills/catalog-index.yaml`
- 팀 온보딩: [docs/TEAM-WORKFLOW.md](https://github.com/namkibok/harness_v2/blob/main/docs/TEAM-WORKFLOW.md)
