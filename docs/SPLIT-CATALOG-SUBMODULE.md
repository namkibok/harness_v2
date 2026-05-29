# ant-skills — skill catalog repository

Harness does **not** vendor skills inside [harness_ant](https://github.com/namkibok/harness_ant).

## Catalog repository

| Item | Value |
|------|--------|
| **GitHub** | [github.com/namkibok/ant-skills](https://github.com/namkibok/ant-skills) |
| **Local clone (team dev)** | `E:\workspace\skills\antigravity` |
| **Env override** | `HARNESS_SKILL_CATALOG` |

## Install flow

```powershell
$env:HARNESS_HOME = "C:\path\to\harness_ant"
# optional — defaults to E:\workspace\skills\antigravity if present
$env:HARNESS_SKILL_CATALOG = "E:\workspace\skills\antigravity"

& "$env:HARNESS_HOME\scripts\install-skills.ps1" -LockFile .harness\skills.lock.yaml
```

Without a local catalog, `install-skills.ps1` sparse-clones **only lock-listed skills** from ant-skills.

## Adding or editing skills

1. Edit under `E:\workspace\skills\antigravity\{skill-id}\` (or clone ant-skills)
2. Commit and push to [ant-skills](https://github.com/namkibok/ant-skills)
3. Re-run `install-skills.ps1` on target projects

## harness_ant vs ant-skills

| Repo | Role |
|------|------|
| [harness_ant](https://github.com/namkibok/harness_ant) | Meta harness, scripts, `catalog-index.yaml` |
| [ant-skills](https://github.com/namkibok/ant-skills) | ~1,300 skill packages (`{id}/SKILL.md`) |
