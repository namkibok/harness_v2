# Harness for Google Antigravity

[revfactory/harness](https://github.com/revfactory/harness)의 **Google Antigravity** 포트입니다. 도메인 한 줄 → 전문 에이전트 팀 + 스킬을 설계·생성하는 **L3 메타 팩토리(팀 아키텍처)** 역할은 동일하고, 런타임만 Antigravity에 맞게 바뀌었습니다.

**English summary:** Same Harness meta-skill; outputs go to `.agent/agents/` and `.agent/skills/`; skill catalog from [ant-skills](https://github.com/namkibok/ant-skills) via Git sparse checkout (no machine-local paths).

**Repository:** [github.com/namkibok/harness_ant](https://github.com/namkibok/harness_ant)

## Claude Code vs Cursor vs Antigravity

| 항목 | Claude Code (원본) | Cursor (이전 포트) | Antigravity (이 포트) |
|------|-------------------|-------------------|------------------------|
| 에이전트 정의 | `.claude/agents/` | `.cursor/agents/` | `.agent/agents/` |
| 스킬 | `.claude/skills/` | `.cursor/skills/` | `.agent/skills/` (워크스페이스) |
| 전역 스킬 | — | `~/.cursor/skills/` | `~/.gemini/antigravity/skills/` |
| 세션 포인터 | `CLAUDE.md` | `AGENTS.md` | **`AGENTS.md`** |
| 멀티 에이전트 | `TeamCreate`, `SendMessage` | 병렬 `Task` + `_workspace/` | 병렬 위임 + `_workspace/` |
| 스킬 카탈로그 | — | cursor-skills (GitHub) | **[ant-skills](https://github.com/namkibok/ant-skills)** (Git sparse) |
| 메타 스킬 설치 | `/plugin install` | `~/.cursor/skills/harness` | `~/.gemini/antigravity/skills/harness` |

## 설치 (팀 · Git)

역할별 상세: **[docs/TEAM-WORKFLOW.md](docs/TEAM-WORKFLOW.md)**

| 역할 | 필요한 것 |
|------|----------|
| **일반 개발자** | 프로젝트 repo + `.harness/skills.lock.yaml` + **Git** → `install-skills.ps1` |
| **하네스 설계자** | [harness_ant](https://github.com/namkibok/harness_ant) + `~/.gemini/antigravity/skills/harness` |

### 환경 변수 (선택)

```powershell
git clone https://github.com/namkibok/harness_ant.git
cd harness_ant
$env:HARNESS_HOME = (Get-Location).Path

# optional overrides (defaults work for everyone)
# $env:HARNESS_SKILL_REPO = "https://github.com/namkibok/ant-skills.git"
# $env:HARNESS_SKILL_CACHE = "$env:LOCALAPPDATA\harness\ant-skills-sparse"
```

### 일반 개발자 — 스킬 설치

```powershell
git clone https://github.com/your-org/your-project.git
cd your-project

& "$env:HARNESS_HOME\scripts\install-skills.ps1" -LockFile .harness\skills.lock.yaml
```

`install-skills.ps1`은 [ant-skills](https://github.com/namkibok/ant-skills)에서 lock에 적힌 스킬만 Git sparse로 받아 `.agent/skills/`에 Junction 합니다.

### 하네스 설계자 — 메타 스킬

```powershell
$agSkills = Join-Path $env:USERPROFILE ".gemini\antigravity\skills"
New-Item -ItemType Directory -Force -Path $agSkills | Out-Null
Copy-Item -Recurse -Force "$env:HARNESS_HOME\skills\harness" "$agSkills\harness"
Copy-Item -Recurse -Force "$env:HARNESS_HOME\skills\provision-skill" "$agSkills\provision-skill"
```

### 말만 하면 스킬 설치

```
hwpx 스킬 구성해줘
```

```powershell
& "$env:HARNESS_HOME\scripts\provision-skill.ps1" -Query "hwpx 스킬 구성해줘"
```

> **금지:** 카탈로그 전체(~1,300개)를 `~/.gemini/antigravity/skills/`에 복사 · PC 전용 `E:\...` 로컬 경로를 팀 표준으로 사용

## 구조

```
harness_ant/
├── skills/harness/           # 메타 스킬
├── scripts/install-skills.ps1  # lock → ant-skills (Git sparse)
└── .harness/skills.lock.yaml.example
```

**스킬 카탈로그:** [namkibok/ant-skills](https://github.com/namkibok/ant-skills)

## 문서

- [팀 워크플로](docs/TEAM-WORKFLOW.md)
- [빠른 시작](docs/quickstart-antigravity.md)
- [런타임 매핑](skills/harness/references/antigravity-runtime-mapping.md)

## 라이선스

Apache 2.0 — [revfactory/harness](https://github.com/revfactory/harness)

## 크레딧

RevFactory / Min Hwang — [revfactory/harness](https://github.com/revfactory/harness)  
Antigravity: [namkibok/harness_ant](https://github.com/namkibok/harness_ant) · Cursor: [namkibok/harness_v2](https://github.com/namkibok/harness_v2)
