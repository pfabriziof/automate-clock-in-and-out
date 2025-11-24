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

variable "api_login_url" {
  description = "The full API endpoint URL for user login."
  type        = string
}

variable "api_clockin_url" {
  description = "The full API endpoint URL for clocking in."
  type        = string
}

variable "owner_tag" {
  description = "owner tag for the resources deployed"
  type        = string
  default     = "the-pragmatic-programmer"
}

variable "project_tag" {
  description = "owner tag for the resources deployed"
  type        = string
  default     = "clockin-automation"
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