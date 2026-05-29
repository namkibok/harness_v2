# Harness for Antigravity — Quickstart

## 1. 환경 변수

```powershell
git clone https://github.com/namkibok/harness_ant.git
cd harness_ant
$env:HARNESS_HOME = (Get-Location).Path
$env:HARNESS_SKILL_CATALOG = "E:\workspace\skills\antigravity"
```

## 2. 메타 스킬 설치 (설계자, 1회)

```powershell
$agSkills = Join-Path $env:USERPROFILE ".gemini\antigravity\skills"
New-Item -ItemType Directory -Force -Path $agSkills | Out-Null
Copy-Item -Recurse -Force "$env:HARNESS_HOME\skills\harness" "$agSkills\harness"
```

Antigravity에서: `하네스 구성해줘. 이 프로젝트는 …`

## 3. 프로젝트에 스킬만 설치 (개발자)

```powershell
cd your-project
& "$env:HARNESS_HOME\scripts\install-skills.ps1" -LockFile .harness\skills.lock.yaml
```

## 산출물 위치

| 경로 | 내용 |
|------|------|
| `.agent/agents/*.md` | 에이전트 정의 |
| `.agent/skills/*/SKILL.md` | lock 기준 설치된 스킬 |
| `AGENTS.md` | 하네스 트리거 포인터 |
| `_workspace/` | 실행 중간 산출물 |

## 문제 해결

**스킬이 안 붙는다** — lock 실행 여부, `.agent/skills/{name}/SKILL.md` 존재 확인, `HARNESS_SKILL_CATALOG` 경로 확인

**카탈로그 ID 없음** — `E:\workspace\skills\antigravity\{id}\SKILL.md` 존재 여부 확인
