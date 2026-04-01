#!/bin/bash
set -euo pipefail
: "${CLAUDE_PLUGIN_ROOT:?missing CLAUDE_PLUGIN_ROOT}"
ENV_OUT="${CLAUDE_ENV_FILE:-}"

# Persist env var: update if exists with different value, add if missing
persist_env() {
  local kv="$1"
  local var_name="${kv%%=*}"
  var_name="${var_name#export }"
  if [[ -n "${ENV_OUT}" ]]; then
    if [[ -f "${ENV_OUT}" ]]; then
      grep -v "^export ${var_name}=" "${ENV_OUT}" > "${ENV_OUT}.tmp" 2>/dev/null || true
      mv "${ENV_OUT}.tmp" "${ENV_OUT}"
    fi
    printf '%s\n' "$kv" >> "${ENV_OUT}"
  fi
}

PYTHON_BIN="$(command -v python3 || command -v python || true)"

persist_env "export ROCQ_PLUGIN_ROOT=\"${CLAUDE_PLUGIN_ROOT}\""
persist_env "export ROCQ_SCRIPTS=\"${CLAUDE_PLUGIN_ROOT}/lib/scripts\""
persist_env "export ROCQ_REFS=\"${CLAUDE_PLUGIN_ROOT}/skills/rocq/references\""
[[ -n "${PYTHON_BIN}" ]] && persist_env "export ROCQ_PYTHON_BIN=\"${PYTHON_BIN}\""

echo "Rocq v1 ready: PLUGIN_ROOT=${CLAUDE_PLUGIN_ROOT}"
exit 0
