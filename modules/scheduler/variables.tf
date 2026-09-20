variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "name_prefix" {
  type = string
}

variable "service_name" {
  description = "Cloud Run service to invoke."
  type        = string
}

variable "service_uri" {
  description = "Base URL of the Cloud Run service (no trailing slash)."
  type        = string
}

variable "jobs" {
  description = "Scheduler jobs: { job_name = { schedule = \"0 * * * *\", path = \"/tasks/x\" } }"
  type = map(object({
    schedule    = string
    path        = string
    http_method = optional(string, "POST")
    time_zone   = optional(string, "Etc/UTC")
  }))
  default = {}
}
