output "cloud_run_url" {
  value = module.stack.cloud_run_url
}

output "cloud_sql_connection_name" {
  value = module.stack.cloud_sql_connection_name
}

output "artifact_registry_path" {
  value = module.stack.artifact_registry_path
}

output "runtime_service_account" {
  value = module.stack.runtime_service_account
}

output "deployer_service_account" {
  value = module.stack.deployer_service_account
}

output "app_deploy_github_variables" {
  value = module.stack.app_deploy_github_variables
}
