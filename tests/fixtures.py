import os
import json
import tftest
import pytest

@pytest.fixture(scope="session")
def test_vpc():
    """Setup test VPC configuration"""
    example_dir = os.path.join(os.path.dirname(__file__), 'terraform')
    tf = tftest.TerraformTest(example_dir)
    
    # Setup test variables
    variables = {
        'environment': 'test',
        'vpc_cidr_east1': '10.0.0.0/16',
        'vpc_cidr_east2': '10.1.0.0/16',
        'subnet_a_cidr_east1': '10.0.1.0/24',
        'subnet_b_cidr_east1': '10.0.2.0/24',
        'subnet_a_cidr_east2': '10.1.1.0/24',
        'subnet_b_cidr_east2': '10.1.2.0/24'
    }
    
    # Set environment variables for AWS mocking
    os.environ.update({
        'AWS_ACCESS_KEY_ID': 'mock_access_key',
        'AWS_SECRET_ACCESS_KEY': 'mock_secret_key',
        'AWS_DEFAULT_REGION': 'us-east-1',
        'AWS_SESSION_TOKEN': 'mock_session_token',
        'TF_VAR_environment': 'test',
        'TF_VAR_project_name': 'test-project',
        'TF_VAR_domain_name': 'example.com',
        'TF_VAR_health_check_path': '/health/status.json'
    })
    
    # Plan and get outputs
    tf.setup()
    tf.init()
    plan = tf.plan(tf_vars=variables, output=True)
    
    return {
        'vpc_id_east1': plan.outputs['vpc_id_east1'],
        'vpc_id_east2': plan.outputs['vpc_id_east2'],
        'subnet_ids_east1': plan.outputs['subnet_ids_east1'],
        'subnet_ids_east2': plan.outputs['subnet_ids_east2']
    }

@pytest.fixture(scope="session")
def alb_failover(test_vpc):
    """Setup complete ALB failover configuration"""
    example_dir = os.path.join(os.path.dirname(__file__), 'terraform')
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
    
    return tf, variables
