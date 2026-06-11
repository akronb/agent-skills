# agent-skills

Personal collection of portable [Agent Skills](https://www.skills.sh) — reusable
capabilities that work across Claude Code, Cursor, Codex, OpenCode, Copilot, and other
agents via the [`skills` CLI](https://github.com/vercel-labs/skills).

## Install

Install every skill in this repo into your agent(s):

```bash
# Project scope (default)
npx skills add akronb/agent-skills

# Global scope (user home)
npx skills add akronb/agent-skills -g

# Target specific agents
npx skills add akronb/agent-skills -a claude-code -a cursor
```

## Skills

| Skill | Description |
| ----- | ----------- |
| [`worktree-setup`](skills/worktree-setup/) | Create an isolated git worktree for a branch, copy gitignored env files (`.env`, `.env.local`, …) from the main checkout into it, and install dependencies. |
| [`execute`](skills/execute/) | Execute a handoff document in an isolated worktree with strict TDD, then write a completion report; includes a review mode for the planning session. Composes with `worktree-setup`. |

## Composition

Skills stay self-contained, but may **soft-depend** on a sibling skill: invoke it if
installed, else locate its bundled script by path pattern (see `execute` step 2). One
source of truth, no copied scripts.

The intended flow with `execute`:

1. Plan in a full-strength session; finish with `/handoff` (a handoff file lands in the temp dir).
2. Launch a cheap executor: `claude --model haiku "/execute <handoff-path>"`. It sets up a
   worktree via `worktree-setup`, implements with TDD, commits on the branch, writes
   `<handoff-path>.report.md`.
3. Back in the planning session: "review the execution at <report-path>" → APPROVE / REVISE
   (max 2 rounds) / BLOCK. Merging and pushing stay with you.

## Layout

```
agent-skills/
└── skills/
    └── <skill-name>/
        ├── SKILL.md        # name + description frontmatter, agent-agnostic instructions
        ├── references/     # detailed docs loaded on demand, one level deep
        └── scripts/        # bundled scripts, referenced relative to SKILL.md
```

Each skill is self-contained and references its bundled scripts by a path **relative to its
own `SKILL.md`**, so it behaves the same wherever the CLI installs it.

## Adding a skill

1. Create `skills/<name>/SKILL.md` with `name` + `description` frontmatter.
2. Keep instructions agent-agnostic — no hardcoded install paths, no assumptions about a
   specific harness.
3. Put any helper scripts in `skills/<name>/scripts/` and reference them relatively.
4. Add a row to the table above.
