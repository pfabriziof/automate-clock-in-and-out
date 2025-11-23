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

variable "clockin_cron" {
  description = "EventBridge cron expression for clockin time (e.g., 'cron(0 9 * * ? *)' for 9:00 AM UTC)."
  type        = string
  # Example: 9:00 AM UTC
  default = "cron(0 9 * * ? *)"
}

variable "clockout_cron" {
  description = "EventBridge cron expression for clockout time (e.g., 'cron(0 17 * * ? *)' for 5:00 PM UTC)."
  type        = string
  # Example: 5:00 PM UTC
  default = "cron(0 17 * * ? *)"
}