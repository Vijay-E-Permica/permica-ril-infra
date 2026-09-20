#!/usr/bin/env bash
set -euo pipefail

# Helper script to destroy an entire environment layer (stack infrastructure, GitHub vars, & bootstrap project resources).
# Usage: ./scripts/destroy.sh <env>
# Example: ./scripts/destroy.sh dev
#          ./scripts/destroy.sh prod

TARGET_ENV="${1:-}"

if [ -z "$TARGET_ENV" ]; then
  echo "Usage: $0 <env>" >&2
  echo "Example: $0 dev" >&2
  exit 1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_DIR="$REPO_ROOT/environments/$TARGET_ENV"
BOOTSTRAP_DIR="$REPO_ROOT/bootstrap"

if [ ! -d "$ENV_DIR" ]; then
  echo "Error: Environment directory not found at $ENV_DIR" >&2
  exit 1
fi

echo "========================================================================="
echo " WARNING: You are about to DESTROY the '$TARGET_ENV' environment."
echo " This will permanently delete Cloud Run, Cloud SQL, Storage Buckets,"
echo " Secret Manager secrets, IAM roles, and the GCP project."
echo "========================================================================="
read -p "Type '$TARGET_ENV' to confirm destruction: " CONFIRM

if [ "$CONFIRM" != "$TARGET_ENV" ]; then
  echo "Destruction cancelled."
  exit 0
fi

# Step 1: Destroy environment application stack resources (Cloud Run, Cloud SQL, etc.)
if [ -f "$ENV_DIR/terraform.tfvars" ]; then
  echo "==> Destroying application stack infrastructure in $ENV_DIR..."
  cd "$BOOTSTRAP_DIR"
  PROJECT_ID=$(terraform output -json github_variables | jq -r --arg env "_$(echo "$TARGET_ENV" | tr '[:lower:]' '[:upper:]')" 'to_entries[] | select(.key | endswith($env)) | select(.key | startswith("GCP_PROJECT_ID")) | .value' || true)

  cd "$ENV_DIR"
  if [ -n "$PROJECT_ID" ] && [ "$PROJECT_ID" != "null" ]; then
    echo "==> Initializing backend with bucket '${PROJECT_ID}-tfstate'..."
    terraform init -input=false -backend-config="bucket=${PROJECT_ID}-tfstate" -backend-config="prefix=terraform/state" || true
  else
    terraform init -input=false || true
  fi

  terraform destroy -auto-approve -input=false -var-file=terraform.tfvars || true
fi

# Step 2: Remove GitHub repository variables for this environment
echo "==> Removing GitHub Actions variables for environment '$TARGET_ENV'..."
"$REPO_ROOT/scripts/delete_github_vars.sh" "$TARGET_ENV" || true

# Step 3: Destroy bootstrap resources targeting this environment
if [ -d "$BOOTSTRAP_DIR" ]; then
  echo "==> Destroying bootstrap resources targeting environment '$TARGET_ENV'..."
  cd "$BOOTSTRAP_DIR"
  terraform init -backend=false -reconfigure -input=false || true

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

  terraform destroy -auto-approve "${TARGET_ARGS[@]}" || true
fi

echo "==> Environment '$TARGET_ENV' destroyed successfully!"
