# Compilation Errors

Error-by-error guidance for Rocq compilation errors. Read this first for any build error.

## Quick Reference

| Error | Cause | Fix |
|-------|-------|-----|
| `The term "X" has type "A" while it is expected to have type "B"` | Type mismatch | Coercion, `change`, annotation |
| `Unable to unify "A" with "B"` | Unification failure | `unfold`, `simpl`, `rewrite` |
| `The reference "X" was not found` | Missing import or typo | `Require Import`, fix name |
| `No matching clauses for match` | Incomplete pattern match | Add missing cases |
| `Universe inconsistency` | Universe level conflict | Universe polymorphism |
| `Cannot guess decreasing argument` | Non-structural recursion | `{struct}`, `Function`, `Program Fixpoint` |
| `The command has indeed failed with message: ...` | Tactic failure | Try different tactic |
| `Syntax error` | Malformed input | Check syntax, missing `.` |

## Detailed Error Explanations

### The term "X" has type "A" while it is expected to have type "B"

**Most common Rocq error.** The type checker found a type mismatch.

**Patterns:**
```coq
(* Missing coercion *)
Lemma foo : forall n : nat, n + 0 = n.
(* If you have n : Z instead of nat, need conversion *)

(* Fix: explicit coercion *)
exact (Z.of_nat_id n).

(* Fix: change goal *)
change (n + 0 = n).

(* Fix: type annotation *)
exact (H : A).
```

### Unable to unify "A" with "B"

**Unification failure.** Rocq cannot see that two terms are equal.

**Fixes:**
- `unfold definition_name.` to expand definitions
- `simpl.` to reduce terms
- `rewrite H.` to rewrite one side
- `change A with B.` when they're definitionally equal

### The reference "X" was not found in the current environment

**Missing import or wrong name.**

**Common fixes:**
```coq
(* Missing import *)
Require Import Coq.Arith.Arith.
Require Import Coq.Lists.List.
Require Import Lia.
Require Import Ring.

(* For MathComp *)
From mathcomp Require Import all_ssreflect.

(* Wrong module path *)
Require Import Coq.Init.Nat.  (* not just Nat *)
```

**Common imports by tactic:**
| Tactic | Import |
|--------|--------|
| `lia` | `Require Import Lia.` |
| `lra` | `Require Import Lra.` |
| `ring` | `Require Import Ring.` |
| `omega` | `Require Import Omega.` (deprecated, use `lia`) |
| `field` | `Require Import Field.` |
| `nia` | `Require Import Lia.` |
| `nra` | `Require Import Lra.` |
| `psatz` | `Require Import Psatz.` |

### No matching clauses for match

**Incomplete pattern match.**

**Fix:** Add the missing case:
```coq
(* Before *)
match n with
| O => ...
end.

(* After — add successor case *)
match n with
| O => ...
| S n' => ...
end.
```

### Universe inconsistency

**Universe levels don't line up.**

**Fixes:**
- `Set Universe Polymorphism.` at the top of the file
- Use `Type@{u}` with explicit universe variables
- Avoid mixing `Prop` and `Type` carelessly

### Cannot guess decreasing argument of fix

**Non-structural recursion.** Rocq can't see the recursive argument is decreasing.

**Fixes:**
```coq
(* Explicit struct annotation *)
Fixpoint f (n : nat) {struct n} : nat := ...

(* Use Function for complex recursion *)
Function f (n : nat) {measure id n} : nat := ...

(* Use Program Fixpoint *)
Program Fixpoint f (n : nat) {measure n} : nat := ...
```

### Tactic failure: "X"

**A tactic didn't work on the current goal.**

**Common situations:**
- `auto` failed → try `eauto` with larger depth: `eauto 10`
- `ring` failed → check that the goal is in ring form; try `ring_simplify` first
- `lia` failed → check that all variables are integers; convert with `Z.of_nat`
- `simpl` did nothing → try `unfold`, `compute`, or `cbv`

### Error location misleading

Rocq error locations can point to the wrong place. Check 5-10 lines before the reported location.

**Common causes:**
- Missing `.` at end of previous sentence
- Unmatched `(` or `{`
- Section/Module not properly closed

## Type Class Debugging

```coq
(* Show what instances are being searched *)
Set Typeclasses Debug.

(* Show full search tree *)
Set Typeclasses Debug Verbosity 2.

(* Limit search depth *)
Set Typeclasses Depth 5.
```

## Common Patterns to Avoid

- **Fighting the type checker:** If Rocq doesn't accept your term, understand why before adding coercions everywhere
- **Over-using `admit`:** Don't postpone — each `admit` makes later proofs harder to debug
- **Ignoring warnings:** Warnings about implicit arguments, unused variables, or deprecated features often indicate real problems
- **Missing `Proof.` keyword:** Every theorem needs `Proof.` before tactics and `Qed.`/`Defined.`/`Admitted.` at the end

## Build Command Reference

```bash
# Single file
coqc -Q . ProjectName File.v

# Using _CoqProject
coq_makefile -f _CoqProject -o CoqMakefile
make -f CoqMakefile

# Via MCP
rocq_compile(source="full file content")
```
