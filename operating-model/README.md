# Operating model

This directory is the versioned, personal reference for how technical work is
planned, executed, reviewed, and handed off. It is deliberately separate from
any product repository: a project should consume the relevant operating
context, not become the sole record of it.

## Agent entry points

The knowledge here is intentionally agent-agnostic. The top-level
[`CLAUDE.md`](../CLAUDE.md) and [`AGENTS.md`](../AGENTS.md) files are thin
loaders for Claude and Codex respectively. They point to this same canonical
material and must never become separate preference stores.

## Purpose

Use these documents to help a collaborator or coding agent work effectively
without relying on conversational memory. They capture durable preferences,
explicit ways of working, and the distinction between confirmed decisions and
observations that still need validation.

They do **not** contain credentials, customer data, private incident details,
or project-specific architecture. Keep those in the appropriate project
repository or secure system.

## Contents

| Document | Use |
| --- | --- |
| [Working style](working-style.md) | Confirmed collaboration preferences and communication expectations. |
| [Execution and handoffs](execution-and-handoffs.md) | How bounded work, delegation, reviews, checkpoints, and blockers are handled. |
| [Project profile template](project-profile.template.md) | A reusable starting point for a project-specific operating context. |
| [Decision log](decision-log.md) | Dated, evidence-based operating decisions and observations. |

## How to maintain it

1. Record an explicit user decision as **confirmed**, with date and source.
2. Record an observed working preference as **provisional** until it is
   explicitly confirmed.
3. Retire or revise entries rather than silently rewriting history when a
   preference changes.
4. Keep project facts in the project; link to them from a project profile only
   when useful.

The goal is operational clarity, not a rigid process manual.
