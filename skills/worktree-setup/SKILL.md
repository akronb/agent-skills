---
name: worktree-setup
description: Create an isolated git worktree for a branch and prepare it for work — copies gitignored env files (.env, .env.local, etc.) from the main checkout into the worktree and installs dependencies. Use when the user says "create a worktree", "set up a worktree", "spin up a worktree for <branch>", "work on <branch> in a worktree", or wants an isolated workspace that needs env files carried over.
---

# Worktree Setup

Creates a git worktree, copies gitignored env files from the main checkout (they
are untracked, so a fresh worktree won't have them), and installs dependencies.

Announce at start: "I'm using the worktree-setup skill to set up an isolated workspace."

## Quick start

Run the bundled script. Its path is **relative to this skill's directory** (where this
SKILL.md lives) — adjust the prefix to wherever your agent installed the skill:

```bash
bash scripts/new-worktree.sh <branch> [base-ref] [--no-install]
```

Examples:

```bash
# New branch off current HEAD, install deps, copy env files
bash scripts/new-worktree.sh feature/checkout-fix

# New branch off origin/main
bash scripts/new-worktree.sh hotfix/login origin/main

# Attach an existing branch, skip install
bash scripts/new-worktree.sh ai-sdk-v6 --no-install
```

If your agent doesn't expose the skill directory, locate the script first:

```bash
script=$(find ~ -path '*/worktree-setup/scripts/new-worktree.sh' 2>/dev/null | head -1)
bash "$script" <branch>
```

## What the script does

1. Resolves the **main checkout root** from any worktree (`git rev-parse --git-common-dir`),
   so it works whether you run it from the repo root or an existing worktree.
2. Picks a worktree location: `.worktrees/<slug>` if `.worktrees` is gitignored, otherwise
   `~/.worktrees/<repo>/<slug>` (never a tracked path). Slashes in the branch become `-` in
   the directory name.
3. Runs `git worktree add` — `-b <branch> <base-ref>` for a new branch, or attaches the
   branch if it already exists.
4. **Copies env files**: every `.env*` file in the main root except `.env.example` (which is
   tracked and already present). These are independent copies — the main checkout keeps its own.
5. Installs deps with the detected manager: pnpm / yarn / bun / npm / cargo / go / uv / pip.
   Skipped with `--no-install`.

## After it finishes

Run the printed `cd <path>` to enter the worktree, then work there as normal.

## Cleanup

When the branch is merged or abandoned, remove the worktree from the main checkout:

```bash
git worktree remove .worktrees/<slug>      # add --force if it has uncommitted changes
git branch -d <branch>                     # delete the branch if done
git worktree prune                         # tidy stale metadata
```

## Notes

- Env files contain secrets — they are copied to a local, gitignored path only. Never commit
  the worktree directory.
- Re-running for an existing worktree path errors out rather than clobbering it.
- Agent-agnostic: no assumptions about Claude Code or any specific harness. If your harness has
  a native worktree tool (e.g. an `EnterWorktree` command or `--worktree` flag), prefer it —
  this script is the portable fallback.
