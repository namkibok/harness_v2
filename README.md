# Harness for Google Antigravity

[revfactory/harness](https://github.com/revfactory/harness)의 **Google Antigravity** 포트입니다. 도메인 한 줄 → 전문 에이전트 팀 + 스킬을 설계·생성하는 **L3 메타 팩토리(팀 아키텍처)** 역할은 동일하고, 런타임만 Antigravity에 맞게 바뀌었습니다.

**English summary:** Same Harness meta-skill; outputs go to `.agent/agents/` and `.agent/skills/`; orchestration uses parallel delegation + `_workspace/` handoffs; skill catalog: [ant-skills](https://github.com/namkibok/ant-skills) (local default `E:\workspace\skills\antigravity`).

**Repository:** [github.com/namkibok/harness_ant](https://github.com/namkibok/harness_ant)

## Claude Code vs Cursor vs Antigravity

| 항목 | Claude Code (원본) | Cursor (이전 포트) | Antigravity (이 포트) |
|------|-------------------|-------------------|------------------------|
| 에이전트 정의 | `.claude/agents/` | `.cursor/agents/` | `.agent/agents/` |
| 스킬 | `.claude/skills/` | `.cursor/skills/` | `.agent/skills/` (워크스페이스) |
| 전역 스킬 | — | `~/.cursor/skills/` | `~/.gemini/antigravity/skills/` |
| 세션 포인터 | `CLAUDE.md` | `AGENTS.md` | **`AGENTS.md`** |
| 멀티 에이전트 | `TeamCreate`, `SendMessage` | 병렬 `Task` + `_workspace/` | 병렬 위임 + `_workspace/` |
| 스킬 카탈로그 | — | cursor-skills (GitHub) | **[ant-skills](https://github.com/namkibok/ant-skills)** · 로컬 `E:\workspace\skills\antigravity` |
| 메타 스킬 설치 | `/plugin install` | `~/.cursor/skills/harness` | `~/.gemini/antigravity/skills/harness` |

## 설치 (팀 · Git)

역할별 상세: **[docs/TEAM-WORKFLOW.md](docs/TEAM-WORKFLOW.md)**

| 역할 | 필요한 것 |
|------|----------|
| **일반 개발자** | 프로젝트 repo + `.harness/skills.lock.yaml` → `install-skills.ps1` (카탈로그 전체 복사 **불필요**) |
| **하네스 설계자** | 하네스 repo + `~/.gemini/antigravity/skills/harness` |

### 환경 변수 (권장)

```powershell
git clone https://github.com/namkibok/harness_ant.git
cd harness_ant

$env:HARNESS_HOME = (Get-Location).Path
$env:HARNESS_SKILL_CATALOG = "E:\workspace\skills\antigravity"
```

### 일반 개발자 — 필요한 스킬만 설치

프로젝트에 `.harness/skills.lock.yaml`이 있으면:

```powershell
git clone https://github.com/your-org/your-project.git
cd your-project

& "$env:HARNESS_HOME\scripts\install-skills.ps1" -LockFile .harness\skills.lock.yaml
```

`install-skills.ps1`은 **로컬 카탈로그**에서 lock에 적힌 스킬만 `.agent/skills/`에 Junction 합니다.  
팀이 `.agent/skills/`를 repo에 커밋해 두었다면 위 스크립트는 생략 가능합니다.

### 하네스 설계자 — 메타 스킬 설치

```powershell
$agSkills = Join-Path $env:USERPROFILE ".gemini\antigravity\skills"
New-Item -ItemType Directory -Force -Path $agSkills | Out-Null
Copy-Item -Recurse -Force "$env:HARNESS_HOME\skills\harness" "$agSkills\harness"
Copy-Item -Recurse -Force "$env:HARNESS_HOME\skills\provision-skill" "$agSkills\provision-skill"
```

### 말만 하면 스킬 설치 (`provision-skill`)

Antigravity에서 프로젝트 폴더를 연 뒤 채팅:

```
hwpx 스킬 구성해줘
```

Agent가 `provision-skill` 스킬을 따라 `provision-skill.ps1`을 실행합니다 (카탈로그에 해당 ID가 있을 때 자동 설치).

```powershell
& "$env:HARNESS_HOME\scripts\provision-skill.ps1" -Query "hwpx 스킬 구성해줘"
```

설계 중 특정 스킬만 받을 때:

```powershell
.\scripts\install-skills.ps1 -Skills typescript-expert,webapp-testing -TargetDir .agent\skills
```

하네스 구성 완료 후 대상 프로젝트에 `.harness/skills.lock.yaml`을 만들고 팀 repo에 커밋하세요. 예시: [.harness/skills.lock.yaml.example](.harness/skills.lock.yaml.example)

> **금지:** 카탈로그 전체(~1,300개)를 `~/.gemini/antigravity/skills/`에 복사하지 마세요.

## 사용법

Antigravity 채팅에서 예:

```
하네스 구성해줘. 이 프로젝트는 API 문서 자동화야.
```

```
Build a harness for deep research with parallel investigators.
```

에이전트가 6단계 워크플로(도메인 분석 → 아키텍처 → 에이전트/스킬 생성 → 오케스트레이션 → 검증 → 진화)를 따르며, 대상 프로젝트에 다음을 생성합니다:

```
your-project/
├── .agent/
│   ├── agents/          # 에이전트 정의
│   └── skills/          # lock 기준 설치된 스킬
├── AGENTS.md            # 하네스 트리거 포인터 (간단히)
└── _workspace/          # 실행 시 중간 산출물 (런타임)
```

## 구조

```
하네스_안티그래비티/
├── skills/
│   ├── harness/                  # 메타 스킬 (6 Phase)
│   └── provision-skill/
├── skills/catalog-index.yaml
├── scripts/
│   ├── install-skills.ps1        # lock → 로컬 카탈로그에서 Junction
│   └── provision-skill.ps1
├── .harness/skills.lock.yaml.example
└── docs/
    ├── TEAM-WORKFLOW.md
    └── quickstart-antigravity.md
```

**스킬 카탈로그:** [namkibok/ant-skills](https://github.com/namkibok/ant-skills) — 로컬 `E:\workspace\skills\antigravity` 또는 `HARNESS_SKILL_CATALOG`.

## 아키텍처 패턴 (동일)

파이프라인 · 팬아웃/팬인 · 전문가 풀 · 생성-검증 · 감독자 · 계층적 위임

## 문서

- [팀 워크플로 (설계자 / 개발자)](docs/TEAM-WORKFLOW.md)
- [Antigravity 빠른 시작](docs/quickstart-antigravity.md)
- [런타임 매핑 상세](skills/harness/references/antigravity-runtime-mapping.md)

## 라이선스

Apache 2.0 — 원본 [revfactory/harness](https://github.com/revfactory/harness)와 동일.

## 크레딧

팀 아키텍처·워크플로우: **RevFactory / Min Hwang** — [revfactory/harness](https://github.com/revfactory/harness)  
Antigravity 포트: [namkibok/harness_ant](https://github.com/namkibok/harness_ant) · Cursor 포트: [namkibok/harness_v2](https://github.com/namkibok/harness_v2)
