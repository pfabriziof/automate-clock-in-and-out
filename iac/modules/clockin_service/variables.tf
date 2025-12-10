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
  description = "EventBridge cron expression for clockin time."
  type        = string
}

variable "clockout_cron" {
  description = "EventBridge cron expression for clockout time."
  type        = string
}

variable "clockout_fridays_cron" {
  description = "EventBridge cron expression for clockout time on fridays."
  type        = string
}

variable "clockin_timezone" {
  description = "Scheduler timezone expression for clockin service to work with localzone"
  type        = string
}

variable "operation_delay" {
  description = "The max delay for the operation clock-in/out to execute after it's initated."
  type        = number
}

variable "max_scheduler_window" {
  description = "Max scheduler time window in minutes to realize the operation"
  type        = number
}

variable "sucursal" {
  description = "The id for the specific talana branch"
  type        = string
}