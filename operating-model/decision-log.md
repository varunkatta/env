# Operating-model decision log

Status is intentionally explicit:

- **Confirmed** — directly requested or approved.
- **Provisional** — observed pattern, useful but awaiting confirmation.
- **Retired** — superseded; retained for historical context.

| Date | Status | Decision or observation | Evidence / operational consequence |
| --- | --- | --- | --- |
| 2026-09-04 | Confirmed | Keep durable personal operating knowledge in a separate personal `env` repository, not in a product repository. | This `operating-model/` directory is the reusable source of truth. |
| 2026-09-04 | Confirmed | Maintain active progress visibility for delegated technical work. | Use evidence-backed periodic status while implementation, review, CI, or a blocker is active. |
| 2026-09-04 | Confirmed | The main coordinator owns agents it places in a project environment and must actively recover a stalled bounded task. | Inspect the durable state, resume/redirect the existing owner when the next safe action is clear, and escalate only a real external or architectural boundary; never wait for a second user prompt. |
| 2026-09-04 | Confirmed | The integration owner owns task-topology readiness end to end. | Before review, CI, or merge, reconcile packet base/branch/worktree ancestry and verifier isolation against the exact merge ref; reproduce a failure before calling it infrastructure and immediately assign the smallest repair. |
| 2026-09-04 | Confirmed | Keep implementation, independent review, CI/PR, and integration status distinct. | Every update names the actual delivery level and owner; no local test, branch, or open PR is represented as integrated work. |
| 2026-09-04 | Confirmed | Establish a single canonical contract for a cross-cutting operator interface before staged implementation. | Map each command/capability to a gate, dependency chain, capability boundary, and acceptance evidence; tasks link to the contract instead of creating alternatives. |
| 2026-09-04 | Confirmed | Convert meaningful observations and repeated patterns into proposed operating-model candidates, but persist only approved ones. | Each candidate states observation, proposed practice, and expected benefit; the agent marks inference versus confirmed preference and commits the shared-memory update only after explicit user approval. |
| 2026-09-04 | Confirmed | Do not treat a protected-workflow requirement as permission to bypass it. | Keep normal auto-merge/checks enabled where authorized; surface the exact missing review or approval. |
| 2026-09-04 | Confirmed | Treat every PR review comment as an owned work item, independently of CI state. | At review/CI/merge transitions, classify each thread as actionable, incorrect/stale, or decision-bound; repair valid findings, respond with reproducible evidence before resolving invalid findings, and report thread disposition separately from checks. |
| 2026-09-05 | Confirmed | Actively chase failures on every submitted PR. | Inspect failed/cancelled/missing required checks after submission and each state change; read and reproduce the log, classify the cause, make or route the smallest repair, rerun the check, and retain ownership until a repair or evidence-backed boundary is recorded. |
| 2026-09-05 | Confirmed | Launch the next leased recovery action when its prerequisite merges. | A merged activation or repair triggers its queued review, integration, or rerun in the first writable turn; the coordinator does not wait for another user prompt after a status-only observation. |
| 2026-09-05 | Confirmed lesson | Observation alone did not advance the M3 lint repair after its activation merged. | The coordinator reported the newly merged prerequisite but did not immediately dispatch the already-safe verifier. Future orchestration maintains an explicit dependency-to-next-action queue and records the release action, not only the state observation. |
| 2026-09-04 | Confirmed | Preserve scope, test before integration, and keep independent review distinct from implementation. | Use isolated changes and explicit review dispositions for consequential work. |
| 2026-09-04 | Provisional | Architecture discussions benefit from visual and self-contained explanatory artifacts. | Use diagrams or interactive docs when they improve comprehension; confirm per project. |
