# 오케스트레이터 스킬 템플릿

오케스트레이터는 팀 전체를 조율하는 상위 스킬이다. 실행 모드별로 3가지 템플릿을 제공한다:

- **템플릿 A: 병렬 Task 팀 모드 (기본)** — 2명 이상 협업 시 최우선 선택
- **템플릿 B: 서브 에이전트 모드 (대안)** — 팀 통신이 불필요한 경우
- **템플릿 C: 하이브리드 모드** — Phase마다 모드를 섞어 구성

---

## 템플릿 A: 병렬 Task 팀 모드 (기본 · 최우선 선택)

2명 이상의 에이전트가 협업할 때 **가장 먼저 검토하는 기본 모드**. `병렬 Task`로 팀을 구성하고, 공유 작업 목록과 `handoff 파일 또는 다음 Task prompt에 맥락 포함`로 조율한다.

```markdown
---
name: {domain}-orchestrator
description: "{도메인} 병렬 Task 팀을 조율하는 오케스트레이터. {초기 실행 키워드}. 후속 작업: {도메인} 결과 수정, 부분 재실행, 업데이트, 보완, 다시 실행, 이전 결과 개선 요청 시에도 반드시 이 스킬을 사용."
---

# {Domain} Orchestrator

{도메인}의 병렬 Task 팀을 조율하여 {최종 산출물}을 생성하는 통합 스킬.

## 실행 모드: 병렬 Task 팀

## 에이전트 구성

| 팀원 | 에이전트 타입 | 역할 | 스킬 | 출력 |
|------|-------------|------|------|------|
| {teammate-1} | {커스텀 또는 빌트인} | {역할} | {skill} | {output-file} |
| {teammate-2} | {커스텀 또는 빌트인} | {역할} | {skill} | {output-file} |
| ... | | | | |

## 워크플로우

### Phase 0: 컨텍스트 확인 (후속 작업 지원)

기존 산출물 존재 여부를 확인하여 실행 모드를 결정한다:

1. `_workspace/` 디렉토리 존재 여부 확인
2. 실행 모드 결정:
   - **`_workspace/` 미존재** → 초기 실행. Phase 1로 진행
   - **`_workspace/` 존재 + 사용자가 부분 수정 요청** → 부분 재실행. 해당 에이전트만 재호출하고, 기존 산출물 중 수정 대상만 덮어쓴다
   - **`_workspace/` 존재 + 새 입력 제공** → 새 실행. 기존 `_workspace/`를 `_workspace_{YYYYMMDD_HHMMSS}/`로 이동한 뒤 Phase 1 진행
3. 부분 재실행 시: 이전 산출물 경로를 에이전트 프롬프트에 포함하여, 에이전트가 기존 결과를 읽고 피드백을 반영하도록 지시

### Phase 1: 준비
1. 사용자 입력 분석 — {무엇을 파악하는지}
2. 작업 디렉토리에 `_workspace/` 생성
   - **초기 실행**: 새 `_workspace/` 생성
   - **새 실행**: 기존 `_workspace/`를 `_workspace_{YYYYMMDD_HHMMSS}/`로 이동한 직후 새 `_workspace/` 재생성
3. 입력 데이터를 `_workspace/00_input/`에 저장

### Phase 2: 병렬 Task 실행

1. `_workspace/00_brief.md`에 공통 브리프·출력 경로 규칙 기록
2. 팀원마다 `Task` 병렬 호출 (`run_in_background: true`):

   ```
   Task(
     description: "{teammate-1} {작업 요약}",
     prompt: "Read .cursor/agents/{teammate-1}.md 와 .cursor/skills/{skill}/SKILL.md.
              입력: _workspace/00_brief.md
              출력: _workspace/02_{teammate-1}_{artifact}.md
              {역할별 상세 지시}",
     subagent_type: "{teammate-1}" | "generalPurpose" | "explore",
     run_in_background: true
   )
   ```

3. (선택) `TodoWrite`로 작업·의존 관계 추적

### Phase 3: {주요 작업 — 예: 조사/생성/분석}

**실행 방식:** 병렬 Task 완료 대기 → 산출물 Read

**핸드오프 (2차 라운드 필요 시):**
- `_workspace/handoff/{from}-to-{to}.md` 작성 후 해당 팀원만 `Task` 재실행
- 또는 통합 Phase에서 메인이 상충 해결

**산출물 저장:**

| 팀원 | 출력 경로 |
|------|----------|
| {teammate-1} | `_workspace/{phase}_{teammate-1}_{artifact}.md` |
| {teammate-2} | `_workspace/{phase}_{teammate-2}_{artifact}.md` |

**오케스트레이터 모니터링:**
- background `Task` 완료 알림 또는 `Await`로 대기
- 실패 시 1회 재시도, handoff에 원인 기록
- `TodoWrite` + `_workspace/` 파일 존재 여부로 진행 확인

### Phase 4: {후속 작업 — 예: 검증/통합}
1. 모든 팀원의 작업 완료 대기 (TodoWrite / 산출물 Read으로 상태 확인)
2. 각 팀원의 산출물을 Read로 수집
3. {통합/검증 로직}
4. 최종 산출물 생성: `{output-path}/{filename}`

### Phase 5: 정리
1. `_workspace/` 보존 (감사·재실행용)
2. 최종 산출물 경로를 사용자에게 보고
3. 다음 Phase가 있으면 `_workspace/` 기반으로 새 `Task` 세트 실행

> **Phase 간 전문가 교체:** 산출물은 `_workspace/`에 두고, 다음 Phase용 `Task` prompt만 갱신한다.

## 데이터 흐름

```
[리더] → 병렬 Task → [teammate-1] ←handoff 파일 또는 다음 Task prompt에 맥락 포함→ [teammate-2]
                          │                           │
                          ↓                           ↓
                    artifact-1.md              artifact-2.md
                          │                           │
                          └───────── Read ────────────┘
                                     ↓
                              [리더: 통합]
                                     ↓
                              최종 산출물
```

## 에러 핸들링

| 상황 | 전략 |
|------|------|
| 팀원 1명 실패/중지 | 리더가 감지 → handoff 파일 또는 다음 Task prompt에 맥락 포함로 상태 확인 → 재시작 또는 대체 팀원 생성 |
| 팀원 과반 실패 | 사용자에게 알리고 진행 여부 확인 |
| 타임아웃 | 현재까지 수집된 부분 결과 사용, 미완료 팀원 종료 |
| 팀원 간 데이터 충돌 | 출처 명시 후 병기, 삭제하지 않음 |
| 작업 상태 지연 | 리더가 TodoWrite / 산출물 Read으로 확인 후 수동으로 TodoWrite |

## 테스트 시나리오

### 정상 흐름
1. 사용자가 {입력}을 제공
2. Phase 1에서 {분석 결과} 도출
3. Phase 2에서 팀 구성 ({N}명 팀원 + {M}개 작업)
4. Phase 3에서 팀원들이 자체 조율하며 작업 수행
5. Phase 4에서 산출물 통합하여 최종 결과 생성
6. Phase 5에서 팀 정리
7. 예상 결과: `{output-path}/{filename}` 생성

### 에러 흐름
1. Phase 3에서 {teammate-2}가 에러로 중지
2. 리더가 유휴 알림 수신
3. handoff 파일 또는 다음 Task prompt에 맥락 포함로 상태 확인 → 재시작 시도
4. 재시작 실패 시 {teammate-2} 작업을 {teammate-1}에게 재할당
5. 나머지 결과로 Phase 4 진행
6. 최종 보고서에 "{teammate-2} 영역 일부 미수집" 명시
```

---

## 템플릿 B: 서브 에이전트 모드 (대안)

팀 통신 오버헤드가 불필요한 경우. `Task` 도구로 직접 호출하고 반환값으로 결과를 수집한다.

```markdown
---
name: {domain}-orchestrator
description: "{도메인} 에이전트를 조율하는 오케스트레이터. {초기 실행 키워드}. 후속 작업 키워드 포함."
---

## 실행 모드: 서브 에이전트

## 에이전트 구성

| 에이전트 | subagent_type | 역할 | 스킬 | 출력 |
|---------|--------------|------|------|------|
| {agent-1} | {빌트인 또는 커스텀} | {역할} | {skill} | {output-file} |
| {agent-2} | ... | ... | ... | ... |

## 워크플로우

### Phase 0: 컨텍스트 확인
(Template A와 동일 — `_workspace/` 존재 여부 분기)

### Phase 1: 준비
1. 입력 분석
2. `_workspace/` 생성 (초기 실행 시, 또는 새 실행에서 기존 `_workspace/`를 보관 디렉토리로 이동한 직후)

### Phase 2: 병렬 실행
단일 메시지에서 N개 Task 도구를 동시 호출:

| 에이전트 | 입력 | 출력 | model | run_in_background |
|---------|------|------|-------|-------------------|
| {agent-1} | {소스} | `_workspace/{phase}_{agent}_{artifact}.md` | opus | true |
| {agent-2} | {소스} | `_workspace/{phase}_{agent}_{artifact}.md` | opus | true |

### Phase 3: 통합
1. 각 에이전트의 반환값 수집
2. 파일 기반 산출물은 Read로 수집
3. 통합 로직 적용 → 최종 산출물

### Phase 4: 정리
1. `_workspace/` 보존
2. 결과 요약 보고

## 에러 핸들링
- 에이전트 1개 실패: 1회 재시도. 재실패 시 누락 명시하고 진행
- 과반 실패: 사용자에게 알리고 진행 여부 확인
- 타임아웃: 현재까지 수집된 부분 결과 사용
```

---

## 템플릿 C: 하이브리드 모드

Phase마다 다른 실행 모드를 사용한다. 각 Phase 상단에 `**실행 모드:** {팀 | 서브}`를 명시한다.

```markdown
---
name: {domain}-orchestrator
description: "{도메인} 오케스트레이터 (하이브리드). {키워드}. 후속 작업 키워드 포함."
---

## 실행 모드: 하이브리드

| Phase | 모드 | 이유 |
|-------|------|------|
| Phase 2 (병렬 수집) | 서브 에이전트 | 독립 자료 수집, 팀 통신 불필요 |
| Phase 3 (합의 통합) | 병렬 Task 팀 | 상충 데이터 토론·합의 필요 |
| Phase 4 (독립 검증) | 서브 에이전트 | QA 에이전트 1명이 객관 검증 |

## 워크플로우

### Phase 2: 병렬 자료 수집
**실행 모드:** 서브 에이전트

단일 메시지에서 Task 도구로 N개 에이전트 병렬 호출 (`run_in_background: true`).
각 결과는 `_workspace/02_{agent}_raw.md`에 저장.

### Phase 3: 합의 기반 통합
**실행 모드:** 병렬 Task 팀

1. `병렬 Task`로 통합 팀 구성 (editor + fact-checker + synthesizer)
2. `TodoWrite`로 작업 분배 — 모두 Phase 2의 `_workspace/02_*` 파일을 Read
3. 팀원들이 `handoff 파일 또는 다음 Task prompt에 맥락 포함`로 상충 데이터를 논의, 파일 기반으로 합의안 도출
4. 최종 통합본 `_workspace/03_integrated.md` 생성
5. `(이전 Phase 산출물 보존 후)`로 팀 정리

### Phase 4: 독립 검증
**실행 모드:** 서브 에이전트

단일 QA 서브 에이전트가 `_workspace/03_integrated.md`를 입력으로 받아 검증 보고서 생성.
```

**하이브리드 전환 규칙:**
- 팀 → 서브: 팀을 반드시 `(이전 Phase 산출물 보존 후)`로 정리한 후 Task 도구 호출
- 서브 → 팀: 서브 에이전트의 파일 산출물을 팀원들에게 Read 경로로 전달
- 팀 → 팀: 이전 팀을 정리한 후 새 `병렬 Task` (세션당 1팀만 활성 가능)

---

## 작성 원칙

1. **실행 모드를 먼저 명시** — 오케스트레이터 상단에 "병렬 Task 팀" / "서브 에이전트" / "하이브리드" 중 하나 명시. 하이브리드면 Phase별 모드 표 필수
2. **팀 모드는 병렬 Task/handoff 파일 또는 다음 Task prompt에 맥락 포함/TodoWrite 사용법을 구체적으로** — 팀 구성, 작업 등록, 통신 규칙
3. **서브 모드는 Task 도구 파라미터를 완전히 명시** — name, subagent_type, prompt, run_in_background, model
4. **파일 경로는 절대적으로** — 상대 경로 금지, `_workspace/` 기준 명확한 경로
5. **Phase 간 의존성 명시** — 어떤 Phase가 어떤 Phase의 결과에 의존하는지. 하이브리드는 모드 전환 지점을 특히 강조
6. **에러 핸들링은 현실적으로** — "모든 것이 성공한다"고 가정하지 않음
7. **테스트 시나리오 필수** — 정상 1 + 에러 1 이상

## description 작성 시 후속 작업 키워드

오케스트레이터 description은 초기 실행 키워드만으로는 부족하다. 다음 후속 작업 표현을 반드시 포함하라:

- 재실행/다시 실행/업데이트/수정/보완
- "{도메인}의 {부분}만 다시"
- "이전 결과 기반으로", "결과 개선"
- 도메인 관련 일상적 요청 (예: 런치 전략 하네스라면 "런치", "홍보", "트렌딩" 등)

후속 키워드가 없으면 첫 실행 후 하네스가 사실상 죽은 코드가 된다.

## 실제 오케스트레이터 참고

팬아웃/팬인 패턴의 오케스트레이터 기본 구조:
준비 → Phase 0(컨텍스트 확인) → 병렬 Task + TodoWrite → N개 팀원 병렬 실행 → Read + 통합 → 정리.
`references/team-examples.md`의 리서치 팀 예시를 참조.
