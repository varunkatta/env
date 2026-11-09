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
| 1 | Ask the owner only in the Lead session, one single-select question per dialog, with the recommendation first | Owner, 2026-10-12, 10-14, 10-19 |
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
| Route each task to the cheapest tier that can do it; state the tier and the actual model. The deepest tier (Fable) needs the owner's yes for each launch | Owner, 2026-09-27, 2026-10-06, 2026-10-19; [Model routing](model-routing.md) |
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

## Learned in micro-steering (confirmed)

From the micro-steering Lead, 2026-11-05 to 2026-11-09. The owner asked for these to be written down on
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
| **Full speed is parallel streams into an integration branch.** One session and worktree per stream, no shared files; interfaces between streams agreed through the Lead; each stream PRs into an integration branch the Lead checks and merges, so the owner can use the joined work at once; one-objective draft PRs to `main` follow for the code owners. This is the owner's exception to "based on main, never stacked" above, for the integration branch only | Owner, 2026-11-09: "Lets go full throttle on the implementation. Full speed. max paralleization of work streams", and his choice of the integration branch the same day |
| **A scorecard from the owner's own words.** Turn the words he uses for success into counted measures, with floors so a trivial answer cannot win, and get his yes | Owner, 2026-11-07: "Make speed, cost and steer precision the scorecard" |
| **Stay in the named scope.** Where another team owns the plan, extend it and never compete: mark each addition "ours" and give that owner a decision row | Owner, 2026-11-05, 2026-11-07 |
| **Pages for a collaborator go through the owner.** Draft a decision page (question, options, recommendation, an empty ruling column, where it lands); the owner sends it himself, as it is | Owner, 2026-11-06: "The page goes to Amit as it is. I send it myself." |
| **Another person's data needs that person's word,** even when the access works. Only counts leave the scratchpad; fixtures are synthetic. Never search the owner's disk: use the paths the repository documents | Owner, 2026-11-05: "Counts only leave the scratchpad."; 2026-11-06, 2026-11-07 |
| **Fetch again before each new plan or brief,** not only at the session start | Lesson, 2026-11-09: a full-speed plan was about to be built on a read of `main` 19 PRs old, and would have duplicated a sidecar already built. [Working style § Lead start of session](working-style.md) |
| **The owner's checkout stays on `main`.** Build in worktrees; never switch his checkout or write his real settings. For an install on his machine, give him the steps and the undo | Lesson, 2026-11-09 |
| **Briefs go inline,** with the session id to report to, since a worker may not read the Lead's scratchpad. When one stream states the interface it codes against, the Lead sends it to the others and settles any difference before merging | Lesson, 2026-11-09 |
| **The design partner, sparingly:** one complete pass per brief | Owner, 2026-11-05: "use it sparingly" |

## Where this came from

| Source | Where |
|---|---|
| The owner's rulings, quoted | `mastrix-ai/user-sandbox`, branch `lead/notes`, `varun/dis-lead/RULINGS.md` |
| The Lead's earlier draft of the owner's preferences, with the replaced rules | the same branch, `varun/dis-lead/OWNER-PREFERENCES.md` (2026-10-23) |
| The project's Claude memory | `~/.claude/projects/-Users-varunkatta-work-code-mastrix-user-sandbox/memory/` (`feedback_*` notes) |
