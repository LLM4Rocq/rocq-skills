# Rocq Plugin

> **Claude Code adapter.** This directory implements the native Claude Code plugin
> (hooks, guardrails, slash commands). The underlying skill content — SKILL.md,
> references, and scripts — is host-agnostic.
> See the [root README](../../README.md) for setup on other hosts.

Unified Rocq plugin for theorem proving, interactive learning, and formalization.

## Commands

| Command | Description |
|---------|-------------|
| `/rocq:draft` | Draft Rocq declaration skeletons from informal claims |
| `/rocq:formalize` | Interactive formalization — drafting plus guided proving |
| `/rocq:autoformalize` | Autonomous end-to-end formalization from informal sources |
| `/rocq:prove` | Guided cycle-by-cycle theorem proving with explicit checkpoints |
| `/rocq:autoprove` | Autonomous multi-cycle theorem proving with hard stop rules |
| `/rocq:checkpoint` | Save progress with a safe commit checkpoint |
| `/rocq:review` | Read-only code review of Rocq proofs |
| `/rocq:refactor` | Leverage stdlib/MathComp, extract helpers, simplify proof strategies |
| `/rocq:golf` | Improve Rocq proofs for directness, clarity, performance, and brevity |
| `/rocq:learn` | Interactive teaching and library exploration |
| `/rocq:doctor` | Diagnostics, cleanup, and migration help |

## Quick Start

```bash
/rocq:draft               # Draft Rocq skeletons from informal claims
/rocq:formalize           # Interactive synthesis (draft + prove)
/rocq:autoformalize       # Autonomous synthesis (source → proof)
/rocq:prove               # Guided Admitted filling (interactive)
/rocq:autoprove           # Autonomous Admitted filling (unattended)
/rocq:checkpoint          # Build-checked save point
/rocq:review              # Check quality (read-only)
/rocq:refactor            # Simplify proof strategies
/rocq:golf                # Optimize proofs
/rocq:learn               # Explore repo or library
/rocq:doctor              # Diagnostics and environment check
git push                  # Manual, after review
```

## How It Works

### Without a Command

When you edit `.v` files in a normal conversation, the plugin activates automatically — it helps with the immediate issue (a build error, a single Admitted) but does one bounded pass only. No looping, no deep escalation. At the end it suggests the right next command.

### The Cycle Engine (Shared)

Both `prove` and `autoprove` run the same 6-phase cycle:

```
Plan → Work → Checkpoint → Review → Replan → Continue/Stop
```

- **Plan** — Discover Admitted via MCP, set order
- **Work** — Per Admitted: search library, try tactics, validate, stage only touched files, commit
- **Checkpoint** — Commit cycle progress
- **Review** — Quality check at configured intervals
- **Replan** — Update plan based on review findings
- **Continue/Stop** — `prove` asks you; `autoprove` auto-continues

### MCP-First Approach

MCP tools are **normative** (required first-pass), not merely preferred:

```
rocq_start(file, theorem)                # Start proof session
rocq_check(body)                         # Execute tactics, see goals
rocq_step_multi(tactics=[...])           # Test multiple tactics
rocq_compile(source)                     # Full file compilation
rocq_query("Search ...")                 # Library search
rocq_verify(proof, ...)                  # Sandboxed verification
```

### Safety Guardrails

Guardrails activate only in Rocq project context (a directory containing `_CoqProject`, `CoqMakefile`, or `.v` files).

Blocked during Rocq project sessions:
- `git push` → Use `/rocq:checkpoint`, then push manually
- `git commit --amend` → Each change is a new commit for safe rollback
- `gh pr create` → Review first with `/rocq:review`
- Destructive git operations → Commit or checkpoint first

**Override environment variables:**

| Variable | Effect |
|----------|--------|
| `ROCQ_GUARDRAILS_DISABLE=1` | Skip all guardrails |
| `ROCQ_GUARDRAILS_FORCE=1` | Force guardrails outside Rocq projects |
| `ROCQ_GUARDRAILS_COLLAB_POLICY` | `ask` (default), `allow`, `block` |

## Environment Variables

Set by `bootstrap.sh` at session start:

| Variable | Purpose |
|----------|---------|
| `ROCQ_PLUGIN_ROOT` | Plugin installation path |
| `ROCQ_SCRIPTS` | Scripts directory |
| `ROCQ_REFS` | References directory |
| `ROCQ_PYTHON_BIN` | Python interpreter |

## File Structure

```
plugins/rocq/
├── .claude-plugin/plugin.json
├── commands/           # User-invocable commands
├── skills/rocq/
│   ├── SKILL.md        # Core skill reference
│   └── references/     # Reference docs
├── agents/             # 4 specialized agents
├── hooks/              # Bootstrap and guardrails
└── lib/scripts/        # Utility scripts
```

## See Also

- [SKILL.md](skills/rocq/SKILL.md) - Core skill reference
- [Commands](commands/) - Command documentation
- [References](skills/rocq/references/) - Cycle engine, tactics, proof golfing, and more
