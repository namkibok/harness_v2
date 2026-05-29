# cursor-skills submodule

[harness_v2](https://github.com/namkibok/harness_v2)는 스킬 카탈로그를 **Git submodule**로 참조합니다.

| Repo | Role |
|------|------|
| [namkibok/cursor-skills](https://github.com/namkibok/cursor-skills) | ~1,300 shared skills (`skills/catalog/`) |
| [namkibok/harness_v2](https://github.com/namkibok/harness_v2) | Harness meta-skill + `catalog-index.yaml` |

## Clone

```powershell
git clone --recurse-submodules https://github.com/namkibok/harness_v2.git
```

## Existing clone — init submodule

```powershell
git submodule update --init --recursive
```

## Update catalog to latest

```powershell
git submodule update --remote skills/catalog
git add skills/catalog
git commit -m "chore: bump cursor-skills submodule"
```

## Standalone catalog repo

카탈로그만 clone:

```powershell
git clone https://github.com/namkibok/cursor-skills.git
$env:HARNESS_SKILL_CATALOG = "$PWD\cursor-skills"
```

## Contribute skills

1. Change files under `cursor-skills` repo (or `harness_v2/skills/catalog` after submodule init)
2. Commit & push to [namkibok/cursor-skills](https://github.com/namkibok/cursor-skills)
3. In harness_v2: bump submodule pointer if needed
