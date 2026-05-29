# 팀 워크플로 — 설계자 vs 개발자

카탈로그(~1,300 skills) **전체 clone은 필수가 아닙니다.** 역할별로 필요한 것만 받습니다.

## 역할 요약

| | 하네스 설계자 | 일반 개발자 |
|---|-------------|------------|
| **하는 일** | "하네스 구성해줘", 에이전트/스킬 선별 | 프로젝트 기능 개발 |
| **clone** | [harness_v2](https://github.com/namkibok/harness_v2) (submodule **선택**) | **프로젝트 repo만** |
| **카탈로그** | sparse fetch 또는 설계 시에만 | **불필요** (lock + install-skills) |
| **전역** | `~/.cursor/skills/harness` | 동일 (메타 스킬 1개) |

## 말만 하면 스킬 설치 (provision-skill)

전역에 `provision-skill` 설치 후, 프로젝트에서:

```
typescript-expert 스킬 구성해줘
```

Agent → `provision-skill.ps1 -Query "..."` → cursor-skills에서 해당 ID만 설치.

## 일반 개발자 (권장)

프로젝트에 `.harness/skills.lock.yaml`과 `.cursor/skills/`(또는 lock만)가 있습니다.

```powershell
git clone https://github.com/your-org/your-project.git
cd your-project

# lock에 적힌 스킬만 GitHub에서 sparse로 받아 .cursor/skills/에 연결
git clone https://github.com/namkibok/harness_v2.git $env:TEMP\harness_v2
& "$env:TEMP\harness_v2\scripts\install-skills.ps1" -LockFile .harness\skills.lock.yaml
```

또는 팀이 `.cursor/skills/`를 **이미 Git에 커밋**해 두었다면 **추가 설치 없음**.

```powershell
Copy-Item -Recurse -Force "$env:TEMP\harness_v2\skills\harness" "$env:USERPROFILE\.cursor\skills\harness"
```

## 하네스 설계자

```powershell
git clone https://github.com/namkibok/harness_v2.git
cd harness_v2
Copy-Item -Recurse -Force "skills\harness" "$env:USERPROFILE\.cursor\skills\harness"
```

카탈로그 submodule **없이** sparse로 필요 스킬만:

```powershell
.\scripts\install-skills.ps1 -Skills typescript-expert,webapp-testing -TargetDir .cursor\skills
```

하네스 구성 완료 후 대상 프로젝트에:

1. `.harness/skills.lock.yaml` 생성 (채택 스킬 ID 목록)
2. `install-skills.ps1` 실행
3. lock 파일을 **프로젝트 repo에 커밋**

## skills.lock.yaml

예시: [.harness/skills.lock.yaml.example](../.harness/skills.lock.yaml.example)

```yaml
domain: code-review
skills:
  - vibers-code-review
  - vulnerability-scanner
  - verification-before-completion
```

## install-skills.ps1 동작

1. [cursor-skills](https://github.com/namkibok/cursor-skills)를 `%LOCALAPPDATA%\harness\cursor-skills-sparse`에 **sparse clone**
2. lock에 있는 폴더만 checkout
3. 프로젝트 `.cursor/skills/{name}`에 **Junction**(기본) 또는 Copy

전역 `~/.cursor/skills/`에 1,300개를 넣지 **않습니다**.

## Submodule vs sparse

| 방식 | disk | 누가 |
|------|------|------|
| `git submodule` (skills/catalog) | ~52MB 전체 | 카탈로그 개발/일괄 탐색 |
| `install-skills.ps1` (sparse) | lock 개수만큼 | **팀 일상** |
