# Execution and handoffs

## Bounded execution loop

1. **Orient.** Read the project handoff, accepted baseline, task packet,
   relevant architecture, and contracts before changing a component.
2. **Bound.** State the objective, non-goals, affected paths, validation, and
   integration owner. Preserve unrelated local changes.
3. **Execute.** Make the smallest coherent implementation change and validate
   it against the real project state.
4. **Monitor.** If work is delegated, check its durable progress, CI, or
   blocker regularly. A running agent without a recent artifact, test result,
   or concrete diagnosis needs attention.
5. **Review.** Obtain independent review when the task or project requires it.
   Treat review conditions as work, not commentary.
6. **Checkpoint.** Commit a clean, tested unit with a handoff that says exactly
   what is true, incomplete, and intentionally deferred.
7. **Integrate.** Merge only through the project’s normal protected workflow
   after required checks and approval. Never bypass a required review or force
   a protected branch.

## Status-report minimum

For an active workstream, report:

- task, branch, worktree, owner, and newest durable commit/checkpoint;
- exact validation command and result, or process state if it is still running;
- progress since the previous report;
- classification: making progress, ready for review/integration, awaiting valid
  work, blocked, or stalled;
- for a blocker: the exact boundary and the smallest safe next action.

## Handoff minimum

Every implementation handoff should include:

- objective and non-goals;
- branch, worktree, base, final commit, and working-tree state;
- files/components changed and design decisions made;
- validations run and their results;
- known failures, shortcuts, assumptions, and unresolved questions;
- recommended next work and integration/review disposition.

## Escalation guide

Escalate rather than improvise when work encounters:

- an unsafe migration, security/ACL/authority risk, or data-loss risk;
- a contract or architecture contradiction;
- an immutable or frozen artifact that would need alteration;
- a protected-branch approval requirement or an unavailable external actor;
- missing authority that would materially change scope.

The escalation should include evidence and a proposed safe decision, not only a
description of the problem.
