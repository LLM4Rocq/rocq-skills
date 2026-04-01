# Rocq MCP Tools API

Full reference for the Rocq MCP server tools.

## Tool Summary

| Tool | Purpose | Mutates State? |
|------|---------|---------------|
| `rocq_start` | Start interactive proof session | Yes (creates session) |
| `rocq_check` | Execute tactics, advance state | Yes (advances state) |
| `rocq_step_multi` | Test multiple tactics (non-destructive) | No |
| `rocq_compile` | Full file compilation | No |
| `rocq_query` | Search, Check, Print, About | No |
| `rocq_goal` | Proof goal at file position (no session needed) | No |
| `rocq_toc` | File structure outline | No |
| `rocq_notations` | Notation disambiguation | No |
| `rocq_verify` | Sandboxed proof verification | No |

## rocq_start

Start an interactive proof session. Returns a `state_id` for use with `rocq_check` and `rocq_step_multi`.

**Three start modes** (precedence: theorem > position > preamble):
1. **By theorem:** `file` + `theorem` — start proving a specific theorem
2. **By position:** `file` + `line` + `character` — jump to error position
3. **From imports:** `preamble` — set up import context only

**Parameters:**
- `file` (string): Path to .v file (relative to workspace)
- `theorem` (string): Name of theorem to prove
- `workspace` (string): Workspace directory
- `line` (int): 0-based line number
- `character` (int): 0-based character offset
- `preamble` (string): Import commands

**Example:**
```
rocq_start(file="theories/MyFile.v", theorem="add_comm")
```

## rocq_check

Execute tactics and see updated goals. Much faster than `rocq_compile` for iterative work — imports are cached.

**Key feature:** On error, returns the last valid state for immediate recovery via `rocq_check(from_state=...)` or `rocq_step_multi(from_state=...)`.

**When `proof_finished=True`:** Returns `proof_tactics` (ordered list) and `proof_hint` (assembly instructions).

**Parameters:**
- `body` (string, required): Tactics to execute
- `from_state` (int): Execute from specific state (default: current)
- `workspace` (string): Workspace directory
- `timeout` (int): Timeout in seconds

**Example:**
```
rocq_check(body="intros n. induction n.")
rocq_check(body="simpl. reflexivity.", from_state=5)  # backtrack
```

## rocq_step_multi

Test multiple tactics without advancing state. Does NOT commit — use `rocq_check` to commit the winner.

**Parameters:**
- `tactics` (list[string], required): Tactics to try (max 20)
- `from_state` (int): Try from specific state (default: current)

**Example:**
```
rocq_step_multi(tactics=[
  "auto.", "lia.", "ring.", "reflexivity.",
  "simpl; auto.", "intuition.", "tauto."
])
```

**Standard automation battery:**
```
tactics=["trivial.", "reflexivity.", "assumption.", "exact I.",
         "auto.", "eauto.", "tauto.", "intuition.", "lia.", "lra.",
         "nia.", "nra.", "ring.", "field.", "decide.",
         "firstorder."]
```
Note: `lia`/`lra`/`ring`/`field` require imports in the .v file.

## rocq_compile

Batch-compile a complete .v file via coqc. Best for checking a finished proof. For iterative development, prefer `rocq_check`.

**Parameters:**
- `source` (string, required): Complete .v file content
- `workspace` (string): Workspace directory
- `timeout` (int): Compilation timeout
- `include_warnings` (bool): Include warnings (default: true)

**On error:** Returns `error_positions` for jumping via `rocq_start(file, line, character)`.

## rocq_query

Search the Rocq environment. Does NOT modify proof state.

**Parameters:**
- `command` (string, required): The query command
- `preamble` (string): Import lines for context
- `workspace` (string): Workspace directory

**Examples:**
```
rocq_query(command="Search (nat -> nat -> nat).")
rocq_query(command="Check Nat.add.")
rocq_query(command="Print Nat.add.")
rocq_query(command="About plus.")
rocq_query(command="Print Assumptions my_theorem.")
rocq_query(command="Search (_ + _ = _ + _).", preamble="Require Import Arith.")
rocq_query(command="SearchPattern (_ -> _ -> Prop).")
```

## rocq_toc

Get the structure of a .v file. Does NOT require a session.

**Parameters:**
- `file` (string, required): Path to .v file
- `workspace` (string): Workspace directory

**Returns:** Hierarchical outline of definitions, lemmas, theorems, sections.

## rocq_goal

Get the proof goal at a specific position in a Rocq file. Does NOT require a `rocq_start` session — useful for quick inspection of proof state at any point.

**Parameters:**
- `file` (string, required): Path to .v file (relative to workspace)
- `line` (int, required): 0-based line number (LSP convention)
- `character` (int, required): 0-based character offset (LSP convention)
- `workspace` (string): Workspace directory

**Example:**
```
rocq_goal(file="theories/MyFile.v", line=42, character=0)
```

**Use cases:**
- Inspect proof state without opening an interactive session
- Quick goal check during review or planning phases
- Complement `rocq_toc` with goal-level detail at specific positions

## rocq_notations

List all notations in a statement and how they resolve. Helps debug notation ambiguity.

**Parameters:**
- `statement` (string, required): The proposition/type to analyze
- `preamble` (string): Import lines for context
- `workspace` (string): Workspace directory

**Example:**
```
rocq_notations(statement="forall n, n + 0 = n")
rocq_notations(statement="forall x, x * 1 = x", preamble="Require Import QArith.")
```

## rocq_verify

Verify that a proof actually proves the original statement. Sandboxed verification.

**Catches:** Type redefinition, Admitted/Abort, custom axioms, statement mismatches. Standard mathematical axioms are accepted.

**Parameters:**
- `proof` (string, required): Complete proof file content
- `problem_name` (string, required): Unqualified theorem name
- `problem_statement` (string, required): Original problem file (with Admitted)
- `workspace` (string): Workspace directory
- `timeout` (int): Verification timeout
- `include_warnings` (bool): Include warnings (default: true)

**Example:**
```
rocq_verify(
  proof="Require Import Arith.\nTheorem add_comm : forall n m, n + m = m + n.\nProof. intros. lia. Qed.",
  problem_name="add_comm",
  problem_statement="Require Import Arith.\nTheorem add_comm : forall n m, n + m = m + n.\nProof.\nAdmitted."
)
```

## Recommended Workflow

```
1. rocq_goal(file="File.v", line=42, character=0)    # Quick goal peek
2. rocq_start(file="File.v", theorem="my_thm")      # Open session
3. rocq_query("Search relevant_pattern.")            # Find lemmas
4. rocq_step_multi(tactics=["auto.", "lia.", ...])   # Explore
5. rocq_check(body="winning_tactic.")                # Commit
6. rocq_compile(source="full file")                  # Validate
7. rocq_verify(proof=..., ...)                       # Verify
```
