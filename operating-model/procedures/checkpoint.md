# Checkpoint and resume

A procedure any agent follows, in any harness. Use it:

| When | Part |
| --- | --- |
| Before a context compaction, reset or handoff to another session; when the owner says they are about to compact; when asked to "record everything so nothing is lost" | A. Checkpoint |
| Right after a compaction, reset or handoff, or when you start a session from someone else's state file | B. Resume |

**Goal:** after a compaction an agent holds only a summary, and anything not written to disk may be lost or
misremembered. Before it, write down everything needed to continue; after it, reload that from disk and verify it
against live sources before acting.

**Principle: disk, not memory. Verify, don't recall.** Every fact recorded comes from a source just checked (git,
`gh`, files), not from the conversation.

Where the files live is the project's rule (its lane or state folder). This procedure names the files by role.

| Role | Holds |
| --- | --- |
| State file | The one dated, READ-FIRST file that supersedes the previous one |
| Rulings log | The owner's words, verbatim, with dates |
| Decisions or notes log | The agent's own decisions, with reasons |

## A. Before compaction (checkpoint)

| # | Do | Check |
| --- | --- | --- |
| 1 | **Freeze new work.** Launch nothing new until the checkpoint is written. Tasks already running may continue. | |
| 2 | **Capture the owner's words verbatim.** Append every ruling, approval, answer and preference given since the last checkpoint to the rulings log, with the date, quoted exactly as typed (typos included). Add a short "reading" beneath each only if it needs interpreting. Approvals of cost, merges and scope matter most. | Every owner message since the last checkpoint maps to a line. |
| 3 | **Capture your own decisions.** Append every decision you made (on reviews, deviations, contradictions, plans) to the decisions log, with its reason and what it supersedes. | |
| 4 | **Snapshot live state from the sources.** The main branch SHA; every PR merged since the last checkpoint with its merge SHA (`gh pr view N --json mergeCommit`); every open PR with its head SHA, merge state, checks and next step; the running agents and background tasks (id, role, state, what each waits for); spend, approved against actual per budget line, read from ledgers or logs; the open questions for the owner and the questions already answered. | Every number was read from a source this turn. |
| 5 | **Write ONE dated state file, READ FIRST,** sections 0 to 8 below. | Every open PR and running agent is in it. |
| 6 | **Update the agent's persistent memory, if the harness has one,** as pointers only: a READ-FIRST entry naming the new state file, and for each rule a pointer to its canonical home in Git. Rule text is not kept in memory. Delete or correct entries the session proved wrong. | |
| 7 | **Put durable decisions in version control** where the project expects them (a decisions file, an ADR), or list them in the state file as "owed to Git" with the PR that will land them. | |
| 8 | **Verify the checkpoint.** Search the state file for "TODO" and "?" and resolve each. | Nothing unresolved remains. |
| 9 | **Tell the owner** what was recorded and where, what is still in flight (and that it keeps running), and that it is safe to compact. | |

State file sections:

| # | Section |
| --- | --- |
| 0 | Role, and the standing rules (how to work, what is forbidden, who approves what) |
| 1 | Where the truth lives (paths) |
| 2 | Git and PR state (tables with SHAs) |
| 3 | The work items or tasks, by milestone |
| 4 | Costs, approved and spent |
| 5 | Open questions for the owner |
| 6 | Answered questions (do not re-ask) |
| 7 | Next actions, in order |
| 8 | The running agents, with ids and how to resume each |

## B. After compaction (resume)

| # | Do |
| --- | --- |
| 1 | Read the READ-FIRST state file in full, then the tail of the rulings log and the decisions log, then the memory index if the harness has one. |
| 2 | **Re-verify live state before acting:** the main SHA, the open PRs (`gh pr list`), and each running agent's status. Trust the live state over the file where they differ, and note the difference. |
| 3 | Do not redo finished work. Do not re-ask answered questions. Do not restate the summary to the owner. |
| 4 | Continue from "Next actions" in order, and pick up messages from agents that arrived during the compaction. |
| 5 | If anything in the file is ambiguous, check the source (the PR, the log, the report) before deciding. Never fill a gap from memory. |

## Harness hooks

A harness may run steps of this procedure automatically (for example before and after a compaction). A hook is a
convenience that calls the same steps; the procedure works without it, so run it by hand when no hook fires.
