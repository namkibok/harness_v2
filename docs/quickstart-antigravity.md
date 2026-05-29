# Harness for Antigravity — Quickstart

## 1. 하네스 + 메타 스킬

```powershell
git clone https://github.com/namkibok/harness_ant.git
cd harness_ant
$env:HARNESS_HOME = (Get-Location).Path

$agSkills = Join-Path $env:USERPROFILE ".gemini\antigravity\skills"
New-Item -ItemType Directory -Force -Path $agSkills | Out-Null
Copy-Item -Recurse -Force "$env:HARNESS_HOME\skills\harness" "$agSkills\harness"
```

Antigravity: `하네스 구성해줘. 이 프로젝트는 …`

## 2. 프로젝트 스킬 설치 (Git)

스킬은 **[ant-skills](https://github.com/namkibok/ant-skills)** 에서 자동으로 받습니다 (Git sparse). **로컬 경로 설정 불필요.**

```powershell
cd your-project
& "$env:HARNESS_HOME\scripts\install-skills.ps1" -LockFile .harness\skills.lock.yaml
```

요구 사항: **Git for Windows** 설치.

## 3. 산출물

| 경로 | 내용 |
|------|------|
| `.agent/agents/*.md` | 에이전트 정의 |
| `.agent/skills/*/SKILL.md` | lock 기준 설치된 스킬 |
| `AGENTS.md` | 하네스 포인터 |

## 문제 해결

| 증상 | 확인 |
|------|------|
| 스킬 없음 | lock 실행, Git 설치, ID가 https://github.com/namkibok/ant-skills 에 있는지 |
| 느림 | 최초 sparse clone만 느림 — 캐시 `%LOCALAPPDATA%\harness\ant-skills-sparse` |
