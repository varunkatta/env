# Codex model routing

Use the four shared tiers from [model-routing.md](../model-routing.md). The
family-to-tier mapping is the owner's durable policy; the verified model IDs
below are examples checked on 2026-10-19.

| Shared tier | Codex family | Verified example model ID |
| --- | --- | --- |
| Mechanical | Luna | `gpt-6-luna` |
| Bounded execution | Terra | `gpt-5.6-terra` |
| Reasoning and planning | Sol | `gpt-6.1-sol` |
| Deep technical reasoning | Astra (explicit owner approval required per use) | `gpt-6-astra` |

## Approval boundary

The owner confirmed on 2026-10-20 that Astra requires explicit owner approval for each use. Without that approval, the highest permitted Codex reasoning choice is `gpt-6.1-sol` at high effort. Do not select Astra, a higher model family, or an effort above Sol High without explicit approval. This applies to future launches, relaunches and model or effort overrides. This approval boundary qualifies the tier mapping below; it does not change historical completed reviews.

These tier assignments are the owner's policy, not a claim that the families
share a release generation. The actual model must be advertised by the
dispatcher being used. As observed on 2026-10-19, this session's
`spawn_agent` choices include Luna, Sol and Astra but not Terra; the app's
`create_thread` Terra option does not establish `spawn_agent` availability.
This is a dated runtime constraint, not a permanent product limitation. Do not
create chats to bypass it. If the selected family is unavailable, follow the
shared no-substitution rule and ask before using another tier.

Official model references: [OpenAI model catalog](https://developers.openai.com/api/docs/models),
[GPT-5.6 Terra](https://developers.openai.com/api/docs/models/gpt-5.6-terra),
[Using GPT-6](https://developers.openai.com/api/docs/guides/latest-model).
