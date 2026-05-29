# Skill Catalog (ant-skills)

Harness installs skills from **[namkibok/ant-skills](https://github.com/namkibok/ant-skills)** via Git sparse checkout — **not** from machine-local paths.

## Catalog source (everyone)

| Item | Default |
|------|---------|
| **Repository** | `https://github.com/namkibok/ant-skills.git` |
| **Sparse cache** | `%LOCALAPPDATA%\harness\ant-skills-sparse` |
| **Override repo** | `HARNESS_SKILL_REPO` |
| **Override cache** | `HARNESS_SKILL_CACHE` |

```powershell
& "$env:HARNESS_HOME\scripts\install-skills.ps1" -LockFile .harness\skills.lock.yaml
```

Only skills listed in `.harness/skills.lock.yaml` are fetched and linked into `.agent/skills/`.

## Phase 4 (하네스 설계자)

1. Browse IDs on GitHub: https://github.com/namkibok/ant-skills
2. Or inspect sparse cache after `install-skills.ps1 -Skills id1,id2,...`
3. Read `{id}/SKILL.md` from cache — adopt or write project-specific skill
4. Run `install-skills.ps1` → update `.harness/skills.lock.yaml` → commit lock to team repo

```powershell
& "$env:HARNESS_HOME\scripts\install-skills.ps1" -Skills typescript-expert,webapp-testing -TargetDir .agent\skills
```

## Designer: browse full catalog locally (optional)

Maintainers editing ant-skills:

```powershell
git clone https://github.com/namkibok/ant-skills.git
cd ant-skills
# edit {skill-id}/SKILL.md, commit, push
```

Regular harness users **do not** need a full clone.

## 금지

- `HARNESS_SKILL_CATALOG=E:\...` 같은 PC 전용 로컬 경로를 팀 표준으로 쓰지 말 것
- 카탈로그 전체를 `~/.gemini/antigravity/skills/`에 복사
