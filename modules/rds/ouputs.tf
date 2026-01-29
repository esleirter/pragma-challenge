output "rds_username" {
  value       = "admin"
  description = "The username for the RDS database"
}

output "rds_password" {
  value       = random_password.password.result
  description = "The password for the RDS database"
  sensitive   = true
}

output "rds_dns_name" {
  value       = aws_rds_cluster.aurora_mysql.endpoint
  description = "The DNS name of the RDS database"
}
