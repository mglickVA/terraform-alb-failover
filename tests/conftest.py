import pytest
import tftest
import os

@pytest.fixture(scope="session")
def terraform_version():
    """Verify terraform version"""
    tf = tftest.TerraformTest("")
    tf.setup()
    version = tf.version()
    assert version.startswith("1.")
    return version

@pytest.fixture(scope="session", autouse=True)
def aws_credentials():
    """Setup mock AWS credentials for testing"""
    # Store original environment variables
    original_env = {}
    for key in os.environ:
        if key.startswith(('AWS_', 'TF_VAR_')):
            original_env[key] = os.environ[key]
    
    # Set test environment variables
    os.environ.update({
        "AWS_ACCESS_KEY_ID": "mock_access_key",
        "AWS_SECRET_ACCESS_KEY": "mock_secret_key",
        "AWS_SESSION_TOKEN": "mock_session_token",
        "AWS_DEFAULT_REGION": "us-east-1",
        "TF_VAR_environment": "test",
        "TF_VAR_project_name": "test-project",
        "TF_VAR_domain_name": "example.com",
        "TF_VAR_health_check_path": "/health/status.json"
    })
    
    yield
    
    # Restore original environment
    for key in list(os.environ.keys()):
        if key.startswith(('AWS_', 'TF_VAR_')):
            if key in original_env:
                os.environ[key] = original_env[key]
            else:
                os.environ.pop(key, None)
