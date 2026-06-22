---
name: to-obsidian-issues
description: Capture work issues as Obsidian notes — create and list per-repo issues in the Obsidian vault under ~/obsidian.
disable-model-invocation: true
---

# To Obsidian Issues

Capture and list issues for the current repo as Markdown notes in the Obsidian vault. **The frontmatter is the single source of truth** — never infer an issue's state from anything else.

Run `/init-obsidian-issues` once per repo first — it scaffolds the folders and the Bases board. To drive an issue through implementation — set it in-progress, build it, and archive it done — use **`/execute-obsidian-issue`**, which owns the status lifecycle.

## Locations

- **Vault root** (`<vault>`) — the single directory under `~/obsidian` containing a `.obsidian/` folder (`find ~/obsidian -maxdepth 2 -name .obsidian -type d` → its parent). Don't hard-code the vault name; it gets renamed.
- **Repo name** (`<repo>`) — basename of `git rev-parse --show-toplevel` (run in the user's cwd). If not in a git repo, ask which repo to use.
- **Active issues:** `<vault>/projects/<repo>/issues/ISSUE-NNNN.md`
- **Archive:** `<vault>/projects/<repo>/issues/archive/ISSUE-NNNN.md`

Always get today's date with `date +%Y-%m-%d` — never hard-code it.

## Issue file format

```markdown
---
id: ISSUE-0014
title: Fix auth redirect loop
status: todo
priority: medium
created: 2026-06-22
updated: 2026-06-22
tags: [bug, api]
---

<body — context, checklist, links>
```

- **title** — short summary; shown on the Bases board
- **status** — one of `todo` · `in-progress` · `blocked` · `done`
- **priority** — one of `low` · `medium` · `high`
- **tags** — optional; `[]` if none

## Operation

Read the argument and pick a branch by intent:

- a title / "create" / "new" / a bug description → **Create**
- "list" / "show" / "open" / a status filter → **List**

Changing status, closing, and archiving are not here — they happen during implementation via **`/execute-obsidian-issue`**.

### Create

1. Resolve `<vault>` and `<repo>`; create the issues dir if missing.
2. **Compute the next ID:** list `ISSUE-*.md` across **both** the active dir **and** `archive/`, take the highest number, add 1, zero-pad to 4 digits. Spanning the archive guarantees IDs are never reused.
3. Write `ISSUE-NNNN.md`: `title` from the request, `status: todo`, `priority` from the request (default `medium`), `created` and `updated` set to today, `tags` from the request. Leave the body for notes.
4. Print the new ID and full path.

**Done when:** the file exists with valid frontmatter and its ID is exactly one above the prior max across active + archive.

### List

1. Glob the active issues dir and read each file's frontmatter.
2. Apply any filter from the argument (status, priority, or tag); no filter → all active issues.
3. Print a table — `ID · title · status · priority · tags` — sorted by priority (high→low) then ID. For a live grouped view, open `issues.base` in Obsidian.

**Done when:** every active issue file appears in the table or is excluded by the stated filter — none silently dropped.
