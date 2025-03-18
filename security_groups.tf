# Security Group for Redis (without rules)
resource "aws_security_group" "redis" {
  name        = "redis-sg-${var.environment}"
  description = "Security group for ElastiCache Redis"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "redis-sg-${var.environment}"
  }
}

# Security Group for ECS Tasks (without rules)
resource "aws_security_group" "ecs_sg" {
  name        = "ecs-sg-${var.environment}"
  description = "Security group for ECS tasks"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "ecs-sg-${var.environment}"
  }
}

# Security Group for ALB (without rules)
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg-${var.environment}"
  description = "Security group for ALB"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "alb-sg-${var.environment}"
  }
}


# Allow ECS tasks to access Redis
resource "aws_security_group_rule" "redis_ingress" {
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  security_group_id        = aws_security_group.redis.id
  source_security_group_id = aws_security_group.ecs_sg.id  # Allow only ECS
}

# Allow ALB to send traffic to ECS on port 8000
resource "aws_security_group_rule" "ecs_ingress" {
  type                     = "ingress"
  from_port                = 8000
  to_port                  = 8000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs_sg.id
  source_security_group_id = aws_security_group.alb_sg.id  # Allow only ALB
}

# Allow ECS to connect to Redis
resource "aws_security_group_rule" "ecs_to_redis_egress" {
  type                     = "egress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs_sg.id
  source_security_group_id = aws_security_group.redis.id  # ECS to Redis
}

# Allow ECS outbound traffic to the internet (for external APIs, logging, etc.)
resource "aws_security_group_rule" "ecs_outbound_https" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.ecs_sg.id
  cidr_blocks       = ["0.0.0.0/0"]  # Allow external requests
}

# Allow HTTP traffic from anywhere to ALB
resource "aws_security_group_rule" "alb_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.alb_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

# Allow ALB to send requests to ECS
resource "aws_security_group_rule" "alb_to_ecs_egress" {
  type                     = "egress"
  from_port                = 8000
  to_port                  = 8000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.alb_sg.id
  source_security_group_id = aws_security_group.ecs_sg.id
}