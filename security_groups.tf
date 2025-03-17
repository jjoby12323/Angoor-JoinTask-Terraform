# Security Group for ElastiCache Redis
resource "aws_security_group" "redis" {
  name        = "redis-sg-${var.environment}"
  description = "Security group for ElastiCache Redis"
  vpc_id      = data.aws_vpc.default.id  # Attach to default VPC

  # Allow inbound Redis traffic (port 6379) from within the VPC
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "redis-sg-${var.environment}"
  }
}

# Security Group for ECS Tasks
resource "aws_security_group" "ecs_sg" {
  name        = "ecs-sg-${var.environment}"
  description = "Security group for ECS tasks"
  vpc_id      = data.aws_vpc.default.id

  # Allow inbound traffic from ALB (Port 8000)
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic (ECS tasks need external access)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs-sg-${var.environment}"
  }
}

# Security Group for ALB
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg-${var.environment}"
  description = "Security group for ALB"
  vpc_id      = data.aws_vpc.default.id

  # Allow HTTP traffic from anywhere (you can restrict later)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg-${var.environment}"
  }
}
