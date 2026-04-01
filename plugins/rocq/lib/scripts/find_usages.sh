#!/bin/bash
# Find usages of a declaration in Rocq .v files.
#
# Usage:
#   find_usages.sh <name> [dir]

set -euo pipefail

NAME="${1:-}"
DIR="${2:-.}"

if [[ -z "$NAME" ]]; then
  echo "Usage: find_usages.sh <name> [dir]" >&2
  exit 1
fi

echo "=== Usages of '$NAME' ==="
grep -rn --include='*.v' "\b${NAME}\b" "$DIR" 2>/dev/null | grep -v "^\s*(\*" | head -50 || echo "(no usages found)"
