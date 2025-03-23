# Create the ALB
resource "aws_lb" "django_alb" {
  name               = "django-alb-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets           = data.aws_subnets.public.ids

  enable_deletion_protection = false

  tags = {
    Name = "django-alb-${var.environment}"
  }
}

# Create the ALB Target Group
resource "aws_lb_target_group" "django_tg" {
  name        = "django-tg-${var.environment}"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "instance"

  health_check {
    path                = "/api/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "django-tg-${var.environment}"
  }
}

# Create the ALB Listener for HTTP traffic
resource "aws_lb_listener" "django_http" {
  load_balancer_arn = aws_lb.django_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.django_tg.arn
  }
}