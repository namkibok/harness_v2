---
name: provision-skill
description: "스킬 자동 분석·설치. 사용자가 'hwpx 스킬 구성해줘', 'typescript-expert 설치', '스킬 적용해줘', 'install skill', '카탈로그에서 스킬 받아줘' 등 특정 스킬 이름·도메인만 언급할 때 반드시 사용. 하네스 전체 팀 설계가 아닌 단일/복수 스킬 프로비저닝. ant-skills(https://github.com/namkibok/ant-skills) 또는 로컬 E:\\workspace\\skills\\antigravity에서 설치 후 .agent/skills/에 연결하고 .harness/skills.lock.yaml 갱신."
---

# Provision Skill — 말만 하면 스킬 분석·설치

"하네스 구성해줘" → `harness`. "hwpx 스킬 구성해줘" → **이 스킬**.

## 카탈로그

- **GitHub:** [namkibok/ant-skills](https://github.com/namkibok/ant-skills)
- **로컬 (기본):** `E:\workspace\skills\antigravity` (`HARNESS_SKILL_CATALOG`)

## 사전 조건

```powershell
git clone https://github.com/namkibok/harness_ant.git
$env:HARNESS_HOME = "C:\path\to\harness_ant"
$env:HARNESS_SKILL_CATALOG = "E:\workspace\skills\antigravity"  # optional

$agSkills = Join-Path $env:USERPROFILE ".gemini\antigravity\skills"
Copy-Item -Recurse -Force "$env:HARNESS_HOME\skills\provision-skill" "$agSkills\provision-skill"
```

## 실행

```powershell
& "$env:HARNESS_HOME\scripts\provision-skill.ps1" -Query "<사용자 원문>"
```

로컬에 없으면 GitHub API로 ant-skills 존재 확인 후 `install-skills.ps1`이 sparse clone합니다.
