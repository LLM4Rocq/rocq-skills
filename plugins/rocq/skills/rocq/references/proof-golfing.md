# Proof Golfing

Proof simplification and optimization guidance for Rocq.

## Core Principle

First make it compile, then make it clean.

**When to use:** After `rocq_compile` or `coqc` succeeds on stable files.
**Expected:** 30-40% reduction typical.
**When NOT to use:** Active development, already-optimized code, missing verification.

## Scoring Order

Among correct candidates, prefer:
1. **Directness** — more direct proof shape wins
2. **Inference burden** — lower tactic complexity wins
3. **Performance** — more deterministic/faster wins
4. **Length** — shorter wins (tiebreaker)

**Tactic complexity ladder:**
`reflexivity`/`exact` < `apply`/`rewrite` < `simpl`/`auto` < `eauto`/`intuition` < broad `lia`/`omega`/`ring`/`decide`

## Quick Reference: Patterns

### Tier 1: Performance (Always Apply)

| Before | After | Savings |
|--------|-------|---------|
| `simpl. auto.` | `auto.` | 1 line (when auto subsumes simpl) |
| `intros x y. exact (f x y).` | `exact f.` | N lines (eta reduction) |
| `intros. reflexivity.` | `reflexivity.` | 1 line (when no real intros needed) |

### Tier 2: Directness (Always Apply)

| Before | After | Savings |
|--------|-------|---------|
| `apply H. exact H'.` | `exact (H H').` | 1 line |
| `split. exact H1. exact H2.` | `exact (conj H1 H2).` | 2 lines |
| `left. exact H.` | `exact (or_introl H).` | 1 line |
| `intros H. exact H.` | `exact id.` | 1 line (identity) |

### Tier 3: Structural (Verify First)

| Before | After | Condition |
|--------|-------|-----------|
| `assert (H : P). { ... } exact (f H).` | Inline if used once | Check usage count |
| `rewrite H1. rewrite H2.` | `rewrite H1, H2.` | Always safe |
| `destruct x; auto.` | `auto.` | If auto handles all cases |

### Tier 4: Conditional (Net Score Improvement Required)

| Before | After | Condition |
|--------|-------|-----------|
| `rewrite H. exact H'.` | `exact (eq_ind _ _ H' _ H).` | Only if clearer |
| Multiple `assert` blocks | Single `pose proof` chain | If reduces complexity |

## Safety Warnings

**93% false positive problem:** Most inlining opportunities are false positives. Always check:
1. Usage count of the binding
2. Whether inlining changes semantics (`Qed` opacity matters)
3. Whether the result is still readable

**Saturation indicators:**
- Success rate < 20% → stop
- Last 3 attempts failed → stop
- Only 1-line savings remaining → stop unless zero-risk

## Systematic Workflow

1. **Phase 0: Audit** — `rocq_compile` to confirm code compiles
2. **Phase 1: Discovery** — Run `find_golfable.py`, identify patterns
3. **Phase 2: Verification** — Check safety (usage counts, opacity)
4. **Phase 3: Apply** — Make changes, `rocq_compile` after each
5. **Phase 4: Saturation** — Stop when success rate drops

## Anti-Patterns

**Never:**
- Inline bindings used 3+ times
- Remove meaningful intermediate names
- Change `Qed` to `Defined` or vice versa (changes opacity)
- Replace `exact` with heavier automation for 1-line savings
- Golf proofs that aren't compiling yet
