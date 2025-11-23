
# region: Lambda function
resource "aws_lambda_function" "clockin_lambda" {
  function_name = "${var.project_nickname}-main-handler"
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.lambda_ecr_repo.repository_url}:latest"
  role          = aws_iam_role.lambda_exec_role.arn
  timeout       = 30

  environment {
    variables = {
      SECRET_ARN = aws_secretsmanager_secret.config_secret.arn
    }
  }

  tags = {
    owner   = "the-pragmatic-programmer"
    project = "clockin-automation"
  }
}

# region: clockin rule
resource "aws_cloudwatch_event_rule" "clockin_rule" {
  name                = "${var.project_nickname}-clockin-schedule"
  description         = "Schedule to trigger check-in action."
  schedule_expression = var.clockin_cron # e.g., cron(0 8 * * ? *)
}

resource "aws_cloudwatch_event_target" "clockin_target" {
  rule = aws_cloudwatch_event_rule.clockin_rule.name
  arn  = aws_lambda_function.clockin_lambda.arn
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
  arn  = aws_lambda_function.clockin_lambda.arn
  input = jsonencode({
    detail = {
      operation = "check_out"
    }
  })
}

# region: eventbridge permissions to invoke lambda
resource "aws_lambda_permission" "allow_eventbridge_clocking" {
  statement_id  = "AllowExecutionFromEventBridgeClockIn"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.clockin_lambda.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.clockin_rule.arn
}

resource "aws_lambda_permission" "allow_eventbridge_clocking" {
  statement_id  = "AllowExecutionFromEventBridgeClockOut"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.clockin_lambda.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.clockout_rule.arn
}