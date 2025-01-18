variable "domain_name" {
  description = "Domain name for Route53 records"
  type        = string
}

variable "primary_alb_dns_name" {
  description = "DNS name of the primary ALB"
  type        = string
}

variable "primary_alb_zone_id" {
  description = "Zone ID of the primary ALB"
  type        = string
}

variable "secondary_alb_dns_name" {
  description = "DNS name of the secondary ALB"
  type        = string
}

variable "secondary_alb_zone_id" {
  description = "Zone ID of the secondary ALB"
  type        = string
}

variable "api_gateway_url" {
  description = "URL of the API Gateway endpoint to health check"
  type        = string
}

resource "aws_route53_health_check" "failover" {
  fqdn              = replace(var.api_gateway_url, "https://", "")
  port              = 443
  type              = "HTTPS_STR_MATCH"  # Use string matching for more control
  resource_path     = "/"
  failure_threshold = "3"
  request_interval  = "30"
  search_string     = "healthy"  # Look for "healthy" in the response
  invert_healthcheck = true  # Invert the health check result

  tags = {
    Name = "failover-health-check"
  }
}

resource "aws_route53_zone" "primary" {
  name = var.domain_name
  
  tags = {
    Environment = "test"
  }
}

resource "aws_route53_record" "primary" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = var.domain_name
  type    = "A"

  failover_routing_policy {
    type = "PRIMARY"
  }

  set_identifier = "primary"
  health_check_id = aws_route53_health_check.failover.id

  alias {
    name                   = var.primary_alb_dns_name
    zone_id               = var.primary_alb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "secondary" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = var.domain_name
  type    = "A"

  failover_routing_policy {
    type = "SECONDARY"
  }

  set_identifier = "secondary"

  alias {
    name                   = var.secondary_alb_dns_name
    zone_id               = var.secondary_alb_zone_id
    evaluate_target_health = true
  }
}

output "primary_record_name" {
  value = aws_route53_record.primary.name
}

output "secondary_record_name" {
  value = aws_route53_record.secondary.name
}
