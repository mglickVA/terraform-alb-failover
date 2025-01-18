variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "test-alb-failover"
}

variable "environment" {
  description = "Environment (dev/staging/prod)"
  type        = string
  default     = "test"
}

variable "domain_name" {
  description = "Domain name for Route53 records"
  type        = string
  default     = "example.com"
}

variable "health_check_path" {
  description = "Path in S3 bucket to check for health status"
  type        = string
  default     = "/health/status.json"
}

# VPC Configuration for us-east-1
variable "vpc_cidr_east1" {
  description = "CIDR block for VPC in us-east-1"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_a_cidr_east1" {
  description = "CIDR block for subnet A in us-east-1"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_b_cidr_east1" {
  description = "CIDR block for subnet B in us-east-1"
  type        = string
  default     = "10.0.2.0/24"
}

# VPC Configuration for us-east-2
variable "vpc_cidr_east2" {
  description = "CIDR block for VPC in us-east-2"
  type        = string
  default     = "10.1.0.0/16"
}

variable "subnet_a_cidr_east2" {
  description = "CIDR block for subnet A in us-east-2"
  type        = string
  default     = "10.1.1.0/24"
}

variable "subnet_b_cidr_east2" {
  description = "CIDR block for subnet B in us-east-2"
  type        = string
  default     = "10.1.2.0/24"
}
