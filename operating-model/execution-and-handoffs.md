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

## Integration-readiness sweep

The integration owner must own the complete delivery topology. Before sending a task to review,
opening or rerunning a PR, or declaring it ready to integrate, verify the following against the
actual Git worktrees and the proposed integration/PR merge ref:

1. each packet's owner, verifier, integration owner, allowed/forbidden paths and acceptance
   commands are complete;
2. each declared base is the real shared ancestor of its registered branch/worktree and descends
   from the accepted baseline;
3. the verifier branch is rooted at that clean base and contains only verifier-owned paths, never
   implementation ancestry; and
4. full task validation plus both implementation and verifier scope gates pass.

The integration owner does not delegate this reconciliation away or treat a first CI failure as
someone else's infrastructure problem. Reproduce it locally against the merge ref, identify whether
it is topology, code, workflow, or external service, and immediately assign the smallest bounded
repair. A task is not ready merely because its implementation test suite and a reviewer report pass.

## PR review-conversation loop

Automated checks and review threads are separate delivery obligations. At review completion, on a
CI state change, and immediately before integration, inspect every unresolved PR comment.

1. **Actionable finding:** assign or make the smallest in-scope repair, rerun the affected check,
   and link the result in the thread.
2. **Incorrect or stale finding:** reply with a reproducible fact—such as the exact target path,
   command result, or commit—and resolve it. Do not add misleading code or documentation solely to
   placate a false positive.
3. **Architecture or external-authority finding:** keep the thread unresolved, record the exact
   decision boundary, and continue other safe work.

A green CI suite, auto-merge setting, or pending approval never substitutes for this loop. Status
updates must report review-thread disposition separately from checks and mergeability.

## PR failure chase loop

The coordinator owns the operational result of every PR it submits. Treat a failed, cancelled, or
unexpectedly missing required check as a work item immediately—not as a background condition that
can linger until the user asks about it.

1. Read the exact failing job log and reproduce the narrowest relevant command against the
   candidate or proposed merge state.
2. Classify the failure: in-scope defect, out-of-scope integrated regression, topology/lease
   defect, flaky or external-service failure, or protected-workflow condition.
3. Repair in scope immediately. For an out-of-scope but real regression, create or route the
   smallest bounded compatibility/integration repair; do not weaken the waiting PR's lease or leave
   it indefinitely red.
4. Push the repair or record evidence of the true external boundary, rerun/await the affected
   check, and update linked review threads with the exact result.

After every push and CI state transition, inspect both checks and review threads. A PR is only
"awaiting checks" while its checks are normally progressing; once a failure is actionable, it is
an owned recovery loop until repaired, explicitly dispositioned, or stopped by a real decision
boundary.

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
