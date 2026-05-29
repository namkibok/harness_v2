# 팀 워크플로 — 설계자 vs 개발자

스킬 카탈로그: **[github.com/namkibok/ant-skills](https://github.com/namkibok/ant-skills)** (Git sparse, lock 기준만 설치)

## 역할 요약

| | 하네스 설계자 | 일반 개발자 |
|---|-------------|------------|
| **하는 일** | 하네스 구성, 스킬 선별 | 기능 개발 |
| **clone** | [harness_ant](https://github.com/namkibok/harness_ant) | 프로젝트 repo + lock |
| **카탈로그** | GitHub ant-skills (browse / sparse) | **install-skills.ps1** 만 |
| **전역** | `~/.gemini/antigravity/skills/harness` | 동일 |

## 일반 개발자

```powershell
git clone https://github.com/your-org/your-project.git
cd your-project

git clone https://github.com/namkibok/harness_ant.git $env:TEMP\harness_ant
$env:HARNESS_HOME = "$env:TEMP\harness_ant"

& "$env:HARNESS_HOME\scripts\install-skills.ps1" -LockFile .harness\skills.lock.yaml
```

팀이 `.agent/skills/`를 repo에 커밋해 두었다면 스크립트 생략 가능.

## 하네스 설계자

```powershell
git clone https://github.com/namkibok/harness_ant.git
cd harness_ant
$env:HARNESS_HOME = (Get-Location).Path

Copy-Item -Recurse -Force "skills\harness" "$env:USERPROFILE\.gemini\antigravity\skills\harness"
```

스킬 미리보기:

```powershell
& ".\scripts\install-skills.ps1" -Skills typescript-expert,webapp-testing -TargetDir .agent\skills
```

카탈로그 수정(메인테이너):

```powershell
git clone https://github.com/namkibok/ant-skills.git
# edit, commit, push → 모든 팀이 다음 install 시 pull
```

## install-skills.ps1 동작

1. `https://github.com/namkibok/ant-skills.git` sparse clone (캐시 재사용)
2. lock의 스킬 ID만 checkout
3. `.agent/skills/{name}` Junction (기본)

전역 `~/.gemini/antigravity/skills/`에 1,300개 복사 **금지**.

## 환경 변수 (선택)

| 변수 | 기본값 |
|------|--------|
| `HARNESS_SKILL_REPO` | `https://github.com/namkibok/ant-skills.git` |
| `HARNESS_SKILL_CACHE` | `%LOCALAPPDATA%\harness\ant-skills-sparse` |

`HARNESS_SKILL_CATALOG` 로컬 경로는 **사용하지 않음** (deprecated).
