# Harness for Cursor — Quickstart

## 설계자 (하네스 처음 구성)

```powershell
git clone https://github.com/namkibok/harness_v2.git
cd harness_v2
Copy-Item -Recurse -Force "skills\harness" "$env:USERPROFILE\.cursor\skills\harness"
```

Cursor에서: `하네스 구성해줘. 이 프로젝트는 …`

구성 후 대상 프로젝트에 `.harness/skills.lock.yaml` + `install-skills.ps1` 실행.  
상세: [TEAM-WORKFLOW.md](TEAM-WORKFLOW.md)

## 개발자 (이미 하네스 있는 프로젝트)

```powershell
git clone https://github.com/your-org/your-project.git
cd your-project

git clone https://github.com/namkibok/harness_v2.git $env:TEMP\harness_v2
& "$env:TEMP\harness_v2\scripts\install-skills.ps1" -LockFile .harness\skills.lock.yaml
Copy-Item -Recurse -Force "$env:TEMP\harness_v2\skills\harness" "$env:USERPROFILE\.cursor\skills\harness"
```

카탈로그 submodule / 1,300개 전체 clone **불필요**.

## 기대 산출물 (프로젝트)

| 경로 | 내용 |
|------|------|
| `.harness/skills.lock.yaml` | 채택 스킬 ID (팀 공유) |
| `.cursor/agents/*.md` | 서브에이전트 |
| `.cursor/skills/*/SKILL.md` | lock 기준 설치된 스킬 |
| `AGENTS.md` | 하네스 트리거 포인터 |

## 문제 해결

**스킬이 안 붙는다** — lock 실행 여부, `.cursor/skills/{name}/SKILL.md` 존재 확인  
**git sparse 실패** — Git 2.25+ 필요, `git --version` 확인
