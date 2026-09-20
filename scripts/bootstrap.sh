#!/usr/bin/env bash
set -euo pipefail

# Helper script to run bootstrap terraform apply for a specific environment or all environments.
# Usage: ./scripts/bootstrap.sh [env]
# Examples:
#   ./scripts/bootstrap.sh dev      # Provision bootstrap resources for dev only
#   ./scripts/bootstrap.sh prod     # Provision bootstrap resources for prod only
#   ./scripts/bootstrap.sh          # Provision bootstrap resources for all environments

TARGET_ENV="${1:-}"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BOOTSTRAP_DIR="$REPO_ROOT/bootstrap"

if [ ! -d "$BOOTSTRAP_DIR" ]; then
  echo "Error: bootstrap directory not found at $BOOTSTRAP_DIR" >&2
  exit 1
fi

cd "$BOOTSTRAP_DIR"

echo "==> Initializing local Terraform workspace in $BOOTSTRAP_DIR..."
if [ -f "$BOOTSTRAP_DIR/terraform.tfstate" ]; then
  STATE_BUCKET=$(terraform output -json state_buckets 2>/dev/null | jq -r --arg env "$TARGET_ENV" '.[$env] // empty' 2>/dev/null || true)
fi

if [ -n "${STATE_BUCKET:-}" ] && [ "$STATE_BUCKET" != "null" ]; then
  echo "==> Initializing backend with GCS bucket '$STATE_BUCKET'..."
  # Re-create backend.tf on the fly for GCS remote state initialization
  cat <<EOF > "$BOOTSTRAP_DIR/backend.tf"
terraform {
  backend "gcs" {}
}
EOF
  terraform init -reconfigure -input=false -backend-config="bucket=$STATE_BUCKET" -backend-config="prefix=bootstrap/state"
else
  echo "==> Initializing local Terraform workspace..."
  rm -f "$BOOTSTRAP_DIR/backend.tf"
  terraform init -backend=false -reconfigure -input=false
fi

if [ -n "$TARGET_ENV" ]; then
  echo "==> Running bootstrap terraform apply targeting environment '$TARGET_ENV'..."
  
  APIS=(
    "cloudresourcemanager.googleapis.com"
    "serviceusage.googleapis.com"
    "iam.googleapis.com"
    "iamcredentials.googleapis.com"
    "sts.googleapis.com"
    "storage.googleapis.com"
  )

  PLAN_ROLES=(
    "roles/viewer"
    "roles/iam.securityReviewer"
    "roles/secretmanager.secretAccessor"
  )

  TARGET_ARGS=(
    "-target=google_project.env[\"${TARGET_ENV}\"]"
    "-target=google_storage_bucket.state[\"${TARGET_ENV}\"]"
    "-target=google_service_account.apply[\"${TARGET_ENV}\"]"
    "-target=google_service_account.plan[\"${TARGET_ENV}\"]"
    "-target=google_project_iam_member.apply_owner[\"${TARGET_ENV}\"]"
    "-target=google_storage_bucket_iam_member.plan_state[\"${TARGET_ENV}\"]"
    "-target=google_iam_workload_identity_pool.github[\"${TARGET_ENV}\"]"
    "-target=google_iam_workload_identity_pool_provider.github[\"${TARGET_ENV}\"]"
    "-target=google_service_account_iam_member.apply_wif[\"${TARGET_ENV}\"]"
    "-target=google_service_account_iam_member.plan_wif[\"${TARGET_ENV}\"]"
  )

  for api in "${APIS[@]}"; do
    TARGET_ARGS+=("-target=google_project_service.bootstrap[\"${TARGET_ENV}/${api}\"]")
  done

  for role in "${PLAN_ROLES[@]}"; do
    TARGET_ARGS+=("-target=google_project_iam_member.plan[\"${TARGET_ENV}/${role}\"]")
  done

  terraform apply -auto-approve "${TARGET_ARGS[@]}"
else
  echo "==> Running bootstrap terraform apply for ALL environments..."
  terraform apply -auto-approve
fi

# Automatically configure GCS backend for bootstrap and migrate local state
STATE_BUCKET=$(terraform output -json state_buckets | jq -r 'to_entries[0].value // empty')

if [ -n "$STATE_BUCKET" ] && [ "$STATE_BUCKET" != "null" ]; then
  echo "==> Migrating bootstrap state to GCS bucket '$STATE_BUCKET'..."
  cat <<EOF > "$BOOTSTRAP_DIR/backend.tf"
terraform {
  backend "gcs" {}
}
EOF
  terraform init -force-copy -input=false -backend-config="bucket=$STATE_BUCKET" -backend-config="prefix=bootstrap/state"
  rm -f "$BOOTSTRAP_DIR/backend.tf" "$BOOTSTRAP_DIR/terraform.tfstate" "$BOOTSTRAP_DIR/terraform.tfstate.backup"
  echo "==> Bootstrap state successfully migrated to GCS bucket '$STATE_BUCKET'!"
fi

# Clean up local .terraform cache directory after bootstrap completes
rm -rf "$BOOTSTRAP_DIR/.terraform" "$BOOTSTRAP_DIR/backend.tf" "$BOOTSTRAP_DIR/terraform.tfstate" "$BOOTSTRAP_DIR/terraform.tfstate.backup"

echo "==> Bootstrap completed successfully!"


