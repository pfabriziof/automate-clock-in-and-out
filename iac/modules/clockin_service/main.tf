
# region: lambda function
module "clockin_service" {
  source            = "../lambda_docker"
  ecr_function_repo = var.ecr_repositories["clockin_service"]
  function_name     = "${var.project_nickname}-clockin-service"
  function_env_vars = {
    SECRET_ARN      = aws_secretsmanager_secret.config_secret.arn
  }
  additional_policy_arns = [
    aws_iam_policy.lambda_logging_policy.arn,
    aws_iam_policy.lambda_secret_read_policy.arn
  ]
}

# Policy to manage logging for lambda.
resource "aws_iam_policy" "lambda_logging_policy" {
  name_prefix = "${var.project_nickname}-loggin-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
      ]
      Effect   = "Allow"
      Resource = "arn:aws:logs:${var.region}:*:*"
    }]
  })
}

# Policy for lambda to read secrets
resource "aws_iam_policy" "lambda_secret_read_policy" {
  name_prefix = "${var.project_nickname}-secret-read"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret",
      ]
      Effect   = "Allow"
      Resource = aws_secretsmanager_secret.config_secret.arn
    }]
  })
}

# region: clockin scheduler
# role and policy for eventbridge
resource "aws_iam_role" "scheduler_role" {
  name = "${var.project_nickname}-scheduler-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "scheduler.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "scheduler_lambda_policy" {
  name = "${var.project_nickname}-scheduler-lambda-policy"
  role = aws_iam_role.scheduler_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "lambda:InvokeFunction",
        ]
        Effect   = "Allow"
        Resource = [
          module.clockin_service.function.arn,
          "${module.clockin_service.function.arn}:*"
        ]
      },
    ]
  })
}


# clockin schedulers
resource "aws_scheduler_schedule" "clockin_scheduler" {
  name       = "${var.project_nickname}-clockin-schedule"
  group_name = "${var.project_nickname}-schedule-group"

  flexible_time_window {
    maximum_window_in_minutes = var.max_scheduler_window
    mode = "FLEXIBLE"
  }

  schedule_expression = var.clockin_cron

  target {
    arn      = module.clockin_service.function.arn
    role_arn = aws_iam_role.scheduler_role.arn
    input = jsonencode({
      operation = "clock_in"
    })
  }
}

resource "aws_scheduler_schedule" "clockout_scheduler" {
  name       = "${var.project_nickname}-clockout-schedule"
  group_name = "${var.project_nickname}-schedule-group"

  flexible_time_window {
    maximum_window_in_minutes = var.max_scheduler_window
    mode = "FLEXIBLE"
  }

  schedule_expression = var.clockin_cron

  target {
    arn      = module.clockin_service.function.arn
    role_arn = aws_iam_role.scheduler_role.arn
    input = jsonencode({
      operation = "clock_out"
    })
  }
}

resource "aws_scheduler_schedule" "clockout_fridays_scheduler" {
  name       = "${var.project_nickname}-clockout-fridays-schedule"
  group_name = "${var.project_nickname}-schedule-group"

  flexible_time_window {
    maximum_window_in_minutes = var.max_scheduler_window
    mode = "FLEXIBLE"
  }

  schedule_expression = var.clockin_cron

  target {
    arn      = module.clockin_service.function.arn
    role_arn = aws_iam_role.scheduler_role.arn
    input = jsonencode({
      operation = "clock_out"
    })
  }
}