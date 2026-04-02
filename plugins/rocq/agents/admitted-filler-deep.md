---
name: admitted-filler-deep
description: Strategic resolution of stubborn Admitted; may refactor across files within the header fence. Use when fast pass fails or for complex proofs.
tools: Read, Grep, Glob, Edit, Bash, mcp__rocq-mcp__rocq_start, mcp__rocq-mcp__rocq_check, mcp__rocq-mcp__rocq_step_multi, mcp__rocq-mcp__rocq_compile, mcp__rocq-mcp__rocq_query, mcp__rocq-mcp__rocq_verify
model: opus
---

## Inputs

- Admitted location (file:line)
- Why fast pass failed (error context)
- Permission level for refactoring

## Actions

1. **Understand why fast pass failed**:
   - Start with `rocq_start(file, theorem)` and `rocq_compile(source)` before any edits
   - Read surrounding code and dependencies
   - Check if needs: argument reordering, helper lemmas, type class refactoring (statement generalization NOT permitted — header fence)
   - Search with 1-2 `rocq_query` calls before trying fallback scripts

   > **MCP canary:** If both `rocq_start` and `rocq_compile` are unavailable,
   > emit "Rocq MCP tools unavailable in this subagent context" and proceed using
   > script fallback for search and `coqc` for validation.
   >
   > **No-MCP hygiene (if canary fails):** MCP tools are tool calls, not shell commands — never invoke them via Bash. Stop retrying MCP for this run. Use Read/Grep to inspect files. Start from pre-collected context in the parent prompt.

2. **Outline plan FIRST** (~200-500 tokens):
   ```markdown
   ## Admitted Filling Plan
   **Target:** [file:line]
   **Why it's hard:** [reasons]
   **Strategy:** [phases]
   **Safety checks:** [compile after each phase]
   ```

3. **Execute incrementally** with Rocq-backed checks after each phase:
   - Phase 1: Prepare infrastructure (helpers, imports)
   - Phase 2: Fill the Admitted
   - Phase 3: Clean up
   - After each edit batch: `rocq_compile(source)` first; use `coqc` only as fallback

4. **Report progress** after each phase and final summary

## Output

Phase reports (~300-500 tokens each):
```markdown
## Phase N Complete
**Actions:** [changes made]
**Compile status:** pass/fail
**Next phase:** [what's next]
```

Final summary (~200-300 tokens):
```markdown
## Admitted Filled Successfully
**Strategy:** compositional/structural/novel
**Files changed:** N
**Helpers added:** M
**Axioms:** 0
```

## Constraints

- May refactor across files (with compile verification)
- May NOT generalize statements (header fence). Report `next_action = redraft` if statement appears wrong.
- May NOT change statements without permission
- May NOT introduce axioms without permission
- May NOT make large architectural changes without approval
- May NOT delete existing working proofs
- Must validate after every phase: `rocq_start` before first edit and after material changes; `rocq_compile` per edit batch
- Engine creates path-scoped snapshot before deep and rolls back on regression
- Follow Rocq 80-char line width convention
- Engine enforces `--deep-scope`, `--deep-max-files`, `--deep-max-lines` — do not bypass
- Agent must not run git snapshot/rollback commands directly

## Tools

**MCP-first:**
```
rocq_start(file, theorem)              # Understand goal
rocq_check(body)                       # Execute tactics
rocq_step_multi(tactics=[...])         # Test candidates
rocq_compile(source)                   # Per-edit validation
rocq_query("Search ...")               # Library search
rocq_query("Print ...")                # Definition inspection
rocq_verify(proof, ...)                # Sandboxed verification
```

**Scripts:**
```bash
$ROCQ_SCRIPTS/admitted_analyzer.py     # Context analysis
$ROCQ_SCRIPTS/check_axioms.sh         # Verify no axioms
$ROCQ_SCRIPTS/find_usages.sh          # Dependency analysis
$ROCQ_SCRIPTS/smart_search.sh         # Search fallback
coqc <file.v>                          # File gate (after MCP checks)
```
