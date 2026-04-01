# Rocq Phrasebook

Common math-to-Rocq translations.

## Types

| Math | Rocq |
|------|------|
| Natural numbers | `nat` |
| Integers | `Z` (from `ZArith`) |
| Rationals | `Q` (from `QArith`) |
| Reals | `R` (from `Reals`) |
| Booleans | `bool` |
| Propositions | `Prop` |
| Sets | `A -> Prop` (predicate) or `Ensemble A` |
| Lists | `list A` |
| Pairs | `A * B` |
| Option | `option A` |
| Functions | `A -> B` |

## Logical Connectives

| Math | Rocq |
|------|------|
| P and Q | `P /\ Q` |
| P or Q | `P \/ Q` |
| not P | `~ P` |
| P implies Q | `P -> Q` |
| P iff Q | `P <-> Q` |
| for all x, P(x) | `forall x, P x` |
| exists x, P(x) | `exists x, P x` |
| True | `True` |
| False | `False` |

## Arithmetic

| Math | Rocq (nat) | Rocq (Z) | Rocq (R) |
|------|-----------|----------|----------|
| a + b | `a + b` | `(a + b)%Z` | `(a + b)%R` |
| a - b | `a - b` | `(a - b)%Z` | `(a - b)%R` |
| a × b | `a * b` | `(a * b)%Z` | `(a * b)%R` |
| a / b | `a / b` | `(a / b)%Z` | `(a / b)%R` |
| a ≤ b | `a <= b` | `(a <= b)%Z` | `(a <= b)%R` |
| a < b | `a < b` | `(a < b)%Z` | `(a < b)%R` |
| a = b | `a = b` | `a = b` | `a = b` |
| |a| | `Nat.abs a` | `Z.abs a` | `Rabs a` |

## Common Patterns

### Function composition
```coq
Definition compose {A B C} (g : B -> C) (f : A -> B) : A -> C :=
  fun x => g (f x).
```

### Inductive definition
```coq
Inductive my_type : Type :=
  | constructor1 : my_type
  | constructor2 : nat -> my_type -> my_type.
```

### Record definition
```coq
Record point := mk_point {
  x_coord : R;
  y_coord : R
}.
```

### Type class
```coq
Class Monoid (A : Type) := {
  mempty : A;
  mappend : A -> A -> A;
  mappend_assoc : forall a b c, mappend a (mappend b c) = mappend (mappend a b) c;
  mempty_left : forall a, mappend mempty a = a;
  mempty_right : forall a, mappend a mempty = a
}.
```

## Common Library Modules

| Topic | Module | Import |
|-------|--------|--------|
| Natural numbers | `Coq.Arith.Arith` | `Require Import Arith.` |
| Integers | `Coq.ZArith.ZArith` | `Require Import ZArith.` |
| Rationals | `Coq.QArith.QArith` | `Require Import QArith.` |
| Reals | `Coq.Reals.Reals` | `Require Import Reals. Open Scope R_scope.` |
| Lists | `Coq.Lists.List` | `Require Import List. Import ListNotations.` |
| Strings | `Coq.Strings.String` | `Require Import String.` |
| Logic | `Coq.Logic.Classical` | `Require Import Classical.` |
| Sets | `Coq.Sets.Ensembles` | `Require Import Ensembles.` |
| Relations | `Coq.Relations.Relation_Definitions` | `Require Import Relations.` |
| Sorting | `Coq.Sorting.Sorted` | `Require Import Sorted.` |

## MathComp Equivalents

| Topic | MathComp Import |
|-------|----------------|
| Everything | `From mathcomp Require Import all_ssreflect.` |
| Algebra | `From mathcomp Require Import all_algebra.` |
| Finite types | `From mathcomp Require Import fintype.` |
| Permutations | `From mathcomp Require Import perm.` |
| Polynomials | `From mathcomp Require Import poly.` |
| Matrices | `From mathcomp Require Import matrix.` |

## Scope Management

```coq
(* Open a scope *)
Open Scope Z_scope.
Open Scope R_scope.
Open Scope list_scope.

(* Local scope annotation *)
(1 + 2)%Z      (* in Z *)
(1 + 2)%R      (* in R *)
(1 + 2)%nat    (* in nat *)
```
