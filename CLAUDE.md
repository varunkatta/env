# Claude operating-model entry point

This file is a loader, not a separate memory store. Before working in a
technical project, read the shared operating model in this order:

Resolve the relative paths below from the directory containing this `CLAUDE.md`,
not from the target repository's working directory.

1. [`operating-model/README.md`](operating-model/README.md)
2. [`operating-model/working-style.md`](operating-model/working-style.md), and when you lead a
   project, [`operating-model/working-with-the-owner.md`](operating-model/working-with-the-owner.md)
3. [`operating-model/execution-and-handoffs.md`](operating-model/execution-and-handoffs.md)
4. [`operating-model/decision-log.md`](operating-model/decision-log.md)
5. [`operating-model/lead-playbook.md`](operating-model/lead-playbook.md), when you are a lead
   session for the owner
6. [`operating-model/agent-work-loop.md`](operating-model/agent-work-loop.md), when you take work
   from a shared board (an issue queue such as Beads)
7. [`operating-model/model-routing.md`](operating-model/model-routing.md) and
   [`operating-model/claude/model-routing.md`](operating-model/claude/model-routing.md) for Claude
   model selection

Use [`operating-model/project-profile.template.md`](operating-model/project-profile.template.md)
when establishing project-specific context. Project repositories remain the
source of truth for their own architecture, contracts, security boundaries,
and active work.

Do not copy or amend the shared preferences here. Update the canonical
`operating-model/` documents instead so Claude and Codex use the same memory.
