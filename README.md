# Rocq Skills

Rocq (formerly Coq) workflow pack for AI coding agents. Gives your agent a structured
prove/review/golf loop, library search, axiom checking, and safety guardrails.
The workflows are host-agnostic — Claude Code, Codex, Gemini CLI, Cursor, and
others all use the same core skill; only the invocation surface differs.

## Workflows

| Workflow | Description |
|---|---|
| draft | Draft Rocq declaration skeletons from informal claims |
| formalize | Interactive formalization — drafting plus guided proving |
| autoformalize | Autonomous end-to-end formalization from informal sources |
| prove | Guided cycle-by-cycle theorem proving |
| autoprove | Autonomous multi-cycle proving with stop rules |
| checkpoint | Save point (per-file + project build, axiom check, commit) |
| review | Read-only quality review |
| refactor | Leverage stdlib/MathComp, extract helpers, simplify proof strategies |
| golf | Improve proofs for directness, clarity, performance, and brevity |
| learn | Interactive teaching and library exploration |
| doctor | Diagnostics and migration help |

**Claude Code:** invoke as `/rocq:<name>`. **Other hosts:** follow the corresponding workflow in [SKILL.md](plugins/rocq/skills/rocq/SKILL.md).

Typical session: `draft` (or `formalize` / `autoformalize`) → `prove` (or `autoprove`) → `review` → `refactor` → `golf` → `checkpoint` → `git push`.

## How It Works

- **`draft`** — Skeleton-only drafting from informal claims. Use when you want Rocq declarations without a full prove run.
- **`formalize`** — Interactive synthesis. Drafts a skeleton, then runs guided prove cycles with user interaction.
- **`autoformalize`** — Autonomous synthesis. Extracts claims from a source, drafts skeletons, and proves them unattended.
- **`prove`** — Guided proof engine for existing declarations. Asks preferences at startup, prompts before each commit, pauses between cycles.
- **`autoprove`** — Autonomous proof engine for existing declarations. Auto-commits, loops until a stop condition fires (max cycles, max time, or stuck).
- The proof engines share one cycle engine: **Plan → Work → Checkpoint → Review → Replan → Continue/Stop**. Each `Admitted` gets a library search, tactic attempts, and validation. `--commit` controls per-fill commit behavior. When stuck, both force a review + replan.
- `formalize` and `autoformalize` wrap drafting around that same engine. Statement and header changes belong there — `prove` and `autoprove` keep declaration headers immutable.
- Editing `.v` files without a command activates the skill for one bounded pass — fix the immediate issue, then suggest the right next command: `draft` / `formalize` for statement work, `prove` / `autoprove` for proof work.

See [plugin README](plugins/rocq/README.md) for the full command guide.

## Installation

### Claude Code (native plugin)

```bash
# TODO: Update once published to marketplace
/plugin install rocq
```

### Rocq MCP Server (Required for full functionality)

The skill works standalone with `coqc`, but is dramatically better with [rocq-mcp](https://github.com/rocq-mcp/rocq-mcp) — interactive proof sessions, parallel tactic testing, and **sub-second feedback** instead of full recompilation cycles.

**What you get:**
- `rocq_start` — open interactive proof session
- `rocq_check` — execute tactics, see goals
- `rocq_step_multi` — test multiple tactics in parallel
- `rocq_compile` — full file compilation
- `rocq_query` — Search, Check, Print, About
- `rocq_toc` — file structure outline
- `rocq_notations` — notation disambiguation
- `rocq_verify` — sandboxed proof verification

**Claude Code** (run from your Rocq project root):
```bash
# User-scoped — available in all your projects
claude mcp add --transport stdio --scope user rocq-mcp -- uvx rocq-mcp

# Or project-scoped — shared via .mcp.json
claude mcp add --transport stdio --scope project rocq-mcp -- uvx rocq-mcp
```

## Compatibility

| Host | Status | Workflow |
|---|---|---|
| Claude Code | Full native | SKILL.md + scripts + `/rocq:*` commands, hooks, guardrails, subagents |
| Codex / Gemini / OpenCode | Documented* | SKILL.md + scripts |
| Cursor / Windsurf | Documented* | Project rules → SKILL.md + scripts |

*Documented setup patterns, not CI-verified.

## Documentation

- [SKILL.md](plugins/rocq/skills/rocq/SKILL.md) - Core skill reference
- [Commands](plugins/rocq/commands/) - Command documentation
- [References](plugins/rocq/skills/rocq/references/) - cycle engine, proof golfing, tactic patterns, and more

## License & Citation

MIT licensed. See [LICENSE](LICENSE) for more information.
