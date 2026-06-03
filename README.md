# Rough2Ready

Rough2Ready turns messy intent into a finished answer, without making the user manage the prompt.

It is a lightweight Codex-compatible skill for people who write prompts quickly, informally, or incompletely and still want the agent to produce a useful final answer. Rough2Ready rewrites the request internally, adds only the structure that matters, researches when current facts are needed, and then executes the improved request in the same turn.

## What It Does

- Converts rough prompts into clear, executable requests.
- Executes the improved prompt immediately by default.
- Keeps clarification lightweight: at most one question unless the user asks for an interview-style refinement.
- Preserves the user's intent, language, named items, constraints, and tone.
- Adds task-specific structure for comparisons, recommendations, research, planning, coding, debugging, writing, and analysis.
- Researches first and cites sources for purchases, travel, products, specs, prices, and current recommendations.
- Avoids bloated prompt engineering. Every word in the rewritten prompt should be load-bearing.

## Why This Exists

Most prompt improvers stop after generating a polished prompt. Rough2Ready is different: it treats the improved prompt as an intermediate step, not the final product.

The goal is simple:

> Write messy. Get ready.

## Example Uses

### Compare Products

```text
$rough2ready compare BYD Dolphin SE com GAC Aion UT Elite
```

Expected behavior:

- infer that this is a purchase comparison
- research current specs, prices, and sources
- compare practical ownership criteria
- cite sources before the verdict
- recommend based on real-world scenarios

### Compare Travel Options

```text
$rough2ready compare Club Med Trancoso com NANNAI Muro Alto
```

Expected behavior:

- compare resort style, location, food, logistics, kids, beach, service, and cost predictability
- research current information
- cite sources
- recommend by traveler profile

### Improve and Execute a Technical Request

```text
$rough2ready compare jundot/omlx com raullenchai/Rapid-MLX quero pros contras funcionalidades etc
```

Expected behavior:

- identify the domain as local LLM inference on Apple Silicon
- check current repository information
- compare APIs, serving model, agent suitability, maturity, and risks
- produce a practical recommendation

### Prompt-Only Mode

```text
$rough2ready só reescreva esse prompt: compare essas duas ferramentas, quero prós e contras
```

If the user explicitly asks only for prompt rewriting, Rough2Ready returns the improved prompt without executing it.

## Core Principles

### Default To Execution

Rough2Ready should not turn every vague request into an interview. If reasonable assumptions are possible, it states them and proceeds.

### Research When Current Facts Matter

For purchases, travel, products, specifications, prices, or current recommendations, the skill must research first and cite sources before giving a verdict.

### Keep The Prompt Lean

Add structure, criteria, constraints, or context only when they make the final answer clearer, more accurate, more useful, or safer.

### Preserve The User

The skill should match the user's language and preserve the original intent. If the user writes in Portuguese, the rewritten prompt and final answer should usually be in Portuguese.

## Installation

### Codex

Install with the script:

```bash
curl -fsSL https://raw.githubusercontent.com/duperin/rough2ready/main/install.sh | bash -s -- --agent codex
```

Then invoke it in Codex:

```text
$rough2ready compare produto A com produto B
```

If you already cloned the repository:

```bash
./install.sh --agent codex
```

Manual install also works:

```bash
mkdir -p ~/.codex/skills
git clone https://github.com/duperin/rough2ready.git ~/.codex/skills/rough2ready
```

Restart Codex or start a new chat if the skill does not appear immediately.

### Claude Code

If your Claude Code setup supports local skills under `~/.claude/skills`, install with:

```bash
curl -fsSL https://raw.githubusercontent.com/duperin/rough2ready/main/install.sh | bash -s -- --agent claude-code
```

From a local clone:

```bash
./install.sh --agent claude-code
```

### Other Agents

For agents that support skill-style instruction folders, add this repository as a skill named `rough2ready` and point the agent to `SKILL.md`.

For agents without native skill support, copy the contents of `SKILL.md` into a reusable instruction, custom command, project rule, or system prompt snippet.

You can also install to a custom skills directory:

```bash
./install.sh --target /path/to/skills
```

### Quick Test

After installing, run:

```text
$rough2ready compare Club Med Trancoso com NANNAI Muro Alto
```

The expected behavior is that the agent improves the request, researches current travel/product facts when needed, cites sources, and gives a practical recommendation without asking a long list of questions.

## Repository Contents

```text
rough2ready/
├── SKILL.md
├── agents/
│   └── openai.yaml
├── install.sh
├── README.md
├── LICENSE
└── .gitignore
```

## Security And Privacy

This repository contains only skill instructions and UI metadata. It should not contain API keys, credentials, tokens, connection strings, private URLs, personal files, logs, or generated chat history.

Before publishing changes, scan for secrets and local-only paths.

## License

MIT
