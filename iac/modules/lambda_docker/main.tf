
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
  tags = {
    owner = var.owner_tag
    project = var.project_tag
  }
}

resource "aws_iam_policy" "ecr_policy" {
  name = "${var.function_name}-ecr-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:DescribeRepositories",
          "ecr:GetAuthorizationToken",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:ListImages",
          "ecr:SetRepositoryPolicy"
        ]
        Sid      = "LambdaGetImage"
        Effect   = "Allow"
        Resource = "${var.ecr_function_repo.arn}"
      },
    ]
  })
  tags = {
    name = "${var.function_name}-ecr-policy"
    owner = var.owner_tag
    project = var.function_name
  }
}

resource "aws_iam_role_policy_attachments_exclusive" "lambda_managed" {
  role_name = aws_iam_role.function_role.name
  policy_arns = concat(
    [
      "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
      "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess",
      aws_iam_policy.ecr_policy.arn,
    ],
    var.additional_policy_arns,
  )
}

resource "aws_lambda_function" "clockin_lambda" {
  function_name = "${var.project_nickname}-main-handler"
  package_type  = "Image"
  image_uri     = "${var.ecr_function_repo.uri}:latest"
  role          = aws_iam_role.lambda_exec_role.arn
  timeout       = 30

  environment {
    variables = {
      SECRET_ARN = aws_secretsmanager_secret.config_secret.arn
    }
  }

  tags = {
    owner   = var.owner_tag
    project = var.project_tag
  }
}