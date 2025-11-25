
# region: Secrets Manager
resource "aws_secretsmanager_secret" "config_secret" {
  name        = "${var.project_nickname}/clockin_service-secrets"
  description = "Stores API URLs and user credentials for the auto-clockin system."
}

resource "aws_secretsmanager_secret_version" "config_secret_version" {
  secret_id = aws_secretsmanager_secret.config_secret.id
  secret_string = jsonencode({
    API_LOGIN_URL   = var.api_login_url
    API_CLOCKIN_URL = var.api_clockin_url
    SUCURSAL        = var.sucursal
    USERNAME        = "john doe"
    PASSWORD        = "foo"
  })
}