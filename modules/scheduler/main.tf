locals {
  enabled = length(var.jobs) > 0
}

# Scheduler calls the (private) Cloud Run endpoint with an OIDC token from this account.
resource "google_service_account" "scheduler" {
  count = local.enabled ? 1 : 0

  project      = var.project_id
  account_id   = "${var.name_prefix}-scheduler"
  display_name = "${var.name_prefix} Cloud Scheduler"
}

resource "google_cloud_run_v2_service_iam_member" "invoker" {
  count = local.enabled ? 1 : 0

  project  = var.project_id
  location = var.region
  name     = var.service_name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.scheduler[0].email}"
}

resource "google_cloud_scheduler_job" "this" {
  for_each = var.jobs

  project          = var.project_id
  region           = var.region
  name             = "${var.name_prefix}-${each.key}"
  schedule         = each.value.schedule
  time_zone        = each.value.time_zone
  attempt_deadline = "320s"

  http_target {
    http_method = each.value.http_method
    uri         = "${var.service_uri}${each.value.path}"

    oidc_token {
      service_account_email = google_service_account.scheduler[0].email
      audience              = var.service_uri
    }
  }

  depends_on = [google_cloud_run_v2_service_iam_member.invoker]
}
