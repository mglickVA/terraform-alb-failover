variable "vpc_id" {
  description = "VPC ID where ALB will be created"
  type        = string
  default     = "vpc-mock-12345"  # Default for testing
}

variable "subnet_ids" {
  description = "List of subnet IDs for ALB"
  type        = list(string)
  default     = ["subnet-mock-1", "subnet-mock-2"]  # Default for testing
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "test"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

resource "aws_security_group" "alb" {
  name        = "alb-sg-${var.environment}-${var.region}"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "alb-sg-${var.environment}-${var.region}"
    Environment = var.environment
  }
}

resource "aws_lb" "main" {
  name               = "alb-${var.environment}-${var.region}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets           = var.subnet_ids

  tags = {
    Name        = "alb-${var.environment}-${var.region}"
    Environment = var.environment
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Hello World"
      status_code  = "200"
    }
  }
}

output "alb_dns_name" {
  value = aws_lb.main.dns_name
}

output "alb_zone_id" {
  value = aws_lb.main.zone_id
}
