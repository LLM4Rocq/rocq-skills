# Proof Templates

Structured proof skeletons for common patterns in Rocq.

## General Theorem Template

```coq
Theorem theorem_name : forall (x : A), P x.
Proof.
  intros x.
  (* Strategy: [describe approach] *)
  (* Step 1: [what to prove first] *)
  admit. (* TODO: fill *)
Admitted.
```

## Induction Template

```coq
Theorem induction_example : forall n : nat, P n.
Proof.
  induction n as [|n' IH].
  - (* Base case: n = 0 *)
    admit. (* TODO *)
  - (* Inductive case: n = S n' *)
    (* IH : P n' *)
    admit. (* TODO *)
Admitted.
```

## Case Analysis Template

```coq
Theorem case_example : forall (x : A), P x.
Proof.
  intros x.
  destruct x as [a | b].
  - (* Case 1: x = inl a *)
    admit. (* TODO *)
  - (* Case 2: x = inr b *)
    admit. (* TODO *)
Admitted.
```

## Calculation Chain Template

```coq
Theorem calc_example : forall n : nat, f n = g n.
Proof.
  intros n.
  (* Step-by-step rewriting *)
  unfold f.
  rewrite lemma1.
  rewrite lemma2.
  unfold g.
  reflexivity.
Qed.
```

## Existential Proof Template

```coq
Theorem exists_example : exists n : nat, P n.
Proof.
  exists 42. (* witness *)
  (* Now prove: P 42 *)
  admit. (* TODO *)
Admitted.
```

## Strong Induction Template

```coq
Require Import Arith.

Theorem strong_induction : forall n : nat, P n.
Proof.
  intros n.
  induction n as [n IH] using lt_wf_ind.
  (* IH : forall m, m < n -> P m *)
  admit. (* TODO *)
Admitted.
```

## Well-Founded Induction Template

```coq
Require Import Wf_nat.

Theorem wf_example : forall n : nat, P n.
Proof.
  apply well_founded_induction with (R := lt).
  - exact lt_wf.
  - intros x IH.
    (* IH : forall y, y < x -> P y *)
    admit. (* TODO *)
Admitted.
```

## If-Then-Else Template

```coq
Require Import Decidable.

Theorem if_example : forall n m : nat, P n m.
Proof.
  intros n m.
  destruct (Nat.eq_dec n m) as [Heq | Hneq].
  - (* Case: n = m *)
    subst. admit. (* TODO *)
  - (* Case: n <> m *)
    admit. (* TODO *)
Admitted.
```

## Uniqueness Proof Template

```coq
Theorem unique_example : forall x : A,
  (exists y, P x y) /\ (forall y1 y2, P x y1 -> P x y2 -> y1 = y2).
Proof.
  intros x. split.
  - (* Existence *)
    exists witness.
    admit. (* TODO *)
  - (* Uniqueness *)
    intros y1 y2 H1 H2.
    admit. (* TODO *)
Admitted.
```

## Equivalence Proof Template

```coq
Theorem equiv_example : forall x : A, P x <-> Q x.
Proof.
  intros x. split.
  - (* Forward: P x -> Q x *)
    intros HP.
    admit. (* TODO *)
  - (* Backward: Q x -> P x *)
    intros HQ.
    admit. (* TODO *)
Admitted.
```

## Proof by Contradiction Template

```coq
Require Import Classical.

Theorem contradiction_example : forall x : A, P x.
Proof.
  intros x.
  apply NNPP. intros Hnot.
  (* Hnot : ~P x *)
  (* Derive a contradiction *)
  admit. (* TODO *)
Admitted.
```

## Tips for Using Templates

1. Start with the easiest Admitted
2. Fill TODOs one at a time
3. Verify frequently with `rocq_compile`
4. Search the library before proving from scratch
5. Use `rocq_step_multi` to test multiple tactics at once
