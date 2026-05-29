# Harness for Cursor

[revfactory/harness](https://github.com/revfactory/harness)의 **Cursor AI** 포트입니다. 도메인 한 줄 → 전문 에이전트 팀 + 스킬을 설계·생성하는 **L3 메타 팩토리(팀 아키텍처)** 역할은 동일하고, 런타임만 Cursor에 맞게 바뀌었습니다.

**English summary:** Same Harness meta-skill; outputs go to `.cursor/agents/` and `.cursor/skills/`; orchestration uses Cursor `Task` subagents instead of Claude Code `TeamCreate` / `SendMessage`.

## Claude Code vs Cursor

| 항목 | Claude Code (원본) | Cursor (이 포트) |
|------|-------------------|------------------|
| 에이전트 정의 | `.claude/agents/` | `.cursor/agents/` |
| 스킬 | `.claude/skills/` | `.cursor/skills/` |
| 세션 포인터 | `CLAUDE.md` | `AGENTS.md` 또는 `.cursor/rules/harness.mdc` |
| 멀티 에이전트 | `TeamCreate`, `SendMessage` | 병렬 `Task` + `_workspace/` |
| 설치 | `/plugin install harness@harness` | `skills/harness` → `~/.cursor/skills/harness` |
| 실험 플래그 | `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` | **불필요** |

## 설치 (팀 · Git)

역할별 상세: **[docs/TEAM-WORKFLOW.md](docs/TEAM-WORKFLOW.md)**

| 역할 | 필요한 것 |
|------|----------|
| **일반 개발자** | 프로젝트 repo + `.harness/skills.lock.yaml` → `install-skills.ps1` (카탈로그 전체 clone **불필요**) |
| **하네스 설계자** | harness_v2 + `~/.cursor/skills/harness` |

### 일반 개발자 — 필요한 스킬만 설치

프로젝트에 `.harness/skills.lock.yaml`이 있으면:

```powershell
git clone https://github.com/your-org/your-project.git
cd your-project

git clone https://github.com/namkibok/harness_v2.git $env:TEMP\harness_v2
& "$env:TEMP\harness_v2\scripts\install-skills.ps1" -LockFile .harness\skills.lock.yaml
```

`install-skills.ps1`은 [cursor-skills](https://github.com/namkibok/cursor-skills)에서 **lock에 적힌 스킬만** sparse checkout 후 `.cursor/skills/`에 Junction 합니다.  
팀이 `.cursor/skills/`를 repo에 커밋해 두었다면 위 스크립트는 생략 가능합니다.

### 하네스 설계자 — 메타 스킬 설치

```powershell
git clone https://github.com/namkibok/harness_v2.git
cd harness_v2
Copy-Item -Recurse -Force "skills\harness" "$env:USERPROFILE\.cursor\skills\harness"
```

카탈로그 submodule(`--recurse-submodules`)은 **선택**입니다. 설계 중 특정 스킬만 받을 때:

```powershell
.\scripts\install-skills.ps1 -Skills typescript-expert,webapp-testing -TargetDir .cursor\skills
```

하네스 구성 완료 후 대상 프로젝트에 `.harness/skills.lock.yaml`을 만들고 팀 repo에 커밋하세요. 예시: [.harness/skills.lock.yaml.example](.harness/skills.lock.yaml.example)

> **금지:** 카탈로그 전체(~1,300개)를 `~/.cursor/skills/`에 복사하지 마세요.

## 사용법

Cursor 채팅에서 예:

```
하네스 구성해줘. 이 프로젝트는 API 문서 자동화야.
```

```
Build a harness for deep research with parallel investigators.
```

에이전트가 6단계 워크플로(도메인 분석 → 아키텍처 → 에이전트/스킬 생성 → 오케스트레이션 → 검증 → 진화)를 따르며, 대상 프로젝트에 다음을 생성합니다:

```
your-project/
├── .cursor/
│   ├── agents/          # 서브에이전트 정의
│   └── skills/          # 도메인 스킬
├── AGENTS.md            # 하네스 트리거 포인터 (간단히)
└── _workspace/          # 실행 시 중간 산출물 (런타임)
```

## 구조

```
harness_v2/
├── skills/
│   ├── harness/                  # 메타 스킬 (6 Phase)
│   └── catalog/                  # submodule (선택)
├── skills/catalog-index.yaml
├── scripts/install-skills.ps1    # lock → sparse fetch
├── .harness/skills.lock.yaml.example
└── docs/
    ├── TEAM-WORKFLOW.md
    └── quickstart-cursor.md
```

카탈로그 소스: [namkibok/cursor-skills](https://github.com/namkibok/cursor-skills). 서브모듈 업데이트: `git submodule update --remote skills/catalog`.

## 아키텍처 패턴 (동일)

파이프라인 · 팬아웃/팬인 · 전문가 풀 · 생성-검증 · 감독자 · 계층적 위임

## 문서

- [팀 워크플로 (설계자 / 개발자)](docs/TEAM-WORKFLOW.md)
- [Cursor 빠른 시작](docs/quickstart-cursor.md)
- [런타임 매핑 상세](skills/harness/references/cursor-runtime-mapping.md)

## 라이선스

Apache 2.0 — 원본 [revfactory/harness](https://github.com/revfactory/harness)와 동일.

## 크레딧

팀 아키텍처·워크플로우: **RevFactory / Min Hwang** — [revfactory/harness](https://github.com/revfactory/harness)  
Cursor 포트: [namkibok/harness_v2](https://github.com/namkibok/harness_v2)
