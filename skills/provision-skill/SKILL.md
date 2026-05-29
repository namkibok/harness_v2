---
name: provision-skill
description: "스킬 자동 분석·설치. 사용자가 'hwpx 스킬 구성해줘', 'typescript-expert 설치', '스킬 적용해줘', 'install skill', '카탈로그에서 스킬 받아줘' 등 특정 스킬 이름·도메인만 언급할 때 반드시 사용. 하네스 전체 팀 설계가 아닌 단일/복수 스킬 프로비저닝. 로컬 Antigravity 카탈로그(E:\\workspace\\skills_안티그래비티\\antigravity)에서 설치 후 프로젝트 .agent/skills/에 연결하고 .harness/skills.lock.yaml 갱신."
---

# Provision Skill — 말만 하면 스킬 분석·설치

사용자가 **스킬 이름·도메인만** 말했을 때(전체 하네스 구성이 아닐 때) 이 스킬을 실행한다.  
`harness` 메타 스킬(팀 설계)과 구분: "하네스 구성해줘" → `harness`, "hwpx 스킬 구성해줘" → **이 스킬**.

## 사전 조건

1. 하네스 repo 및 환경 변수 (최초 1회):

```powershell
git clone https://github.com/namkibok/harness_ant.git
$env:HARNESS_HOME = "C:\path\to\harness_ant"
$env:HARNESS_SKILL_CATALOG = "E:\workspace\skills_안티그래비티\antigravity"

$agSkills = Join-Path $env:USERPROFILE ".gemini\antigravity\skills"
New-Item -ItemType Directory -Force -Path $agSkills | Out-Null
Copy-Item -Recurse -Force "$env:HARNESS_HOME\skills\provision-skill" "$agSkills\provision-skill"
Copy-Item -Recurse -Force "$env:HARNESS_HOME\skills\harness" "$agSkills\harness"
```

2. 작업 디렉터리 = **대상 프로젝트 루트** (`.agent/skills/`가 생길 위치)

3. **터미널 실행 권한** (스크립트)

## 워크플로 (매 요청 시)

### Step 1: 사용자 발화에서 스킬 의도 추출

- 예: `hwpx 스킬 구성해줘` → 후보 `hwpx`
- 예: `typescript랑 webapp-testing 스킬 설치` → `typescript-expert`, `webapp-testing` (카탈로그 ID는 하이픈 형식)
- `catalog-index.yaml`의 `aliases:` 확인 (예: `한글: hwpx`)

### Step 2: 스크립트 실행 (필수)

프로젝트 루트에서 **반드시** Shell로 실행:

```powershell
& "$env:HARNESS_HOME\scripts\provision-skill.ps1" -Query "<사용자 원문 그대로 또는 핵심 키워드>"
```

ID를 이미 알면:

```powershell
& "$env:HARNESS_HOME\scripts\provision-skill.ps1" -SkillIds hwpx,typescript-expert
```

스크립트가 자동으로:

1. `HARNESS_SKILL_CATALOG` 경로에 스킬 존재 여부 확인
2. `.harness/skills.lock.yaml` 병합 갱신
3. `install-skills.ps1`로 **해당 스킬만** → `.agent/skills/{id}/`

### Step 3: 결과 보고

- 설치된 스킬 ID 목록
- 생성/갱신된 경로: `.agent/skills/`, `.harness/skills.lock.yaml`
- 실패 시: 카탈로그에 없음 → Step 4

### Step 4: 카탈로그에 없을 때

1. 사용자에게 "`HARNESS_SKILL_CATALOG`에 `{id}` 없음" 명시
2. 프로젝트 전용 스킬이 필요하면 `.agent/skills/{id}/SKILL.md` **신규 작성** (최소 frontmatter + 절차)
3. lock에 추가 후 `install-skills`는 생략 가능
4. (선택) `skills_안티그래비티\antigravity` 카탈로그에 스킬 추가 권장

## 금지

- `~/.gemini/antigravity/skills/`에 카탈로그 전체 복사
