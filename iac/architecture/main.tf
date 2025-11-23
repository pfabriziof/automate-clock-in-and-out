
# region: ECR for Docker Image
resource "aws_ecr_repository" "lambda_ecr_repo" {
  name                 = "${var.project_nickname}-lambda-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# region: Secrets Manager
resource "aws_secretsmanager_secret" "config_secret" {
  name        = "${var.project_nickname}-secrets"
  description = "Stores API URLs and user credentials for the auto-clockin system."
}

resource "aws_secretsmanager_secret_version" "config_secret_version" {
  secret_id = aws_secretsmanager_secret.config_secret.id
  secret_string = jsonencode({
    API_LOGIN_URL   = var.api_login_url
    API_CLOCKIN_URL = var.api_clockin_url
    USER_USERNAME   = "john doe"
    USER_PASSWORD   = "foo"
  })
}

# region: Lambda Policies
resource "aws_iam_role" "lambda_exec_role" {
  name_prefix = "${var.project_nickname}-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
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

resource "aws_iam_role_policy_attachment" "lambda_logging_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_logging_policy.arn
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

resource "aws_iam_role_policy_attachment" "lambda_secret_read_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_secret_read_policy.arn
}

# Basic policy for pulling images from ECR
resource "aws_iam_role_policy_attachment" "lambda_ecr_policy_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# region: Lambda function
resource "aws_lambda_function" "checkin_lambda" {
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