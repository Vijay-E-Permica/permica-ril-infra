#!/usr/bin/env bash
set -euo pipefail

# Helper script to retrieve secret values from GCP Secret Manager.
# Usage: ./scripts/get_secret.sh <secret-name> <project-id> [version]

SECRET_NAME="${1:-}"
PROJECT_ID="${2:-}"
VERSION="${3:-latest}"

if [ -z "$SECRET_NAME" ] || [ -z "$PROJECT_ID" ]; then
  echo "Usage: $0 <secret-name> <project-id> [version]" >&2
  echo "Example: $0 jwt-secret permica-ai-dev-134567 latest" >&2
  exit 1
fi

echo "==> Fetching secret '$SECRET_NAME' (version: $VERSION) from project '$PROJECT_ID'..." >&2

gcloud secrets versions access "$VERSION" --secret="$SECRET_NAME" --project="$PROJECT_ID"
