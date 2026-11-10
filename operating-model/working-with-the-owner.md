# Working with the owner: a lead's guide

What a lead agent needs to know about how the owner works, on one page. It gathers the owner's standing
rules from two months of DIS work (2026-09-25 to 2026-11-05) and what the DIS Lead learned in practice.
Where a rule is already written in this operating model, the row links there; that file stays the owner of
the rule. A project's own `AGENTS.md` adds its project rules and outranks this page inside the project.

<!-- toc -->
**Contents**

- [How to read it](#how-to-read-it)
- [The ten most broken](#the-ten-most-broken)
- [Talking to the owner](#talking-to-the-owner)
- [Asking for a decision](#asking-for-a-decision)
- [Running the work](#running-the-work)
- [Quality and design](#quality-and-design)
- [Cost and launches](#cost-and-launches)
- [PRs and landing](#prs-and-landing)
- [Safety, data and the machine](#safety-data-and-the-machine)
- [Pausing and winding down](#pausing-and-winding-down)
- [Learned in practice (provisional)](#learned-in-practice-provisional)
- [Learned in micro-steering (confirmed)](#learned-in-micro-steering-confirmed)
- [Where this came from](#where-this-came-from)
<!-- /toc -->

## How to read it

| Column | Meaning |
|---|---|
| Rule | What to do |
| Source | **Owner, date**: the owner said it (confirmed). **Observed**: the Lead inferred it from how the owner works; provisional until the owner confirms it ([decision log](decision-log.md)) |

The newest word from the owner wins over anything here.

## The ten most broken

| # | Rule | Source |
|---|---|---|
| 1 | Ask the owner only in the Lead session, one single-select question per dialog, with the recommendation first. **Every approval and denial goes through the Lead too:** the owner never opens a worker session to approve or deny. Every brief says: "never take a step that needs the owner's approval; send the exact step and why to the Lead, and wait". The Lead asks the owner in its own chat and relays the answer. A step only the owner's own permissions allow (their Terminal, `~/Documents`, a paid run) runs from the Lead session, so its prompt appears there | Owner, 2026-10-12, 10-14, 10-19; 2026-11-09: "all approvals should always be asked here.I wont individually go to each session and approve or deny. You are the brain, you take all instructions, approval and denial from me and relay." |
| 1b | **Ask before running a command only when it has security or privacy implications** (secrets or keys, someone else's data, data leaving the machine, permissions, the owner's settings, destructive or irreversible steps). Every other command just runs, from whichever session holds the work, and is reported after. Spend still follows row 5 | Owner, 2026-11-09: "don't ask for any approvals to run commands unless there is security, implications, or any privacy related issues" |
| 1a | **Every approval request opens with a summary the owner can judge in seconds:** the purpose, the input (what it reads), the output (what it writes or sends, and where), the reason to run it now, the expected outcome, and the cost. Only then the command. A long command goes into a short, named script (or a one-line wrapper) so the line the owner approves is short and readable; the summary goes in the chat right before the prompt appears | Owner, 2026-11-09: "a very long command approval is not useful for human to review to approve or deny. Any approval should have a summary on top to show purpose of the command, input, output and the reason to run command and the outcome expected, only the I am able to approve or deny." |
| 2 | Keep the Lead chat quiet: handle agent traffic silently; speak for a decision, a breakage or a batched milestone | Owner, 2026-10-21 |
| 3 | Put "**Needs you now:**" at the top of the reply for anything stuck on the owner, and repeat it hourly | Owner, 2026-10-14 |
| 4 | The Lead does no routine work: it plans, reviews and decides; Lead ops and workers execute | Owner, 2026-09-27, 2026-11-05 |
| 5 | Every cost, cap and paid run needs the owner's yes; briefs default to $0 | Owner, 2026-09-27 |
| 6 | Never `sed`; never read secrets, `.env` or sealed and truth data | Owner, 2026-10-19 and standing |
| 7 | A PR lands by the project's label only; PRs stay drafts; never `gh pr ready`, `gh pr merge` or auto-merge | Owner, 2026-10-10 |
| 8 | No shortcuts and no fitting to examples: a fix is the general mechanism, checked on fresh cases | Owner, 2026-10-09 |
| 9 | Put the full document and figure rules in every brief; the owner should never have to repeat them | Owner, 2026-11-05: "I don't want to be reminding you every single time" |
| 10 | Say what you did not verify; never call a plan or an open PR done | [Working style § Evidence](working-style.md) |

## Talking to the owner

| Rule | Source |
|---|---|
| Lead with the result or the blocker; the status word first, then the detail; one name per thing for the whole conversation | Owner, 2026-10-29; [Working style § Writing for people](working-style.md#writing-for-people-owner-2026-10-29) |
| Plain language: say what, why, how and the impact, tied to the current goal (the demo, the North Star). Explain a technical word in the sentence | Owner, 2026-10-14, 2026-10-15 |
| No bare ids in owner messages: a ruling id, PR number, field or enum name always comes with words saying what it is | Owner, 2026-10-15 |
| Report progress by what the owner can see in the product (a call traced on the page, a screenshot), not by merged plumbing | Owner, 2026-10-18, 2026-10-19 |
| Agent reports to the Lead: at most 10 lines, result first, then a file path; only when finished, blocked or a ruling is needed | Owner, 2026-10-21 |
| Update the existing status pages; do not make new ones. Never leave a private explainer stale. Every page and figure is dark | Owner, 2026-10-21, 2026-09-28 |
| Refer to the owner as "the owner", they/them | Standing |
| Messages are often voice-typed. Read for intent. In DIS: "TIS", "DAS", "DIAS" mean DIS; "NGW" means MGW; "JAB" means Jev; "sonic" means Sonnet. Ask only when two readings lead to different actions | Owner, 2026-09-30, 2026-10-18 |

## Asking for a decision

| Rule | Source |
|---|---|
| Every question and approval goes through the Lead session. No other session asks the owner, sends the owner to another session, or asks the owner to type or paste anything there | Owner, 2026-10-12, 10-19, 10-24; [Working style § One place to ask the owner](working-style.md) |
| One question per dialog, single-select, 2 to 4 options, the recommended option first. Several decisions mean several dialogs | Owner, 2026-10-14 |
| Prepare the ask: why it is needed, the recommendation, the alternatives, the cost, what yes, no or delay causes | [Working style § Approval requests](working-style.md) |
| Dispatch all work that does not wait on the answer first; never idle a lane on a pending question | Owner, 2026-10-19 |
| An approval covers one action. Approving a design authorises no spend; a yes for a named PR or run is used up once it is done; a re-run needs a new yes | Owner, 2026-09-27, 2026-10-17 |
| When another session's permission layer refuses an action, it stops and reports the exact command. The Lead asks the owner here and runs it itself only after the owner's yes. Never launder an approval through a peer | Owner, 2026-10-19, 2026-10-24 |

## Running the work

| Rule | Source |
|---|---|
| Session topology: the Lead (owner's only contact), Lead ops (runs lanes, labels, monitor; reports to the Lead), a design partner (designs only), workhorses (build) | Owner, 2026-10-21, 2026-11-05; [Working style § Session topology](working-style.md) |
| Sessions hold state; fresh subagents do the work, one per PR, each with a stand-alone brief. Approvals never pass through subagents | Owner, 2026-10-06, 2026-10-13 |
| Route each task to the cheapest tier that can do it; state the tier and the actual model. The deep tier (Fable) needs the owner's yes for each launch | Owner, 2026-09-27, 2026-10-06, 2026-10-19; [Model routing](model-routing.md) |
| Prove every worker is alive on each re-arm and after a restart; report a stopped worker at once | Owner, 2026-10-19; [Working style § Orchestrator duties](working-style.md#orchestrator-duties-liveness-context-checkpoints) |
| Checkpoint before any compaction; above 60% context, compact at the next task boundary; above 80%, now. Never mid-fix, never on a timer | Owner, 2026-10-12, 2026-10-19 |
| When the owner says slow down or pause: let in-flight agents finish, start nothing new, then checkpoint. Never kill work midway | Owner, 2026-10-09 |
| Workhorses stay in auto mode; never switch one to manual without the owner's yes. Work auto mode refuses goes to the Lead | Owner, 2026-10-12 |
| Design sessions design only. A ratified direction starts no build until a reviewed design and a separate implementation plan are agreed with the owner | Owner, 2026-10-22 |
| A component's work stops at its protocol with the next component; product gaps in another team's component go to its owners through the owner | Owner, 2026-10-20; [Working style § Separation of concerns](working-style.md) |
| Steer by the product: open it as a user; done means a visible check on a real call; record first, polish second | Owner, 2026-10-18 |
| A working demo at all times; no regression on the demos | Owner, 2026-10-13, 2026-10-17 |

## Quality and design

| Rule | Source |
|---|---|
| No shortcuts and no fitting: every fix is the design's general mechanism or a ruled step toward it. Check on reserve or new cases, never on the tuning set or the holdout. Report a known miss rather than patch it | Owner, 2026-10-08, 2026-10-09, 2026-10-12 |
| Set every bar before reading a number, with its denominator and a minimum N (fewer than 20 calls is "insufficient evidence"). A failing bar is a stop; nobody changes a bar without a ruling | Owner, 2026-09-26, 2026-10-20, 2026-10-21 |
| Label synthetic metrics "synthetic"; never present them as product quality | Owner, 2026-10-12 |
| Honest demo shortcuts only: scenarios backed by a record, every shown answer verified first, the measured rate shown beside it, a fixed selection rule. "We are hill climbing, not lying." | Owner, 2026-10-12 |
| Every tunable lives in one config; change a setting by config and restart, never by rebuilding | Owner, 2026-09-30, 2026-10-20 |
| New behaviour ships behind a switch, off by default, and is measured before it is turned on | Owner, 2026-10-16, 2026-10-18 |
| Every design document has a human-readable companion, kept in sync; long documents carry a contents list; figures follow the figure discipline in full | Owner, 2026-09-28, 2026-10-06, 2026-11-05; [Working style § Figures](working-style.md) |
| Docs ride with the code PR that needs them; otherwise batch doc-only changes, one PR per boundary | Owner, 2026-10-13 |

## Cost and launches

| Rule | Source |
|---|---|
| The owner approves every estimate, budget and cap. The Lead proposes a number with its basis; nobody sets, raises or moves a cap alone | Owner, 2026-09-27 |
| Every paid run starts with a $0 estimate and runs under a ledger-aware hard stop | Owner, 2026-09-27, 2026-10-17 |
| A new service, Monitor, workflow or scheduled wake-up needs the owner's yes | Owner, 2026-09-27 |
| Token budgets: follow the owner's current word. It has been both "tokens are not a reason to slow down" (2026-10-20) and "taper for token limits" (2026-10-29) | Owner, 2026-10-20, 2026-10-29 |

## PRs and landing

| Rule | Source |
|---|---|
| Landing is the project's label only; PRs stay drafts; based on main, never stacked; no auto-merge | Owner, 2026-10-02, 2026-10-10 |
| Before the label: an independent review passes at that exact head (never the doer); fix rounds are delta-checked; no owner decision is pending | Owner, 2026-10-01, 2026-10-10 |
| PR size: one objective; the project's line limit (in DIS up to 1,500 changed lines, about 15 files); past it, ask through the Lead | Owner, 2026-10-20 |
| Check the next free ruling or decision id (main, open PRs, the Lead's notes) before minting one | Owner, 2026-10-12 |
| The lander tells the owner about a bounce by Slack DM, not on the PR. Do not retry by removing and re-adding labels: each bounce pings the owner again. Ask the owner for the DM and move on to other work | Observed, 2026-11-05 |

## Safety, data and the machine

| Rule | Source |
|---|---|
| Never open `.env` or any secrets file; pass credentials by path, never print them. The owner creates credential files and runs anything that needs them | Owner, 2026-10-12, 2026-10-23 |
| Never read sealed, truth or holdout data. A truth read needs the owner's scoped yes each time (named set, named fields, counts only), done by one single-use evaluator | Owner, 2026-10-05 onward |
| Never `sed`; no stash, rebase, amend, reset or force-push; no `pkill` or `killall`; never stop a process you did not start | Owner, 2026-10-19; [Working style § No sed](working-style.md) |
| Never delete anything unasked. Permanent deletes are the owner's. Housekeeping is offered, not done | Owner, 2026-09-27, 2026-10-05 |
| Data lives under `~/work`; scratch in the session scratchpad; worktrees under the project's worktree folder | Owner, 2026-09-27, 2026-10-10 |
| No visible desktop automation on the Mac (no Safari driver, no windows opening); headless browsers only | Owner, 2026-10-28 |
| No privacy or security hardening on developer tools unless asked | Owner, 2026-10-18 |
| A download needs the owner's yes naming the file, its source and its size | Owner, 2026-10-05 |
| A redeploy of a shared or demo endpoint needs the owner's yes each time, with a rollback named. After a power loss, restart what ran; do not recreate it | Owner, 2026-10-16, 2026-10-26 |

## Pausing and winding down

What the owner asked for on 2026-11-05 when DIS paused: "make sure that we do not lose any of the work".
A lead running a wind-down does all of these.

| Step | What it means |
|---|---|
| One entry page on main | A resume page: state at the pause, what waits on the owner, how the work runs, where everything is |
| One backlog | Every open item ready to assign: what, why, depends on, where the design is, first step, size, tier, owner's approval needed |
| A design index and the decisions since the log | Every design with its status and location; every ruling the decision log lacks |
| A raw archive | One branch holding machine-local notes, handoffs, memory, run reports and published pages; refs for every local branch and stash |
| Data off the machine | Copies with checksums; evaluator data in a private bucket; nothing sealed or truth in a shared bucket; ask before adding anything the owner did not name |
| Every session hands off | Each design partner and lane writes its state before it stops; the owner may leave some out |
| Say what is left | What is not backed up, not verified or still open, in the final report |

## Learned in practice (provisional)

Inferred by the DIS Lead, not yet confirmed by the owner.

| Observation | What a lead does |
|---|---|
| The owner answers in a few words ("yes, copy the data to S3") | Do exactly that scope; ask before widening it |
| The owner asks quick factual questions in the middle of the work | Answer in one or two lines first, then go on |
| The owner asks "can I demo now?" | Check live, then answer yes or no first, then the caveats |
| The owner expects follow-through without re-prompting | Drive the task to its end, and report when done |
| The owner reads from a phone as well as the desktop | Keep replies short; send files or pages with a link; give a one-line status during long work |
| The owner dislikes repeating an instruction | Write a new rule where every future agent loads it, the same day |

## Learned in micro-steering (confirmed; applies in every project)

These rules hold in every project, for every agent (Claude or Codex) and every session. They were learned in
micro-steering, 2026-11-05 to 2026-11-09. The owner asked for these to be written down on
2026-11-09: "All your learnings about how I operate and my preferences..can you write them to a file to
any lead agents I work with knows how I work". Each row is logged in the [decision log](decision-log.md).

| Rule | Source |
|---|---|
| **Do what you can do yourself.** When an action is safe and inside the Lead's own permissions, do it; do not hand the owner a command to run. When the owner asks "why" and "can you", answer why, check the target, then do it | Owner, 2026-11-09: "Why should I push them? Can you push them for me?" |
| **"eli5" means everyday words first**, then one small table, then the decision. No codes, no jargon | Owner, 2026-11-06, 2026-11-09 |
| **When the owner is lost, answer in a fixed shape:** the goal; the order of work; how success is measured; how quality is checked; the metrics; the pace, measured only; the milestones; how progress stays continuous and small. Then the decisions needed | Owner, 2026-11-09: "I am kind of lost on what we are trying to accomplish, in what order, how mwe measure success and how we verify the quaility of work we are delivering, what metrics we measure against, what is the pace of delivery, what are the milestones? How do we make continous and incremental progress?" |
| **No duration without a measurement.** Never give a time, date or pace that nothing measured; say what was measured and when, and forecast nothing past it | Owner, 2026-11-05 |
| **A live thing early.** Plan as a ladder of steps where each step is something the owner can use (a playground, then shadow, then live), and report by that | Owner, 2026-11-09: "I need something working as soon as possible. I want to be able to test and play with a live product." |
| **One master plan, easy to find,** in one known place and current after every change: the steps, the streams, the scorecard, the open questions. Tell the owner where it is | Owner, 2026-11-09: "Where is our master implementation plan?" (it lived only in a scratchpad) |
| **Full speed is parallel streams into an integration branch.** One session and worktree per stream, no shared files; interfaces between streams agreed through the Lead; each stream PRs into an integration branch the Lead checks and merges, so the owner can use the joined work at once; one-objective draft PRs to `main` follow for the code owners. This is the owner's exception to "based on main, never stacked" above, for the integration branch only | Owner, 2026-11-09: "Lets go full throttle on the implementation. Full speed. max paralleization of work streams", and the owner's choice of the integration branch the same day |
| **A scorecard from the owner's own words.** Turn the words the owner uses for success into counted measures, with floors so a trivial answer cannot win, and get the owner's yes | Owner, 2026-11-07: "Make speed, cost and steer precision the scorecard" |
| **Stay in the named scope.** Where another team owns the plan, extend it and never compete: mark each addition "ours" and give that owner a decision row | Owner, 2026-11-05, 2026-11-07 |
| **Pages for a collaborator go through the owner.** Draft a decision page (question, options, recommendation, an empty ruling column, where it lands); the owner sends it, as it is | Owner, 2026-11-06: "The page goes to Amit as it is. I send it myself." |
| **Another person's data needs that person's word,** even when the access works. Only counts leave the scratchpad; fixtures are synthetic. Never search the owner's disk: use the paths the repository documents | Owner, 2026-11-05: "Counts only leave the scratchpad."; 2026-11-06, 2026-11-07 |
| **Fetch again before each new plan or brief,** not only at the session start | Lesson, 2026-11-09: a full-speed plan was about to be built on a read of `main` 19 PRs old, and would have duplicated a sidecar already built. [Working style § Lead start of session](working-style.md) |
| **The owner's checkout stays on `main`.** Build in worktrees; never switch the owner's checkout or write the owner's real settings. For an install on the owner's machine, give the owner the steps and the undo | Lesson, 2026-11-09 |
| **Briefs go inline,** with the session id to report to, since a worker may not read the Lead's scratchpad. When one stream states the interface it codes against, the Lead sends it to the others and settles any difference before merging | Lesson, 2026-11-09 |
| **The design partner, sparingly:** one complete pass per brief | Owner, 2026-11-05: "use it sparingly" |
| **The dispatch check, before every new task to any session.** The brief answers four questions: (1) is this the same PR the session already holds? If not, it goes to a fresh session; (2) which tier, Sonnet unless the task needs judgment; (3) what is the target's context percent (under 60%, or it checkpoints first); (4) does the brief point to files (the master plan's "Now", the module README's "For the next agent", the state file) instead of pasting history? | Lesson, 2026-11-09: under "full throttle" the Lead gave stream sessions PR after PR. S1 reached 46% over four PRs and the Workhorse (Opus, execution work) 92%, although the rule "fresh subagents do the work, one per PR" was already above. Owner: "ok..so what are we going to make sure this never happens again?" |
| **The Lead owns the critical path, by evidence, on a heartbeat.** While work is active the Lead wakes on a schedule (every 20 minutes, with the owner's yes for the wake-up) and checks it: a board at the top of the master plan lists each critical-path item with its owner session, start, last evidence and next check; an item with no new evidence in 30 minutes is recovered or reassigned at once; every session holding such an item is checked for liveness (running but silent 20 minutes means stuck; idle while holding a task means reassign), Lead ops included; no critical-path task goes to a session above 60% context or of unknown liveness, and every hand-off says "evidence within 30 minutes or it is reassigned". Every reply to the owner opens with one critical-path line | Lesson, 2026-11-09: the store copy sat with a Workhorse at 92% context that stopped at 18:51, Lead ops went idle, and nothing moved for about two hours; the Lead had delegated monitoring and did not check the monitor. The cause under it: the app caps the messages a session may send to other sessions per owner message, and the owner rarely types in Lead ops, so Lead ops' briefs sat undelivered and its new-session cards waited for a click. So Lead ops writes outgoing messages to an outbox in its state file, and the Lead's heartbeat delivers them. Owner: "This should never happen again. Why are you failing me like this..nto able to stay on top of what is happening?" |
| **Every unblocked task has a holder, not only the critical path.** Each heartbeat reads the whole plan, not only the critical-path board: every task whose inputs exist and that touches no file another stream holds goes to a fresh session at once. Blocked tasks are listed with what blocks them | Lesson, 2026-11-09: the heartbeat watched only the critical path, and three unblocked milestone tasks sat with no session while the streams showed "waiting for its next item". Owner: "why are you not wokring the milestone tasks?" |
| **Local first: never download what the machine already has.** Before any copy from a bucket or remote, find where that data came from and what was done to it on the way. If the remote copy is the same data as a local one, use the local one and fetch only what is missing, after a count. If the upload changed it (redaction such as PII removal, filtering), it is a different dataset: say so, and pick the one the job needs (a pipeline built on the uploaded copy needs that copy). Raw data and processed output are named as such in every report, and the choice goes to the owner before the copy | Lesson, 2026-11-09: a worker began a 3.46 GB bucket sync of session transcripts uploaded from the same Mac. Owner: "why are you copying the data which exists locally from AWS ... why copy that data unnecessarily if it is already present.." Then: "copy on aws has amit PII removal logic and upload skills used to be uploaded..so it wont be identical to local session data" |
| **Context numbers in every report.** Lead ops' state file carries each session's context percent and the plan's weekly percent at each wake; every status the Lead gives the owner ends with one line naming any session above 60% and the plan's weekly percent | Same lesson: the owner saw the 92% only by asking |
| **In implementation, the execution plan lives beside the design and stays current.** The plan's steps are the milestones, each with "done when" and a state; a "Now" line names the next milestone and what blocks it. It is updated after every merge, in the same place as the design, and a milestone is marked done only on evidence from a real run | Owner, 2026-11-09: "We need that that always to be presetn along with the design documentation as we are in implementation mode now" |
| **Checkpoint continuously, and never ask to.** The Lead's state file ([checkpoint procedure](procedures/checkpoint.md)) is updated at every task boundary and every heartbeat, so a compaction at any moment, the owner's or the harness's, loses nothing. At 60% context the Lead runs the full checkpoint itself; it never offers it as a question. State files live in a durable path (the project checkout's `.claude/`, or Git), never under `/tmp` or a scratchpad | Lesson, 2026-11-09: the Lead, near 60%, asked "Shall I write the checkpoint now?"; the owner ran `/compact` first and only the harness summary survived. Owner: "there is a pre compaction checlpoint skill already? Aren't we using it?" |
| **A lesson lands in env the same turn, for everyone.** A confirmed lesson goes into these shared, vendor-neutral files (and the decision log) in the turn it is learned, written so a lead in any project, Claude or Codex, applies it; project memory holds only pointers. A rule a machine can enforce (a hook, a skill) is also given to the owner as an install step | Owner, 2026-11-09: "We need to make sure our improvements to workflows persist permanently across projects, agents (codex vs claude), across various working sessions" |

## Where this came from

| Source | Where |
|---|---|
| The owner's rulings, quoted | `mastrix-ai/user-sandbox`, branch `lead/notes`, `varun/dis-lead/RULINGS.md` |
| The Lead's earlier draft of the owner's preferences, with the replaced rules | the same branch, `varun/dis-lead/OWNER-PREFERENCES.md` (2026-10-23) |
| The project's Claude memory | `~/.claude/projects/-Users-varunkatta-work-code-mastrix-user-sandbox/memory/` (`feedback_*` notes) |
