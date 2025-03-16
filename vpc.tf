# Fetch the default VPC
data "aws_vpc" "default" {
  default = true
}

# Fetch all public subnets in the default VPC
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Fetch the first public subnet from the list (for ALB & ECS networking)
data "aws_subnet" "public_a" {
  id = tolist(data.aws_subnets.public.ids)[0] # Selects the first available public subnet
}
/* 
data "aws_subnet" "public_b" {
  id = tolist(data.aws_subnets.public.ids)[1] # Second available public subnet
} */