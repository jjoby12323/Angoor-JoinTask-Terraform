# Fetch the latest image tag from ECR dynamically
data "aws_ecr_image" "django_latest" {
  repository_name = "django-app-dev"
  most_recent     = true
}

data "aws_ecr_image" "celery_latest" {
  repository_name = "celery-worker-dev"
  most_recent     = true
}

# Fetch Existing ECS Task Execution Role
data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

# Create ECS Clusters
resource "aws_ecs_cluster" "django" {
  name = "django-cluster-${var.environment}"
}

resource "aws_ecs_cluster" "celery" {
  name = "celery-cluster-${var.environment}"
}

# Create CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "django_logs" {
  name = "/ecs/django-server"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "celery_logs" {
  name = "/ecs/celery-workers"
  retention_in_days = 7
}

# Create Task Definitions with Log Collection
resource "aws_ecs_task_definition" "django" {
  family                   = "django-task-${var.environment}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = "512"
  cpu                      = "256"
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "django-server"
      image = "${data.aws_ecr_repository.django_repo.repository_url}@${data.aws_ecr_image.django_latest.image_digest}"
      memory = 512
      cpu = 256
      essential = true
      portMappings = [{
        containerPort = 8000
        hostPort      = 8000
        protocol      = "tcp"
      }]
      environment = [
        {
          name  = "CELERY_BROKER_URL"
          value = "redis://${aws_elasticache_replication_group.redis.primary_endpoint_address}/0"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/django-server"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "celery" {
  family                   = "celery-task-${var.environment}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = "512"
  cpu                      = "256"
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "celery-workers"
      image = "${data.aws_ecr_repository.celery_repo.repository_url}@${data.aws_ecr_image.celery_latest.image_digest}"
      memory = 512
      cpu = 256
      essential = true
      environment = [
        {
          name  = "CELERY_BROKER_URL"
          value = "redis://${aws_elasticache_replication_group.redis.primary_endpoint_address}/0"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/celery-workers"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

# ECS Services
resource "aws_ecs_service" "django" {
  name            = "django-service-${var.environment}"
  cluster         = aws_ecs_cluster.django.id
  task_definition = aws_ecs_task_definition.django.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [data.aws_subnet.public_a.id]
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
}

resource "aws_ecs_service" "celery" {
  name            = "celery-service-${var.environment}"
  cluster         = aws_ecs_cluster.celery.id
  task_definition = aws_ecs_task_definition.celery.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [data.aws_subnet.public_a.id]
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
}