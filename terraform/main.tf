# Use pre-existing VPC and subnet IDs for both regions

# ALB in us-east-1 (Primary)
module "alb_us_east_1" {
  source = "./modules/alb"
  vpc_id      = var.vpc_id_east1
  subnet_ids  = var.subnet_ids_east1
  environment = var.environment
  region      = "us-east-1"
}

# ALB in us-east-2 (Secondary)
module "alb_us_east_2" {
  source = "./modules/alb"
  vpc_id      = var.vpc_id_east2
  subnet_ids  = var.subnet_ids_east2
  environment = var.environment
  region      = "us-east-2"
}

# S3 Bucket in us-east-2
module "s3_bucket" {
  source = "./modules/s3"
  bucket_name  = "${var.project_name}-${var.environment}-status"
  environment = var.environment
}

# API Gateway in us-east-2
module "api_gateway" {
  source = "./modules/api_gateway"
  environment    = var.environment
  s3_bucket_name = module.s3_bucket.bucket_name
  s3_bucket_path = var.health_check_path
}

# Route53 Failover Configuration
module "route53" {
  source = "./modules/route53"
  domain_name            = var.domain_name
  primary_alb_dns_name   = module.alb_us_east_1.alb_dns_name
  primary_alb_zone_id    = module.alb_us_east_1.alb_zone_id
  secondary_alb_dns_name = module.alb_us_east_2.alb_dns_name
  secondary_alb_zone_id  = module.alb_us_east_2.alb_zone_id
  api_gateway_url        = module.api_gateway.api_gateway_url
}

output "primary_alb_dns" {
  value = module.alb_us_east_1.alb_dns_name
}

output "secondary_alb_dns" {
  value = module.alb_us_east_2.alb_dns_name
}

output "api_gateway_url" {
  value = module.api_gateway.api_gateway_url
}

output "s3_bucket_name" {
  value = module.s3_bucket.bucket_name
}

output "route53_primary_record" {
  value = module.route53.primary_record_name
}

output "route53_secondary_record" {
  value = module.route53.secondary_record_name
}
