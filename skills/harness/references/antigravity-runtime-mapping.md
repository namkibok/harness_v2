# Antigravity 런타임 매핑

## 경로 매핑

| Claude Code | Cursor | Antigravity |
|-------------|--------|-------------|
| `.claude/agents/` | `.cursor/agents/` | `.agent/agents/` |
| `.claude/skills/` | `.cursor/skills/` | `.agent/skills/` |
| `~/.claude/skills/harness/` | `~/.cursor/skills/harness/` | `~/.gemini/antigravity/skills/harness/` |
| `CLAUDE.md` | `AGENTS.md` | **`AGENTS.md`** |
| 스킬 카탈로그 | cursor-skills (GitHub) | **[ant-skills](https://github.com/namkibok/ant-skills)** (Git sparse) |

## 스킬 카탈로그 (Git only)

모든 사용자는 동일한 Git 카탈로그를 사용한다:

```text
https://github.com/namkibok/ant-skills.git
```

`install-skills.ps1`이 lock에 있는 ID만 sparse checkout → 프로젝트 `.agent/skills/`에 Junction.

| 환경 변수 | 용도 |
|----------|------|
| `HARNESS_SKILL_REPO` | 카탈로그 Git URL (기본: ant-skills) |
| `HARNESS_SKILL_CACHE` | sparse clone 캐시 경로 (기본: `%LOCALAPPDATA%\harness\ant-skills-sparse`) |

PC별 로컬 폴더(`E:\workspace\...`)는 **팀 표준으로 사용하지 않는다.**

## 설치

```powershell
git clone https://github.com/namkibok/harness_ant.git
$env:HARNESS_HOME = "C:\path\to\harness_ant"

$agSkills = Join-Path $env:USERPROFILE ".gemini\antigravity\skills"
Copy-Item -Recurse -Force "$env:HARNESS_HOME\skills\harness" "$agSkills\harness"
```
