# Agent orchestration

This is the one owner of how agents are organised and run in any project: who does what, what a session keeps and
what it hands off, and what a project may bind. It states no model names, no board commands and no project facts.

**Contents**

- [Who owns what](#who-owns-what)
- [Roles](#roles)
- [Long-lived sessions: sessions hold state, subagents do work](#long-lived-sessions-sessions-hold-state-subagents-do-work)
- [What a project binds](#what-a-project-binds)

## Who owns what

One owner per fact. A rule is written in its owner and linked from everywhere else.

| Topic | Owner |
| --- | --- |
| Roles, sessions and subagents, context clearing | This file |
| The dispatcher, the stop rule, independence, hand-offs on the board | [`agent-work-loop.md`](agent-work-loop.md) |
| Model tiers, the vendor mapping, premium launches, costs | [`working-style.md`](working-style.md) → Model tiers, Model tier mapping, Launches and costs |
| Bounded work, delegation, reviews, PR loops, checkpoints, documentation gates, scratch files and worktrees | [`execution-and-handoffs.md`](execution-and-handoffs.md) |
| Communication, theme, editor and other personal preferences | [`working-style.md`](working-style.md) |
| Why a rule exists, and when it was ruled | [`decision-log.md`](decision-log.md): history, never the rule |

## Roles

| Role | Does | Never does |
| --- | --- | --- |
| Orchestrator (a lead) | Plans, briefs, reviews, rules, routes approvals | Builds or runs what a cheaper tier can do |
| Design partner | Holds the design thread, rulings and open questions | Dispatches builders or code PRs |
| Workhorse (builder) | Keeps its queue and state note; one fresh subagent per PR | Asks the owner for approvals itself |
| Dispatcher and its sub-agents | One clean-context sub-agent per job, then stop ([`agent-work-loop.md`](agent-work-loop.md) section 2) | Reads code or diffs itself |
| Independent reviewer | Checks work at an exact head and reports a verdict | Reviews its own work or edits what it reviews |
| Inquiry session | Answers questions to build understanding, read-only on the project, with artifacts kept locally ([`working-style.md`](working-style.md) → Inquiry sessions) | Edits a project or opens PRs |

## Long-lived sessions: sessions hold state, subagents do work

Some projects run several long-lived sessions side by side, such as a lead, design partners and workhorses. A
session's context grows with every file it reads, and compaction loses details. So each session keeps only the state
it needs and hands the reading and building to fresh subagents. This extends the dispatcher of
[`agent-work-loop.md`](agent-work-loop.md) section 2 to sessions that live for days.

| Role | Keeps in its own context | Hands to fresh subagents | Compacts or clears |
| --- | --- | --- | --- |
| Lead (orchestrator) | the board, the owner's rulings, approvals | every review, run preparation, wide reads | at the owner's word, after a checkpoint |
| Design partner | the design thread: rulings, open questions, what each document owns | measurements, scripts, wide code reads | at a design-PR boundary past about 60% of the window, after updating its state file; never mid-ruling |
| Workhorse (builder) | its queue, PR heads, review findings, a state note | each PR's build: one fresh subagent per PR | itself, at a landing, once its state note is written (see [Workers self-clear at landings](#workers-self-clear-at-landings)) |

- **A brief stands alone.** It names the goal, the spec anchors, the exact files, the done-criteria (tests seen red
  first, mutations, one full check) and what not to touch, and it points to the project's rules file. If a subagent
  needs the session's memory to do the job, the brief is wrong.
- **The tier follows the task.** Builds and fix rounds use the default (standard) tier; mechanical sub-steps use the
  lightest tier; the independent review of a behaviour change uses the deep tier. The orchestrator reasons and decides
  and hands mechanical work down. The table is `working-style.md` → Model tiers; a premium launch still needs the
  owner's per-launch yes.
- **Only conclusions come back:** the PR head, counts and disclosures, never file dumps.
- **A fix round goes back to the same subagent,** which still has the code in context. A new PR gets a new subagent.
- **Approvals never pass through subagents.** Costs, reads of protected data, writes to live systems and rebuilds stay
  with the session the owner approves through. A subagent's own safety checks may refuse such actions, and that
  refusal must not be routed around.
- **Compact at task boundaries, not on a timer.** Mid-task, compact only past about half the window, and only after
  writing a state note (branch, head, done, next). Never compact while review findings are being fixed.
- **A lead or design partner clears rarely;** a worker clears at landings, below. Observed 2026-10-13 in the Claude
  desktop app: it pauses one session's messages to other sessions after about ten sends without the owner typing, and
  a cleared session is reachable only through that route. A session that dispatches subagents seldom needs clearing,
  and a cleared worker is reached through its state note and the orchestrator's board, not through a message.

### Workers self-clear at landings

A worker does not wait to be told to clear. When its PR has landed and no fix round is open, it clears its own
context, and its state note is how it resumes.

| Step | Rule |
| --- | --- |
| When | A worker's PR has landed and the worker has no fix round open. A worker may hold one PR in review while it builds the next, and clears at the first point where neither has an open fix round. |
| Before | Write the state note: the queue, open PRs with their heads, and pending findings. |
| Clear | The worker clears its own context. |
| Next action | Read the state note, then the project's operating rules. Nothing else carries over. |
| Never | While a fix round is open, or before the state note is written. |
| Orchestrator | At each landing it reports, check whether the worker cleared; if not, name the clear as the worker's next step. |

## What a project binds

A project inherits these rules. Its agent instructions link here and state only its own bindings
([`agent-work-loop.md`](agent-work-loop.md) section 7 sets the same rule for the work loop).

| A project may bind | Example |
| --- | --- |
| Which session holds which role now | The lane table |
| Which model each tier names | The vendor mapping in `working-style.md` |
| Protected data and forbidden paths | Secrets, sealed or held-out data |
| Its landing mechanism | A label gate, who merges, size limits |
| Its own parameters and quality gates | Re-check interval, the project's checks |

A project may not restate these rules or change what they mean. If a project file and this file disagree on a rule
this file owns, this file wins and the project file is fixed.
