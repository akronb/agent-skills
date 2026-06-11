# Reviewing an Execution

Review the executor's work the way a tech lead reviews a spec-driven PR. The
executor's report is a claim, not evidence — verify everything yourself, in the
worktree named in the report.

## Steps

1. **Re-run verification.** Run every check from the report's Verification table
   (and the repo's standard suite) in the worktree yourself. Don't trust reported
   results.
2. **Check scope.** `git diff --stat <base-ref>` must show only files the handoff
   put in scope. Out-of-scope changes need an explicit, convincing justification in
   the Deviations section.
3. **Read the full diff** against the handoff's intent and the repo's conventions —
   not just whether it works, but whether it belongs in this codebase.
4. **Audit the new tests.** Executors game criteria — a test that asserts nothing
   meaningful passes the suite and proves nothing. Each test must assert observable
   behavior and would have failed before the implementation existed.
5. **Weigh deviations.** A real obstacle met with a minimal, explained adaptation
   that serves the handoff's intent merits approval. Silent or sprawling deviations
   don't.

## Verdict

| Verdict     | Condition                                                   | Action                                                                                                                                                        |
| ----------- | ----------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **APPROVE** | Checks pass, scope clean, tests meaningful, quality holds    | Tell the user the worktree path and branch with a diff summary. **Never merge or push** — that's the user's call.                                              |
| **REVISE**  | Fixable gaps (max 2 rounds)                                  | Append a `## Revision feedback` section to the handoff file with concrete, actionable items; the user re-runs the executor, which re-enters the same worktree. |
| **BLOCK**   | STOPPED status, scope violation, or revision rounds exhausted | Explain why; the fix is a better handoff (re-plan), not a third revision round.                                                                                |
