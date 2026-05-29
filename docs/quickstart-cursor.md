# Harness for Cursor — Quickstart

5분 안에 메타 스킬을 설치하고 첫 하네스를 생성합니다.

## 1. 설치

```powershell
git clone --recurse-submodules https://github.com/namkibok/harness_v2.git
cd harness_v2
Copy-Item -Recurse -Force "skills\harness" "$env:USERPROFILE\.cursor\skills\harness"
$env:HARNESS_SKILL_CATALOG = "$PWD\skills\catalog"
```

## 2. 트리거

Cursor Agent 채팅:

```
하네스 구성해줘. 이 저장소는 React + FastAPI 풀스택이고,
코드 리뷰·보안·테스트를 병렬로 돌리는 팀이 필요해.
```

## 3. 기대 산출물

| 경로 | 내용 |
|------|------|
| `.cursor/agents/*.md` | 역할·프로토콜·핸드오프 |
| `.cursor/skills/*/SKILL.md` | 절차·references |
| `.cursor/skills/*-orchestrator/SKILL.md` | 팀 조율 |
| `AGENTS.md` | 트리거 한 줄 + 변경 이력 |

## 4. 첫 실행

오케스트레이터 스킬이 생성된 뒤:

```
{도메인} 오케스트레이터로 샘플 작업 한 번 돌려줘.
```

오케스트레이터는 `_workspace/`에 중간 파일을 쓰고, 병렬 `Task`로 팀원을 호출합니다.

## 5. Claude Code 원본과의 차이

- `TeamCreate` 없음 → **병렬 `Task`**
- `SendMessage` 없음 → **`_workspace/handoff/`** 또는 prompt에 맥락
- 플러그인 마켓플레이스 없음 → **스킬 폴더 복사**

자세한 표: [cursor-runtime-mapping.md](../skills/harness/references/cursor-runtime-mapping.md)

## 문제 해결

**스킬이 안 붙는다**  
- `~/.cursor/skills/harness/SKILL.md` 존재 확인  
- description에 "하네스" 키워드 포함 여부 확인  
- 채팅에서 `@harness` 또는 "harness 스킬 사용" 명시

**서브에이전트가 커스텀 이름으로 안 뜬다**  
- `.cursor/agents/{name}.md`의 frontmatter `name`과 `Task`의 `subagent_type` 일치 확인
