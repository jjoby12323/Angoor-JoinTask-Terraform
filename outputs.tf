/* """output "vpc_id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.AngoorTaskVPC.id
}

output "public_subnet_id" {
  description = "The ID of the public subnet"
  value       = aws_subnet.public_subnet.id
}

output "private_subnet_id" {
  description = "The ID of the private subnet"
  value       = aws_subnet.private_subnet.id
}

output "redis_primary_endpoint" {
  description = "Primary endpoint of Elasticache Redis"
  value       = aws_elasticache_replication_group.redis.primary_endpoint_address
}""" */

/* """output "django_ecr_url" {
  value = aws_ecr_repository.django_repo.repository_url
}

output "celery_ecr_url" {
  value = aws_ecr_repository.celery_repo.repository_url
}

output "alb_dns" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.django_alb.dns_name
}""" */