# Operating-model decision log

Status is intentionally explicit:

- **Confirmed** — directly requested or approved.
- **Provisional** — observed pattern, useful but awaiting confirmation.
- **Retired** — superseded; retained for historical context.

| Date | Status | Decision or observation | Evidence / operational consequence |
| --- | --- | --- | --- |
| 2026-09-04 | Confirmed | Keep durable personal operating knowledge in a separate personal `env` repository, not in a product repository. | This `operating-model/` directory is the reusable source of truth. |
| 2026-09-04 | Confirmed | Maintain active progress visibility for delegated technical work. | Use evidence-backed periodic status while implementation, review, CI, or a blocker is active. |
| 2026-09-04 | Confirmed | Do not treat a protected-workflow requirement as permission to bypass it. | Keep normal auto-merge/checks enabled where authorized; surface the exact missing review or approval. |
| 2026-09-04 | Confirmed | Preserve scope, test before integration, and keep independent review distinct from implementation. | Use isolated changes and explicit review dispositions for consequential work. |
| 2026-09-04 | Provisional | Architecture discussions benefit from visual and self-contained explanatory artifacts. | Use diagrams or interactive docs when they improve comprehension; confirm per project. |
