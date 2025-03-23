# Fetch the latest image tag from ECR dynamically

data "aws_ecr_repository" "django_repo" {
  name = "django-app-dev"
}

data "aws_ecr_repository" "celery_repo" {
  name = "celery-worker-dev"
}

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

# # Create ECS Clusters
# resource "aws_ecs_cluster" "django" {
#   name = "django-cluster-${var.environment}"
# }

# resource "aws_ecs_cluster" "celery" {
#   name = "celery-cluster-${var.environment}"
# }

# Create CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "django_logs" {
  name = "/ecs/django-server"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "celery_logs" {
  name = "/ecs/celery-workers"
  retention_in_days = 7
}

# Reference existing Django ECS cluster
data "aws_ecs_cluster" "django" {
  cluster_name = "Django-Cluster-vEC2"
}

# Reference existing Celery ECS cluster
data "aws_ecs_cluster" "celery" {
  cluster_name = "Celery-Cluster-vEC2"
}

# Updated Task Definition - Django
resource "aws_ecs_task_definition" "django" {
  family                   = "django-task-${var.environment}"
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  memory                   = "512"
  cpu                      = "1024"
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name      = "django-server"
    image     = "${data.aws_ecr_repository.django_repo.repository_url}@${data.aws_ecr_image.django_latest.image_digest}"
    memory    = 512
    cpu       = 1024
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
        },
        {
            name  = "POSTGRES_DB"
            value = var.db_name
        },
        {
            name  = "POSTGRES_USER"
            value = var.db_username
        },
        {
            name  = "POSTGRES_PASSWORD"
            value = var.db_password
        },
        {
            name  = "POSTGRES_HOST"
            value = aws_db_instance.postgres.address
        },
        {
            name  = "POSTGRES_PORT"
            value = tostring(var.db_port)
        },
        {
            name  = "ALLOWED_HOSTS"
            value = aws_lb.django_alb.dns_name
        }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.django_logs.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}

# Updated Task Definition - Celery
resource "aws_ecs_task_definition" "celery" {
  family                   = "celery-task-${var.environment}"
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  memory                   = "512"
  cpu                      = "1024"
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name      = "celery-workers"
    image     = "${data.aws_ecr_repository.celery_repo.repository_url}@${data.aws_ecr_image.celery_latest.image_digest}"
    memory    = 512
    cpu       = 1024
    essential = true
    environment = [
        {
            name  = "CELERY_BROKER_URL"
            value = "redis://${aws_elasticache_replication_group.redis.primary_endpoint_address}/0"
        },
        {
            name  = "POSTGRES_DB"
            value = var.db_name
        },
        {
            name  = "POSTGRES_USER"
            value = var.db_username
        },
        {
            name  = "POSTGRES_PASSWORD"
            value = var.db_password
        },
        {
            name  = "POSTGRES_HOST"
            value = aws_db_instance.postgres.address
        },
        {
            name  = "POSTGRES_PORT"
            value = tostring(var.db_port)
        },
        {
            name  = "ALLOWED_HOSTS"
            value = aws_lb.django_alb.dns_name
        }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.celery_logs.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}

# ECS Service - Django
resource "aws_ecs_service" "django" {
  name            = "django-service-${var.environment}"
  cluster         = data.aws_ecs_cluster.django.id
  task_definition = aws_ecs_task_definition.django.arn
  desired_count   = 1
  launch_type     = "EC2"

  load_balancer {
    target_group_arn = aws_lb_target_group.django_tg.arn
    container_name   = "django-server"
    container_port   = 8000
  }

  depends_on = [aws_lb_listener.django_http]
}

# ECS Service - Celery (no load balancer needed)
resource "aws_ecs_service" "celery" {
  name            = "celery-service-${var.environment}"
  cluster         = data.aws_ecs_cluster.celery.id
  task_definition = aws_ecs_task_definition.celery.arn
  desired_count   = 1
  launch_type     = "EC2"
}