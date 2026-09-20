variable "project_id" {
  type = string
}

variable "app_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "github_repo" {
  type = string
}

variable "deploy_branch" {
  type = string
}

variable "wif_pool_name" {
  description = "Full resource name of the GitHub Workload Identity pool (from bootstrap)."
  type        = string
}

variable "enable_bigtable" {
  type    = bool
  default = true
}

variable "developer_members" {
  description = "IAM members, e.g. group:devs@example.com or user:jane@example.com"
  type        = list(string)
  default     = []
}

variable "developer_roles" {
  type    = list(string)
  default = []
}

variable "admin_members" {
  type    = list(string)
  default = []
}

variable "admin_roles" {
  type    = list(string)
  default = []
}
