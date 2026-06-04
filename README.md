# Rough2Ready

Rough2Ready turns messy intent into a finished answer, without making the user manage the prompt.

It is a lightweight agent skill for people who write prompts quickly, informally, or incompletely and still want the agent to produce a useful final answer. Rough2Ready rewrites the request internally, adds only the structure that matters, researches when current facts are needed, and then executes the improved request in the same turn.

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

## How It Thinks

Rough2Ready does not show the rewritten prompt by default. It uses the improved request internally, then returns the final answer.

Input:

```text
compare two project management apps, pros cons features etc
```

Internally, Rough2Ready treats that as something closer to:

```text
Compare the two project management apps as a practical usage decision. Include a feature table, pricing and current availability if relevant, pros and cons for each option, key workflow differences, ideal user profiles, risks, and a final recommendation by scenario. Research current facts and cite sources before the verdict.
```

Normal output:

```text
[final comparison answer]
```

## Example Uses

### Compare Products

```text
$rough2ready compare Framework Laptop 13 with MacBook Air, focus on travel use, repairability, battery life, and long-term value
```

Expected behavior:

- infer that this is a purchase comparison
- research current specs, prices, and sources
- compare practical ownership criteria
- cite sources before the verdict
- recommend based on real-world scenarios

### Compare Travel Options

```text
$rough2ready compare Kyoto with Seoul for a first-time family trip
```

Expected behavior:

- compare trip style, logistics, seasonal considerations, cost drivers, family fit, food, transit, and likely tradeoffs
- research current information
- cite sources
- recommend by traveler profile

### Improve and Execute a Technical Request

```text
$rough2ready compare Pinecone with Weaviate for a small RAG app, include pros, cons, features, and practical differences
```

Expected behavior:

- identify the domain as vector databases for retrieval-augmented generation
- check current repository information
- compare hosting options, developer experience, scaling model, pricing risks, ecosystem, and operational tradeoffs
- produce a practical recommendation

### Prompt-Only Mode

```text
$rough2ready only rewrite this prompt: help me choose between two project management apps
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

The skill should match the user's language and preserve the original intent. If the user writes in a non-English language, the rewritten prompt and final answer should usually stay in that language.

## Quick Install

### Requirements

- An agent that supports local skills or reusable command instructions, such as Codex, Claude Code, or OpenCode.
- macOS/Linux: Bash, Git, and `curl`.
- Windows: Windows 10 or later, PowerShell 5.1 or later, and internet access. Git is not required for the one-line Windows installer.

### Linux, macOS, WSL2, Termux

```bash
curl -fsSL https://raw.githubusercontent.com/duperin/rough2ready/main/install.sh | bash
```

### Windows PowerShell

```powershell
irm https://raw.githubusercontent.com/duperin/rough2ready/main/install.ps1 | iex
```

Both commands install Rough2Ready for Codex by default.

<details>
<summary>Install for Claude Code, OpenCode, or a custom path</summary>

Use the same installer with an agent option.

| Agent | macOS/Linux | Windows PowerShell |
| --- | --- | --- |
| Codex | `curl -fsSL https://raw.githubusercontent.com/duperin/rough2ready/main/install.sh \| bash` | `irm https://raw.githubusercontent.com/duperin/rough2ready/main/install.ps1 \| iex` |
| Claude Code | `curl -fsSL https://raw.githubusercontent.com/duperin/rough2ready/main/install.sh \| bash -s -- --agent claude-code` | `iex "& { $(irm https://raw.githubusercontent.com/duperin/rough2ready/main/install.ps1) } -Agent claude-code"` |
| OpenCode | `curl -fsSL https://raw.githubusercontent.com/duperin/rough2ready/main/install.sh \| bash -s -- --agent opencode` | `iex "& { $(irm https://raw.githubusercontent.com/duperin/rough2ready/main/install.ps1) } -Agent opencode"` |

Default install locations:

| Agent | Location |
| --- | --- |
| Codex | `~/.codex/skills/rough2ready` |
| Claude Code | `~/.claude/skills/rough2ready` |
| OpenCode | `~/.config/opencode/commands/rough2ready.md` |

From a local clone:

```bash
./install.sh --agent codex
```

```powershell
.\install.ps1 -Agent codex
```

Re-running the installer backs up an existing install before replacing it.

</details>

### Quick Test

After installing, run:

```text
$rough2ready compare Notion with Obsidian for personal knowledge management
```

The expected behavior is that the agent improves the request, researches current facts when needed, cites sources, and gives a practical recommendation without asking a long list of questions.

## Repository Contents

```text
rough2ready/
├── SKILL.md
├── agents/
│   └── openai.yaml
├── install.sh
├── install.ps1
├── README.md
├── LICENSE
└── .gitignore
```

## License

MIT
