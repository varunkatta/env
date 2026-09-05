# Working style

This is a living record of confirmed preferences for technical collaboration.
It is intentionally concise: a collaborator should be able to apply it before
starting work.

## Confirmed preferences

| Topic | Preference | Practical implication |
| --- | --- | --- |
| Ownership | A designated integration owner makes final integration decisions. | Keep implementation isolated until it is tested and independently reviewed; do not silently merge or broaden work. |
| Momentum | Work should advance decisively, not wait passively for routine uncertainty. | Identify the smallest safe next action, act within granted authority, and state a real external boundary when one exists. |
| Progress visibility | Delegated work must be actively monitored. | Report evidence-backed state on a regular cadence while work, review, CI, or a real blocker remains active. |
| Orchestration ownership | The main coordinator owns the agents it places in a project environment. | When a bounded task is stalled and its next safe action is clear, resume, redirect, or replace the assigned agent in the same operating turn; do not wait for the user to ask. |
| Integration readiness ownership | One named integration owner is accountable for the whole task topology, not only merge mechanics. | Before review, PR creation, CI rerun, or integration, reconcile each packet's declared base/branch/worktree with the real Git topology and run the full readiness sweep. A CI failure is never assumed to be infrastructure until reproduced. |
| PR conversation ownership | PR comments are work items with an explicit disposition, separate from automated checks. | Inspect review threads at review/CI/merge transitions; repair valid findings or reply with reproducible evidence and resolve incorrect/stale findings. Never treat green CI or auto-merge as closure for unresolved comments. |
| PR failure ownership | A submitted PR must be actively driven to a disposition, not left with failing checks. | Inspect failed/cancelled/missing required checks immediately; read and reproduce the failure, classify it, repair it in scope or open the smallest compatible repair, then rerun and document the result. |
| State clarity | Task implementation, independent review, CI, and integration are distinct states. | Name the exact state, owning boundary, newest durable evidence, and smallest safe action; do not collapse a passing test, open PR, or branch into an integration claim. |
| Interface governance | Cross-cutting operator interfaces need one canonical contract before staged implementation. | Map each command or capability to one owning gate and its dependencies; link to the canonical interface rather than creating parallel designs. |
| Evidence | Claims of completion require reproducible evidence. | Name commit, branch, validation command, result, and any remaining limitation. Do not describe plans as completed work. |
| Independence | Important implementation work needs review independent of the implementer. | Use a separate reviewer or review task; record its disposition rather than treating a self-review as acceptance. |
| Scope | A small, coherent change is preferable to hidden expansion. | Preserve task boundaries, immutable historical evidence, and unrelated working-tree changes. Escalate a material conflict instead of repairing around it. |
| Documentation | Plans, constraints, and architectural decisions should survive sessions and agent changes. | Commit durable plans, handoffs, and acceptance criteria before dependent implementation. |
| User interaction | Keep the main conversation available for questions while delegated work proceeds. | Provide short, direct updates; do not go quiet during long-running work. |

## Communication standard

- Lead with the current outcome or blocker.
- Be concise, concrete, and technically honest.
- Distinguish **observed fact**, **inference**, **decision**, and **next action**.
- When blocked, name the exact boundary and the smallest safe action or the
  specific authority needed. Do not call waiting, a plan, or a queued job
  progress.
- Surface contradictions early, particularly around data integrity, security,
  policy, migration safety, and release acceptance.
- A status report is not the end of coordination: when it finds a recoverable
  stall, take the safe recovery action and report both the evidence and action.

## Learning and memory proposals

After a meaningful observation, repeated pattern, or consequential delivery, identify what was
learned and propose any useful operating-model candidate. Each proposal must separate:

1. the **observation** (what actually happened);
2. the **proposed rule or practice** (the conceptual change); and
3. **why it would help** across future projects.

Treat every new candidate as an inference unless the user explicitly confirms it. Do not silently
write a candidate into shared memory. Present it for approval; only after user approval may it be
recorded as a confirmed preference and committed to this repository. Preserve the distinction
between a confirmed user decision and an agent's provisional inference.

## Integration-topology preflight

The integration owner must run and record this preflight before declaring a task ready for review,
CI, or integration:

1. Confirm every implementation and verifier packet has one named owner, linked verifier,
   integration owner, exact allowed/forbidden paths, and required acceptance commands.
2. Confirm the declared base is the actual shared ancestor of the registered branch/worktree and
   descends from the accepted baseline; do not substitute a later activation commit merely because
   it contains the packet.
3. Confirm a verifier branch starts from that clean shared base, not from the implementation
   branch. It may inspect a candidate SHA, but its own diff may contain only its packet and report.
4. Run the full task/lease validator and each implementation and verifier branch-diff gate against
   the exact integration/PR merge ref, not just a local happy-path command.
5. Treat any failure as an owned integration-readiness defect until a local reproduction identifies
   a true external boundary. Assign the smallest bounded repair immediately; do not label it a CI
   issue by assumption.

## Decision posture

Use initiative for reversible, bounded work that is already within scope. Stop
for material changes to authority, security boundaries, production data,
contracts, or architecture unless the decision owner has explicitly authorized
the change. If an external approval or protected workflow is required, do not
bypass it; make the dependency visible and keep all safe parallel work moving.

## Provisional observations

These are useful tendencies, not standing rules, until explicitly confirmed.

- Visual explanations, diagrams, and self-contained documentation are often
  valuable for architectural review.
- A proposal should state both what it enables and what it deliberately does
  not claim.
- Data and evaluation work should be grounded in realistic distributions and
  measured quality rather than toy examples.

Track confirmation, revision, or retirement in the [decision log](decision-log.md).
