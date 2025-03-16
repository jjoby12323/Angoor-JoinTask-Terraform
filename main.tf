/* """terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Define the VPC
resource "aws_vpc" "AngoorTaskVPC" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "Angoor-Task-VPC"
  }
}

# Define a Public Subnet (for Django)
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.AngoorTaskVPC.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public-Subnet"
  }
}

# Define a Private Subnet (for RDS & Redis)
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.AngoorTaskVPC.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "Private-Subnet"
  }
}

resource "aws_security_group" "django_sg" {
  name        = "django_sg"
  description = "Allow HTTP, HTTPS, and SSH traffic for Django server"
  vpc_id      = aws_vpc.AngoorTaskVPC.id  # Replace with your VPC ID reference

  # Allow HTTP traffic (port 80)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to all (public access)
  }

  # Allow HTTPS traffic (port 443)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to all (public access)
  }

  # Allow SSH access only from your IP (Replace YOUR_IP)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["106.222.237.100/32"]  # My IP
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Django-SG"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds_sg"
  description = "Allow PostgreSQL access only from Django and Celery"
  vpc_id      = aws_vpc.AngoorTaskVPC.id  # Replace with your VPC ID reference

  # Allow PostgreSQL access from Django and Celery instances
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_security_group.django_sg.id]  # Django can access DB
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_security_group.celery_sg.id]  # Celery can access DB
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RDS-SG"
  }
}

resource "aws_security_group" "redis_sg" {
  name        = "redis_sg"
  description = "Allow Redis access only from Django and Celery"
  vpc_id      = aws_vpc.AngoorTaskVPC.id  # Replace with your VPC ID reference

  # Allow Redis access from Django
  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    security_groups = [aws_security_group.django_sg.id]  # Django can access Redis
  }

  # Allow Redis access from Celery
  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    security_groups = [aws_security_group.celery_sg.id]  # Celery can access Redis
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Redis-SG"
  }
}

# Security Group for Celery Workers
resource "aws_security_group" "celery_sg" {
  name        = "celery_sg"
  description = "Allow Celery workers to communicate with Django, RDS, and Redis"
  vpc_id      = aws_vpc.AngoorTaskVPC.id

  # Allow outbound connections to Redis and RDS
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Celery-SG"
  }
}""" */