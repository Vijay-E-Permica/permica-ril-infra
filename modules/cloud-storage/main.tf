resource "google_storage_bucket" "this" {
  name                        = var.name
  project                     = var.project_id
  location                    = var.location
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = var.force_destroy
  labels                      = var.labels

  versioning {
    enabled = var.versioning
  }
}

resource "google_storage_bucket_iam_member" "object_user" {
  bucket = google_storage_bucket.this.name
  role   = "roles/storage.objectUser"
  member = var.object_user_member
}
