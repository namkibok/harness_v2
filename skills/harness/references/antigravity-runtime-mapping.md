# Antigravity 런타임 매핑 (Claude Code Harness → Google Antigravity)

원본 Harness는 Claude Code의 **Agent Teams**(`TeamCreate`, `SendMessage`, `TaskCreate`)에 최적화되어 있다. Antigravity 포트는 **동일한 팀 아키텍처 사고방식**을 유지하되, Antigravity의 스킬·에이전트 디렉터리와 **파일 기반 조율**(`_workspace/`)로 구현한다.

## 경로 매핑

| Claude Code | Cursor (이전 포트) | Antigravity (이 포트) |
|-------------|-------------------|------------------------|
| `.claude/agents/{name}.md` | `.cursor/agents/{name}.md` | `.agent/agents/{name}.md` |
| `.claude/skills/{name}/SKILL.md` | `.cursor/skills/{name}/SKILL.md` | `.agent/skills/{name}/SKILL.md` |
| `~/.claude/skills/harness/` | `~/.cursor/skills/harness/` | `~/.gemini/antigravity/skills/harness/` |
| `CLAUDE.md` (하네스 포인터) | `AGENTS.md` / `.cursor/rules/` | **`AGENTS.md`** (권장) 또는 프로젝트 규칙 파일 |
| 스킬 카탈로그 | `cursor-skills` (GitHub) | **[ant-skills](https://github.com/namkibok/ant-skills)** · 로컬 `E:\workspace\skills\antigravity` |

## 스킬 카탈로그 (필수)

| 우선순위 | 소스 |
|----------|------|
| 1 | `HARNESS_SKILL_CATALOG` |
| 2 | 로컬 `E:\workspace\skills\antigravity` |
| 3 | sparse clone [namkibok/ant-skills](https://github.com/namkibok/ant-skills) (`install-skills.ps1`) |

카탈로그 전체를 `~/.gemini/antigravity/skills/`에 복사하지 말 것 — lock에 있는 ID만 Junction/Copy.

## 실행 모드 매핑

| Harness 개념 | Claude Code | Antigravity 구현 |
|--------------|-------------|------------------|
| **에이전트 팀** (기본) | `TeamCreate` + `SendMessage` | **병렬 위임** + `_workspace/` 산출물 + 오케스트레이터 Read·통합 (handoff 2차 라운드) |
| **서브 에이전트** | `Agent` 단일/병렬 | 단일·순차 위임, 반환값 + 파일 수집 |
| **하이브리드** | Phase별 팀/서브 전환 | Phase별 병렬 vs 순차 명시 |
| 팀원 간 메시지 | `SendMessage` | `_workspace/handoff/{from}-to-{to}.md` 또는 다음 위임 prompt에 이전 산출물 요약 |
| 공유 작업 목록 | `TaskCreate` / `TaskUpdate` | `_workspace/tasks.md` (선택) |
| 커스텀 에이전트 | `.claude/agents/` | `.agent/agents/{name}.md` — 위임 시 파일 전문·역할 준수 |

## 스킬 로딩

Antigravity는 채팅에서 **`@skill-name`**으로 스킬을 호출한다. 오케스트레이터·에이전트 정의에는 다음을 명시한다:

1. 관련 스킬이 있으면 `@skill-name`으로 로드하거나 `.agent/skills/{name}/SKILL.md`를 Read
2. 에이전트 위임 prompt에 스킬 경로·입출력 `_workspace/` 경로 포함

## 병렬 팀 워크플로 (SendMessage 대체)

1. 오케스트레이터가 `_workspace/00_brief.md`에 공통 브리프 작성
2. 팀원마다 **독립 위임** — 각 prompt에 브리프 경로 + `.agent/agents/{name}.md` 준수 + 출력 경로
3. 산출물 Read 후 통합
4. 상호 피드백 필요 시 `_workspace/handoff/` 메모 후 **해당 팀원만 재실행**
5. 오케스트레이터가 통합 산출물 작성

## 위임 체크리스트 (오케스트레이터용)

```text
위임 시 포함할 내용:
  1) .agent/agents/{name}.md 전문을 따를 것
  2) .agent/skills/{skill}/SKILL.md 또는 @skill-name 적용
  3) 입력: _workspace/...
  4) 출력: _workspace/{phase}_{agent}_{artifact}.md
```

## 설치

```powershell
# 하네스 repo 루트
$env:HARNESS_HOME = "C:\path\to\harness_ant"  # git clone https://github.com/namkibok/harness_ant.git
$env:HARNESS_SKILL_CATALOG = "E:\workspace\skills\antigravity"

# 전역 메타 스킬 (권장)
$agSkills = Join-Path $env:USERPROFILE ".gemini\antigravity\skills"
New-Item -ItemType Directory -Force -Path $agSkills | Out-Null
Copy-Item -Recurse -Force "$env:HARNESS_HOME\skills\harness" "$agSkills\harness"
Copy-Item -Recurse -Force "$env:HARNESS_HOME\skills\provision-skill" "$agSkills\provision-skill"
```

트리거: **"하네스 구성해줘"**, **"Build a harness for this project"**
