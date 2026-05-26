# Cursor 런타임 매핑 (Claude Code Harness → Cursor)

원본 Harness는 Claude Code의 실험적 **Agent Teams**(`TeamCreate`, `SendMessage`, `TaskCreate`)에 최적화되어 있다. Cursor 포트는 **동일한 팀 아키텍처 사고방식**을 유지하되, Cursor Agent가 제공하는 **`Task` 서브에이전트**와 **파일 기반 조율**로 구현한다.

## 경로 매핑

| Claude Code | Cursor |
|-------------|--------|
| `.claude/agents/{name}.md` | `.cursor/agents/{name}.md` |
| `.claude/skills/{name}/SKILL.md` | `.cursor/skills/{name}/SKILL.md` |
| `~/.claude/skills/harness/` | `~/.cursor/skills/harness/` |
| `CLAUDE.md` (하네스 포인터) | `AGENTS.md` 또는 `.cursor/rules/harness.mdc` (`alwaysApply: true`) |

## 실행 모드 매핑

| Harness 개념 | Claude Code | Cursor 구현 |
|--------------|-------------|-------------|
| **에이전트 팀** (기본) | `TeamCreate` + `SendMessage` + `TaskCreate` | **병렬 Task 팀**: `Task`를 `run_in_background: true`로 동시에 여러 개 실행 + `_workspace/` 산출물 + 오케스트레이터가 Read·통합 |
| **서브 에이전트** | `Agent` 단일/병렬 | `Task` 단일 또는 순차 호출 (`run_in_background` 선택) |
| **하이브리드** | Phase별 팀/서브 전환 | Phase별 병렬 Task vs 순차 Task |
| 팀원 간 메시지 | `SendMessage` | `_workspace/handoff/{from}-to-{to}.md` 또는 오케스트레이터가 다음 Task `prompt`에 이전 산출물 요약 포함 |
| 공유 작업 목록 | `TaskCreate` / `TaskUpdate` | `TodoWrite` + `_workspace/tasks.md` (선택) |
| 커스텀 에이전트 | `.claude/agents/` + `subagent_type` | `.cursor/agents/{name}.md` — `Task`의 `subagent_type`에 **파일의 `name`** 사용 (빌트인: `generalPurpose`, `explore`, `shell` 등) |

## 빌트인 subagent_type

| 역할 | Cursor `subagent_type` | 비고 |
|------|------------------------|------|
| 범용·웹·구현 | `generalPurpose` | 기본 |
| 읽기 전용 탐색·분석 | `explore` | `readonly: true` 가능 |
| 터미널·git | `shell` | 명령 실행 |
| 계획·설계만 | `explore` 또는 `SwitchMode` → `plan` | 파일 수정 금지 지침을 에이전트 정의에 명시 |

## Task 호출 체크리스트 (오케스트레이터용)

```text
Task(
  description: "3~5단어 요약",
  prompt: "
    1) .cursor/agents/{name}.md 전문을 따를 것
    2) .cursor/skills/{skill}/SKILL.md가 있으면 Read 후 적용
    3) 입력: _workspace/...
    4) 출력: _workspace/{phase}_{agent}_{artifact}.md
  ",
  subagent_type: "{name}" | "generalPurpose" | "explore" | "shell",
  run_in_background: true,   // 병렬 팀 시
  model: "{사용자 지정 시만}"
)
```

## 병렬 팀 워크플로 (SendMessage 대체)

1. 오케스트레이터가 `_workspace/00_brief.md`에 공통 브리프 작성
2. 팀원마다 `Task(..., run_in_background: true)` — 각 prompt에 브리프 경로 + 역할 + 출력 경로
3. `Await` 또는 완료 알림 후 산출물 Read
4. 상호 피드백이 필요하면: `_workspace/handoff/` 메모 작성 후 **해당 팀원만 재실행** (2차 라운드)
5. 오케스트레이터가 통합 산출물 작성

## 스킬 로딩

Cursor는 `description` 기반으로 스킬을 자동 선택한다. 에이전트 prompt에 "먼저 `.cursor/skills/{x}/SKILL.md`를 Read하라"고 명시하면 확실히 적용된다.

## 설치

```powershell
# 사용자 전역 (권장)
Copy-Item -Recurse skills\harness "$env:USERPROFILE\.cursor\skills\harness"

# 프로젝트에 메타 스킬만 둘 때
Copy-Item -Recurse skills\harness .cursor\skills\harness
```

트리거: **"하네스 구성해줘"**, **"Build a harness for this project"**
