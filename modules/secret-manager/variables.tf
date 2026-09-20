variable "project_id" {
  type = string
}

variable "secret_ids" {
  description = "Secrets to create empty (values added manually), e.g. jwt-secret."
  type        = list(string)
  default     = []
}

variable "accessor_member" {
  description = "IAM member allowed to read the secrets (the Cloud Run runtime service account)."
  type        = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "labels" {
  type    = map(string)
  default = {}
}
