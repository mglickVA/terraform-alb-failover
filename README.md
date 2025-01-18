# Terraform ALB Failover Infrastructure

This project implements a multi-region AWS infrastructure with Application Load Balancer (ALB) failover capability using Terraform. The infrastructure includes ALBs in both us-east-1 and us-east-2 regions, with a Route53 failover configuration that can be triggered via S3 bucket updates.

## Features

- Multi-region ALB deployment (us-east-1 and us-east-2)
- S3-triggered failover mechanism
- API Gateway integration with S3
- Route53 health checks with inverted logic
- Comprehensive test suite using tftest
- Mocked AWS resources for testing

## Prerequisites

- Python 3.12 or higher
- Terraform 1.0.0 or higher
- Make

## Project Structure

```
terraform-alb-failover/
├── modules/                    # Terraform modules
│   ├── alb/                   # ALB module
│   ├── api_gateway/           # API Gateway module
│   ├── route53/              # Route53 module
│   └── s3/                   # S3 bucket module
├── examples/                  # Example configurations
│   └── test-vpc/             # Test VPC configuration
├── tests/                    # Test suite
│   ├── unit/                # Unit tests
│   └── integration/         # Integration tests
├── .vscode/                 # VSCode configuration
├── main.tf                  # Main Terraform configuration
├── variables.tf             # Variable definitions
├── providers.tf             # Provider configuration
└── versions.tf              # Version constraints
```

## Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd terraform-alb-failover
```

2. Install dependencies:
```bash
make install
```

3. Initialize Terraform:
```bash
make init
```

## Running Tests

The project uses tftest for testing with mocked AWS resources. No actual AWS credentials are required.

Run all tests:
```bash
make test
```

Run specific test suites:
```bash
make test-unit          # Run unit tests only
make test-integration   # Run integration tests only
```

Clean up test artifacts:
```bash
make clean             # Clean test artifacts
make clean-all         # Clean all artifacts including Terraform
```

## Infrastructure Components

### Application Load Balancers
- Primary ALB in us-east-1
- Secondary ALB in us-east-2
- Both configured with fixed response returning "Hello World"

### S3 Bucket
- Located in us-east-2
- Stores health check status file
- Path: /health/status.json

### API Gateway
- Proxies requests to S3 bucket
- Implements response transformation:
  * 2xx/3xx responses indicate unhealthy status
  * 4xx/5xx responses indicate healthy status

### Route53 Configuration
- Primary record points to us-east-1 ALB
- Secondary record points to us-east-2 ALB
- Health check monitors API Gateway endpoint
- Inverted health check logic for manual failover

## Manual Failover Process

To trigger a failover:

1. Upload a file to the S3 bucket:
```json
{
    "status": "healthy"
}
```
This will cause the API Gateway to return a 500 status, which due to the inverted health check logic, will trigger failover to the secondary region.

To revert to primary:
```json
{
    "status": "error"
}
```

## Development

### VSCode Configuration
The project includes VSCode configuration for:
- Test discovery and execution
- Terraform formatting
- Debug configurations for tests

### Environment Variables
Required environment variables are automatically set by the test framework:
```bash
AWS_ACCESS_KEY_ID=mock_access_key
AWS_SECRET_ACCESS_KEY=mock_secret_key
AWS_SESSION_TOKEN=mock_session_token
AWS_DEFAULT_REGION=us-east-1
```

## Contributing

Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on contributing to this project.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
