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