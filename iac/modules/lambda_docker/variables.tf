
variable "project_nickname" {
  description = "A unique name for the project to prefix resources, it should be small."
  type        = string
}

variable "owner_tag" {
  description = "owner tag for the resources deployed"
  type = string
}

variable "project_tag" {
  description = "owner tag for the resources deployed"
  type = string
}

variable "function_name" {
  description = "The name of the lambda function"
  type = string
}

variable "additional_policy_arns" {
  description = "List of Policy ARN's to add to the default Lambda role"
  type = list(any)
  default = []
}