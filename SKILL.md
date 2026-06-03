---
name: rough2ready
description: Rewrite rough, incomplete, informal, or underspecified user prompts into clear, detailed, well-structured prompts, then execute the improved prompt in the same turn. Use when the user asks to improve, rephrase, structure, expand, professionalize, clarify, "turn this into a better prompt", or use a rough prompt for any topic, including comparisons, research, purchases, travel, planning, coding, writing, strategy, analysis, reviews, or decision support.
---

# Rough2Ready

Rough2Ready turns messy intent into a finished answer, without making the user manage the prompt.

## Goal

Transform the user's rough prompt into a stronger prompt, then answer the improved prompt immediately. Preserve the user's intent, language, constraints, and tone unless the user asks to change them.

## Core Workflow

1. Infer the task type:
   - comparison or decision
   - research or explanation
   - recommendation or buying choice
   - planning or strategy
   - critique or review
   - writing or editing
   - coding or debugging
   - data analysis
   - creative generation
   - other custom task

2. Infer the domain and role:
   - Choose a useful expert role based on the subject, not a generic "expert".
   - Examples: "automotive reviewer", "travel planner", "software architect", "security analyst", "product strategist", "financial analyst", "technical writer".
   - If the domain is unclear, use a broader role and include a short placeholder for the user to fill.

3. Preserve explicit inputs:
   - Keep named items, links, files, products, places, tools, people, dates, budgets, constraints, and target audience.
   - Do not invent missing facts.
   - If an important input is missing, add a bracketed placeholder like `[budget]`, `[location]`, `[tool A]`, or `[success criteria]`.

4. Add useful structure:
   - Convert vague requests into ordered sections.
   - Add output format instructions when helpful: table, bullets, checklist, rubric, timeline, decision matrix, code block, JSON, report, or executive summary.
   - Add evaluation criteria specific to the task.
   - Add an explicit final deliverable or recommendation when the original prompt implies a decision.
   - Add only structure and criteria that improve the answer; remove any phrase that only makes the prompt longer without making the task clearer.

5. Add quality constraints:
   - Ask for neutrality when comparing.
   - Ask for assumptions to be stated.
   - Ask for uncertainty, tradeoffs, risks, and edge cases where useful.
   - Ask for sources or web verification only when the prompt needs current facts, prices, laws, availability, schedules, reviews, or other time-sensitive information.
   - For purchases, travel, products, specifications, prices, or current recommendations, research first and cite sources before giving the verdict.

6. Execute by default.
   - If the original prompt is dangerously ambiguous, follow the Clarification Policy before proceeding.
   - If reasonable assumptions are enough, include them inside the rewritten prompt under "Assumptions to use if not specified".
   - Unless the user explicitly asks only for the rewritten prompt, answer the task using the improved prompt in the same response.
   - Keep the rewritten prompt visible but compact when the final answer is the main value.

## Clarification Policy

Default to execution, not interrogation.

Only ask a clarification question when the request cannot be executed at all without it, or when proceeding would likely produce a misleading or unsafe answer.

When details are missing but reasonable assumptions are possible:
- make the assumptions explicit
- proceed immediately
- keep the answer practical

Ask at most 1 clarification question by default. Never ask multiple questions unless the user explicitly asks for an interview-style refinement.

## Prompt Economy

Every word in the rewritten prompt should be load-bearing.

When rewriting, add structure, criteria, constraints, or context only when they make the final answer clearer, more accurate, more useful, or safer. Remove generic padding, motivational language, duplicated instructions, and ornamental phrasing.

Prefer a compact prompt that reliably produces the right answer over a long prompt that sounds impressive.

## Prompt Template Pattern

Use this flexible shape. Remove sections that do not fit the user's request.

```text
Act as a [specific expert role].

I need help with [clear task objective] about [subject/items/context].

Context:
- [Preserved detail from the original prompt]
- [Relevant constraint, audience, goal, or use case]
- [Placeholder for missing but important detail]

Your task:
1. [First concrete analysis or creation step]
2. [Second concrete analysis or creation step]
3. [Third concrete analysis or creation step]

Please structure the response as follows:
1. [Section tailored to the task]
2. [Section tailored to the task]
3. [Section tailored to the task]
4. [Final recommendation, next steps, checklist, or deliverable]

Requirements:
- Be specific and practical.
- State assumptions clearly.
- Explain tradeoffs and limitations.
- Prefer concrete examples over generic advice.
- If current information matters, verify it with reliable up-to-date sources and cite them.
```

## Task-Specific Structures

### Comparison or Decision

Include:
- objective and decision context
- brief overview of each option
- comparison table with domain-specific criteria
- strengths and weaknesses for each option
- crucial differences in philosophy, architecture, experience, cost, or fit
- scenario-based recommendation
- when the non-recommended option would be better

### Recommendation or Purchase

Include:
- user profile and intended use
- budget, location, timing, and constraints placeholders if missing
- must-have vs nice-to-have criteria
- shortlist criteria
- risks, hidden costs, maintenance, warranty, safety, or availability where relevant
- final recommendation with caveats

### Research or Explanation

Include:
- target audience and desired depth
- definitions of key concepts
- structured explanation from fundamentals to nuance
- examples and counterexamples
- common misconceptions
- practical implications
- source requirements if facts are current or contentious

### Planning or Strategy

Include:
- goal, starting state, constraints, and timeline
- phases or milestones
- dependencies and risks
- success criteria
- decision points
- concrete next actions

### Coding or Debugging

Include:
- project context, expected behavior, actual behavior, and environment
- relevant files, logs, commands, or error messages placeholders
- reproduction steps
- requested output: diagnosis, patch, tests, explanation, or review
- constraints about preserving existing behavior

### Writing or Editing

Include:
- audience, purpose, tone, format, and length
- source material to preserve
- desired structure
- style constraints
- examples of what to avoid if implied
- final output format

## Style Rules

- Match the user's language. If the user writes in a non-English language, rewrite the prompt in that language.
- Keep the rewritten prompt self-contained.
- Make the prompt detailed, but not bloated.
- Prefer headings and numbered sections over long paragraphs.
- Use placeholders only for information that materially improves the answer.
- Do not add fake requirements, fake citations, fake examples, or fake context.
- Do not stop at the rewritten prompt unless the user explicitly asks only for prompt rewriting.
- When executing, follow the improved prompt as the operative instruction.

## Output Format

By default, return:

```markdown
## Rewritten Prompt
[rewritten prompt]

## Answer
[answer produced by following the rewritten prompt]
```

If the user explicitly asks only to rewrite the prompt, return:

```markdown
## Rewritten Prompt
[rewritten prompt]
```

If clarification is necessary before rewriting, return:

```markdown
Before rewriting, I need to clarify:
1. [question]
```
