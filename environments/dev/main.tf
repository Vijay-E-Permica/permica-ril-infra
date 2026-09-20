module "stack" {
  source = "../../modules/stack"

  project_id    = var.project_id
  region        = var.region
  app_name      = var.app_name
  github_repo   = var.github_repo
  environment   = "dev"
  deploy_branch = "develop"

  # Small and disposable.
  deletion_protection   = false
  sql_tier              = "db-f1-micro"
  sql_availability_type = "ZONAL"
  min_instances         = 0
  max_instances         = 3

  enable_bigtable  = var.enable_bigtable
  bigtable_tables  = var.bigtable_tables
  scheduler_jobs   = var.scheduler_jobs
  extra_secret_env = var.extra_secret_env

  # Developers can deploy, read logs and add secret values in dev.
  developer_members = var.developer_members
  developer_roles = [
    "roles/viewer",
    "roles/logging.viewer",
    "roles/run.developer",
    "roles/cloudsql.client",
    "roles/secretmanager.secretVersionAdder",
    "roles/storage.objectUser",
  ]

  admin_members = var.admin_members
  admin_roles = [
    "roles/run.admin",
    "roles/cloudsql.admin",
    "roles/secretmanager.admin",
    "roles/storage.admin",
    "roles/bigtable.admin",
  ]
}
