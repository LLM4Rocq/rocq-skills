# Tactic Patterns

Quick reference for choosing tactics based on goal structure.

## Goal Structure Patterns

### Equality
| Goal | Tactic |
|------|--------|
| `x = x` | `reflexivity` |
| `f x = f y` | `f_equal` / `congr` |
| `x = y` (nat arithmetic) | `lia` / `ring` |
| `x = y` (real arithmetic) | `lra` / `ring` / `field` |
| `x = y` (rewrite needed) | `rewrite H` |
| `x = y` (unfold needed) | `unfold f; simpl` |

### Universal Quantifier
| Goal | Tactic |
|------|--------|
| `forall x, P x` | `intros x` |
| `forall x y, P x y` | `intros x y` |

### Existential Quantifier
| Goal | Tactic |
|------|--------|
| `exists x, P x` | `exists witness` |
| `{ x : A | P x }` | `exist witness` |

### Implication
| Goal | Tactic |
|------|--------|
| `P -> Q` | `intros H` |
| `P -> Q` (with exact proof) | `exact (fun H => ...)` |

### Conjunction
| Goal | Tactic |
|------|--------|
| `P /\ Q` | `split` |
| `P /\ Q /\ R` | `repeat split` or `split; [|split]` |

### Disjunction
| Goal | Tactic |
|------|--------|
| `P \/ Q` (P provable) | `left` |
| `P \/ Q` (Q provable) | `right` |

### Negation
| Goal | Tactic |
|------|--------|
| `~P` | `intros H` (then derive `False`) |
| `P` (from `~~P`) | classical logic: `apply NNPP` |

### Inequality
| Goal | Tactic |
|------|--------|
| `n < m` (nat) | `lia` / `omega` |
| `n <= m` (nat) | `lia` / `omega` |
| `x < y` (R) | `lra` / `nra` |

## Domain-Specific Patterns

### Natural Numbers
```coq
induction n as [|n' IH].
- (* Base case: n = 0 *) simpl. reflexivity.
- (* Inductive case: n = S n' *) simpl. rewrite IH. reflexivity.
```

### Lists
```coq
induction l as [|x l' IH].
- (* Base case: l = nil *) simpl. reflexivity.
- (* Inductive case: l = x :: l' *) simpl. rewrite IH. reflexivity.
```

### Booleans
```coq
destruct b.
- (* b = true *) ...
- (* b = false *) ...
```

### Option Types
```coq
destruct o as [x|].
- (* Some x *) ...
- (* None *) ...
```

### Real Analysis (with Reals library)
```coq
Require Import Reals.
Open Scope R_scope.
(* Use lra for linear, nra for nonlinear *)
```

### Algebra (with MathComp)
```coq
From mathcomp Require Import all_ssreflect.
(* Use ssreflect tactics: move=>, apply/, rewrite *)
```

## General Tactics (Always Worth Trying)

**Automation:** `auto`, `eauto`, `trivial`, `tauto`, `intuition`, `firstorder`

**Structuring:** `intros`, `destruct`, `induction`, `split`, `left`, `right`, `exists`

**Hypothesis work:** `apply H`, `exact H`, `rewrite H`, `specialize`, `generalize`

**Cleanup:** `simpl`, `unfold`, `clear`, `rename`

## Workflow Tips

1. Try automation first (`auto`, `lia`, `ring`)
2. If automation fails, introduce/destruct to simplify
3. Break down with `assert` for intermediate results
4. Search the library for existing lemmas
5. Check types with `Check` and `About`
