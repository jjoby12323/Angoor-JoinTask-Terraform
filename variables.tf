variable "redis_node_type" {
  description = "Instance type for Elasticache Redis"
  type        = string
  default     = "cache.t3.micro"
}

variable "environment" {
  description = "Deployment environment (staging/production)"
  type        = string
}

variable "aws_region" {
  default = "us-east-1"
}

variable "db_username" {
  description = "Master username for RDS"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Master password for RDS"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Database Name inside RDS Postgres instance"
  type        = string
  sensitive   = true
}

variable "db_port" {
  description = "PostgreSQL port"
  type        = number
  default     = 5432
}