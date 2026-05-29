# ant-skills catalog (Git)

| Repo | URL |
|------|-----|
| Harness | [namkibok/harness_ant](https://github.com/namkibok/harness_ant) |
| Skills | [namkibok/ant-skills](https://github.com/namkibok/ant-skills) |

## Install (all users)

```powershell
$env:HARNESS_HOME = "C:\path\to\harness_ant"
& "$env:HARNESS_HOME\scripts\install-skills.ps1" -LockFile .harness\skills.lock.yaml
```

Uses Git sparse checkout — no per-machine `E:\workspace\...` paths.

## Maintain skills

```powershell
git clone https://github.com/namkibok/ant-skills.git
cd ant-skills
# edit {skill-id}/SKILL.md
git push origin main
```

Teams pick up changes on next `install-skills.ps1` (cache pulls latest).
