#!/usr/bin/env bash
set -euo pipefail

# Ensure script is run from repo root or bootstrap directory
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BOOTSTRAP_DIR="$REPO_ROOT/bootstrap"

if [ ! -d "$BOOTSTRAP_DIR" ]; then
  echo "Error: bootstrap directory not found at $BOOTSTRAP_DIR" >&2
  exit 1
fi

cd "$BOOTSTRAP_DIR"

echo "==> Fetching terraform outputs from $BOOTSTRAP_DIR..."
if ! terraform output -json github_variables > /dev/null 2>&1; then
  echo "Error: Failed to read terraform output 'github_variables'. Ensure 'terraform apply' has been run in bootstrap/." >&2
  exit 1
fi

echo "==> Setting GitHub repository variables via gh CLI..."
terraform output -json github_variables | jq -r 'to_entries[] | "\(.key)=\(.value)"' | while IFS='=' read -r key val; do
  echo "Setting variable: $key"
  gh variable set "$key" --body "$val"
done

echo "==> Successfully updated GitHub repository variables!"
