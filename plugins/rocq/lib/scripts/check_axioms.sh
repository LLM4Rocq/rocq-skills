#!/bin/bash
# Check for non-standard axioms in Rocq .v files.
#
# Usage:
#   check_axioms.sh <file_or_dir> [--report-only]
#
# Standard axioms (not flagged):
#   - classic, NNPP (Classical_Prop)
#   - functional_extensionality (FunctionalExtensionality)
#   - propositional_extensionality (PropExtensionality)
#   - proof_irrelevance (ProofIrrelevance)
#   - JMeq_eq (JMeq)
#   - Real number axioms (Rdefinitions)
#
# Exit codes:
#   0 - no custom axioms found
#   1 - custom axioms found (suppressed with --report-only)
#   2 - error

set -euo pipefail

REPORT_ONLY=0
TARGET=""

for arg in "$@"; do
  case "$arg" in
    --report-only) REPORT_ONLY=1 ;;
    *) TARGET="$arg" ;;
  esac
done

if [[ -z "$TARGET" ]]; then
  echo "Usage: check_axioms.sh <file_or_dir> [--report-only]" >&2
  exit 2
fi

# Standard axioms pattern (not flagged)
STANDARD_AXIOMS="classic\|NNPP\|functional_extensionality\|functional_extensionality_dep\|propositional_extensionality\|proof_irrelevance\|JMeq_eq\|Raxioms\|Rplus_comm\|Rplus_assoc\|Rmult_comm\|Rmult_assoc\|Rplus_0_l\|Rmult_1_l\|R1_neq_R0\|completeness\|archimed\|total_order_T"

# Find all .v files
if [[ -f "$TARGET" ]]; then
  FILES=("$TARGET")
else
  mapfile -t FILES < <(find "$TARGET" -name '*.v' -type f | sort)
fi

if [[ ${#FILES[@]} -eq 0 ]]; then
  echo "No .v files found in $TARGET" >&2
  exit 2
fi

FOUND_CUSTOM=0

for file in "${FILES[@]}"; do
  # Extract theorem/lemma names from the file
  DECLS=$(grep -oP '^\s*(Theorem|Lemma|Proposition|Corollary|Fact|Definition)\s+\K\w+' "$file" 2>/dev/null || true)

  if [[ -z "$DECLS" ]]; then
    continue
  fi

  # For each declaration, check Print Assumptions
  # This requires the file to be compiled. If rocq_query is not available,
  # fall back to searching for explicit Axiom/Parameter declarations.
  while IFS= read -r decl; do
    [[ -z "$decl" ]] && continue
    # Check for Axiom/Parameter/Conjecture declarations in the file
    :
  done <<< "$DECLS"

  # Check for explicit axiom declarations
  AXIOMS=$(grep -nP '^\s*(Axiom|Parameter|Conjecture)\s+\w+' "$file" 2>/dev/null || true)
  if [[ -n "$AXIOMS" ]]; then
    while IFS= read -r axiom_line; do
      [[ -z "$axiom_line" ]] && continue
      # Check if it's a standard axiom
      AXIOM_NAME=$(echo "$axiom_line" | grep -oP '(Axiom|Parameter|Conjecture)\s+\K\w+' || true)
      if [[ -n "$AXIOM_NAME" ]] && ! echo "$AXIOM_NAME" | grep -qw "$STANDARD_AXIOMS"; then
        echo "CUSTOM AXIOM: $file: $axiom_line"
        FOUND_CUSTOM=1
      fi
    done <<< "$AXIOMS"
  fi
done

if [[ $FOUND_CUSTOM -eq 0 ]]; then
  echo "Standard axioms only"
  exit 0
else
  echo ""
  echo "Found custom axioms. Use rocq_query(\"Print Assumptions theorem_name.\") for detailed audit."
  if [[ $REPORT_ONLY -eq 1 ]]; then
    exit 0
  else
    exit 1
  fi
fi
