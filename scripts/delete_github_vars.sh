#!/usr/bin/env bash
set -euo pipefail

# Helper script to remove GitHub Actions repository variables.
# Usage: ./scripts/delete_github_vars.sh [env]
# Example: ./scripts/delete_github_vars.sh staging   # deletes only GCP_*_STAGING variables
#          ./scripts/delete_github_vars.sh           # deletes all variables currently defined in bootstrap outputs

TARGET_ENV="${1:-}"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BOOTSTRAP_DIR="$REPO_ROOT/bootstrap"

if [ ! -d "$BOOTSTRAP_DIR" ]; then
  echo "Error: bootstrap directory not found at $BOOTSTRAP_DIR" >&2
  exit 1
fi

cd "$BOOTSTRAP_DIR"

if [ -n "$TARGET_ENV" ]; then
  ENV_UPPER="$(echo "$TARGET_ENV" | tr '[:lower:]' '[:upper:]')"
  echo "==> Removing GitHub repository variables for environment '$TARGET_ENV' (${ENV_UPPER})..."
  VARS=(
    "GCP_PROJECT_ID_${ENV_UPPER}"
    "GCP_WIF_PROVIDER_${ENV_UPPER}"
    "GCP_TF_APPLY_SA_${ENV_UPPER}"
    "GCP_TF_PLAN_SA_${ENV_UPPER}"
  )
  for key in "${VARS[@]}"; do
    echo "Deleting variable: $key"
    gh variable delete "$key" || true
  done
else
  echo "==> Fetching terraform outputs from $BOOTSTRAP_DIR..."
  if ! terraform output -json github_variables > /dev/null 2>&1; then
    echo "Error: Failed to read terraform output 'github_variables'. Ensure 'terraform apply' has been run in bootstrap/." >&2
    exit 1
  fi

  echo "==> Removing ALL GitHub repository variables from bootstrap outputs via gh CLI..."
  terraform output -json github_variables | jq -r 'keys[]' | while read -r key; do
    echo "Deleting variable: $key"
    gh variable delete "$key" || true
  done
fi

echo "==> Done removing GitHub repository variables!"

