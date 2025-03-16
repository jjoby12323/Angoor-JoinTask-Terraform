# ECR repository for Django app
resource "aws_ecr_repository" "django_repo" {
  name = "django-app-${var.environment}"

  tags = {
    Name        = "django-app-${var.environment}"
    Environment = var.environment
  }
}

# ECR repository for Celery workers
resource "aws_ecr_repository" "celery_repo" {
  name = "celery-worker-${var.environment}"

  tags = {
    Name        = "celery-worker-${var.environment}"
    Environment = var.environment
  }
}