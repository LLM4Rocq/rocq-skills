#!/bin/bash
set -euo pipefail

# Override: skip all guardrails if explicitly disabled
[[ "${ROCQ_GUARDRAILS_DISABLE:-}" == "1" ]] && exit 0

# Rocq project detection: walk ancestors for _CoqProject, dune-project (with coq), *.v files
is_rocq_project() {
  local dir="$1"
  [[ -d "$dir" ]] || return 1
  while true; do
    [[ -f "$dir/_CoqProject" || -f "$dir/CoqMakefile" ]] && return 0
    # Check for dune-project with coq
    if [[ -f "$dir/dune-project" ]] && grep -q 'coq' "$dir/dune-project" 2>/dev/null; then
      return 0
    fi
    # Check for .v files in the directory
    if ls "$dir"/*.v >/dev/null 2>&1; then
      return 0
    fi
    [[ "$dir" == "/" ]] && break
    dir=$(dirname "$dir")
  done
  return 1
}

# Read JSON input from stdin
INPUT=$(cat)

# Parse command
if command -v jq >/dev/null 2>&1; then
  COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // .command // empty' 2>/dev/null) || COMMAND=""
else
  COMMAND=$(echo "$INPUT" | python3 -c '
import json, sys
try:
    data = json.load(sys.stdin)
    ti = data.get("tool_input") or {}
    print(ti.get("command") or data.get("command") or "")
except Exception:
    print("")
' 2>/dev/null) || COMMAND=""
fi

[ -z "$COMMAND" ] && exit 0

# Determine working directory
if command -v jq >/dev/null 2>&1; then
  TOOL_CWD=$(echo "$INPUT" | jq -r '(.cwd // .tool_input.cwd // .tool_input.workdir) // empty' 2>/dev/null) || TOOL_CWD=""
else
  TOOL_CWD=$(echo "$INPUT" | python3 -c '
import json, sys
try:
    data = json.load(sys.stdin)
    ti = data.get("tool_input") or {}
    print(data.get("cwd") or ti.get("cwd") or ti.get("workdir") or "")
except Exception:
    print("")
' 2>/dev/null) || TOOL_CWD=""
fi
TOOL_CWD="${TOOL_CWD:-$PWD}"
TOOL_CWD=$(realpath "$TOOL_CWD" 2>/dev/null || (cd "$TOOL_CWD" 2>/dev/null && pwd -P) || echo "$TOOL_CWD")

# Skip guardrails if not in a Rocq project (unless forced)
if ! is_rocq_project "$TOOL_CWD"; then
  [[ "${ROCQ_GUARDRAILS_FORCE:-}" == "1" ]] || exit 0
fi

# Collaboration policy
COLLAB_POLICY="${ROCQ_GUARDRAILS_COLLAB_POLICY:-ask}"
case "$COLLAB_POLICY" in
  ask|allow|block) ;;
  *) COLLAB_POLICY="ask" ;;
esac

# One-shot bypass detection
BYPASS=0
if [[ "$COMMAND" =~ ROCQ_GUARDRAILS_BYPASS=1 ]]; then
  BYPASS=1
fi

_check_collab_op() {
  local label="$1" msg="$2"
  case "$COLLAB_POLICY" in
    allow) return 0 ;;
    block)
      echo "BLOCKED (Rocq guardrail): $label - $msg [policy=block]" >&2
      exit 2
      ;;
    *)
      if [[ $BYPASS -ne 1 ]]; then
        echo "BLOCKED (Rocq guardrail): $label - $msg [policy=ask, confirm then rerun]" >&2
        echo "  To proceed once, prefix with: ROCQ_GUARDRAILS_BYPASS=1" >&2
        exit 2
      fi
      ;;
  esac
}

# --- Collaboration ops (policy-controlled) ---

# Block git push
if echo "$COMMAND" | grep -qE '\bgit\b.*\bpush\b' && ! echo "$COMMAND" | grep -qE '\bstash\b.*\bpush\b'; then
  if ! echo "$COMMAND" | grep -qE -- '--dry-run'; then
    _check_collab_op "git push" "use /rocq:checkpoint, then push manually"
  fi
fi

# Block git commit --amend
if echo "$COMMAND" | grep -qE '\bgit\b.*\bcommit\b.*--amend'; then
  _check_collab_op "git commit --amend" "proving workflow creates new commits for safe rollback"
fi

# Block gh pr create
if echo "$COMMAND" | grep -qE '\bgh\b.*\bpr\b.*\bcreate\b'; then
  _check_collab_op "gh pr create" "review first, then create PR manually"
fi

# --- Destructive ops (never bypassable) ---

# Block destructive checkout
if echo "$COMMAND" | grep -qE '\bgit\b.*\bcheckout\b.*\s--\s'; then
  echo "BLOCKED (Rocq guardrail): destructive git checkout. Commit or checkpoint first." >&2
  exit 2
fi
if echo "$COMMAND" | grep -qE '\bgit\b.*\bcheckout\b\s+\.(\s|$)'; then
  echo "BLOCKED (Rocq guardrail): git checkout . discards changes. Commit or checkpoint first." >&2
  exit 2
fi

# Block git reset --hard
if echo "$COMMAND" | grep -qE '\bgit\b.*\breset\b.*--hard'; then
  echo "BLOCKED (Rocq guardrail): git reset --hard. Commit or checkpoint first." >&2
  exit 2
fi

# Block git clean -f
if echo "$COMMAND" | grep -qE '\bgit\b.*\bclean\b.*(-[a-zA-Z]*f|--force)'; then
  echo "BLOCKED (Rocq guardrail): git clean deletes untracked files. Commit or checkpoint first." >&2
  exit 2
fi

# Block git restore (worktree changes)
if echo "$COMMAND" | grep -qE '\bgit\b.*\brestore\b'; then
  if ! echo "$COMMAND" | grep -qE -- '--staged'; then
    echo "BLOCKED (Rocq guardrail): git restore discards changes. Commit or checkpoint first." >&2
    exit 2
  fi
fi

exit 0
