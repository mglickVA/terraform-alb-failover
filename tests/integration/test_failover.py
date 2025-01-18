import tftest
import pytest
from tests.fixtures import test_vpc, alb_failover

def test_failover_configuration(alb_failover):
    """Test complete failover configuration"""
    tf, variables = alb_failover
    
    # Plan the configuration using new test terraform directory
    tf.setup()
    tf.init()
    plan = tf.plan(tf_vars=variables, output=True)
    
    # Verify ALB configurations
    alb_east1 = plan.resources['module.alb_failover.module.alb_us_east_1.aws_lb.main']
    alb_east2 = plan.resources['module.alb_failover.module.alb_us_east_2.aws_lb.main']
    
    assert alb_east1['values']['name'].startswith('alb-test-us-east-1')
    assert alb_east2['values']['name'].startswith('alb-test-us-east-2')
    
    # Verify S3 bucket configuration
    bucket = plan.resources['module.alb_failover.module.s3_bucket.aws_s3_bucket.main']
    assert bucket['values']['bucket'] == f"{variables['project_name']}-{variables['environment']}-status"
    
    # Verify Route53 configuration
    primary_record = plan.resources['module.alb_failover.module.route53.aws_route53_record.primary']
    secondary_record = plan.resources['module.alb_failover.module.route53.aws_route53_record.secondary']
    
    assert primary_record['values']['failover_routing_policy'][0]['type'] == 'PRIMARY'
    assert secondary_record['values']['failover_routing_policy'][0]['type'] == 'SECONDARY'
    
    # Verify health check configuration
    health_check = plan.resources['module.alb_failover.module.route53.aws_route53_health_check.failover']
    assert health_check['values']['type'] == 'HTTPS'
    assert health_check['values']['invert_healthcheck'] is True

def test_vpc_integration(test_vpc):
    """Test VPC outputs are properly integrated"""
    assert test_vpc['vpc_id_east1'] is not None
    assert test_vpc['vpc_id_east2'] is not None
    assert len(test_vpc['subnet_ids_east1']) == 2
    assert len(test_vpc['subnet_ids_east2']) == 2
