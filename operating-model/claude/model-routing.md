# Claude model routing

Use the four shared tiers from [model-routing.md](../model-routing.md). This
mapping applies the owner's tier policy to Anthropic's model families; it is
not Anthropic's own four-tier policy. The API model examples below were checked
on 2026-10-19.

| Shared tier | Anthropic family | Verified example API model ID |
| --- | --- | --- |
| Mechanical | Haiku | `claude-haiku-5-5` |
| Bounded execution | Sonnet | `claude-sonnet-5-5` |
| Reasoning and planning | Opus | `claude-opus-5-5` |
| Deep technical reasoning | Fable | `claude-fable-5-1` |

Treat these as family mappings, separate from dated model IDs and actual
Claude Code launcher availability. Use a reasoning-effort setting only when
the selected model and client support it. Start with Opus for demanding work;
reserve Fable for a demonstrated deep-technical need, especially when Opus at
supported higher effort still falls short. An API model ID does not prove that
the active Claude Code launcher can select it; check its advertised choices
and follow the shared no-substitution rule if the selected family is absent.

Official references: [Anthropic model overview](https://platform.claude.com/docs/en/models/overview),
[choosing a model](https://platform.claude.com/docs/en/about-claude/models/choosing-a-model),
and [effort levels](https://platform.claude.com/docs/en/build-with-claude/effort).

## Claude Code activation

The global `~/.claude/CLAUDE.md` wrapper activates this mapping through an
absolute `@` import of the environment repository's [Claude loader](../../CLAUDE.md).
Claude Code expands imports when a session starts; restart or start a session
after changing the imported files, then confirm them with `/context`.
