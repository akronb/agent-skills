# TDD Loop for Autonomous Execution

Test-driven development adapted for an executor working from a handoff: no
user-approval gates — the handoff is the spec. If a fuller `tdd` skill is installed,
its philosophy applies too; these rules win where they conflict (they remove the
interactive steps).

## Core principle

Tests verify **behavior through public interfaces**, not implementation details.
A good test reads like a specification — "user can checkout with valid cart" — and
survives refactors because it doesn't care about internal structure. If renaming an
internal function breaks a test, that test was testing implementation.

## Anti-pattern: horizontal slices

**Do not write all tests first, then all implementation.** Bulk-written tests test
*imagined* behavior and end up asserting the shape of things rather than what the
system does.

```
WRONG (horizontal):           RIGHT (vertical):
  RED:   test1..test5           RED→GREEN: test1→impl1
  GREEN: impl1..impl5           RED→GREEN: test2→impl2
                                ...
```

## The loop

1. **List behaviors** from the handoff — observable behaviors, not implementation
   steps. Prioritize critical paths and complex logic; you can't test everything.
2. **Tracer bullet**: write ONE test for the first behavior, watch it fail (RED),
   write minimal code to pass (GREEN). This proves the path works end-to-end.
3. **Repeat** for each remaining behavior: one test → fails → minimal code → passes.
   Each test responds to what the previous cycle taught you.
4. **Refactor** only when green: extract duplication, deepen modules, re-run tests
   after each step. **Never refactor while red.**

## Checklist per cycle

```
[ ] Test describes behavior, not implementation
[ ] Test uses the public interface only
[ ] Test would survive an internal refactor
[ ] Watched the test fail before making it pass
[ ] Code is minimal for this test — no speculative features
```

## Honesty rules

- A test that asserts nothing meaningful is worse than no test — reviewers audit for this.
- Don't weaken or delete an existing failing test to get green; that's a STOP condition
  if you can't make it pass legitimately.
- Use the project's domain vocabulary (glossary, ADRs) in test names and interfaces.
