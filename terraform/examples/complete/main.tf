# VPC Infrastructure and ALB Failover Example

# VPC and Networking for us-east-1
resource "aws_vpc" "us_east_1" {
  provider             = aws.us_east_1
  cidr_block           = var.vpc_cidr_east1
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name        = "vpc-${var.environment}-us-east-1"
    Environment = var.environment
  }
}

resource "aws_internet_gateway" "us_east_1" {
  provider = aws.us_east_1
  vpc_id   = aws_vpc.us_east_1.id

  tags = {
    Name        = "igw-${var.environment}-us-east-1"
    Environment = var.environment
  }
}

resource "aws_route_table" "us_east_1" {
  provider = aws.us_east_1
  vpc_id   = aws_vpc.us_east_1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.us_east_1.id
  }

  tags = {
    Name        = "rt-${var.environment}-us-east-1"
    Environment = var.environment
  }
}

resource "aws_subnet" "us_east_1_a" {
  provider          = aws.us_east_1
  vpc_id            = aws_vpc.us_east_1.id
  cidr_block        = var.subnet_a_cidr_east1
  availability_zone = "us-east-1a"
  
  tags = {
    Name        = "subnet-${var.environment}-us-east-1a"
    Environment = var.environment
  }
}

resource "aws_subnet" "us_east_1_b" {
  provider          = aws.us_east_1
  vpc_id            = aws_vpc.us_east_1.id
  cidr_block        = var.subnet_b_cidr_east1
  availability_zone = "us-east-1b"
  
  tags = {
    Name        = "subnet-${var.environment}-us-east-1b"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "us_east_1_a" {
  provider       = aws.us_east_1
  subnet_id      = aws_subnet.us_east_1_a.id
  route_table_id = aws_route_table.us_east_1.id
}

resource "aws_route_table_association" "us_east_1_b" {
  provider       = aws.us_east_1
  subnet_id      = aws_subnet.us_east_1_b.id
  route_table_id = aws_route_table.us_east_1.id
}

# VPC and Networking for us-east-2
resource "aws_vpc" "us_east_2" {
  provider             = aws.us_east_2
  cidr_block           = var.vpc_cidr_east2
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name        = "vpc-${var.environment}-us-east-2"
    Environment = var.environment
  }
}

resource "aws_internet_gateway" "us_east_2" {
  provider = aws.us_east_2
  vpc_id   = aws_vpc.us_east_2.id

  tags = {
    Name        = "igw-${var.environment}-us-east-2"
    Environment = var.environment
  }
}

resource "aws_route_table" "us_east_2" {
  provider = aws.us_east_2
  vpc_id   = aws_vpc.us_east_2.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.us_east_2.id
  }

  tags = {
    Name        = "rt-${var.environment}-us-east-2"
    Environment = var.environment
  }
}

resource "aws_subnet" "us_east_2_a" {
  provider          = aws.us_east_2
  vpc_id            = aws_vpc.us_east_2.id
  cidr_block        = var.subnet_a_cidr_east2
  availability_zone = "us-east-2a"
  
  tags = {
    Name        = "subnet-${var.environment}-us-east-2a"
    Environment = var.environment
  }
}

resource "aws_subnet" "us_east_2_b" {
  provider          = aws.us_east_2
  vpc_id            = aws_vpc.us_east_2.id
  cidr_block        = var.subnet_b_cidr_east2
  availability_zone = "us-east-2b"
  
  tags = {
    Name        = "subnet-${var.environment}-us-east-2b"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "us_east_2_a" {
  provider       = aws.us_east_2
  subnet_id      = aws_subnet.us_east_2_a.id
  route_table_id = aws_route_table.us_east_2.id
}

resource "aws_route_table_association" "us_east_2_b" {
  provider       = aws.us_east_2
  subnet_id      = aws_subnet.us_east_2_b.id
  route_table_id = aws_route_table.us_east_2.id
}

# ALB Failover Infrastructure
module "alb_failover" {
  source = "../../"

  providers = {
    aws.us_east_1 = aws.us_east_1
    aws.us_east_2 = aws.us_east_2
  }

  project_name      = var.project_name
  environment       = var.environment
  domain_name       = var.domain_name
  health_check_path = var.health_check_path

  vpc_id_east1     = aws_vpc.us_east_1.id
  vpc_id_east2     = aws_vpc.us_east_2.id
  subnet_ids_east1 = [aws_subnet.us_east_1_a.id, aws_subnet.us_east_1_b.id]
  subnet_ids_east2 = [aws_subnet.us_east_2_a.id, aws_subnet.us_east_2_b.id]
}

# Outputs
output "vpc_id_east1" {
  value = aws_vpc.us_east_1.id
}

output "vpc_id_east2" {
  value = aws_vpc.us_east_2.id
}

output "subnet_ids_east1" {
  value = [aws_subnet.us_east_1_a.id, aws_subnet.us_east_1_b.id]
}

output "subnet_ids_east2" {
  value = [aws_subnet.us_east_2_a.id, aws_subnet.us_east_2_b.id]
}

output "primary_alb_dns" {
  value = module.alb_failover.primary_alb_dns
}

output "secondary_alb_dns" {
  value = module.alb_failover.secondary_alb_dns
}

output "api_gateway_url" {
  value = module.alb_failover.api_gateway_url
}

output "s3_bucket_name" {
  value = module.alb_failover.s3_bucket_name
}

output "route53_primary_record" {
  value = module.alb_failover.route53_primary_record
}

output "route53_secondary_record" {
  value = module.alb_failover.route53_secondary_record
}
