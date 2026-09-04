# Execution and handoffs

## Bounded execution loop

1. **Orient.** Read the project handoff, accepted baseline, task packet,
   relevant architecture, and contracts before changing a component.
2. **Bound.** State the objective, non-goals, affected paths, validation, and
   integration owner. Preserve unrelated local changes.
3. **Execute.** Make the smallest coherent implementation change and validate
   it against the real project state.
4. **Monitor and recover.** If work is delegated, check its durable progress,
   CI, or blocker regularly. A running agent without a recent artifact, test
   result, or concrete diagnosis needs attention. A stopped or stalled agent is
   the coordinator's responsibility: when its existing task remains bounded,
   its isolated worktree is safe, and its next action is clear, resume or
   redirect it immediately rather than waiting for the user to prompt.
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

State the delivery level explicitly: implementation checkpoint, independent-review disposition,
CI/PR state, and protected-branch integration are separate facts. A local or branch-level pass is
not an integration claim.

## Delegated-work recovery rule

The coordinator owns the agents it launches or assigns in a project environment.
Monitoring must therefore lead to action, not only narration.

1. On a stalled or interrupted task, inspect the worktree, latest commit,
   task packet, active process, and linked review/CI state.
2. If a real boundary exists—missing authority, a forbidden path, an unsafe
   migration, unavailable external actor, or material architecture decision—do
   not work around it. Record the evidence and surface the narrowest decision
   required.
3. If there is no such boundary, issue the existing owner a concrete recovery
   instruction in the same turn: exact remaining condition, allowed paths,
   acceptance command, commit/handoff requirement, and reviewer/integration
   next step. Reassign only when the existing owner cannot continue safely.
4. Do not require a second user prompt to resume a recoverable bounded task.
   Report the recovery action, then continue the monitoring cadence until it
   reaches review, integration, or a genuine blocker.

Never terminate or restart a valid long-running process merely to create the
appearance of movement. Recovery changes ownership or instructions only when
the durable evidence shows that normal progress has stopped.

## Learning loop

At the end of meaningful work or when a repeated operating pattern appears, propose—not silently
persist—an operating-model candidate with the observed evidence, proposed rule, and expected
benefit. Mark it as a provisional inference. Add it to the durable shared operating model only
after explicit user approval, then record the confirmed decision and commit it.

For a new cross-cutting operator/API interface, first establish one canonical contract, then map
each staged implementation task to its owned commands, dependencies, capability boundary, and
acceptance gate. Tasks must link back to that contract rather than define competing variants.

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
