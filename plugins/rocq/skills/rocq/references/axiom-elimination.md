# Axiom Elimination

Reference for systematically eliminating custom axioms in Rocq proofs.

## Standard vs Custom Axioms

### Standard (Acceptable)

These are part of the standard Rocq ecosystem and not flagged:

| Axiom | Source | Purpose |
|-------|--------|---------|
| `classic` | `Coq.Logic.Classical_Prop` | Law of excluded middle |
| `NNPP` | `Coq.Logic.Classical_Prop` | Double negation elimination |
| `functional_extensionality` | `Coq.Logic.FunctionalExtensionality` | Function extensionality |
| `propositional_extensionality` | `Coq.Logic.PropExtensionality` | Proposition extensionality |
| `proof_irrelevance` | `Coq.Logic.ProofIrrelevance` | Proof irrelevance |
| Real number axioms | `Coq.Reals.Rdefinitions` | Axiomatic reals |
| `JMeq_eq` | `Coq.Logic.JMeq` | John Major equality |

### Custom (Flag and Eliminate)

Any `Axiom`, `Parameter`, `Conjecture`, or `Hypothesis` not in the standard set. These should be eliminated or explicitly justified.

## Verification

### Via MCP
```
rocq_query("Print Assumptions theorem_name.")
```

### Via Script
```bash
bash "$ROCQ_SCRIPTS/check_axioms.sh" FILE.v
```

### Manual Check
```coq
Print Assumptions my_theorem.
(* Lists all axioms used by my_theorem *)
```

## Elimination Workflow

### Phase 1: Audit
1. `Print Assumptions` for each theorem
2. Collect all non-standard axioms
3. Build dependency graph

### Phase 2: Document Plan
```markdown
## Axiom Elimination Plan
**Total custom axioms:** N
**Target:** 0

1. **axiom_1** — library_search (exists in stdlib)
2. **axiom_2** — compositional (combine existing lemmas)
3. **axiom_3** — structural (needs helper lemma)
```

### Phase 3: Search Library
For each axiom, search for an existing proof:
```
rocq_query("Search (statement_of_axiom).")
rocq_query("SearchPattern (pattern_of_axiom).")
```

### Phase 4: Eliminate
For each axiom (in dependency order, bottom-up):

1. **Simple (library exists):**
   ```coq
   (* Before *)
   Axiom add_comm : forall n m, n + m = m + n.
   
   (* After *)
   Require Import Arith.
   (* Use Nat.add_comm directly *)
   ```

2. **Compositional (combine lemmas):**
   ```coq
   (* Before *)
   Axiom my_fact : forall n, P n -> Q n.
   
   (* After *)
   Lemma my_fact : forall n, P n -> Q n.
   Proof. intros. apply lemma1. apply lemma2. assumption. Qed.
   ```

3. **Structural (needs refactoring):**
   - Extract helper lemma
   - Restructure proof to avoid needing the axiom
   - Last resort: convert to `Admitted` (better than hiding behind axiom)

## Handling Dependencies

Always eliminate bottom-up: if axiom B depends on axiom A, eliminate A first.

```
axiom A ← axiom B ← theorem C
          ↑
     eliminate first
```

## Progress Tracking

After each elimination:
1. Run `Print Assumptions` on affected theorems
2. Verify axiom count decreased
3. Verify build still passes (`rocq_compile`)

**Expected rates:**
- Library search: 60% of custom axioms
- Compositional: 25%
- Structural/Admitted: 15%

## Common Pitfalls

**Don't:**
- Add new axioms while eliminating old ones
- Skip the library search step
- Break dependent theorems
- Eliminate axioms that the user intentionally added

**Do:**
- Search exhaustively before manual proving
- Verify after each elimination
- Track axiom count (should trend down)
- Ask before removing intentional axioms

## When to Keep Axioms

Rare but acceptable cases (require user approval):
- Axioms representing external system assumptions
- Axioms that are intentionally left abstract
- Axioms for performance (avoiding expensive computation)
