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

## Layout

```
agent-skills/
└── skills/
    └── <skill-name>/
        ├── SKILL.md        # name + description frontmatter, agent-agnostic instructions
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
