import tftest
import pytest
import os
import json

def test_s3_bucket_configuration():
    """Test S3 bucket module configuration"""
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
    
    try:
        # Verify bucket configuration
        bucket = plan.resources['module.s3_bucket.aws_s3_bucket.main']
        assert bucket['values']['bucket'] == f"{variables['project_name']}-{variables['environment']}-status"
        assert bucket['values']['tags']['Environment'] == variables['environment']
        
        # Verify public access block configuration
        public_access_block = plan.resources['module.s3_bucket.aws_s3_bucket_public_access_block.main']
        assert public_access_block['values']['block_public_acls'] is True
        assert public_access_block['values']['block_public_policy'] is True
        assert public_access_block['values']['ignore_public_acls'] is True
        assert public_access_block['values']['restrict_public_buckets'] is True
    finally:
        # Clean up environment variables
        for key in variables:
            os.environ.pop(f'TF_VAR_{key}', None)
