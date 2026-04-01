# Admitted Filling

Primary reference for `Admitted`/`admit` elimination tactics used in prove/autoprove work phase.

## Core Workflow

1. **Understand context** — `rocq_goal(file, line, character)` for quick goal peek, or `rocq_start(file, theorem)` to open a full session
2. **Search library FIRST** — `rocq_query("Search ...")` before writing tactics
3. **Generate 2-3 candidates** — different approaches (Direct, Tactics, Automation)
4. **Test before applying** — `rocq_step_multi(tactics=[...])` to test all at once
5. **Apply shortest working solution** — `rocq_check(body)` to commit the winner
6. **Validate** — `rocq_compile(source)` to verify full file compiles

## MCP-First Requirement

Always use MCP tools when available:
- `rocq_goal(file, line, character)` — quick goal at position (no session needed)
- `rocq_start(file, theorem)` — open proof session, see goals
- `rocq_check(body)` — execute tactics, advance state
- `rocq_step_multi(tactics)` — test multiple tactics (non-destructive, max 20)
- `rocq_compile(source)` — full file compilation
- `rocq_query("Search pattern.")` — find relevant lemmas
- `rocq_verify(proof, name, statement)` — sandboxed correctness check

## Search Strategies

### By Pattern
```
rocq_query("Search (_ + _ = _ + _).")          # Arithmetic patterns
rocq_query("Search (_ -> _ -> _).")            # Implication chains
rocq_query("SearchPattern (_ * _ = _ * _).")   # Pattern-based
rocq_query("Search \"add\" \"comm\".")          # By name fragments
```

### By Type
```
rocq_query("Check Nat.add_comm.")              # Check specific lemma
rocq_query("About Nat.add_comm.")              # Full info
rocq_query("Print Nat.add_comm.")              # See definition
```

### Using Notation Disambiguation
```
rocq_notations("forall n, n + 0 = n")          # See what notations resolve to
rocq_notations("forall x, x * 1 = x", preamble="Require Import QArith.")
```

## Common Admitted Types

### Type 1: Forgot to Search
**Symptom:** Simple fact that's already in the library.
**Fix:** `rocq_query("Search ...")` finds it immediately.

### Type 2: Missing Import
**Symptom:** Tactic or lemma not found.
**Fix:** Add `Require Import Module.` and retry.

### Type 3: Wrong Proof Strategy
**Symptom:** Repeated failures with same approach.
**Fix:** Try different approach. Common pivots:
- Direct proof → proof by contradiction (`classical_proof`)
- Induction on wrong variable → change induction target
- Missing intermediate lemma → extract helper

### Type 4: Structural Issue
**Symptom:** Goal shape doesn't match any known pattern.
**Fix:** `unfold`, `simpl`, `rewrite` to reshape the goal first.

### Type 5: Complex Multi-Step
**Symptom:** Multiple sub-goals, dependencies between steps.
**Fix:** Use `assert` for intermediate results, prove sub-goals individually.

## Proof Candidate Generation

Always generate 2-3 approaches:

1. **Direct:** Exact library lemma application
2. **Tactics:** Step-by-step tactic proof
3. **Automation:** Let `auto`/`eauto`/`lia`/`omega` solve it

## Tactic Suggestions by Goal Pattern

| Goal Pattern | Tactics to Try |
|-------------|----------------|
| `X = X` | `reflexivity` |
| `X = Y` (arithmetic) | `ring`, `lia`, `omega` |
| `X = Y` (rewriting) | `rewrite H`, `simpl`, `unfold` |
| `P /\ Q` | `split` |
| `P \/ Q` | `left` or `right` |
| `exists x, P x` | `exists witness` |
| `forall x, P x` | `intros x` |
| `P -> Q` | `intros H` |
| `~P` | `intros H` (then derive contradiction) |
| `True` | `exact I` |
| `nat` inequality | `lia`, `omega` |
| `R` inequality | `lra`, `nra` |

## Testing Candidates

### With MCP (preferred)
```
rocq_step_multi(tactics=["reflexivity.", "auto.", "lia.", "ring."])
```
Returns results for all tactics. Commit the winner:
```
rocq_check(body="ring.")
```

### Without MCP (fallback)
Edit the file, replacing `Admitted.` with the candidate tactic, then compile:
```bash
coqc -Q . ProjectName File.v
```
Revert on failure.

## When to Escalate

Give up on fast-pass and escalate to deep mode when:
- 3+ failed attempts with different strategies
- Search returns empty results
- Goal requires multi-file refactoring
- Goal requires helper lemma extraction

**Escalation options:**
1. Deep mode (admitted-filler-deep agent)
2. Proof repair (proof-repair agent)
3. Mark stuck and move to next Admitted

## Output Size Limits

- Max 3 candidates per Admitted
- Each diff ≤80 lines
- No statement changes
- No cross-file refactoring (fast path only)
