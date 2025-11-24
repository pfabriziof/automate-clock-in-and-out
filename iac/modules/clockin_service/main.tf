
# region: lambda function
module "clockin_service" {
  source        = "../lambda_docker"
  ecr_function_repo = var.ecr_repositories["clockin_service"]
  function_name = "${var.project_nickname}-clockin-service"
  function_env_vars = {
    SECRET_ARN = aws_secretsmanager_secret.config_secret.arn
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

# region: clockin rule
resource "aws_cloudwatch_event_rule" "clockin_rule" {
  name                = "${var.project_nickname}-clockin-schedule"
  description         = "Schedule to trigger check-in action."
  schedule_expression = var.clockin_cron # e.g., cron(0 8 * * ? *)
}

resource "aws_cloudwatch_event_target" "clockin_target" {
  rule = aws_cloudwatch_event_rule.clockin_rule.name
  arn  = module.clockin_service.function.arn
  input = jsonencode({
    detail = {
      operation = "check_in"
    }
  })
}

# region: clockout rule
resource "aws_cloudwatch_event_rule" "clockout_rule" {
  name                = "${var.project_nickname}-clockout-schedule"
  description         = "Schedule to trigger check-out action."
  schedule_expression = var.clockout_cron # e.g., cron(0 19 * * ? *)
}

resource "aws_cloudwatch_event_target" "clockout_target" {
  rule = aws_cloudwatch_event_rule.clockout_rule.name
  arn  = module.clockin_service.function.arn
  input = jsonencode({
    detail = {
      operation = "check_out"
    }
  })
}

# region: eventbridge permissions to invoke lambda
resource "aws_lambda_permission" "allow_eventbridge_clockin" {
  statement_id  = "AllowExecutionFromEventBridgeClockIn"
  action        = "lambda:InvokeFunction"
  function_name = module.clockin_service.function.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.clockin_rule.arn
}

resource "aws_lambda_permission" "allow_eventbridge_clockout" {
  statement_id  = "AllowExecutionFromEventBridgeClockOut"
  action        = "lambda:InvokeFunction"
  function_name = module.clockin_service.function.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.clockout_rule.arn
}