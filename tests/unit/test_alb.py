import tftest
import pytest
import os
import json
from tests.fixtures import test_vpc

def test_alb_configuration_east1(test_vpc):
    """Test ALB module configuration for us-east-1"""
    example_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'terraform')
    tf = tftest.TerraformTest(example_dir)
    
    # Setup test variables
    variables = {
        'project_name': 'test-project',
        'environment': 'test',
        'domain_name': 'example.com',
        'health_check_path': '/health/status.json',
        'vpc_cidr_east1': '10.0.0.0/16',
        'vpc_cidr_east2': '10.1.0.0/16',
        'subnet_a_cidr_east1': '10.0.1.0/24',
        'subnet_b_cidr_east1': '10.0.2.0/24',
        'subnet_a_cidr_east2': '10.1.1.0/24',
        'subnet_b_cidr_east2': '10.1.2.0/24'
    }
    
    # Set AWS provider configuration through environment variables
    os.environ.update({
        'AWS_ACCESS_KEY_ID': 'mock_access_key',
        'AWS_SECRET_ACCESS_KEY': 'mock_secret_key',
        'AWS_DEFAULT_REGION': 'us-east-1',
        'AWS_SESSION_TOKEN': 'mock_session_token'
    })
        
    # Initialize and plan
    tf.setup()
    tf.init()
    plan = tf.plan(tf_vars=variables, output=True)
    
    # Verify ALB configuration
    alb = plan.resources['module.alb_us_east_1.aws_lb.main']
    assert alb['values']['load_balancer_type'] == 'application'
    assert alb['values']['name'].startswith('alb-test-us-east-1')
    
    # Verify listener configuration
    listener = plan.resources['module.alb_us_east_1.aws_lb_listener.front_end']
    assert listener['values']['port'] == 80
    assert listener['values']['protocol'] == 'HTTP'
    
    # Verify fixed response
    default_action = listener['values']['default_action'][0]
    assert default_action['type'] == 'fixed-response'
    assert default_action['fixed_response'][0]['content_type'] == 'text/plain'
    assert default_action['fixed_response'][0]['message_body'] == 'Hello World'
    assert default_action['fixed_response'][0]['status_code'] == '200'

def test_alb_configuration_east2(test_vpc):
    """Test ALB module configuration for us-east-2"""
    example_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'terraform')
    tf = tftest.TerraformTest(example_dir)
    
    # Setup test variables
    variables = {
        'project_name': 'test-project',
        'environment': 'test',
        'domain_name': 'example.com',
        'health_check_path': '/health/status.json',
        'vpc_cidr_east1': '10.0.0.0/16',
        'vpc_cidr_east2': '10.1.0.0/16',
        'subnet_a_cidr_east1': '10.0.1.0/24',
        'subnet_b_cidr_east1': '10.0.2.0/24',
        'subnet_a_cidr_east2': '10.1.1.0/24',
        'subnet_b_cidr_east2': '10.1.2.0/24'
    }
    
    # Set AWS provider configuration through environment variables
    os.environ.update({
        'AWS_ACCESS_KEY_ID': 'mock_access_key',
        'AWS_SECRET_ACCESS_KEY': 'mock_secret_key',
        'AWS_DEFAULT_REGION': 'us-east-2',
        'AWS_SESSION_TOKEN': 'mock_session_token'
    })
        
    # Initialize and plan
    tf.setup()
    tf.init()
    plan = tf.plan(tf_vars=variables, output=True)
    
    # Verify ALB configuration
    alb = plan.resources['module.alb_us_east_2.aws_lb.main']
    assert alb['values']['load_balancer_type'] == 'application'
    assert alb['values']['name'].startswith('alb-test-us-east-2')
    
    # Verify listener configuration
    listener = plan.resources['module.alb_us_east_2.aws_lb_listener.front_end']
    assert listener['values']['port'] == 80
    assert listener['values']['protocol'] == 'HTTP'
    
    # Verify fixed response
    default_action = listener['values']['default_action'][0]
    assert default_action['type'] == 'fixed-response'
    assert default_action['fixed_response'][0]['content_type'] == 'text/plain'
    assert default_action['fixed_response'][0]['message_body'] == 'Hello World'
    assert default_action['fixed_response'][0]['status_code'] == '200'
