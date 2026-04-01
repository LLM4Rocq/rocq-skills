# Subagent Workflows

Guide for leveraging subagents in Rocq development.

## Overview

Delegate mechanical tasks while keeping proof development focused. Subagents handle search, analysis, and verification in parallel.

## When to Dispatch Subagents

**Delegate:**
- Library search tasks
- Axiom audits
- Proof optimization (golfing)
- Admitted analysis

**Keep in main conversation:**
- Proof development (interactive)
- Design decisions
- Error debugging
- Strategic planning

## Agent Types

### Explore Agent (fast, lightweight)
Use for simple searches and script execution:
- Find lemmas via `rocq_query`
- Run `admitted_analyzer.py`
- Check axioms

### General-Purpose Agent (thorough)
Use for complex multi-step analysis:
- Deep library exploration
- Multi-file dependency analysis
- Complex refactoring planning

### Specialized Workflows
Integrated into prove/autoprove/golf commands:
- **proof-repair** — compiler-guided error fixing (sonnet)
- **admitted-filler-deep** — stubborn Admitted resolution (opus)
- **proof-golfer** — proof optimization (opus)
- **axiom-eliminator** — axiom removal (opus)

## Pre-collected Context

When dispatching subagents, include:
```markdown
## Pre-flight Context

### Goal State
[Output from rocq_start / rocq_check]

### Compilation Status
[Output from rocq_compile]

### Search Results
[Top results from rocq_query("Search ...")]
```

## MCP in Subagents

MCP tools should be available to subagents. If not:
1. Run MCP canary check (try `rocq_compile`)
2. If unavailable: fall back to scripts + `coqc`
3. Note limitation in output

## Best Practices

**Do:**
- Pre-collect MCP context before dispatching
- Include error context in dispatch prompts
- Set clear success criteria
- Check for MCP availability (canary)

**Don't:**
- Dispatch for single-file operations you can do directly
- Dispatch when you already know the answer
- Launch subagents without pre-flight context
- Retry MCP in subagent after canary fails

## V4 Commands

| Command | Subagent Use |
|---------|-------------|
| `/rocq:prove` | Dispatches proof-repair, admitted-filler-deep |
| `/rocq:autoprove` | Same as prove, fully autonomous |
| `/rocq:golf` | Dispatches proof-golfer |
| `/rocq:review` | May dispatch explore agents |
| `/rocq:checkpoint` | No subagents (direct work) |
