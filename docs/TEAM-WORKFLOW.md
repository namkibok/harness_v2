# 팀 워크플로 — 설계자 vs 개발자

카탈로그(~1,300 skills) **전체 복사는 필수가 아닙니다.** 역할별로 필요한 것만 받습니다.

**카탈로그 경로:** `E:\workspace\skills_안티그래비티\antigravity` (`HARNESS_SKILL_CATALOG`)

## 역할 요약

| | 하네스 설계자 | 일반 개발자 |
|---|-------------|------------|
| **하는 일** | "하네스 구성해줘", 에이전트/스킬 선별 | 프로젝트 기능 개발 |
| **clone** | 하네스 repo | **프로젝트 repo만** |
| **카탈로그** | 로컬 `skills_안티그래비티\antigravity` | **불필요** (lock + install-skills) |
| **전역** | `~/.gemini/antigravity/skills/harness` | 동일 (메타 스킬 1개) |

## 말만 하면 스킬 설치 (provision-skill)

전역에 `provision-skill` 설치 후, 프로젝트에서:

```
typescript-expert 스킬 구성해줘
```

Agent → `provision-skill.ps1 -Query "..."` → 로컬 카탈로그에서 해당 ID만 설치.

## 일반 개발자 (권장)

프로젝트에 `.harness/skills.lock.yaml`과 `.agent/skills/`(또는 lock만)가 있습니다.

```powershell
git clone https://github.com/your-org/your-project.git
cd your-project

git clone https://github.com/namkibok/harness_ant.git
$env:HARNESS_HOME = "$PWD"  # or path to harness_ant clone
$env:HARNESS_SKILL_CATALOG = "E:\workspace\skills_안티그래비티\antigravity"

& "$env:HARNESS_HOME\scripts\install-skills.ps1" -LockFile .harness\skills.lock.yaml
```

또는 팀이 `.agent/skills/`를 **이미 Git에 커밋**해 두었다면 **추가 설치 없음**.

```powershell
$agSkills = Join-Path $env:USERPROFILE ".gemini\antigravity\skills"
Copy-Item -Recurse -Force "$env:HARNESS_HOME\skills\harness" "$agSkills\harness"
```

## 하네스 설계자

```powershell
git clone https://github.com/namkibok/harness_ant.git
$env:HARNESS_HOME = "$PWD"  # or path to harness_ant clone
$env:HARNESS_SKILL_CATALOG = "E:\workspace\skills_안티그래비티\antigravity"

$agSkills = Join-Path $env:USERPROFILE ".gemini\antigravity\skills"
Copy-Item -Recurse -Force "$env:HARNESS_HOME\skills\harness" "$agSkills\harness"
```

필요 스킬만:

```powershell
.\scripts\install-skills.ps1 -Skills typescript-expert,webapp-testing -TargetDir .agent\skills
```

하네스 구성 완료 후 대상 프로젝트에:

1. `.harness/skills.lock.yaml` 생성 (채택 스킬 ID 목록)
2. `install-skills.ps1` 실행
3. lock 파일을 **프로젝트 repo에 커밋**

## skills.lock.yaml

예시: [.harness/skills.lock.yaml.example](../.harness/skills.lock.yaml.example)

```yaml
domain: code-review
skills:
  - vibers-code-review
  - vulnerability-scanner
  - verification-before-completion
```

## install-skills.ps1 동작

1. `HARNESS_SKILL_CATALOG`(기본: `E:\workspace\skills_안티그래비티\antigravity`)에서 스킬 폴더 확인
2. lock에 있는 ID만 선택
3. 프로젝트 `.agent/skills/{name}`에 **Junction**(기본) 또는 Copy

전역 `~/.gemini/antigravity/skills/`에 1,300개를 넣지 **않습니다**.
