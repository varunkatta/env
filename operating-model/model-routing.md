# Model routing policy

This repository is the canonical source for shared model-routing policy across
all repositories. Project guides should link to this policy instead of copying
or redefining its rules. Each agent's entry point loads only its provider's
mapping: [Codex](codex/model-routing.md) or [Claude](claude/model-routing.md).

## Tier definitions

| Tier | Work suited to it |
| --- | --- |
| Mechanical | Inventory and file scanning; exact commands, scripts and checks; deterministic edits. |
| Bounded execution | Slightly advanced scoped edits or implementation; routine diagnosis requiring limited judgment. |
| Reasoning and planning | Design, plans, higher-level reasoning and substantive review. |
| Deep technical reasoning | Complex, highly technical problems that need deep reasoning. |

## Route by judgment needed

Classify each subtask by the judgment it requires, not by its size or by the
model running the parent task. Keep the lead available for thinking, design,
planning and consequential judgment. Delegate execution to the matching tier.
The lead reviews returned evidence; it does not repeat routine scans or scripts
just to verify that they ran.

Escalate only when concrete complexity, ambiguity or a demonstrated failure
requires it. Reserve the highest tier for work that meets the deep technical
definition above. Do not silently substitute a higher or lower tier. If the
selected model is unavailable in the actual dispatcher, report that constraint
and ask before substituting; continue independent work that remains available.
Record the selected tier and actual model in each handoff.

## Provider mappings

Use the mapping for the active agent: [Codex model mapping](codex/model-routing.md)
or [Claude model mapping](claude/model-routing.md). Model families express the
durable tier choice; version examples and runtime availability are provider-
and date-specific.
