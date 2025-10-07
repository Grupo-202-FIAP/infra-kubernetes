output "db_url" {
  value     = data.aws_ssm_parameter.db_url.value
  sensitive = true
}

output "db_user" {
  value     = data.aws_ssm_parameter.db_user.value
  sensitive = true
}

output "db_pass" {
  value     = data.aws_ssm_parameter.db_pass.value
  sensitive = true
}