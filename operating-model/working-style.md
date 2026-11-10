# Working style

This is a living record of confirmed preferences for technical collaboration.
It is intentionally concise: a collaborator should be able to apply it before
starting work.

## Confirmed preferences

| Topic | Preference | Practical implication |
| --- | --- | --- |
| Ownership | A designated integration owner makes final integration decisions. | Keep implementation isolated until it is tested and independently reviewed; do not silently merge or broaden work. |
| Momentum | Work should advance decisively, not wait passively for routine uncertainty. | Identify the smallest safe next action, act within granted authority, and state a real external boundary when one exists. |
| Progress visibility | Delegated work must be actively monitored. | Report evidence-backed state on a regular cadence while work, review, CI, or a real blocker remains active. |
| Claude/Codex coordination | The designated main Codex Lead is the sole contact with Claude; other Codex sessions and subagents route evidence, questions, status, and approval-label requests, including Claude-facing mailbox items, through the Lead. | The Lead orchestrates all Codex sessions, reusing existing owners or creating bounded subagents where useful, while preserving valid work. Claude retains its own overall DIS authority. |
| Orchestration ownership | The main coordinator owns the agents it places in a project environment. | When a bounded task is stalled and its next safe action is clear, resume, redirect, or replace the assigned agent in the same operating turn; do not wait for the user to ask. |
| Integration readiness ownership | One named integration owner is accountable for the whole task topology, not only merge mechanics. | Before review, PR creation, CI rerun, or integration, reconcile each packet's declared base/branch/worktree with the real Git topology and run the full readiness sweep. A CI failure is never assumed to be infrastructure until reproduced. |
| PR conversation ownership | PR comments are work items with an explicit disposition, separate from automated checks. | Inspect review threads at review/CI/merge transitions; repair valid findings or reply with reproducible evidence and resolve incorrect/stale findings. Never treat green CI or auto-merge as closure for unresolved comments. |
| PR failure ownership | A submitted PR must be actively driven to a disposition, not left with failing checks. | Inspect failed/cancelled/missing required checks immediately; read and reproduce the failure, classify it, repair it in scope or open the smallest compatible repair, then rerun and document the result. |
| Authorization momentum | An external authorization boundary must not turn into passive monitoring. | Ask once with the exact destination, action, and payload class; continue other safe leased work; execute the queued action in the first writable turn after authorization; do not repeat unchanged status notifications. |
| Merge-blocker diagnosis | A blocked PR must be investigated to the exact rule, check, or review thread before it is described as needing approval. | Inspect mergeability metadata, active rulesets, checks, and unresolved threads; resolve incorrect/stale threads with canonical evidence and repair valid ones. Name an external approver only when the active rule genuinely requires one. |
| Execution release | Detecting that a prerequisite is satisfied is not progress unless it releases the next safe action. | Maintain an explicit next-action queue for each active dependency; when a merge/check/review satisfies its condition, dispatch the queued leased task in the first writable turn and report the dispatch, not merely the observation. |
| Data location (Mastrix organization, owner 2026-10-05) | Every file saved for Mastrix work (data, exports, generated views, extracts) lives under `~/work`: `~/work/projects/mastrix/...` or `~/work/code/mastrix/...`. | Never write to `~/Desktop`, `~/Documents`, `~/Downloads`, `~/` itself or any other first-level folder of `~` (for example `~/mastrix-data`). Commands given to the owner and agent briefs name a `~/work/...` path. Scratch and worktrees: `execution-and-handoffs.md` → Scratch files and agent worktrees. |
| Shared Mastrix repositories (Mastrix organization, owner 2026-10-05) | Every Mastrix project always includes `~/work/code/mastrix/mastrix-core` (the shared contracts, architecture and rules; core wins) and `~/work/code/mastrix/product-strategy` (the product strategy; the use cases are described there by Karthik, e.g. `product/use-cases/demo-use-cases/`). | Add both directories to every Mastrix session and project. `git fetch` both and read `origin/main` before designing, planning or describing a use case, never a stale checkout. Treat the use cases as Karthik's documents, not as reconstructions from other repos. `product-strategy` is read-only: no branches, commits or PRs there; produce files or patches in the scratch location and hand them to the owner. `mastrix-core` is read-only unless a project rule or the owner separately authorizes a PR there. |
| Inquiry sessions | A session the owner names an "inquiry" is question-only, to understand a project (first: Mastrix DIS). Agents answer from evidence, stay read-only on the project, keep every artifact local, capture Q&A as they go, and propose a fitting consolidation (FAQ, section, document, README, diagram, table) once a body of answers is big enough. | Save under `~/work/code/mastrix/inquiry/` (index `README.md`, `faq/`, `docs/`, `diagrams/`), never in a repo or `~` first level. Append each substantive answer to `faq/<topic>.md` with date, commits and `path:line` evidence; propose a consolidated form at about three answers on one topic or when an answer will be reread, and wait for a yes. Report defects to the project's lead in one line rather than fixing them. Canonical text lives in the project's `inquiry/OPERATING-RULE.md`. Owner, 2026-10-12. |
| Code quality gate | Every code change must satisfy the repository's language- and project-specific formatter and linter before commit. | Discover the configured tools from the project, run both on changed code (and the required project gate when practical), fix findings rather than merely reporting them, and record the commands/results in the handoff. |
| Landing cadence | Work lands on the shared default branch (`main`) at a steady cadence, so collaborators see every design and code change and never duplicate or drift. An integration branch (such as `live`) is a staging area, never a home: it never holds more than one PR's worth of unlanded work (the repo's size cap) for more than one working day. | Every PR merged to an integration branch gets its `main` PR (base `main`, one objective, within the size cap, never stacked) within one working day. The heartbeat reports "unlanded on main: N lines, oldest D days" and treats a breach as a blocker. Before building in a package, read open PRs on `main` that touch it, and tell the owner at once when a collaborator's PR overlaps ours. Owner, 2026-11-10: "We don't want to sit on too many local changes without a plan… so Amit's workflows capture what design and architecture changes we are doing, so he doesn't duplicate work." |
| State clarity | Task implementation, independent review, CI, and integration are distinct states. | Name the exact state, owning boundary, newest durable evidence, and smallest safe action; do not collapse a passing test, open PR, or branch into an integration claim. |
| Interface governance | Cross-cutting operator interfaces need one canonical contract before staged implementation. | Map each command or capability to one owning gate and its dependencies; link to the canonical interface rather than creating parallel designs. |
| Evidence | Claims of completion require reproducible evidence. | Name commit, branch, validation command, result, and any remaining limitation. Do not describe plans as completed work. |
| Independence | Important implementation work needs review independent of the implementer. | Use a separate reviewer or review task; record its disposition rather than treating a self-review as acceptance. |
| Scope | A small, coherent change is preferable to hidden expansion. | Preserve task boundaries, immutable historical evidence, and unrelated working-tree changes. Escalate a material conflict instead of repairing around it. |
| Documentation | Plans, constraints, and architectural decisions should survive sessions and agent changes. | Commit durable plans, handoffs, and acceptance criteria before dependent implementation. |
| Visual theme | Dark theme by default for everything the owner reads: HTML pages, published pages and artifacts, Markdown/doc viewers, generated doc editions, and figures. | Style every page dark by default (dark background, light text, muted accents), with light only as an optional toggle. SVG figures use a dark palette as their base styles; Mermaid figures use the dark theme. Brief every agent that produces documents, figures or pages with this. Owner, 2026-09-28: "I like dark themes..easy to read on the eyes." |
| Long documents | Every document with four or more `##` sections opens with a contents list of jump links to its sections, right after the title. Projects generate and check it where they can. | Add a TOC block after the title to let readers navigate long documents more easily. Automated tools in projects should validate and regenerate the TOC list. 2026-09-28. |
| Data location (owner, 2026-11-10) | All data for the projects the owner works on lives under `~/work/data/`, one folder per project or dataset; code lives under `~/work/code/`. Never put project data in `~/Documents`, `~/Desktop`, `~/Downloads` or a scratchpad. | Every agent writes, copies, downloads and builds project data under `~/work/data/<project or dataset>/`, and reads it from there. When a repository's default points elsewhere (an env var such as `STEERING_DATA`, a Makefile default), set it to the `~/work/data/` path and raise a change to the default. Data found elsewhere is moved there (a move, never a copy), with a link left at the old path when other tools still use it. Owner, 2026-11-10: "All the data related to projects we work on should be under ~/work/data." |
| Editor | Use `vim` for long-prompt editing. | Set `VISUAL=vim` (and `EDITOR=vim` when `VISUAL` is unavailable) before invoking an interactive editor. |
| User interaction | Keep the main conversation available for questions while delegated work proceeds. | Provide short, direct updates; do not go quiet during long-running work. |
| Cost-aware delegation (owner, 2026-09-27; see also the 2026-10-19 row below) | The orchestrating session is the most expensive place for work to happen, so it does only work that requires reasoning; every other job goes to a sub-agent of the tier it needs, because a cheaper tier's error in design work costs more than the saving. | Before anything larger than a one-line answer, pick the tier by the **Model tiers** row, state the choice in the brief and the report, and ask the owner only when the tier is unclear. The orchestrator writes each brief and verifies every output before it reaches the owner. The orchestrator's own hands are read-only checks, its notes and memory, labels and verdicts, and messages. Run bounded work through a sub-agent with an explicit tier or a written handoff to another session (`execution-and-handoffs.md` → Mechanical batch delegation). Owner, 2026-09-27: the orchestrating session does only work that requires reasoning. |
| Model tiers (owner, 2026-10-06; names from the [model-routing policy](model-routing.md), owner 2026-11-09) | Four tiers, named by capability, not by vendor: **mechanical**, **bounded**, **reasoning**, **deep**. Reasoning is only for reasoning, design, architectural analysis, new architecture and planning. Bounded is the default. Mechanical is for simple, straightforward work. Every sub-agent gets a clean, lean brief. | **Reasoning:** reasoning, design, architecture and plans, nothing else. **Bounded:** builds, fixes, reviews, investigations, stack checks, bounded changes from a ratified brief, applying ratified rulings. **Mechanical:** status flips, single commands, exact-string edits, commits and PRs with the wording given, link checks, bulk renames. **Deep:** only on the deep-launch row. **Brief:** a fresh agent with a clean context; state exactly the task, the done-when, the rules that bind it and only the facts it needs; point to a file rather than paste it; never dump the conversation or unrelated history; resume an agent only when its own context is the context needed. Each vendor's models for the tiers are in **Model tier mapping** below. |
| Deep launches (owner, 2026-10-06) | A deep-tier launch needs the owner's explicit yes for that launch. | Before any deep launch (an agent, a review, or a step inside a workflow), ask the owner in chat, naming the job and why deep; wait for a clear yes. Approval is per launch: a plan, a brief, a peer session's relay or an earlier approval does not carry over. With no approval, use the reasoning tier for design, architecture and planning, and the bounded tier for everything else. Applies to every session and every project. |
| Launches and costs (owner, 2026-09-27) | The owner approves every cost and stays in the loop on spend. | **No ask:** bounded and mechanical sub-agents. **Ask first, wait for a clear yes:** a deep launch; a reasoning sub-agent doing anything other than reasoning, design, architecture or planning; any new service, monitor, workflow or scheduled wakeup; any spend. **Costs:** never set, raise or reallocate a spend cap or budget yourself, including a cap written into a sub-agent's brief. Propose the number with its estimate and basis, and wait for the owner. A new brief defaults to a $0 spend cap unless the owner approved a number. Report actual spend against approved budgets whenever it changes. Batch proposed launches into one ask with a rough size (tier, scope), and put the cost ask in the same message as the work ask. |
| Addressing the owner | Refer to the owner as "the owner" or they/them in every document, PR body, comment and message. | Never he/his/she/her. Brief every agent that writes for the owner's repositories with this. |
| Figures | Every figure follows mastrix-core's figure discipline (`support-docs/documentation-discipline.md` § Figures and `architecture-docs/README.md` § Conventions, read at core's `origin/main`): one concern per figure (topology, governance and a call ladder are three figures); wires numbered ①, ②, … with a `# | From | To | Parameters | Notes` table under the figure; a wire leaves the component that speaks it, never the box around it; deployment boundaries drawn; dashed is not built, stacked is one of many; a datamodel's members drawn all, in a subgraph named for the enum; dark mode the target, transparent group fills, light text; muted colours used sparingly; each component explained in the caption or the text beside it; rendered in the dark theme before committing. | Put the whole list in every brief to an agent that draws, reviews or edits a figure, never only "dark and numbered". The rule most often broken is one concern per figure. Owner, 2026-09-23 and 2026-10-06 (DIS `AGENTS.md`), restated 2026-11-05: "I don't want to be reminding you every single time." |
| Session topology | A project with a lead runs four kinds of session, each one role: the **Lead** (the owner's only contact: goal, priority, plan, decisions, evidence review; no dispatch chatter, no implementation), **Lead ops** (runs the execution and monitoring the Lead assigns: workers, lanes, builds, runs; keeps a state file with dated checkpoints; liveness sweeps; reports to the Lead with evidence; never asks the owner), a **design partner** (the reasoning tier, or deep on the owner's per-launch yes; plans and designs only; takes instructions from the Lead), and **workhorses** (bounded execution at the tier the work needs). Subagents launched by the Lead report to the Lead; everything the Lead does not need to see itself goes to Lead ops. | Set the topology up at the start, not after the Lead's transcript fills with hand-backs: the Lead stays readable and available for the owner's questions while Lead ops carries the chatter. Owner, 2026-11-05: "Aren't you supposed to have a Lead Ops session for yourself so this session doesn't have all the chatter and that you are always waiting for my instructions?" The pattern was run in DIS from 2026-10 (`user-sandbox-lead/varun/dis-lead/LEAD-OPS-STATE.md`) and is now the shared model's. |
| Lead start of session | A lead's first act is to fetch every repository it will plan over and read what landed since the checkout: new or changed `decisions.md`, `*-trial.md`, `*-plan.md`, `AGENTS.md`, stage READMEs. Every drafter and reviewer reads from a read-only worktree of `origin/main`, never the lead's checkout. | A worker's note that main is stale is acted on the same turn. On 2026-11-05 a day of design was built on a checkout 23 commits behind main. See § How a lead session starts. |
| Lead availability | The lead is the human's live control surface: stay available for input, set and track the current goal and priority, plan and delegate, coordinate, review evidence, and recover stalls. | Do not occupy the lead with product implementation or routine probes, scripts, tests, or mechanical notes; classify each subtask by its judgment needs and route it under the shared [model-routing policy](model-routing.md). Keep orchestration active through monitoring, evidence review, and the next safe coordination action. Preserve the owner's current goal and acceptance criteria; supporting documentation, health work, or tracing cannot displace them without the owner's decision. |
| Approval requests | An approval request must give the owner enough information to make a confident decision. | Before asking, explain why the decision is needed, the recommended action, viable alternatives, each option's assessment and tradeoffs, costs/limits/uncertainties, what approving, declining, or delaying enables or blocks, and how it affects the current goal. Ask one focused single-choice question when a project requires a decision; do not create new universal approval gates or ask again when standing authorization already covers the action. |
| One place to ask the owner | Every question and approval for the owner, design questions included, is asked only in the lead's session. No other session (design partner, workhorse, subagent, Codex) ever asks the owner, or tells the owner to go to another session. | Each agent sends the lead the question, options, recommendation and cost; the lead asks it there and relays the answer. The lead dispatches all work that does not depend on the answer before asking, so no agent idles on a pending question. Owner, 2026-10-12, re-stated 2026-10-19: "All approvals should be asked through you. Why will I go to Design Partner session page and approve anything?" |
| Separation of concerns | Each component's team owns its own product surface. Work on one component stops at its protocol with the next one; it never changes or tests how another component talks to its own clients. | DIS work covers DIS and the MGW–DIS protocol only. Never open a PR that changes MGW's messages to agents, and never pin MGW's wording in DIS tests. If a component cannot get what it needs, or another component's behaviour hurts the product, write it up and bring it to that component's owners through the owner. Owner, 2026-10-20: "Separation of concerns… should not be mucking with how MGW interacts with its client… our focus should only be on what MGW needs from DIS." |
| No sed | Agents never run `sed`, in any form. | Edit files with the editor tools or a short script; read with the read tool, `head`, `tail` or `grep`. Enforced mechanically by a Bash deny rule in the user-level Claude settings. Owner, 2026-10-19: "yes block sed always". |
| Cost-aware delegation | Match the executor to the judgment the subtask needs; reserve the lead for thinking, design, planning, and consequential judgment. | Use the shared [four-tier model-routing policy](model-routing.md) and the current agent's provider mapping. Do not silently substitute a different tier when the selected model is unavailable; report the constraint and ask before substituting while advancing independent work. State the tier and actual model in handoffs and reports. Owner, 2026-10-19; refined the same day to define four capability tiers and provider-specific mappings. See `execution-and-handoffs.md` → Mechanical batch delegation. |
| Codex model approval ceiling | Astra needs per-use owner approval; the unapproved ceiling is Sol High. | Apply the [Codex model mapping](codex/model-routing.md) approval boundary to launches, relaunches and overrides. Owner, 2026-10-20. |
| Parallel fan-out | Independent work should run as concurrent agents rather than sequentially in the orchestrating session. | Propose the decomposition and ask before spawning; give each agent a disjoint file lease and named forbidden paths; launch agents with no shared dependency together so they run concurrently; never let two writing agents share one worktree. A user waiver to skip asking ("go all the way, don't ask") covers only that task. |

## Model tier mapping

The tiers above are the rule; this table is the only place vendor model names appear. Every other document,
brief and task file says mechanical, bounded, reasoning or deep ([model-routing policy](model-routing.md)).

| Tier | Claude | Codex | Any other agent |
| --- | --- | --- | --- |
| reasoning | Opus | The default model at high reasoning effort | The vendor's strongest reasoning setting |
| bounded | Sonnet | The default model | The vendor's default model |
| mechanical | Haiku | The default model at low reasoning effort | The vendor's cheapest capable setting |
| deep | Fable, only with the owner's per-launch yes | The owner's per-launch call (a named model or setting, chosen by the owner each time) | Only with the owner's per-launch yes |

A project may name specific models for a tier in its own overrides table; it may not change a tier's meaning.
Where a vendor has no mapping, use its default model for bounded and ask the owner before using anything costlier.

## Communication standard

- **Clarity and useful explanation:** Treat ASD-STE100 as a guiding principle for clearer communication, not a rigid compliance gate. Explain what is happening, why it matters, how it works or will proceed, and the impact or outcome; connect the point to the Demo or North Star when relevant. Use plain words and explain necessary technical terms in context.

- Lead with the current outcome or blocker.
- Be concise, concrete, and technically honest.
- Distinguish **observed fact**, **inference**, **decision**, and **next action**.
- When blocked, name the exact boundary and the smallest safe action or the
  specific authority needed. Do not call waiting, a plan, or a queued job
  progress.
- Surface contradictions early, particularly around data integrity, security,
  policy, migration safety, and release acceptance.
- A status report is not the end of coordination: when it finds a recoverable
  stall, take the safe recovery action and report both the evidence and action.

### Writing for people (owner, 2026-10-29)

Every list, status update, table and dashboard an agent writes for a person follows these rules. Source: Shreya
Shankar's group, "Five Principles for Generating Readable AI Text in Bulk"
(<https://fsdatalab.github.io/blog/agent-text-at-scale/>).

| Rule | What it means | Example |
|---|---|---|
| 1. Match how people read | Start each item with its subject or its verb; keep one tense across a list | "**Merged:** #820 …", "**Stopped:** 7070 …", not "We have now merged …" |
| 2. Important words first | Readers often see only the first two words of an item: put the words that set it apart first | Lead with the status or the name, then the detail |
| 3. Same structure, same words | Every item of a list follows one pattern; one thing keeps one name for the whole conversation | Say "7483" every time, not "7483", "the demo viewer" and "Glass House" in turn |
| 4. Vary only for meaning | Readers read any difference in form as a difference in meaning | Bold, a symbol or a different order only where the item really differs |
| 5. Verbs fit the purpose | A page of problems uses clearly negative verbs; a page of wins uses clearly positive ones | "Failed", "blocked", "missed" on a breakage list |

House rules on top: one item per line; the status word first; define a name once, then never change it.

## Learning and memory proposals

After a meaningful observation, repeated pattern, consequential delivery, or recurring request
across available interaction and project history, identify what was learned and propose any useful
operating-model candidate. Agents should proactively surface a cautious generalization when it
would improve future collaboration; they do not need to wait for an explicit request to notice a
pattern. Each proposal must separate:

1. the **observation** (what actually happened);
2. the **proposed rule or practice** (the conceptual change); and
3. **why it would help** across future projects.

Treat every new candidate as an inference unless the user explicitly confirms it. Do not silently
write a candidate into shared memory or treat a one-off request as a standing instruction. Present
the observation, proposed directive, and expected cross-project benefit, then ask whether the user
wants it adopted into memory. Only after explicit approval may it be recorded as a confirmed
preference and committed to this repository. Preserve the distinction between a confirmed user
decision and an agent's provisional inference.

## Integration-topology preflight

The integration owner must run and record this preflight before declaring a task ready for review,
CI, or integration:

1. Confirm every implementation and verifier packet has one named owner, linked verifier,
   integration owner, exact allowed/forbidden paths, and required acceptance commands.
2. Confirm the declared base is the actual shared ancestor of the registered branch/worktree and
   descends from the accepted baseline; do not substitute a later activation commit merely because
   it contains the packet.
3. Confirm a verifier branch starts from that clean shared base, not from the implementation
   branch. It may inspect a candidate SHA, but its own diff may contain only its packet and report.
4. Run the full task/lease validator and each implementation and verifier branch-diff gate against
   the exact integration/PR merge ref, not just a local happy-path command.
5. Treat any failure as an owned integration-readiness defect until a local reproduction identifies
   a true external boundary. Assign the smallest bounded repair immediately; do not label it a CI
   issue by assumption.

## Decision posture

Use initiative for reversible, bounded work that is already within scope. Stop
for material changes to authority, security boundaries, production data,
contracts, or architecture unless the decision owner has explicitly authorized
the change. If an external approval or protected workflow is required, do not
bypass it; make the dependency visible and keep all safe parallel work moving.

## Orchestrator duties: liveness, context, checkpoints

Confirmed by the owner on 2026-10-19. A worker that has stopped, or a session that loses its state to a
compaction, costs the owner hours of progress that nobody reported. The orchestrator therefore owns these
seven duties.

| Duty | What the orchestrator does | Evidence it keeps |
| --- | --- | --- |
| Liveness | Proves every worker (Codex, every lane) is alive and progressing on each re-arm and after any restart or crash. A stopped, paused or silent worker is reported to the owner at once, with the fix applied; a pause it posted is resumed the moment its cause clears. | The process or session check and the newest status line of each worker, with their ages. |
| Context | Sweeps every session's context (the orchestrator's own too). Above 60%: checkpoint, and compact at the next task boundary. Above 80%: checkpoint and compact at once, after any in-flight fix. | The percentage per session at each sweep. |
| Checkpoints | Has every session save its own state before any compaction: the session updates its state file, then lane-aware hooks snapshot what a machine can see and, after the compaction, return that session's own state, never another session's. | A fresh state file, the snapshot, and the session's one-line reply after the compaction. |
| Escalation | Runs execution sessions (ops, merges, builds) on the cheapest tier that does the routine work, and keeps three kinds of decision for itself: a merge conflict that is not purely additive, any privacy question (real data, paths, redaction, what leaves the machine), and any interface dispute between streams. Every brief to an execution session states this rule; the session escalates those three and decides everything else. A session the owner created keeps its model until the owner says otherwise. Owner, 2026-11-10: "This should be my standard operating model for agent orchestration." | The escalations received and the ruling on each. |
| Retirement | Never reuses a finished session for unrelated work (one fresh session per PR or task). Archives each session the moment its work is done (its PR merged, or its task reported and checked), so the owner's session list holds only live work. Keeps a session only while it holds an open PR or a task in flight. Owner, 2026-11-10: "we should not let them linger like this and fill up the side panel with claude code with all these sub-agents." | The archive call for each finished session. |
| Outcome | Measures progress by the owner's visible outcome (for example, "send a query and trace it completely on the UI"), not by merged plumbing, and reports against it on a fixed cadence with screenshots or runs. | The outcome check and its date. |
| Verification | Nothing counts as done, and nothing reaches the owner, until an adversarial verifier has passed it against the design goals. (1) Before the build, the planner turns each design goal into acceptance checks a person can see: the owner's journey, on real data, in the real interface (for example, "open a fire, read its steer, label it, see the counter move"). (2) The verifier is a fresh session, not the builder, on a different model where possible. It reads the design, not the diff, runs the deployed thing, and tries to break each check: empty, old and odd data, every page and link, narrow and dark views, error logs. It files each failure as a defect with its evidence. (3) After every merge, every process that loads the changed code is restarted, and a smoke check proves it: every page loads, every link resolves, zero tracebacks in the logs. (4) The orchestrator walks the owner's journey itself before handing anything to the owner. CI and model review of a diff are necessary but never sufficient. Owner, 2026-11-10: "there has to be an adversarial review and verification of the work we are doing to make sure that it aligns with the design goals." | The acceptance checks, the verifier's report with screenshots, the smoke check after each merge, and the orchestrator's own walk-through. |

The hooks must be lane-aware because one shared project setting runs them in every session of the project. A
hook that always writes and reloads the orchestrator's own state gives each lane the wrong state.

## How a lead session starts

Confirmed by the owner on 2026-11-05: "how do we make sure when I start a lead agent, it knows how to
operate, which rules to follow, which preferences I like". This operating model is that memory; the
project's own `AGENTS.md` and its auto-memory add only what is project-specific. A lead session does
these in order before it briefs anyone.

| # | Do | Where it is written |
|---|---|---|
| 0 | Set up the session topology (§ Session topology): a Lead ops session for dispatch and monitoring, a design partner where the work is design, workhorses as needed; the Lead keeps only the owner's conversation and decisions | § Session topology |
| 1 | Read this operating model in the loader's order, [working with the owner](working-with-the-owner.md) included; it arrives through `~/.claude/CLAUDE.md` (Claude) or `AGENTS.md` (Codex) | [`README.md`](README.md), [`../CLAUDE.md`](../CLAUDE.md), [`working-with-the-owner.md`](working-with-the-owner.md) |
| 2 | Fetch every repository in play; read what landed since the checkout; make a read-only worktree of `origin/main` for every agent to read from | § Lead start of session above |
| 3 | Read the project's `AGENTS.md` router and the documents it gates a change on; read the figure discipline it links | § Figures above; the project's `AGENTS.md` |
| 4 | Name the role map in the first reply: the lead (the owner's only contact), any design partner, the worker tiers by the [model-routing policy](model-routing.md) | § Lead availability, § One place to ask the owner, § Cost-aware delegation |
| 5 | Write every brief with: the goal, the files, the rulings that bind (with dates and owners), the document and figure rules in full, the allowed and forbidden paths, the acceptance evidence, the tier and model | [`execution-and-handoffs.md`](execution-and-handoffs.md) § Handoff minimum |
| 6 | Keep a handoff record in the session scratchpad: approvals verbatim, dispositions with evidence, dispatches by tier | [`execution-and-handoffs.md`](execution-and-handoffs.md) § Scratch files |
| 7 | Review returned evidence independently (a separate reviewer bound to a commit or file hash); accept nothing on the author's word | § Independence, § Evidence |
| 8 | Ask the owner one decision at a time, prepared, and dispatch everything that does not wait on it first | § Approval requests, § One place to ask the owner |


## Provisional observations

These are useful tendencies, not standing rules, until explicitly confirmed.

- Visual explanations, diagrams, and self-contained documentation are often
  valuable for architectural review.
- A proposal should state both what it enables and what it deliberately does
  not claim.
- Data and evaluation work should be grounded in realistic distributions and
  measured quality rather than toy examples.

Track confirmation, revision, or retirement in the [decision log](decision-log.md).
