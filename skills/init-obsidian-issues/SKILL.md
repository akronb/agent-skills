---
name: init-obsidian-issues
description: One-time per-repo setup for Obsidian issue tracking — scaffolds the issues folders, creates the Bases board, and reports prerequisite status. Run before /to-obsidian-issues.
disable-model-invocation: true
---

# Init Obsidian Issues

One-time setup so `/to-obsidian-issues` works for the current repo: scaffold the issues folders, create a Bases board, and report what's still missing. **Idempotent** — never overwrite an existing board or note; only create what's absent.

## Resolve targets

- **Vault root** (`<vault>`) — the single directory under `~/obsidian` containing a `.obsidian/` folder (`find ~/obsidian -maxdepth 2 -name .obsidian -type d` → its parent). Don't hard-code the vault name; it gets renamed.
- **Repo name** (`<repo>`) — basename of `git rev-parse --show-toplevel`. If not in a git repo, ask which repo to use.
- **Issues dir** — `<vault>/projects/<repo>/issues/`

## Steps

1. **Scaffold folders** — `mkdir -p` the issues dir and its `archive/` subfolder.
2. **Create the board** — if `<issues>/issues.base` does not exist, write the template below (substitute `<repo>`). If it already exists, leave it untouched. For any syntax tweak, follow the `obsidian-bases` skill.
3. **Prerequisite check** — print a checklist with ✅ or ⚠️ + the fix for each:
   - `obsidian` CLI on PATH — `command -v obsidian`
   - Obsidian running with this vault open — required for the CLI
   - **Bases** core plugin enabled — Settings → Core plugins → Bases (can't be detected; always remind)

**Done when:** the folders exist, `issues.base` is present, and the prerequisite checklist is printed.

## Board template (`issues.base`)

```yaml
filters:
  and:
    - file.inFolder("projects/<repo>/issues")
    - not:
        - file.inFolder("projects/<repo>/issues/archive")
formulas:
  prio_rank: 'if(priority == "high", 1, if(priority == "medium", 2, 3))'
  status_order: 'if(status == "todo", "1 To Do", if(status == "in-progress", "2 In Progress", if(status == "blocked", "3 Blocked", "4 Done")))'
views:
  - type: table
    name: Open Issues
    groupBy:
      property: formula.status_order
      direction: ASC
    order:
      - file.name
      - title
      - status
      - priority
      - tags
    sort:
      - property: formula.prio_rank
        direction: ASC
```

Folder paths are vault-relative. The `not:` clause keeps closed issues off the board. **Negation must be the structural `not:` key** (or a quoted inline `'!file.inFolder(...)'`) — a bare inline `not file.inFolder(...)` is not a valid Bases expression and silently empties the view.

**Enum ordering.** Bases sorts a column by its raw text, so `priority` (high/medium/low) and `status` would sort alphabetically. The `prio_rank` / `status_order` formulas exist only to sort and group in logical order; the readable `status`/`priority` columns stay clean. Trade-off: clicking a raw column header re-sorts it alphabetically and overrides the formula sort — change ordering by editing this config, not by clicking headers.
