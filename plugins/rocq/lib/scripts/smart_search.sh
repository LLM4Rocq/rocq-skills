#!/bin/bash
# Multi-source search for Rocq lemmas and definitions.
#
# Usage:
#   smart_search.sh <query> [--dir=<project_dir>]
#
# Searches:
#   1. Local project files (grep)
#   2. Coq standard library (coqc + Search)
#
# Prefer MCP (rocq_query) over this script when available.

set -euo pipefail

QUERY="${1:-}"
PROJECT_DIR="${2:-.}"

if [[ -z "$QUERY" ]]; then
  echo "Usage: smart_search.sh <query> [project_dir]" >&2
  exit 1
fi

echo "=== Local Search ==="
# Search in local .v files
grep -rn --include='*.v' "$QUERY" "$PROJECT_DIR" 2>/dev/null | head -20 || echo "(no local matches)"

echo ""
echo "=== Library Search ==="
echo "Use MCP for library search: rocq_query(\"Search $QUERY.\")"
echo "Or: rocq_query(\"SearchPattern ($QUERY).\")"
echo ""
echo "Manual: coqc -e \"Require Import Arith. Search $QUERY.\""
