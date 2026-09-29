# Agent work loop

How an AI coding agent (Claude, Codex or any other) takes work from a shared work board: an issue queue that agents
claim from, such as Beads. It covers what to take next, who does the work, when to stop, who may review or repair
what, and how work passes between agents.

The agent you launch is a **dispatcher**: it picks jobs and launches one fresh sub-agent per job, one at a time. It
never does a job itself. Each sub-agent works with a clean context, does one job and reports back.

Projects inherit this protocol. A project may set the parameters in the table at the end and may add rules; it may
not change the rules below. See [Inheritance](#7-inheritance).

<!-- toc -->
**Contents**

- [Terms](#terms)
- [1. The work loop](#1-the-work-loop)
- [2. The dispatcher and its sub-agents](#2-the-dispatcher-and-its-sub-agents)
- [3. The stop rule](#3-the-stop-rule)
- [4. Independence](#4-independence)
- [5. Hand-offs are signals on the board](#5-hand-offs-are-signals-on-the-board)
- [6. Models and vendor mechanics](#6-models-and-vendor-mechanics)
- [7. Inheritance](#7-inheritance)
- [Project-set parameters](#project-set-parameters)
<!-- /toc -->

## Terms

| Term | Means |
|---|---|
| **Board** | The shared queue of jobs. The project names it and its commands. |
| **Job** | One unit an agent claims: a new task, a review, or a repair. |
| **Run** | One launch of the dispatcher: up to the project's job limit of jobs, then a full stop. |
| **Dispatcher** | The launched agent. It reads the board, claims a job and launches a sub-agent for it. It does no job itself. |
| **Sub-agent** | A fresh agent, with a clean context, launched by the dispatcher to do exactly one job. |
| **Doer** | The sub-agent that built a piece of work. |
| **Reviewer** | A sub-agent that checks someone else's work and gives a verdict. |
| **Repair** | Fixing work after a REVISE verdict. The repairer works on the same branch and PR. |
| **Actor** | The identity used to claim a job on the board and to write to it. |

## 1. The work loop

The dispatcher never goes idle while eligible work exists and its job limit is not reached. After each job it goes
back to the board and picks the next one, in this order. "Its own" work means work built by a sub-agent it
launched in this run:

| Priority | Take | Condition |
|---|---|---|
| 1 | **Its own open repair**: a REVISE on work built in this run | Always first, so its own work doesn't wait |
| 2 | **A review that is waiting** | Work no sub-agent of this run reviewed or repaired. Prefer work built by another vendor |
| 3 | **A repair of another agent's work whose doer is gone** | "Gone" is the project's threshold. Never a repair of work this run reviewed |
| 4 | **A brand-new task** | Only when nothing above is eligible |

Reviews and repairs come before new work because unfinished work is worth more once it is finished. A new task
that starts while a review waits only adds to the pile.

A job is finished when its output is handed in on the board: a PR marked for review, a verdict posted, or a repair
pushed and marked for review again.

## 2. The dispatcher and its sub-agents

The agent you launch works with a small, clean context and never builds, reviews or repairs anything itself. Each
job goes to a fresh sub-agent, so no job inherits another job's context.

**The dispatcher's round.** Each round it:

1. Reads the board, read-only, and picks the next job in the priority order of [section 1](#1-the-work-loop).
2. Claims the job with the job's actor, before launching anything.
3. Launches **one** sub-agent with a fresh context and a short brief: the job kind, the board id, the task id, the
   actor to use, and a pointer to the project's doer and reviewer rules.
4. Waits for the sub-agent to end and reads its report.
5. Checks the board's new state and the PR or verdict the report names.
6. Logs one line (job, kind, result, PR and head), then starts the next round.

**Rules for the dispatcher**

- **One sub-agent at a time.** It never runs two sub-agents at once.
- **No reading of code or diffs.** It reads the board and the sub-agent's report only, so its context stays small.
- **No repairing a sub-agent's failure itself.** If a sub-agent fails or stops on a rule, the dispatcher logs it,
  releases or flags the claim as the project says, and moves on. It never re-does the job in its own context.

**Rules for the sub-agent**

- It does **exactly one job**: build, review or repair.
- It works under the actor the dispatcher claimed with.
- It makes the job's board transition itself: hand-in (open the review item and mark the task "in review"), post
  the verdict, or post the REPAIRED signal. See [section 5](#5-hand-offs-are-signals-on-the-board).
- It reports back and ends. It never launches the next job and never picks another from the board.

**Claims.** The dispatcher claims before it launches, so two dispatchers never start the same job.

## 3. The stop rule

- **A run is bounded.** After the project's job limit of sub-agent jobs, the dispatcher **stops completely** and
  writes its report. It takes no further job until a human tells it to go again, which starts a new run of the same
  size. It never restarts itself.
- When nothing is eligible, re-check the board at the project's interval, up to the project's number of re-checks.
  If it is still empty, stop and write a short report.
- Stop at the project's budget limit, even if work remains, and write the report.
- Never poll without a bound. Every check costs credits.

The report lists: each job taken (id, kind, result, PR and head), anything stopped on, and why the run ended
(board empty, job limit, or budget limit).

## 4. Independence

- Never review your own work.
- Never repair work you reviewed.
- A reviewer never changes the implementation. It reports; someone else repairs.
- One actor identity per job. A reviewer or a repairer never uses the doer's actor. A doer repairing its own work
  may keep its own actor.
- Each sub-agent has a clean context and its own actor, and does one job. So a dispatcher may launch a review of
  work a sibling sub-agent built earlier in the same run. Prefer work another vendor built. A sub-agent never
  reviews work it built, since it does one job only.
- Claims are atomic and the first claim wins. If a claim fails because someone else holds the job, take the next
  eligible job. If it fails on a lock or busy error, wait briefly and retry a bounded number of times.

## 5. Hand-offs are signals on the board

Agents don't call each other. The board is the mailbox. The dispatcher and its sub-agents talk through a short
brief and a final report; everything else that other agents must see goes on the board.

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

## 6. Models and vendor mechanics

**Models**

- The dispatcher uses the cheapest capable model tier: it only reads the board and launches.
- A sub-agent uses the tier the task asks for. Projects define the tiers (for example light, standard and deep) and
  map them to each vendor's models.
- A review uses at least the task's tier.
- Where a vendor has no tier mapping, the sub-agent uses that vendor's default model unless the launch prompt says
  otherwise.

**Launching a sub-agent.** Use the vendor's own mechanism and name it in the launch prompt or the project's page.
Every mechanism must give the sub-agent a fresh context and let the dispatcher wait for its report.

| Vendor | Mechanism |
|---|---|
| Claude | Its sub-agent tool (Agent / Task) with a chosen model |
| Codex | `codex exec`: a fresh non-interactive process per job, with the brief as the prompt and `-m` for a model. `-o <file>` writes the final message to a file the dispatcher reads as the report. Codex also lists a `multi_agent` feature; check `codex features list` on the installed version before relying on it |
| Any other | A fresh non-interactive process or session per job |

**If a vendor cannot launch sub-agents,** its agent falls back to one job per session with a clean context. The
human, or a script, launches the next session. The rest of this protocol still holds: one job, its actor, its board
transition, then stop.

## 7. Inheritance

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
| Job limit | The most sub-agent jobs one run takes |
| Budget limit | The most one run may spend |
| Cross-vendor review | Preferred or required |
| Dispatcher sub-agent model | The model tier for the dispatcher, and the mapping from task tier to each vendor's sub-agent model |
| Jobs per run, then full stop until a human says go | Whether the dispatcher stops completely at the job limit and resumes only when a human says "go" (starting another run of the same size), and the number of jobs that run takes |
