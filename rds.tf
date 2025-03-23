# Create RDS PostgreSQL instance
resource "aws_db_instance" "postgres" {
  identifier             = "postgres-db-${var.environment}"
  engine                 = "postgres"
  engine_version         = "17.2"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  username               = var.db_username
  password               = var.db_password
  db_name                = var.db_name
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.default.name
  skip_final_snapshot    = true
  backup_retention_period = 0
  performance_insights_enabled = false
  deletion_protection    = false
  multi_az               = false

  tags = {
    Name = "postgres-db-${var.environment}"
  }
}

# Use default subnet group for RDS (fetching subnets from default VPC)
resource "aws_db_subnet_group" "default" {
  name       = "default-subnet-group-${var.environment}"
  subnet_ids = data.aws_subnets.public.ids

  tags = {
    Name = "default-subnet-group-${var.environment}"
  }
}