resource "aws_elasticache_replication_group" "redis" {
  replication_group_id       = "redis-cache-${var.environment}"
  engine                     = "redis"
  node_type                  = var.redis_node_type
  automatic_failover_enabled = false
  multi_az_enabled           = false
  security_group_ids         = [aws_security_group.redis.id]
  description = "Celery Redis sample Elasticache OSS"
  tags = {
    Name = "redis-${var.environment}"
  }
}