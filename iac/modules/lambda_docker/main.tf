
resource "aws_iam_role" "function_role" {
  name_prefix = "${var.function_name}-role"
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

resource "aws_lambda_function" "function" {
  function_name = var.function_name
  package_type  = "Image"
  image_uri     = "${var.ecr_function_repo.uri}:latest"
  role          = aws_iam_role.function_role.arn
  architectures = [var.function_architecture]
  timeout       = var.timeout
  memory_size   = var.memory_size
  tracing_config {
    mode = "Active"
  }
  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }
  environment {
    variables = var.function_env_vars
  }
}