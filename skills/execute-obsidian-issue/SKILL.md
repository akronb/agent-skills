---
name: execute-obsidian-issue
description: Implement an Obsidian-tracked issue end-to-end — set it in-progress, choose worktree vs branch, build and verify, then archive it done. Run /execute-obsidian-issue ISSUE-NNNN.
disable-model-invocation: true
---

# Execute Obsidian Issue

Take one Obsidian-tracked issue from `todo` to `done`: mark it in-progress, implement it,
verify, and archive the closed note. Sibling to `/execute` — same build-and-verify engine,
but where `/execute` reads a prompt or handoff file, this one's spec is the issue note.

**The issue note is the record** — its frontmatter is the single source of truth for status,
and its body becomes the execution log. The note lives in the Obsidian vault, not the repo,
so status edits are independent of whatever branch or worktree the code lands on.

Capture and listing live in `/to-obsidian-issues`; this skill owns the lifecycle.

## Locations

- **Vault root** (`<vault>`) — the single directory under `~/obsidian` containing a
  `.obsidian/` folder (`find ~/obsidian -maxdepth 2 -name .obsidian -type d` → its parent).
- **Repo** (`<repo>`) — basename of `git rev-parse --show-toplevel`.
- **Issue note:** `<vault>/projects/<repo>/issues/ISSUE-NNNN.md`; archived to `issues/archive/`.

Get today's date with `date +%Y-%m-%d` — never hard-code it.

## Steps

### 1. Read the issue

The issue ID comes from the argument. No ID → stop and ask; never guess. Locate
`ISSUE-NNNN.md`, read its frontmatter and body fully, and read anything it links (PRDs,
plans, ADRs, code paths). If `status` is already `done`, stop and say so.

**Done when:** you can state the issue's goal and its acceptance signal in one sentence.

### 2. Mark in-progress

Edit the vault note: set `status: in-progress` and bump `updated` to today. Do this before
writing code so the board shows the work as active.

**Done when:** the note's frontmatter shows `in-progress` with today's `updated`.

### 3. Choose worktree vs branch

Pick the smallest isolation the work needs. Branch name: `<type>/<slug>` — a
Conventional-Commits-style type matching the issue (a `bug` tag → `fix`, a feature → `feat`,
else the closest of `chore`/`refactor`/`perf`/`docs`) and a short slug from the title. Match
the project's existing branch convention.

| Signal | Choose |
| ------ | ------ |
| Working tree dirty (`git status --porcelain` non-empty) | **worktree** — don't disturb uncommitted work |
| Broad scope: many files, a migration, or a feature spanning modules | **worktree** |
| Clean tree **and** surgical scope (a focused fix, few files) | **branch** in the current checkout |
| Genuinely borderline | **ask the user** |

- **Worktree:** invoke the **worktree-setup** skill if installed, else run its script —
  `script=$(find ~ -path '*/worktree-setup/scripts/new-worktree.sh' | head -1); bash "$script" <type>/<slug>`.
  Work only inside the worktree afterward; it carries env files and installs deps.
- **Branch:** `git checkout -b <type>/<slug>` in the current checkout.

**Done when:** you are on `<type>/<slug>` and know whether it is a worktree or the main checkout.

### 4. Implement with TDD

The issue body is your spec. Follow the **execute** skill's TDD loop — vertical slices, one
failing test → minimal code → refactor only on green, never refactor while red. Locate and
read it: `find ~ -path '*/execute/references/tdd-loop.md' | head -1`.

**Done when:** the issue's behavior is implemented and its critical paths have tests that passed after first failing.

### 5. Verify

Run the repo's full verification — test suite, typecheck, build, whatever its docs or CI
define. A fresh worktree may need one full build. Claim only what you can point to; state
skipped checks plainly.

**Done when:** each verification command has been run and its pass/fail recorded.

### 6. Commit, close, archive

Commit on the branch — **never push, never merge**. Then close the note: append an
`## Execution` section (branch, worktree path if any, the verification results, `git diff
--stat`, and any deviations), set `status: done`, add `closed: <today>`, bump `updated`, and
move the file to `issues/archive/`.

**Done when:** the commit exists on the branch, and the note is in `archive/` with
`status: done`, a `closed` date, and an `## Execution` log.

End your final message with the branch name, the worktree path (if any), and the archived note path.

## STOP conditions

When the issue contradicts the code, scope balloons past what the note describes, the test
suite can't run, or a decision only the user can make arises: stop, set the note's
`status: blocked`, record the blocker in its body, and report — don't improvise.
