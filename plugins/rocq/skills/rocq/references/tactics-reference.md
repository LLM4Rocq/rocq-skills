# Rocq Tactics Reference

Comprehensive tactics reference for Rocq theorem proving.

## Decision Tree

```
Goal is X = X?                    → reflexivity
Goal is arithmetic?               → ring / lia / lra / nia / nra
Goal is propositional logic?      → tauto / firstorder / intuition
Goal has hypothesis to apply?     → exact H / apply H
Goal needs case analysis?         → destruct / case_eq
Goal needs induction?             → induction n
Goal needs contradiction?         → exfalso / absurd
Goal needs classical logic?       → classic (Require Import Classical)
Don't know?                       → auto / eauto / trivial
```

## Quick Reference

| Want to... | Use |
|-----------|-----|
| Prove X = X | `reflexivity` |
| Prove with exact term | `exact term` |
| Apply a lemma | `apply lemma` |
| Introduce hypotheses | `intros` / `intros x H` |
| Split conjunction | `split` |
| Prove disjunction (left) | `left` |
| Prove disjunction (right) | `right` |
| Provide existential witness | `exists witness` |
| Case analysis | `destruct x` |
| Induction | `induction n` |
| Rewrite | `rewrite H` / `rewrite <- H` |
| Simplify | `simpl` / `cbn` / `unfold f` |
| Arithmetic (integers) | `lia` / `omega` |
| Arithmetic (reals) | `lra` / `nra` |
| Ring equations | `ring` |
| Field equations | `field` |
| Auto-prove | `auto` / `eauto` / `trivial` |
| Propositional logic | `tauto` / `intuition` |
| First-order logic | `firstorder` |
| Decide (finite) | `decide` / `reflexivity` |
| Contradiction | `contradiction` / `discriminate` |
| Inversion | `inversion H` |
| Injection | `injection H as H'` |
| Clear hypothesis | `clear H` |
| Rename hypothesis | `rename H into H'` |
| Assert intermediate | `assert (H : P)` |
| Pose proof | `pose proof (lemma args) as H` |
| Specialize | `specialize (H arg)` |
| Generalize | `generalize dependent x` |
| Replace term | `replace t1 with t2` |
| Compute | `compute` / `cbv` / `vm_compute` |
| Pattern match | `match goal with ... end` |

## Essential Tactics

### Simplification
- `simpl` — weak head normal form reduction
- `cbn` — call-by-name reduction (often better than simpl)
- `unfold f` — unfold a specific definition
- `compute` — full reduction
- `cbv` — call-by-value (full reduction)
- `vm_compute` — compiled computation (fast but opaque)

### Case Analysis
- `destruct x` — case split
- `destruct x as [H1 H2]` — with naming
- `destruct x eqn:E` — remember equation
- `case_eq x` — case with equation
- `inversion H` — inversion on inductive hypothesis

### Rewriting
- `rewrite H` — rewrite left-to-right
- `rewrite <- H` — rewrite right-to-left
- `rewrite H1, H2` — sequential rewrites
- `rewrite H in H'` — rewrite in hypothesis
- `rewrite H in *` — rewrite everywhere
- `simpl_rewrite` / `autorewrite with db` — automated rewriting

### Application
- `exact term` — provide exact proof term
- `apply lemma` — apply a lemma
- `eapply lemma` — apply with existential variables
- `refine term` — partial proof term with holes

### Construction
- `split` — prove conjunction
- `left` / `right` — prove disjunction
- `exists witness` — provide existential witness
- `constructor` — apply first matching constructor
- `econstructor` — constructor with existential variables

### Specialized Automation

| Tactic | Domain | Import |
|--------|--------|--------|
| `ring` | Ring equations | `Require Import Ring.` |
| `field` | Field equations | `Require Import Field.` |
| `lia` | Linear integer arithmetic | `Require Import Lia.` |
| `lra` | Linear real arithmetic | `Require Import Lra.` |
| `nia` | Nonlinear integer arithmetic | `Require Import Lia.` |
| `nra` | Nonlinear real arithmetic | `Require Import Lra.` |
| `psatz` | Polynomial arithmetic | `Require Import Psatz.` |
| `omega` | Integer arithmetic (deprecated) | `Require Import Omega.` |
| `tauto` | Propositional logic | (built-in) |
| `firstorder` | First-order logic | (built-in) |
| `intuition` | Intuitionistic logic | (built-in) |
| `decide` | Decidable goals | (built-in) |
| `congruence` | Congruence closure | (built-in) |

### Tactic Combinations

```coq
(* Simplify then auto *)
simpl; auto.

(* Introduce then destruct *)
intros H; destruct H as [H1 H2].

(* Induction with automation *)
induction n; simpl; auto.

(* Cases with lia *)
destruct (le_dec n m); lia.

(* Assert and use *)
assert (H : P) by auto.
exact (f H).
```

## Interactive Exploration

```coq
Check term.               (* See type *)
Print term.               (* See definition *)
About term.               (* Full info *)
Search pattern.            (* Find lemmas *)
SearchPattern pattern.     (* Pattern search *)
Locate "notation".         (* Find notation source *)
Print Assumptions thm.     (* Check axiom usage *)
```

## Advanced Patterns

### Calc-style (with `transitivity`)
```coq
transitivity middle_term.
- (* first part *) ...
- (* second part *) ...
```

### Conv-style (selective rewriting)
```coq
(* Rewrite only the left side of an equation *)
pattern (f x).
rewrite H.
```

### Focused Tactics
```coq
(* Apply tactic to specific goal *)
1: auto.    (* first goal *)
2: lia.     (* second goal *)
all: auto.  (* all goals *)
```

### Ltac
```coq
(* Simple tactic macro *)
Ltac my_tactic := intros; simpl; auto.

(* Pattern matching *)
Ltac solve_eq :=
  match goal with
  | |- ?x = ?x => reflexivity
  | |- _ => ring
  end.
```
