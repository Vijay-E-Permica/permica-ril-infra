resource "google_bigtable_instance" "this" {
  name                = var.name
  project             = var.project_id
  deletion_protection = var.deletion_protection
  labels              = var.labels

  cluster {
    cluster_id   = "${var.name}-c1"
    zone         = var.zone
    num_nodes    = var.num_nodes
    storage_type = var.storage_type
  }
}

resource "google_bigtable_table" "tables" {
  for_each = var.tables

  project       = var.project_id
  instance_name = google_bigtable_instance.this.name
  name          = each.key

  dynamic "column_family" {
    for_each = each.value.column_families

    content {
      family = column_family.value
    }
  }
}
