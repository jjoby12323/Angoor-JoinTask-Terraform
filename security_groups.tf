data "aws_security_group" "django_cluster_sg" {
  id = "sg-0cd74b18e9a3fc180"
}

data "aws_security_group" "celery_cluster_sg" {
  id = "sg-0921f1274d8d97cbe"
}

# Security Group for Redis (without rules)
resource "aws_security_group" "redis" {
  name        = "redis-sg-${var.environment}"
  description = "Security group for ElastiCache Redis"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Allow Redis access from Django ECS cluster"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    security_groups = [data.aws_security_group.django_cluster_sg.id]
  }

  ingress {
    description = "Allow Redis access from Celery ECS cluster"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    security_groups = [data.aws_security_group.celery_cluster_sg.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "redis-sg-${var.environment}"
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

# ALB Inbound — HTTP from anywhere
resource "aws_security_group_rule" "alb_ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.alb_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

# ALB Outbound — to Django ECS on port 8000
resource "aws_security_group_rule" "alb_to_django_ecs" {
  type                     = "egress"
  from_port                = 8000
  to_port                  = 8000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.alb_sg.id
  source_security_group_id = data.aws_security_group.django_cluster_sg.id
}


# Security Group for RDS (allows all traffic for now)
resource "aws_security_group" "rds_sg" {
  name        = "rds-sg-${var.environment}"
  description = "Allow PostgreSQL from ECS"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description              = "Allow PostgreSQL from Django ECS"
    from_port                = 5432
    to_port                  = 5432
    protocol                 = "tcp"
    security_groups          = [data.aws_security_group.django_cluster_sg.id, data.aws_security_group.celery_cluster_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg-${var.environment}"
  }
}