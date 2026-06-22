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
    - 'file.inFolder("projects/<repo>/issues")'
    - 'not file.inFolder("projects/<repo>/issues/archive")'
views:
  - type: table
    name: Open Issues
    groupBy:
      property: status
      direction: ASC
    order:
      - title
      - status
      - priority
      - tags
```

Folder paths are vault-relative. The `not file.inFolder(...archive)` clause keeps closed issues off the board.
