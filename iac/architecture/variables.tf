variable "region" {
  description = "AWS Region where the solution is going to be deployed"
  type        = string
  default     = "us-east-2"
}

variable "project_nickname" {
  description = "A unique name for the project to prefix resources, it should be small."
  type        = string
  default     = "clockin"
}

variable "owner_tag" {
  description = "owner tag for the resources deployed"
  type        = string
  default     = "the-pragmatic-architect"
}

variable "project_tag" {
  description = "project tag for the resources deployed"
  type        = string
  default     = "clockin-automation"
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
  default     = "cron(0 8 ? * MON-FRI *)"
}

variable "clockout_cron" {
  description = "EventBridge cron expression for clockout time."
  type        = string
  default     = "cron(0 19 ? * MON-THU *)"
}

variable "clockout_fridays_cron" {
  description = "EventBridge cron expression for clockout time on fridays."
  type        = string
  default     = "cron(0 17 ? * FRI *)"
}

variable "clockin_timezone" {
  description = "Scheduler timezone expression for clockin service to work with localzone"
  type        = string
  default     = "America/Lima"
}

variable "max_scheduler_window" {
  description = "Max scheduler time window in minutes to realize the operation"
  type        = number
  default     = 5
}

variable "operation_delay" {
  description = "The max delay for the operation clock-in/out to execute after it's initated."
  type        = number
  default     = 180
}

variable "sucursal" {
  description = "The id for the specific talana branch"
  type        = string
  default     = "15327"
}

variable "ecr_repositories" {
  description = "List of ECR repositories for backend logic."
  type        = map(any)
  default = {
    clockin_service = {
      uri = "975050261044.dkr.ecr.us-east-2.amazonaws.com/clockin_automation_clockin_service"
      arn = "arn:aws:ecr:us-east-2:975050261044:repository/clockin_automation_clockin_service"
    }
  }
}