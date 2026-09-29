# Agent work loop

How an AI coding agent (Claude, Codex or any other) takes work from a shared work board: an issue queue that agents
claim from, such as Beads. It covers what to take next, when to stop, who may review or repair what, and how work
passes between agents.

Projects inherit this protocol. A project may set the parameters in the table at the end and may add rules; it may
not change the rules below. See [Inheritance](#5-inheritance).

## Terms

| Term | Means |
|---|---|
| **Board** | The shared queue of jobs. The project names it and its commands. |
| **Job** | One unit an agent claims: a new task, a review, or a repair. |
| **Doer** | The agent that built a piece of work. |
| **Reviewer** | An agent that checks someone else's work and gives a verdict. |
| **Repair** | Fixing work after a REVISE verdict. The repairer works on the same branch and PR. |
| **Actor** | The identity an agent uses to claim a job on the board. |

## 1. The work loop

An agent never goes idle while eligible work exists. After finishing any job it goes back to the board and takes
the next one, in this order:

| Priority | Take | Condition |
|---|---|---|
| 1 | **Its own open repair**: a REVISE on work it built | Always first, so its own work doesn't wait |
| 2 | **A review that is waiting** | Work it did not build or repair. Prefer work built by another vendor |
| 3 | **A repair of another agent's work whose doer is gone** | "Gone" is the project's threshold. Never a repair of work it reviewed |
| 4 | **A brand-new task** | Only when nothing above is eligible |

Reviews and repairs come before new work because unfinished work is worth more once it is finished. A new task
that starts while a review waits only adds to the pile.

A job is finished when its output is handed in on the board: a PR marked for review, a verdict posted, or a repair
pushed and marked for review again.

## 2. The stop rule

- When nothing is eligible, re-check the board at the project's interval, up to the project's number of re-checks.
  If it is still empty, stop and write a short report.
- Stop after the project's job limit or budget limit per session, even if work remains, and write the report.
- Never poll without a bound. Every check costs credits.

The report lists: each job taken (id, kind, result, PR and head), anything stopped on, and why the session ended
(board empty, job limit, or budget limit).

## 3. Independence

- Never review your own work.
- Never repair work you reviewed.
- A reviewer never changes the implementation. It reports; someone else repairs.
- One actor identity per job. A doer, a reviewer and a repairer use different actors, even when one agent session
  does all three jobs on different work.
- Claims are atomic and the first claim wins. If a claim fails because someone else holds the job, take the next
  eligible job. If it fails on a lock or busy error, wait briefly and retry a bounded number of times.

## 4. Hand-offs are signals on the board

Agents don't call each other. The board is the mailbox.

| Step | Signal |
|---|---|
| The doer hands in | It marks the work "needs review" on the board, with the PR and head commit |
| The reviewer gives a verdict | PASS, REVISE or REJECT, bound to the exact commit it reviewed |
| The head moves after a verdict | The verdict no longer holds; the work needs review again |
| REVISE | The work goes back on the board as a repair |
| Too many REVISE rounds | After the project's limit, the work goes to the owner, not to another round |
| REJECT | The work goes to the owner |

A project may also run a reconciliation job as a backstop: it reads the source of truth (for example the PRs) and
posts any signal an agent missed. It is a backstop, not a replacement: agents still post their own signals.

## 5. Inheritance

- A project inherits this protocol. Its agent instructions link here rather than restate it.
- A project may only set the parameters below and add rules of its own (its board commands, labels, quality gates
  and merge rules).
- A project states its values in one table, titled "Overrides of the env work loop", and links to this file.
- If a project file and this file disagree on a rule, this file wins. Fix the project file.

## Project-set parameters

| Parameter | Means |
|---|---|
| Re-check interval | How long to wait between checks of an empty board |
| Re-check count | How many empty checks before the agent stops |
| Doer "gone" threshold | How long without activity before another agent may repair a doer's work |
| REVISE round limit | How many REVISE rounds before the work goes to the owner |
| Job limit | The most jobs one agent session takes |
| Budget limit | The most one agent session may spend |
| Cross-vendor review | Preferred or required |
