---
name: execute
description: Execute a handoff document in an isolated git worktree using strict test-driven development, then write a standardized completion report for review. Use when given a handoff file to implement — "/execute <handoff-path>", "execute this handoff", "implement the handoff" — typically in a fresh session on a fast model. Also use to review a finished execution ("review the execution", "execute review <report-path>").
---

# Execute

Implements a handoff document end-to-end in an isolated worktree, TDD-style, and
writes a report the planning agent can review like a tech lead reviews a PR.

Designed to run in a cheap, fast session. From the planning session (after `/handoff`),
the user launches:

```bash
claude --model haiku "/execute <handoff-path>"
```

Announce at start: "I'm using the execute skill to implement <handoff-path> in an isolated worktree."

## Executor mode

### 1. Read the handoff

The handoff path comes from the arguments. No path → stop and ask for one; never guess.
Read it fully. If it references PRDs, plans, ADRs, or issues by path or URL, read those too.

### 2. Set up the worktree

Derive a branch name: the branch named in the handoff if there is one, else
`execute/<handoff-file-slug>`.

- If the **worktree-setup** skill is installed, invoke it.
- Otherwise locate its bundled script and run it directly:

  ```bash
  script=$(find ~ -path '*/worktree-setup/scripts/new-worktree.sh' 2>/dev/null | head -1)
  bash "$script" <branch>
  ```

- **Revision round** (the handoff contains `## Revision feedback` and a worktree for the
  branch already exists): `cd` into the existing worktree and address only the feedback —
  don't recreate anything.

Work ONLY inside the worktree from here on. Env files and dependencies are handled by
worktree-setup.

### 3. Implement with TDD

Follow the loop in [references/tdd-loop.md](references/tdd-loop.md): vertical slices —
one failing test → minimal code to green → refactor. Never refactor while red.
The handoff is your spec; don't pause for user approval mid-loop.

### 4. Verify

Run the repo's full verification: test suite, typecheck, build — whatever the repo's
docs or CI define. A fresh worktree may need one full build even if the handoff didn't
mention it. Only claim what you can point to evidence for; state skipped verifications
plainly — never paper over them.

### 5. Commit and report

Commit on the branch (**never push, never merge**). Write the report to
`<handoff-path>.report.md`:

```md
# Execution report: <handoff filename>

STATUS: COMPLETE | STOPPED
WORKTREE: <absolute path>
BRANCH: <branch>

## Verification

| Check | Command | Result |
| ----- | ------- | ------ |

## Changed files

<output of `git diff --stat <base-ref>`>

## Deviations & notes

<anything done differently from the handoff and why; skipped checks; open questions>
```

End your final message with the report path and worktree path so the user can hand
them to the reviewing session.

### STOP conditions

Stop, set `STATUS: STOPPED`, and record the blocker in the report — instead of
improvising — when: the handoff contradicts the actual code, scope balloons beyond
what it describes, the test suite can't run at all, or a decision arises that only
the planning agent or user can make.

## Review mode

When asked to review a completed execution (usually back in the planning session),
read the report, then follow [references/review.md](references/review.md): re-run
verification yourself in the worktree, check scope, read the full diff, audit the
new tests, and give a verdict — APPROVE / REVISE (max 2 rounds) / BLOCK.
