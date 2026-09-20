variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "name" {
  type = string
}

variable "database_version" {
  type    = string
  default = "POSTGRES_17"
}

variable "tier" {
  description = "Machine tier, e.g. db-f1-micro (dev) or db-custom-2-7680 (prod)."
  type        = string
}

variable "availability_type" {
  description = "ZONAL or REGIONAL (high availability). Shared-core tiers only support ZONAL."
  type        = string
  default     = "ZONAL"
}

variable "disk_size" {
  type    = number
  default = 20
}

variable "database_name" {
  type = string
}

variable "user_name" {
  type    = string
  default = "app"
}

variable "deletion_protection" {
  type    = bool
  default = true
}

variable "labels" {
  type    = map(string)
  default = {}
}
