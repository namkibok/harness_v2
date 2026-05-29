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

### GitHub에서 clone (권장)

메타 스킬 + **스킬 카탈로그 서브모듈**(`skills/catalog` → [namkibok/cursor-skills](https://github.com/namkibok/cursor-skills))을 함께 받습니다.

```powershell
git clone --recurse-submodules https://github.com/namkibok/harness_v2.git
cd harness_v2

# 이미 clone한 경우 서브모듈만 받기
# git submodule update --init --recursive

Copy-Item -Recurse -Force "skills\harness" "$env:USERPROFILE\.cursor\skills\harness"
$env:HARNESS_SKILL_CATALOG = "$PWD\skills\catalog"
```

설치 후 Cursor를 재시작하거나 새 채팅을 열면 `harness` 스킬이 후보에 포함됩니다.

> 카탈로그 전체를 `~/.cursor/skills/`에 복사하지 마세요. Harness Phase 4가 프로젝트마다 3~8개만 골라 `.cursor/skills/`에 링크합니다.

### 저장소를 이미 클론한 경우

```powershell
Copy-Item -Recurse -Force "skills\harness" "$env:USERPROFILE\.cursor\skills\harness"
$env:HARNESS_SKILL_CATALOG = "$(Get-Location)\skills\catalog"
```

### 프로젝트에만 두기

```powershell
New-Item -ItemType Directory -Force -Path ".cursor\skills"
Copy-Item -Recurse -Force "skills\harness" ".cursor\skills\harness"
```

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
│   │   └── references/
│   │       ├── skill-catalog.md  # 카탈로그 연동 규칙
│   │       └── ...
│   └── catalog/                  # submodule → github.com/namkibok/cursor-skills
├── skills/catalog-index.yaml     # 도메인별 추천 스킬 ID
└── docs/
    ├── quickstart-cursor.md
    └── SPLIT-CATALOG-SUBMODULE.md  # 선택: 별도 repo + submodule 분리
```

카탈로그 소스: [namkibok/cursor-skills](https://github.com/namkibok/cursor-skills). 서브모듈 업데이트: `git submodule update --remote skills/catalog`.

## 아키텍처 패턴 (동일)

파이프라인 · 팬아웃/팬인 · 전문가 풀 · 생성-검증 · 감독자 · 계층적 위임

## 문서

- [Cursor 빠른 시작](docs/quickstart-cursor.md)
- [런타임 매핑 상세](skills/harness/references/cursor-runtime-mapping.md)

## 라이선스

Apache 2.0 — 원본 [revfactory/harness](https://github.com/revfactory/harness)와 동일.

## 크레딧

팀 아키텍처·워크플로우: **RevFactory / Min Hwang** — [revfactory/harness](https://github.com/revfactory/harness)  
Cursor 포트: [namkibok/harness_v2](https://github.com/namkibok/harness_v2)
