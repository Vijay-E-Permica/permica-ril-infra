variable "project_id" {
  type = string
}

variable "name" {
  description = "Instance ID (6-33 chars)."
  type        = string
}

variable "zone" {
  type = string
}

variable "num_nodes" {
  type    = number
  default = 1
}

variable "storage_type" {
  type    = string
  default = "SSD"
}

variable "deletion_protection" {
  type    = bool
  default = true
}

variable "tables" {
  description = "Tables to create: { table_name = { column_families = [\"cf1\"] } }"
  type = map(object({
    column_families = list(string)
  }))
  default = {}
}

variable "labels" {
  type    = map(string)
  default = {}
}
