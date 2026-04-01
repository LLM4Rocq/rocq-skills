# Proof Golfing Patterns

Detailed pattern explanations for Rocq proof optimization.

## Tactic Complexity Ladder

```
reflexivity/exact < apply/rewrite < simpl/auto < eauto/intuition < broad lia/omega/ring/decide
```

## High-Priority Patterns

### Eta Reduction
```coq
(* Before *)
intros x. exact (f x).

(* After *)
exact f.
```

### Apply + Exact → Exact
```coq
(* Before *)
apply H. exact H'.

(* After *)
exact (H H').
```

### Split + Exact → Exact Pair
```coq
(* Before *)
split.
- exact H1.
- exact H2.

(* After *)
exact (conj H1 H2).
```

### Redundant Intros
```coq
(* Before *)
intros. reflexivity.

(* After *)
reflexivity.
(* reflexivity handles intros automatically *)
```

### Sequential Rewrites
```coq
(* Before *)
rewrite H1. rewrite H2. rewrite H3.

(* After *)
rewrite H1, H2, H3.
```

### Destruct with Auto
```coq
(* Before *)
destruct x.
- auto.
- auto.

(* After *)
destruct x; auto.
```

### Single-Use Assert Inline
```coq
(* Before — H used exactly once *)
assert (H : P x) by auto.
exact (f H).

(* After *)
exact (f ltac:(auto)).
(* Or *)
apply f. auto.
```
**VERIFY:** Only if `H` is used exactly once.

### Remove Redundant Simpl
```coq
(* Before *)
simpl. auto.

(* After — when auto handles simplification *)
auto.
```

### Constructor Shorthand
```coq
(* Before *)
split.
- left. exact H.
- right. exact H'.

(* After *)
exact (conj (or_introl H) (or_intror H')).
```

## Medium-Priority Patterns

### Unfold + Simpl → Simpl
```coq
(* Before *)
unfold f. simpl. auto.

(* After — when simpl unfolds f automatically *)
simpl. auto.
```

### Pose Proof Inline
```coq
(* Before *)
pose proof (H := some_lemma x y).
exact H.

(* After *)
exact (some_lemma x y).
```

### Match Goal Simplification
```coq
(* Before *)
match goal with
| |- ?x = ?x => reflexivity
end.

(* After *)
reflexivity.
```

### Omega → Lia
```coq
(* Before (deprecated) *)
omega.

(* After *)
lia.
```

## Documentation Quality Patterns

### Remove Duplicate Comments
If a comment restates what the tactic does, remove it:
```coq
(* Before *)
intros n. (* introduce n *)
induction n. (* do induction on n *)

(* After *)
intros n.
induction n.
```
