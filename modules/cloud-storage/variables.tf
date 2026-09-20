variable "project_id" {
  type = string
}

variable "name" {
  description = "Globally unique bucket name."
  type        = string
}

variable "location" {
  type = string
}

variable "versioning" {
  type    = bool
  default = true
}

variable "force_destroy" {
  description = "Allow terraform destroy to delete a non-empty bucket. Keep false for prod."
  type        = bool
  default     = false
}

variable "object_user_member" {
  description = "IAM member that can read/write objects (the Cloud Run runtime service account)."
  type        = string
}

variable "labels" {
  type    = map(string)
  default = {}
}
