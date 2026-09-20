variable "project_id" {
  type = string
}

variable "services" {
  description = "API service names to enable."
  type        = list(string)
}
