# Cursor Skills Catalog

Shared skill library for [namkibok/harness_v2](https://github.com/namkibok/harness_v2).

Harness uses this repo as a **read-only parts catalog** — do not copy all skills into `~/.cursor/skills/`. During harness Phase 4, pick domain-relevant skills and link or copy only those into the target project's `.cursor/skills/`.

## Layout

Each subdirectory contains one skill:

```
{skill-name}/
└── SKILL.md
```

## Use with Harness

Clone harness_v2 with submodules:

```powershell
git clone --recurse-submodules https://github.com/namkibok/harness_v2.git
```

Default catalog path (relative to harness_v2 root):

```
skills/catalog/
```

Override with environment variable:

```powershell
$env:HARNESS_SKILL_CATALOG = "C:\path\to\skills\catalog"
```

## License

Individual skills may include their own metadata (`source`, `category` in frontmatter). Use and redistribute according to each skill's terms and your organization's policy.
