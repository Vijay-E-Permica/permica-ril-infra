variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "name" {
  type = string
}

variable "writer_member" {
  description = "IAM member allowed to push images (the CI deployer service account)."
  type        = string
}

variable "labels" {
  type    = map(string)
  default = {}
}
