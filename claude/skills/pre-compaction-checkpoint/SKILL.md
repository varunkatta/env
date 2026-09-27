---
name: pre-compaction-checkpoint
description: Use before a context compaction (/compact), when the user says they are about to compact, or when asked to "record everything so nothing is lost". Materializes every fact, decision, approval, in-flight task and next step into durable files, so the session can resume exactly where it left off without hallucinating. Also use right after a compaction, to resume.
---

# Pre-compaction checkpoint (and resume)

**Goal:** after compaction you remember only a summary. Anything not written to disk may be lost or misremembered.
Before compacting, write down everything needed to continue; after compacting, reload it from disk and verify it
against live sources before acting.

**The principle: disk, not memory. Verify, don't recall.** Every fact you record should come from a source you
just checked (git, `gh`, files), not from what you remember of the conversation.

## A. Before compaction (checkpoint)

1. **Freeze new work.** Don't launch new tasks until the checkpoint is written. Tasks already running may continue.
2. **Capture the user's words verbatim.** Append every user ruling, approval, answer and preference given since the
   last checkpoint to the project's rulings log, with the date, quoted exactly as typed (typos included). Add a
   short "reading" beneath each only if you need to interpret it. Approvals of cost, merges and scope matter most.
3. **Capture your own decisions.** Append every decision you made (on reviews, deviations, contradictions, plans)
   to the project's decisions or notes log, with its reason and what it supersedes.
4. **Snapshot live state from the sources**, not from memory:
   - the main branch SHA; every PR merged since the last checkpoint with its merge SHA (`gh pr view N --json
     mergeCommit`); every open PR with its head SHA, merge state, checks and next step;
   - the running background tasks and agents: their id, role, current state, and what each is waiting for;
   - spend: approved against actual, per budget line, read from ledgers or logs;
   - the open questions for the user, and questions already answered (so they aren't asked again).
5. **Write ONE dated state file, READ FIRST,** that supersedes the previous one. It has these sections:
   - 0. Role, and the standing rules (how to work, what is forbidden, who approves what);
   - 1. Where the truth lives (paths);
   - 2. Git and PR state (tables with SHAs);
   - 3. The work items or tasks by milestone;
   - 4. Costs (approved and spent);
   - 5. Open questions for the user;
   - 6. Answered questions (don't re-ask);
   - 7. Next actions, in order;
   - 8. The running agents, with ids and how to resume each.
6. **Update persistent memory.** Point a "READ FIRST" entry at the top of the memory index to the new state file.
   Save each new standing preference the user gave as its own feedback memory (the rule, why, how to apply). Update
   or delete memories the session proved wrong.
7. **Put durable decisions in version control where the project expects them** (e.g. a decisions file or ADR), or
   list them in the state file as "owed to Git" with the PR that will land them.
8. **Verify the checkpoint:**
   - every user message since the last checkpoint maps to a line in the rulings log;
   - every open PR and running agent is in the state file;
   - every number in the state file was read from a source this turn;
   - grep the state file for "TODO" or "?" and resolve each.
9. **Tell the user** what was recorded and where, what is still in flight (and that it keeps running), and that
   it's safe to compact.

## B. After compaction (resume)

1. Read the READ-FIRST state file in full, then the tail of the rulings log and the decisions log, then the memory
   index.
2. **Re-verify live state before acting:** the main SHA, the open PRs (`gh pr list`), and each running agent's
   status. Trust the live state over the file where they differ, and note the difference.
3. Don't redo finished work. Don't re-ask answered questions. Don't restate the summary to the user.
4. Continue from "Next actions" in order, and pick up messages from agents that arrived during the compaction.
5. If anything in the file is ambiguous, check the source (the PR, the log, the report) before deciding. Never fill
   a gap from memory.
