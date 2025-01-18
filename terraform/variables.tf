variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "alb-failover-demo"
}

variable "environment" {
  description = "Environment (dev/staging/prod)"
  type        = string
  default     = "dev"
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

variable "vpc_id_east1" {
  description = "ID of the pre-existing VPC in us-east-1"
  type        = string
}

variable "vpc_id_east2" {
  description = "ID of the pre-existing VPC in us-east-2"
  type        = string
}

variable "subnet_ids_east1" {
  description = "List of pre-existing subnet IDs in us-east-1"
  type        = list(string)
}

variable "subnet_ids_east2" {
  description = "List of pre-existing subnet IDs in us-east-2"
  type        = list(string)
}
