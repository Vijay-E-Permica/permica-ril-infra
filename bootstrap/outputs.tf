output "github_variables" {
  description = "Create these as GitHub repository VARIABLES (Settings > Secrets and variables > Actions > Variables). They are identifiers, not secrets."
  value = merge(
    { for k, v in local.envs : "GCP_PROJECT_ID_${upper(k)}" => v.project_id },
    { for k in keys(local.envs) : "GCP_WIF_PROVIDER_${upper(k)}" => google_iam_workload_identity_pool_provider.github[k].name },
    { for k in keys(local.envs) : "GCP_TF_APPLY_SA_${upper(k)}" => google_service_account.apply[k].email },
    { for k in keys(local.envs) : "GCP_TF_PLAN_SA_${upper(k)}" => google_service_account.plan[k].email },
  )
}

output "state_buckets" {
  value = { for k in keys(local.envs) : k => google_storage_bucket.state[k].name }
}
