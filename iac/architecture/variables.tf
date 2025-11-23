variable "region" {
  default     = "us-east-2"
  type        = string
  description = "AWS Region where the solution is going to be deployed"
}

variable "project_nickname" {
  description = "A unique name for the project to prefix resources, it should be small."
  type        = string
  default     = "clockin"
}

variable "api_login_url" {
  description = "The full API endpoint URL for user login."
  type        = string
}

variable "api_clockin_url" {
  description = "The full API endpoint URL for clocking in."
  type        = string
}