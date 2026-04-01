# Cycle Engine

Shared logic for `/rocq:prove`, `/rocq:autoprove`, `/rocq:formalize`, and `/rocq:autoformalize`.

## Six-Phase Cycle

```
Plan → Work → Checkpoint → Review → Replan → Continue/Stop
```

### Phase 1: Plan

Discover Admitted via MCP, set filling order.

**MCP-First Protocol:**
1. `rocq_toc(file)` to get file structure
2. `rocq_start(file, theorem)` at each Admitted to see goals
3. Up to 3 `rocq_query("Search ...")` calls (~30s total)
4. Record top candidates per Admitted

**Script fallback** (only when MCP is unavailable or exhausted):
- `$ROCQ_SCRIPTS/admitted_analyzer.py` for discovery
- `$ROCQ_SCRIPTS/smart_search.sh` for search

### Phase 2: Work (Per Admitted)

1. **Open session:** `rocq_start(file, theorem)` → see initial goals
2. **Search:** `rocq_query("Search pattern.")` for relevant lemmas
3. **Generate candidates:** 2-3 tactic approaches
4. **Test:** `rocq_step_multi(tactics=[candidate1, candidate2, ...])` — tests all without advancing state
5. **Commit winner:** `rocq_check(body="winning_tactic.")` — advances state
6. **Continue or close:** If `proof_finished=True`, assemble proof from `proof_tactics`; otherwise repeat from step 2
7. **Validate:** `rocq_compile(source)` — verify full file compiles
8. **Verify:** `rocq_verify(proof, problem_name, problem_statement)` for sandboxed correctness check
9. **Stage & commit** (if `--commit` allows)

**Tactic cascade** (if no candidate passed in step 4):
```
reflexivity → auto → trivial → ring → lia → lra → nia → nra →
tauto → firstorder → intuition → eauto → decide
```

Note: `lia`/`lra`/`ring` require imports. Always check file preamble.

### Phase 3: Checkpoint

Stage only files from accepted fills. Never `git add -A`. Skip if nothing changed.

**Commit message format:** `checkpoint(rocq): fill N Admitted in File.v`

### Phase 4: Review

Run `/rocq:review` at configured `--review-every` intervals. Review is always read-only.

- `batch` mode: full report
- `stuck` mode: top 3 blockers only

### Phase 5: Replan

Enter planner mode. Produce action plan for next cycle based on review findings.

### Phase 6: Continue/Stop

- **prove:** Ask user before each cycle
- **autoprove:** Auto-continue unless stop condition met

## Build Target Policy

Three-tier verification ladder:

| Tier | Tool | Speed | When |
|------|------|-------|------|
| Per-tactic | `rocq_check(body)` | Sub-second | After each tactic |
| File compile | `rocq_compile(source)` | Seconds | File-level gate |
| Project gate | `make -f CoqMakefile` | Minutes | Checkpoint/final verification |

## Stuck Definition

An Admitted is **stuck** when any of:
- Same failure pattern 2-3 times
- Same build error 2 times
- No progress for 10+ minutes
- Empty `rocq_query("Search ...")` results 2 times

**Blocker signature:** Hash of (error message template, goal shape, file:line).

**When stuck:**
1. Mandatory review (`--mode=stuck`)
2. Planner mode produces revised action plan
3. **prove:** Present plan for user approval ([yes / no / skip])
4. **autoprove:** Auto-execute revised plan

**Stuck handoff evidence** (required in review/replan):
- Search queries attempted
- Top candidates tried
- `rocq_step_multi` outcomes
- Error messages encountered

## Deep Mode

Bounded subroutine for stubborn Admitted. Invoked by the cycle engine when configured.

### Safety Definitions

- **Header fence:** Declaration headers (`Theorem`/`Lemma`/`Definition` through `Proof.`) are immutable during deep mode
- **Scope fence:** `--deep-scope=target` (single theorem) or `cross-file`
- **Budget fence:** `--deep-sorry-budget`, `--deep-time-budget`, `--deep-max-files`, `--deep-max-lines`

### Snapshot/Rollback

1. Before deep: create path-scoped snapshot (`git stash push -m "pre-deep: file:line"`)
2. During deep: enforce budgets, check header fence at each checkpoint
3. After deep: if regression detected → rollback, mark stuck with reason

**Regression = any of:** new Admitted introduced, build fails, header modified, budget exceeded.

### prove vs autoprove Deep Defaults

| Setting | prove | autoprove |
|---------|-------|-----------|
| `--deep` | `never` | `stuck` |
| `--deep-sorry-budget` | 1 | 2 |
| `--deep-time-budget` | 10m | 20m |
| `--deep-max-files` | 1 | 2 |
| `--deep-max-lines` | 120 | 200 |

## Repair Mode

Compiler-guided repair is **escalation-only** — not the first response to build errors.

**Trigger conditions:**
- Same blocker 2× in current cycle
- Same build error 2×
- 3+ errors in scope

**Budget:** max 2 per error signature, max 6-8 total per cycle.

**Error quick-reference:**

| Error Pattern | Quick Fix |
|--------------|-----------|
| `The term "X" has type "A" while expected "B"` | `change`, type annotation, `rewrite` |
| `Unable to unify "A" with "B"` | `unfold`, `simpl`, `rewrite` |
| `No matching clauses for match` | Add missing case, `destruct` |
| `The reference "X" was not found` | `Require Import`, check module path |
| `Universe inconsistency` | Universe polymorphism, `Set Universe Polymorphism` |
| `Cannot guess decreasing argument` | `{struct arg}`, `Function`, `Program Fixpoint` |

## Safety

**Blocked git commands** (via guardrails.sh):
- `git push` → use `/rocq:checkpoint`, then push manually
- `git commit --amend` → new commits for safe rollback
- `gh pr create` → review first
- Destructive: `checkout --`, `restore`, `reset --hard`, `clean -f`

## Synthesis Outer Loop

Optional wrapper for `/rocq:formalize` and `/rocq:autoformalize`.

1. **Claim acquisition:** Extract from `--source`, filter by `--claim-select`
2. **Draft phase:** Invoke `/rocq:draft` logic per claim
3. **Inner cycle:** Run 6-phase prove cycle
4. **Review router:** On stuck, check `next_action`:
   - `continue` → next cycle
   - `redraft` → return to draft phase (check provenance + statement-policy)
   - `deep` → invoke deep mode
   - `stop` → advance to next claim or stop
5. **File assembly:** Combine drafted declarations into output file

## Pre-flight Context for Subagent Dispatch

When dispatching subagents (proof-repair, admitted-filler-deep, proof-golfer, axiom-eliminator), include:

```markdown
## Pre-flight Context

### Goal State
[Output from rocq_start / rocq_check]

### Compilation Status
[Output from rocq_compile]

### Search Results
[Top results from rocq_query("Search ...")]

### Error Context (if applicable)
[Structured error from rocq_compile]
```
