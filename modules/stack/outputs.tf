output "cloud_run_url" {
  value = module.cloud_run.uri
}

output "cloud_sql_connection_name" {
  value = module.cloud_sql.connection_name
}

output "artifact_registry_path" {
  description = "Push images here: <path>/backend:<tag>"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${module.artifact_registry.repository_id}"
}

output "runtime_service_account" {
  value = module.iam.runtime_email
}

output "deployer_service_account" {
  value = module.iam.deployer_email
}

output "app_deploy_github_variables" {
  description = "Set these as GitHub variables in the repo that builds/deploys the app (suffix with _DEV / _PROD)."
  value = {
    GCP_REGION        = var.region
    GCP_PROJECT_ID    = var.project_id
    GCP_WIF_PROVIDER  = "${data.google_iam_workload_identity_pool.github.name}/providers/github"
    GCP_DEPLOYER_SA   = module.iam.deployer_email
    ARTIFACT_REGISTRY = "${var.region}-docker.pkg.dev/${var.project_id}/${module.artifact_registry.repository_id}"
    CLOUD_RUN_SERVICE = module.cloud_run.name
  }
}
