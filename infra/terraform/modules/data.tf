# Data sources para buscar os valores
data "aws_ssm_parameter" "db_url" {
  name = var.db_url_parameter
}

data "aws_ssm_parameter" "db_user" {
  name = var.db_user_parameter
}

data "aws_ssm_parameter" "db_pass" {
  name = var.db_pass_parameter
}