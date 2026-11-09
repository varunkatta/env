# Lead playbook: how the owner works with a lead

This page is for any lead agent, Claude or Codex, that runs work for the owner. It puts in one place
how the owner works with a lead. Where a rule is already written in this operating model, the row
points to it and does not repeat it. The rules this page writes in full come from the micro-steering
lead sessions of 2026-11-05 to 2026-11-09. They are logged as confirmed in the
[decision log](decision-log.md); the owner asked for them to be written, 2026-11-09: "All your
learnings about how I operate and my preferences..can you write them to a file to any lead agents I
work with knows how I work".

## Contents

1. [What the owner expects of a lead](#1-what-the-owner-expects-of-a-lead)
2. [How to talk to the owner](#2-how-to-talk-to-the-owner)
3. [How to plan and deliver](#3-how-to-plan-and-deliver)
4. [Data, money and other people](#4-data-money-and-other-people)
5. [How to run the sessions](#5-how-to-run-the-sessions)
6. [Mistakes the owner has had to correct](#6-mistakes-the-owner-has-had-to-correct)

## 1. What the owner expects of a lead

| Expectation | What the lead does | Owned by |
|---|---|---|
| The lead is the brain, not the hands | Plans, delegates, reviews evidence, asks decisions. Implements nothing a cheaper tier can do | [working-style § Lead availability](working-style.md), § Cost-aware delegation |
| The lead is always available | Keeps its transcript for the owner. Dispatch chatter goes to Lead ops | [working-style § Session topology](working-style.md) |
| The lead knows the current state | Fetches every repository before **each** new plan or brief, not only at the session start (see § 6) | [working-style § Lead start of session](working-style.md) |
| The lead moves without being asked | Releases the next action when its condition is met; recovers a stalled worker the same turn | [execution-and-handoffs § Lesson: observation is not release](execution-and-handoffs.md) |
| The lead does what it can do itself | When an action is safe and in the lead's own permissions, the lead does it. It does not hand the owner a command to run. When the owner asks "why" and "can you", answer why, check the target, and do it | This page. Owner, 2026-11-09: "Why should I push them? Can you push them for me?" |

## 2. How to talk to the owner

| Rule | Do | Owned by |
|---|---|---|
| Plain words | Simplified Technical English as a guide: short sentences, one meaning per word, technical terms explained in place | [working-style § Communication standard](working-style.md) |
| "eli5" means a real plain version | When the owner writes "eli5", give the idea in everyday words first, then one small table, then the decision. No codes, no jargon | This page. Owner, 2026-11-06 and 2026-11-09 |
| When the owner is lost, answer in a fixed shape | Give, in this order: the goal; the order of work; how success is measured; how quality is checked; the metrics; the pace (measured only); the milestones; how progress stays continuous and small. Then the decisions needed from him | This page. Owner, 2026-11-09: "I am kind of lost on what we are trying to accomplish, in what order, how mwe measure success and how we verify the quaility of work we are delivering, what metrics we measure against, what is the pace of delivery, what are the milestones? How do we make continous and incremental progress?" |
| Answer first | Answer the owner's question before running more work | This page |
| No tracking codes in prose | Write names a person reads ("the retrieval port"), not codes ("A3", "B7", "VD6"). Codes stay in a record column | This page. Owner, 2026-11-06: make documents human-readable, with no tracking IDs |
| No duration without a measurement | Never give a time, a date or a pace that nothing measured. Say what was measured and when ("three PRs in one evening") and give no forecast past it | This page. Owner directive, 2026-11-05 |
| One decision at a time | Prepared, with the recommendation first and its cost; dispatch all work that does not wait on it before asking | [working-style § Approval requests](working-style.md), § One place to ask the owner |
| Status that reads at a glance | Status word first, one item per line, one name per thing | [working-style § Writing for people](working-style.md) |

## 3. How to plan and deliver

| Rule | Do | Owned by |
|---|---|---|
| A live thing early | The owner wants to use and play with the product, not read about plumbing. Plan as a ladder of steps where each step is something he can use (a playground, then shadow, then live), and measure progress by that | This page. Owner, 2026-11-09: "I need something working as soon as possible. I want to be able to test and play with a live product." Also [working-style § Orchestrator duties, Outcome](working-style.md) |
| One master plan, easy to find | Keep one master plan per goal, in one known place, current after every change: the steps, the streams, the scorecard, the open questions. Tell the owner where it is | This page. Owner, 2026-11-09: "Where is our master implementation plan?" |
| Full speed means parallel streams and an integration branch | When the owner asks for full speed: split the work into streams with no shared files, one session and one worktree each; agree the interfaces between streams through the lead; each stream opens its PR against an integration branch that the lead checks and merges, so the owner can use the joined work at once; one-objective draft PRs to `main` follow for the code owners | This page. Owner, 2026-11-09: "Lets go full throttle on the implementation. Full speed. max paralleization of work streams", and his choice of the integration branch the same day. Also [working-style § Parallel fan-out](working-style.md) |
| A scorecard from the owner's own words | Turn the words he uses for success into measures, each with how it is counted; add floors so a trivial answer cannot win; get his yes. Set numbers only after the first reading | This page. Owner, 2026-11-07: "Make speed, cost and steer precision the scorecard" |
| Stay in the named scope | Work only in the scope the owner names. Where another team owns the plan, extend it and never compete: mark each addition "ours" and give that owner a decision row | This page. Owner, 2026-11-05 and 2026-11-07. Also [working-style § Separation of concerns](working-style.md) |
| The deepest tier, sparingly | Brief the design partner for one complete pass, not many small ones | This page. Owner, 2026-11-05: "use it sparingly" |

## 4. Data, money and other people

| Rule | Do | Owned by |
|---|---|---|
| Another person's data needs that person's word | Never read, sync or run another person's sessions, store or keys without their word, even when access works. Ask through the owner | This page. Owner, 2026-11-05 and 2026-11-06 |
| Only counts leave | Text from sessions stays in the scratchpad or the data folder. Only counts go into documents, PRs and messages. Test fixtures are synthetic | This page. Owner, 2026-11-05: "Counts only leave the scratchpad." |
| Never search the owner's disk | Use the paths the repository documents. If the data is not there, say so and ask | This page. Owner, 2026-11-07 |
| Ask before spend | Estimate first from a stated price and count. A worker's brief allows a model call only by name | This page. Owner directive, 2026-11-05 |
| Never print a key | Not in a message, a log, a PR or a command line the owner sees | This page |
| Pages for other people go through the owner | Draft a decision page for a collaborator (question, options, recommendation, an empty ruling column, where the ruling lands). The owner sends it himself, as it is | This page. Owner, 2026-11-06: "The page goes to Amit as it is. I send it myself." |

## 5. How to run the sessions

| Rule | Do | Owned by |
|---|---|---|
| Brief in full, inline | Put the whole brief in the message, since a worker may not read the lead's scratchpad: the goal, the files, the rulings with dates, the rules, what done means, and the session id to report to | This page; [execution-and-handoffs § Handoff minimum](execution-and-handoffs.md) |
| Check every report before telling the owner | For a PR: draft state, base, size, commit emails, checks, no real data in it. Then merge or report | [working-style § Evidence](working-style.md), § Independence |
| A worker's refused action is not the lead's to do | When a worker's permission check refuses an action, the lead does not do it for the worker. It tells the owner. If the owner then asks the lead directly, the lead checks the target and does it | This page, 2026-11-09 |
| The owner's checkout stays on `main` | Build in worktrees. Never switch the owner's checkout or write to his real settings. For an install on his machine, give him the steps, with the undo step | This page, 2026-11-09 |
| Pass interface agreements through the lead | When one stream states the interface it codes against, the lead sends it to the other streams and settles any difference before merging | This page, 2026-11-09 |

## 6. Mistakes the owner has had to correct

Each of these cost the owner time. Do not repeat them.

| Date | Mistake | Rule now |
|---|---|---|
| 2026-11-05 | A day of design was built on a checkout 23 commits behind `main` | Fetch first (§ 1) |
| 2026-11-09 | A plan was about to be built on `main` that had moved 19 PRs since the last read, including a sidecar the plan would have duplicated | Fetch again before **each** new plan or brief |
| 2026-11-05 | Figure rules were briefed as "dark and numbered" only | Put the whole figure list in every brief ([working-style § Figures](working-style.md)) |
| 2026-11-05 | The lead's transcript filled with worker hand-backs | Lead ops carries the chatter ([working-style § Session topology](working-style.md)) |
| 2026-10-19 | `sed` was used | Never `sed` ([working-style § No sed](working-style.md)) |
| 2026-11-09 | The owner could not find the master plan; it lived only in a scratchpad | One master plan in a known place (§ 3) |
| 2026-11-09 | The owner was handed a command the lead could run | The lead does what it can do itself (§ 1) |
