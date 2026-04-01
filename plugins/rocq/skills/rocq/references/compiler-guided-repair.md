# Compiler-Guided Repair

Quick reference for compiler-guided proof repair. Escalation-only — not first-pass.

## Philosophy

Generate → Compile → Diagnose → Fix → Verify tight loop instead of blind best-of-N sampling.

## Core Workflow

1. Compile (`rocq_compile`) / extract error
2. Try automation cascade via `rocq_step_multi`
3. Agent repair (Stage 1 fast: 6 attempts, Stage 2 strong: 18 attempts)
4. Apply patch / recompile

## Repair Strategies by Error Type

| Error | Strategy |
|-------|----------|
| `type_mismatch` | `change`, type annotation, `refine`, `rewrite` |
| `unable_to_unify` | `unfold`, `simpl`, `rewrite`, `change A with B` |
| `unknown_ident` | `Require Import`, check module path, `Search` |
| `synth_instance` | `assert` instance, `Existing Instance`, hint DB |
| `admitted_present` | Fill proof via admitted-filling workflow |
| `timeout` | `simpl` first, `clear` unused hypotheses, explicit instances |
| `universe_inconsistency` | Universe polymorphism, explicit levels |

## Error Pattern Recognition

| Pattern | Diagnosis | Fix |
|---------|-----------|-----|
| "has type X while expected Y" | Type mismatch | Check coercions |
| "Unable to unify" | Definitional inequality | `unfold`/`simpl` then retry |
| "was not found" | Missing import | `Require Import` |
| "No matching clauses" | Incomplete match | Add missing case |
| "Cannot guess decreasing" | Non-structural recursion | `{struct}`, `Function` |

## Best Practices

1. **Build after every fix** (most important rule)
2. **Search library first** — `rocq_query("Search ...")` before writing custom proofs
3. **Use `rocq_step_multi`** to test multiple approaches at once
4. **Minimal diffs** — change 1-5 lines, not entire proofs
5. **Trust the loop** — compile → diagnose → fix → repeat
6. **Use `rocq_check(from_state=...)` for recovery** — backtrack to last good state on error

## Tools

```
rocq_start(file, theorem)         # Start session
rocq_check(body, from_state=N)    # Execute with optional backtrack
rocq_step_multi(tactics=[...])    # Test multiple approaches
rocq_compile(source)              # Full file check
rocq_query("Search ...")          # Library search
rocq_verify(proof, ...)           # Final correctness check
```
