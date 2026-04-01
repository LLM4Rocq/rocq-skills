# Coq Standard Library Guide

Navigation guide for the Coq standard library and common packages.

## Library Structure

```
Coq.Init          — Core types, logic, nat basics
Coq.Logic         — Classical logic, extensionality, decidability
Coq.Arith         — Natural number arithmetic
Coq.ZArith        — Integer arithmetic
Coq.QArith        — Rational arithmetic
Coq.Reals         — Real number analysis
Coq.Lists         — List operations
Coq.Vectors       — Vectors (length-indexed lists)
Coq.Strings       — String operations
Coq.Bool          — Boolean operations
Coq.Sets          — Set theory (Ensembles)
Coq.Relations     — Relations
Coq.Sorting       — Sorting algorithms
Coq.Structures    — Ordered types
Coq.Numbers       — Unified number library
Coq.Program       — Program mode support
Coq.Classes       — Type classes
Coq.Wellfounded   — Well-founded recursion
```

## Searching

### Via MCP (preferred)
```
rocq_query("Search (nat -> nat -> nat).")       # By type pattern
rocq_query("Search \"add\" \"comm\".")           # By name
rocq_query("SearchPattern (_ + _ = _ + _).")    # By pattern
rocq_query("About Nat.add_comm.")               # Full info
rocq_query("Print Nat.add.")                    # Definition
rocq_query("Locate \"+\".")                      # Find notation
```

### Useful Queries by Domain

**Arithmetic:**
```
Search (forall n, n + 0 = n).
Search Nat.add.
Search (_ * (_ + _)).    (* distributivity *)
```

**Lists:**
```
Search (length (app _ _)).
Search (In _ (map _ _)).
Search (rev (rev _)).
```

**Logic:**
```
Search (~ ~ _ -> _).          (* double negation *)
Search (_ \/ _ -> _).         (* disjunction elimination *)
Search (exists _, _ /\ _).    (* existential with conjunction *)
```

## Common Lemma Patterns

### Natural Numbers (Coq.Arith)
| Lemma | Statement |
|-------|-----------|
| `Nat.add_0_r` | `forall n, n + 0 = n` |
| `Nat.add_comm` | `forall n m, n + m = m + n` |
| `Nat.add_assoc` | `forall n m p, n + (m + p) = (n + m) + p` |
| `Nat.mul_comm` | `forall n m, n * m = m * n` |
| `Nat.mul_assoc` | `forall n m p, n * (m * p) = (n * m) * p` |
| `Nat.add_sub` | `forall n m, n + m - m = n` |

### Lists (Coq.Lists.List)
| Lemma | Statement |
|-------|-----------|
| `app_nil_r` | `forall l, l ++ [] = l` |
| `app_assoc` | `forall l1 l2 l3, l1 ++ (l2 ++ l3) = (l1 ++ l2) ++ l3` |
| `rev_involutive` | `forall l, rev (rev l) = l` |
| `map_length` | `forall f l, length (map f l) = length l` |
| `in_map_iff` | `forall f l y, In y (map f l) <-> exists x, f x = y /\ In x l` |

### Logic
| Lemma | Statement | Import |
|-------|-----------|--------|
| `classic` | `forall P, P \/ ~P` | `Classical_Prop` |
| `NNPP` | `forall P, ~~P -> P` | `Classical_Prop` |
| `not_and_or` | `forall A B, ~(A /\ B) -> ~A \/ ~B` | `Classical_Prop` |

## MathComp

### Installation
```bash
opam install coq-mathcomp-ssreflect
opam install coq-mathcomp-algebra
```

### Key Differences from Standard Library
- Uses `ssreflect` proof language (`move=>`, `apply/`, `rewrite`)
- Boolean reflection: proofs via `bool` computation
- `finType` for finite types
- `eqType` for types with decidable equality
- Different naming conventions

### Common Imports
```coq
From mathcomp Require Import ssreflect ssrbool ssrnat eqtype seq.
From mathcomp Require Import fintype bigop.
From mathcomp Require Import ssralg ssrnum.
```

## Other Common Packages

| Package | Purpose | Install |
|---------|---------|---------|
| `coq-mathcomp-ssreflect` | SSReflect proof language | `opam install` |
| `coq-mathcomp-algebra` | Algebraic structures | `opam install` |
| `coq-coquelicot` | Real analysis | `opam install` |
| `coq-flocq` | Floating-point arithmetic | `opam install` |
| `coq-ext-lib` | Extended library | `opam install` |
| `coq-equations` | Dependent pattern matching | `opam install` |
| `coq-elpi` | Coq-Elpi metaprogramming | `opam install` |
