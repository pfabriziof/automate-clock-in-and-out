
variable "function_name" {
  description = "The name of the lambda function"
  type        = string
}

variable "function_architecture" {
  type        = string
  description = "Instruction set architecture for Lambda function"
  default     = "arm64"
}

variable "function_env_vars" {
  type        = map(any)
  description = "Map of environment variables for Lambda function"
  default     = {}
}

variable "memory_size" {
  type    = number
  default = 1408
}

variable "timeout" {
  type    = number
  default = 3
}

variable "subnet_ids" {
  type    = list(any)
  default = []
}

variable "security_group_ids" {
  type    = list(any)
  default = []
}

variable "ecr_function_repo" {
  type        = map(string)
  description = "ECR function repo"
}

variable "additional_policy_arns" {
  description = "List of Policy ARN's to add to the default Lambda role"
  type        = list(any)
  default     = []
}