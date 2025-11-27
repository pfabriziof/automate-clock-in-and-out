variable "region" {
  description = "AWS Region where the solution is going to be deployed"
  type        = string
}

variable "project_nickname" {
  description = "A unique name for the project to prefix resources, it should be small."
  type        = string
}

variable "ecr_repositories" {
  description = "List of ECR repositories for backend logic."
  type        = map(any)
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
  description = "EventBridge cron expression for clockin time (e.g., 'cron(0 13 ? * MON-FRI *)' for 1:00 PM UTC)."
  type        = string
}

variable "clockout_cron" {
  description = "EventBridge cron expression for clockout time (e.g., 'cron(0 0 ? * MON-THU *)' for 12:00 AM UTC)."
  type        = string
}

variable "clockout_fridays_cron" {
  description = "EventBridge cron expression for clockout time (e.g., 'cron(0 22 ? * FRI *)' for 12:00 AM UTC)."
  type        = string
}

variable "sucursal" {
  description = "The id for the specific talana branch"
  type        = string
}

variable "operation_delay" {
  description = "The max delay for the operation clock-in/out to execute after it's initiated."
  type        = number
}