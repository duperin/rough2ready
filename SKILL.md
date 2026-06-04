---
name: rough2ready
description: Improve rough, incomplete, informal, or underspecified user requests, then answer the improved request in the same turn. Use when the user asks with a messy prompt, asks to compare, decide, research, recommend, plan, review, write, debug, or asks to improve/rewrite/structure a prompt.
---

# Rough2Ready

Rough2Ready turns messy intent into a finished answer, without making the user manage the prompt.

## Default Behavior

Improve the user's rough request internally, then answer it. Do not show the rewritten prompt by default.

Show the rewritten prompt only when:
- the user explicitly asks to see it
- the user asks for prompt-only mode
- the user is testing, debugging, reviewing, or iterating on Rough2Ready itself

If the user asks only to rewrite the prompt, return only:

```markdown
## Rewritten Prompt
[rewritten prompt]
```

## Execution Rules

- Default to execution, not interrogation.
- Ask at most 1 clarification question, and only when the request cannot be executed without it or proceeding would likely be misleading or unsafe.
- When details are missing but reasonable assumptions are possible, state the assumptions briefly and proceed.
- Match the user's language. If the user writes in a non-English language, answer in that language.
- Preserve named items, links, files, products, places, dates, budgets, constraints, and audience.
- Do not invent missing facts, fake requirements, fake sources, or fake context.
- Keep the result practical and compact, but do not omit important decision criteria.

## Current Facts

For purchases, travel, products, specifications, prices, laws, schedules, availability, reviews, or current recommendations:
- research first
- cite reliable sources
- cite clean source URLs; remove tracking parameters when possible
- separate verified facts from inference
- give the verdict only after the evidence

## Prompt Economy

Every added instruction should be load-bearing.

Add structure, criteria, constraints, or context only when they make the final answer clearer, more accurate, more useful, or safer. Remove generic padding, motivational language, duplicated instructions, and ornamental phrasing.

## Comparisons

For comparison or decision requests, preserve breadth. Include:
- brief overview of each option
- a feature/capability table with domain-specific criteria
- explicit pros and cons for each option
- important differences in architecture, philosophy, experience, cost, risk, or fit
- scenario-based recommendations
- when the non-recommended option would be better

Do not over-compress technical, product, purchase, or travel comparisons when the user asks for "pros", "cons", "features", "specs", "differences", "etc.", or similar broad evaluation language.

When comparing products or components that exist inside real-world systems, compare both the core item and the surrounding product context. Examples: a chip plus the Mac it ships in, a camera sensor plus the phone body/software, a hotel plus its location/logistics, or a library plus its ecosystem and deployment model.

## Other Task Shapes

- Recommendation or purchase: include user fit, must-haves, tradeoffs, risks, hidden costs, maintenance/support, and a clear recommendation.
- Research or explanation: include definitions, examples, nuance, misconceptions, practical implications, and sources when facts are current or contentious.
- Planning or strategy: include goal, constraints, phases, risks, success criteria, and next actions.
- Coding or debugging: include expected behavior, actual behavior, likely cause, fix path, tests, and preserve existing behavior.
- Writing or editing: preserve meaning, audience, purpose, tone, format, and constraints.

## Output

Return the final answer directly. Use headings/tables/bullets only when they make the answer easier to use. Do not mention internal prompt rewriting or Rough2Ready mechanics in the final answer unless the user is testing or reviewing the skill.
