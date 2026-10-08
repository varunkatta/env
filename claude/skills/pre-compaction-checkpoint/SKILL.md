---
name: pre-compaction-checkpoint
description: Use before a context compaction (/compact), when the user says they are about to compact, or when asked to "record everything so nothing is lost". Materializes every fact, decision, approval, in-flight task and next step into durable files, so the session can resume exactly where it left off without hallucinating. Also use right after a compaction, to resume.
---

# Pre-compaction checkpoint (and resume)

This skill is a loader. The procedure is vendor-neutral and lives in one place:
`~/work/code/personal/env/operating-model/procedures/checkpoint.md`.

Read that file in full and follow it: part A before a compaction, part B right after one. Do not keep a copy of the
steps here; amend the procedure file instead.
