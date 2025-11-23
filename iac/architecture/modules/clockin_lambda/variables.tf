
variable "project_nickname" {
  description = "A unique name for the project to prefix resources, it should be small."
  type        = string
}

variable "clockin_cron" {
  description = "EventBridge cron expression for clockin time (e.g., 'cron(0 13 * * ? *)' for 1:00 PM UTC)."
  type        = string
  # Example: 13:00 AM UTC
  default = "cron(0 13 * * ? *)"
}

variable "clockout_cron" {
  description = "EventBridge cron expression for clockout time (e.g., 'cron(0 24 * * ? *)' for 12:00 AM UTC)."
  type        = string
  # Example: 24:00 PM UTC
  default = "cron(0 24 * * ? *)"
}