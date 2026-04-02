---
name: rocq
description: "Use when editing .v files, debugging Rocq/Coq builds (type mismatch, Admitted, failed to unify, axiom warnings, coqc errors), searching for lemmas in stdlib or MathComp, formalizing mathematics in Rocq, or learning Rocq concepts. Also trigger when the user asks for help with Rocq, Coq, MathComp, or _CoqProject. Do NOT trigger for Lean 4, Agda, Isabelle, HOL4, Mizar, Idris, Megalodon, or other non-Rocq theorem provers."
---

# Rocq Theorem Proving

Use this skill whenever you're editing Rocq proofs, debugging Rocq builds, formalizing mathematics in Rocq, or learning Rocq concepts. It prioritizes MCP-based interactive proving and library search, with scripted primitives for Admitted analysis, axiom checking, and error parsing.

## Core Principles

**Search before prove.** Many mathematical facts already exist in the Coq standard library, MathComp, or other installed packages. Search exhaustively before writing tactics.

**Build incrementally.** Rocq's type checker is your test suite — if it compiles with no `Admitted` and standard axioms only, the proof is sound.

**Respect scope.** Follow the user's preference: fill one `Admitted`, its transitive dependencies, all `Admitted` in a file, or everything. Ask if unclear.

**Use 80-character line width for Rocq files.** Follow the standard Coq/Rocq convention of 80-character lines.

**Never change statements or add axioms without explicit permission.** Theorem/lemma statements, type signatures, and doc comments are off-limits unless the user requests changes. Custom axioms require explicit approval — if a proof seems to need one, stop and discuss. Exception: within synthesis wrappers (`/rocq:formalize`, `/rocq:autoformalize`), session-generated declarations may be redrafted under the outer-loop statement-safety rules; see cycle-engine.md.

## Commands

| Command | Purpose |
|---------|---------|
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

### Which Command?

| Situation | Command |
|-----------|---------|
| Draft a Rocq skeleton (skeleton by default) | `/rocq:draft` |
| Draft + prove interactively | `/rocq:formalize` |
| Filling Admitted (interactive) | `/rocq:prove` |
| Filling Admitted (unattended) | `/rocq:autoprove` |
| Save point (per-file + project build, axiom check, commit) | `/rocq:checkpoint` |
| Quality check (read-only) | `/rocq:review` |
| Simplify proof strategies (library leverage, helpers) | `/rocq:refactor` |
| Optimizing compiled proofs | `/rocq:golf` |
| New to this project / exploring | `/rocq:learn --mode=repo` |
| Navigating stdlib/MathComp for a topic | `/rocq:learn --mode=library` |
| Something not working | `/rocq:doctor` |
| Formalize + prove end-to-end (unattended) | `/rocq:autoformalize --source=... --claim-select=first --out=...` |

## Typical Workflow

```
┌─ Entry points (pick one) ──────────────────────────────────────────────────────────┐
│ /rocq:draft              Skeleton by default (--mode=attempt for shallow proof)    │
│ /rocq:formalize          Interactive: draft + guided proving                       │
│ /rocq:autoformalize      Autonomous: draft + autonomous proving                    │
└────────────────────────────────────────────────────────────────────────────────────┘
        ↓ (if Admitted remain)
/rocq:prove / autoprove    Proof engines (Admitted filling, no header edits)
        ↓
/rocq:refactor             Leverage stdlib/MathComp, extract helpers (optional)
        ↓
/rocq:golf                 Improve proofs (optional)
        ↓
/rocq:checkpoint           Save point (per-file + project build)
```

Use `/rocq:learn` at any point to explore repo structure or navigate libraries. Three entry points: `/rocq:draft` for skeletons, `/rocq:formalize` for interactive synthesis (draft + guided proving), `/rocq:autoformalize` for unattended source-to-proof.

**Notes:**
- `/rocq:prove` asks before each cycle; `/rocq:autoprove` loops autonomously with hard stop conditions
- Both trigger `/rocq:review` at configured intervals (`--review-every`)
- When reviews run (via `--review-every`), they act as gates: review → replan → continue. In prove, replan requires user approval; in autoprove, replan auto-continues
- Review supports `--mode=batch` (default) or `--mode=stuck` (triage); review is always read-only
- `/rocq:autoformalize` wraps draft+autoprove in a single command (source → claims → skeletons → proofs)
- Proof engines (`prove`/`autoprove`) never modify declaration headers (header fence)
- If you hit environment issues, run `/rocq:doctor` to diagnose

## MCP Tools (Preferred)

Interactive proof sessions and search via Rocq MCP:

```
rocq_start(file, theorem)                       # Start proof session, see goals
rocq_check(body)                                # Execute tactics, see updated goals
rocq_step_multi(tactics=[...])                  # Test multiple tactics in parallel (max 20)
rocq_compile(source)                            # Full file compilation check
rocq_query("Search nat.", preamble="...")        # Search, Check, Print, About
rocq_toc(file)                                  # File structure outline
rocq_notations(statement, preamble="...")        # Notation disambiguation
rocq_verify(proof, problem_name, problem_statement)  # Sandboxed proof verification
```

**Session-based workflow:** Unlike file-position-based LSP tools, Rocq MCP uses interactive sessions:
1. `rocq_start(file, theorem)` — open a proof session, see initial goals
2. `rocq_check(body)` — advance the proof, see updated goals; use `from_state` to backtrack
3. `rocq_step_multi(tactics)` — test multiple tactics against the current state (non-destructive)
4. `rocq_compile(source)` — verify full file compiles
5. `rocq_verify(...)` — sandboxed correctness verification

**Search workflow:** Use `rocq_query` for all search needs:
```
rocq_query("Search (_ + _ = _ + _).")           # Pattern search
rocq_query("Check Nat.add_comm.")               # Type check
rocq_query("Print Nat.add.")                    # See definition
rocq_query("About plus.")                       # Summary
rocq_query("SearchPattern (_ * _ = _ * _).")    # Pattern-based search
```

## Capabilities

| Capability | Required | Check | Fallback |
|-----------|----------|-------|----------|
| coqc | yes | `coqc --version` | none — run `/rocq:doctor` |
| Python 3 | yes (scripts) | `$ROCQ_PYTHON_BIN` set by bootstrap | none for script-dependent operations |
| `$ROCQ_SCRIPTS` | yes (set by bootstrap) | `echo "$ROCQ_SCRIPTS"` | run `/rocq:doctor` |
| Rocq MCP | no | try `rocq_query("Check nat.")` | scripts + `coqc` (file-level only) |
| Subagent dispatch | no | host-dependent | run work in main thread |
| Slash commands | no | host-dependent | follow skill instructions directly |

## Operating Profiles

The skill adapts to what's available. Determine your profile by checking capabilities above, then follow the corresponding guidance.

### full (all capabilities)

MCP + subagents + commands. Full workflow with interactive proof sessions, parallel tactic testing, and subagent dispatch. Subagents get pre-collected MCP context per [cycle-engine.md § Pre-flight Context](references/cycle-engine.md#pre-flight-context-for-subagent-dispatch).

### mcp_main_only (MCP available, no subagent dispatch)

MCP works in the main thread. Run all proof work directly — do not delegate to subagents. All cycle-engine phases execute in-thread.

### scripts_only (no MCP, no subagents)

Use `$ROCQ_SCRIPTS` for search and `coqc` for validation. **Key limitations in this mode:**
- **No interactive proof sessions** — `rocq_start`/`rocq_check` are unavailable; you can read the file and check compilation output, but cannot see proof state interactively
- **No tactic testing** — `rocq_step_multi` is unavailable; edits must be validated by compiling the file (`coqc`)
- **No real-time diagnostics** — `rocq_compile` is unavailable; use `coqc` for compilation errors, but feedback is file-level
- **Search is script-based** — `$ROCQ_SCRIPTS/smart_search.sh` replaces MCP search tools

This mode is functional for straightforward proofs but significantly slower and less precise than MCP-backed workflows.

### review_only (read-only, no edits)

Read proof state and assess quality. No edits, no commits, no subagent dispatch.

## File Handling Rules

**Scratch-work ladder** (in preference order):
1. Interactive session + MCP tools (`rocq_start`, `rocq_check`, `rocq_step_multi`)
2. `rocq_check` with preamble for isolated experiments
3. `/tmp` scratch files only when MCP is unavailable and the experiment must not touch the live file
4. Never create scratch files in the repo root

**File inspection:** Use Read and Grep to view source files. Never write Python scripts, temp files, or use `cat` pipelines just to read lines from a file you already have access to.

**Staging:** Stage only files touched during the current session. Never use `git add -A` or broad glob patterns. Print the exact staged set before committing.

See [admitted-filling.md](references/admitted-filling.md) for the full scratch-work preference order.

## Core Primitives

| Script | Purpose | Output |
|--------|---------|--------|
| `admitted_analyzer.py` | Find Admitted/admit with context | text (default), json, markdown, summary |
| `check_axioms.sh` | Check for non-standard axioms | text |
| `smart_search.sh` | Multi-source library search | text |
| `find_golfable.py` | Detect optimization patterns | JSON |
| `find_usages.sh` | Find declaration usages | text |

**Usage:** Invoked by commands automatically. See [references/](references/) for details.

**Invocation contract:** Never run bare script names. Always use:
- Python: `${ROCQ_PYTHON_BIN:-python3} "$ROCQ_SCRIPTS/script.py" ...`
- Shell: `bash "$ROCQ_SCRIPTS/script.sh" ...`
- Report-only calls: add `--report-only` to `admitted_analyzer.py`, `check_axioms.sh` — suppresses exit 1 on findings; real errors still exit 1. Do not use in gate commands like `/rocq:checkpoint`.
- Keep stderr visible for Rocq scripts (no `/dev/null` redirection), so real errors are not hidden.

If `$ROCQ_SCRIPTS` is unset or missing, run `/rocq:doctor` and stay MCP-only until resolved.

## Automation

`/rocq:prove` and `/rocq:autoprove` handle most tasks:
- **prove** — guided, asks before each cycle. Ideal for interactive sessions.
- **autoprove** — autonomous, loops with hard stop rules. Ideal for unattended runs.

Both share the same cycle engine (plan → work → checkpoint → review → replan → continue/stop) and follow the MCP-first protocol: MCP tools are normative for discovery and search; script fallback only when MCP is unavailable or exhausted. Compiler-guided repair is escalation-only — not the first response to build errors. For complex proofs, they may delegate to internal workflows for deep Admitted-filling (with snapshot, rollback, and scope budgets), proof repair, or axiom elimination. You don't invoke these directly.

## Skill-Only Behavior

When editing `.v` files without invoking a command, the skill runs **one bounded pass**:
- Start a proof session via `rocq_start` or read the goal from context
- Search with `rocq_query` (up to 2 queries)
- Try the [Automation Tactics](#automation-tactics) cascade via `rocq_step_multi`
- Validate with `rocq_compile` (no project-gate build in this mode)
- No looping, no deep escalation, no multi-cycle behavior, no commits
- End with suggestions:
  > Use `/rocq:prove` for guided cycle-by-cycle help.
  > Use `/rocq:autoprove` for autonomous cycles with stop safeguards.

## Quality Gate

A proof is complete when:
- `rocq_compile` passes (or `coqc` / project build passes)
- Zero `Admitted`/`admit` in agreed scope
- Only standard axioms (check via `rocq_query("Print Assumptions theorem_name.")`)
- `rocq_verify` confirms proof correctness (sandboxed verification)
- No statement changes without permission

Verification ladder: `rocq_check(body)` per-tactic → `rocq_compile(source)` file gate → project build (`make` or `coq_makefile`) project gate only. See [cycle-engine: Build Target Policy](references/cycle-engine.md#build-target-policy).

**Standard axioms** (not flagged): `Coq.Logic.Classical_Prop` axioms (`classic`, `NNPP`), `Coq.Logic.FunctionalExtensionality` (`functional_extensionality`), `Coq.Logic.PropExtensionality` (`propositional_extensionality`), `Coq.Logic.ProofIrrelevance` (`proof_irrelevance`). All others reported as non-standard.

## Common Fixes

See [compilation-errors](references/compilation-errors.md) for error-by-error guidance (type mismatch, unable to unify, universe inconsistency, timeout, etc.).

## Type Class Patterns

```coq
(* Local instance for this proof block *)
assert (H : SomeClass A) by exact _.
pose proof (some_instance : SomeClass A).

(* Global vs local instances *)
#[local] Instance my_instance : SomeClass A := { ... }.
#[export] Instance my_instance : SomeClass A := { ... }.

(* Existing instances *)
Existing Instance my_instance.
```

Order matters: provide outer structures before inner ones.

## Automation Tactics

Try in order (stop on first success) via `rocq_step_multi`:
`reflexivity` → `auto` → `trivial` → `ring` → `lia` → `lra` → `nia` → `nra` → `tauto` → `firstorder` → `intuition` → `eauto` → `decide`

Note: `lia`/`lra`/`ring` require appropriate imports (`Require Import Lia.`, `Require Import Lra.`, `Require Import Ring.`). `eauto` can be powerful with hint databases. See [tactics-reference](references/tactics-reference.md) for extended guidance.

## Troubleshooting

If MCP tools aren't responding, check your operating profile above. In `scripts_only` mode, `$ROCQ_SCRIPTS` provides search and `coqc` provides file-level compilation feedback, but interactive proof sessions, tactic testing, and interactive diagnostics are unavailable. If environment variables (`ROCQ_SCRIPTS`, `ROCQ_REFS`) are missing, run `/rocq:doctor` to diagnose.

**Script environment check:**
```bash
echo "$ROCQ_SCRIPTS"
ls -l "$ROCQ_SCRIPTS/admitted_analyzer.py"
# One-pass discovery for troubleshooting (human-readable default text):
${ROCQ_PYTHON_BIN:-python3} "$ROCQ_SCRIPTS/admitted_analyzer.py" . --report-only
# Structured output (optional): --format=json
# Counts only (optional): --format=summary
```

## References

**Cycle Engine:** [cycle-engine](references/cycle-engine.md) — shared prove/autoprove logic (stuck, deep mode, safety)

**MCP Tools:** [rocq-mcp-tools-api](references/rocq-mcp-tools-api.md) (full API reference)

**Search:** [coq-stdlib-guide](references/coq-stdlib-guide.md) (read when searching for existing lemmas), [rocq-phrasebook](references/rocq-phrasebook.md) (math→Rocq translations)

**Errors:** [compilation-errors](references/compilation-errors.md) (read first for any build error), [compiler-guided-repair](references/compiler-guided-repair.md) (escalation-only repair — not first-pass)

**Tactics:** [tactics-reference](references/tactics-reference.md) (tactic lookup), [tactic-patterns](references/tactic-patterns.md)

**Proof Development:** [proof-templates](references/proof-templates.md), [admitted-filling](references/admitted-filling.md)

**Optimization:** [proof-golfing](references/proof-golfing.md), [proof-golfing-patterns](references/proof-golfing-patterns.md)

**Domain:** [axiom-elimination](references/axiom-elimination.md)

**Workflows:** [subagent-workflows](references/subagent-workflows.md)
