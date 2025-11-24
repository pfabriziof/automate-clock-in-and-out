
module "clockin_service" {
  source           = "../modules/clockin_service"
  region           = var.region
  project_nickname = var.project_nickname
  ecr_repositories = var.ecr_repositories
  api_login_url = var.api_login_url
  api_clockin_url = var.api_clockin_url
}
