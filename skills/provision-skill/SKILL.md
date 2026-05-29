---
name: provision-skill
description: "스킬 자동 분석·설치. 'hwpx 스킬 구성해줘', 'typescript-expert 설치' 등 단일/복수 스킬 요청 시 사용. GitHub ant-skills(https://github.com/namkibok/ant-skills)에서 sparse install 후 .agent/skills/ 및 .harness/skills.lock.yaml 갱신."
---

# Provision Skill

카탈로그: **[namkibok/ant-skills](https://github.com/namkibok/ant-skills)** (Git only)

```powershell
git clone https://github.com/namkibok/harness_ant.git
$env:HARNESS_HOME = "C:\path\to\harness_ant"

& "$env:HARNESS_HOME\scripts\provision-skill.ps1" -Query "<사용자 원문>"
```

GitHub API로 ID 확인 → `install-skills.ps1`이 sparse clone → `.agent/skills/`.
